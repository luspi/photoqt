/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <QImage>
#include <QtSvg>

#include "../../logger.h"
#include "errorimage.h"

namespace LoadImage {

    namespace Qt {

        static QImage load(QString filename, QSize maxSize, bool metaRotate) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "LoadImageQt: Load image using Qt: " << QFileInfo(filename).fileName().toStdString() << NL;

            // For reading SVG files
            QSvgRenderer svg;
            QPixmap svg_pixmap;

            // For all other supported file types
            QImageReader reader;

            // Return image
            QImage img;

            QSize origSize;

            // Suffix, for easier access later-on
            QString suffix = QFileInfo(filename).suffix().toLower();

            if(suffix == "svg") {

                // Loading SVG file
                svg.load(filename);

                // Invalid vector graphic
                if(!svg.isValid()) {
                    LOG << CURDATE << "LoadImageQt: reader svg - Error: invalid svg file" << NL;
                    return LoadImage::ErrorImage::load("The file doesn't contain a valid vector graphic");
                }

                // Render SVG into pixmap
                svg_pixmap = QPixmap(svg.defaultSize());
                svg_pixmap.fill(::Qt::transparent);
                QPainter painter(&svg_pixmap);
                svg.render(&painter);

                // Store the width/height for later use
                origSize = svg.defaultSize();

            } else {

                // Setting QImageReader
                reader.setFileName(filename);

                // Store the width/height for later use
                origSize = reader.size();

                // Sometimes the size returned by reader.size() is <= 0 (observed for, e.g., .jp2 files)
                // -> then we need to load the actual image to get dimensions
                if(origSize.width() <= 0 || origSize.height() <= 0) {
                    LOG << CURDATE << "LoadImageQt: imagereader qt - Error: failed to read origsize" << NL;
                    QImageReader r;
                    r.setFileName(filename);
                    origSize = r.read().size();
                }

            }

            int dispWidth = origSize.width();
            int dispHeight = origSize.height();

            double q;

            if(dispWidth > maxSize.width()) {
                q = maxSize.width()/(dispWidth*1.0);
                dispWidth *= q;
                dispHeight *= q;
            }

            // If thumbnails are kept visible, then we need to subtract their height from the absolute height otherwise they overlap with the main image
            if(dispHeight > maxSize.height()) {
                q = maxSize.height()/(dispHeight*1.0);
                dispWidth *= q;
                dispHeight *= q;
            }

            // Finalise SVG files
            if(suffix == "svg") {

                // Convert pixmap to image
                img = svg_pixmap.toImage();

            } else {

                // Scale imagereader (if not zoomed)
                if(maxSize.width() != -1)
                    reader.setScaledSize(QSize(dispWidth,dispHeight));

                reader.setAutoTransform(metaRotate);

                // Eventually load the image
                img = reader.read();

                // If an error occured
                if(img.isNull()) {
                    QString err = reader.errorString();
                    LOG << CURDATE << "LoadImageQt: reader qt - Error: file failed to load: " << err.toStdString() << NL;
                    LOG << CURDATE << "LoadImageQt: Filename: " << filename.toStdString() << NL;
                    return LoadImage::ErrorImage::load(err);
                }

            }

            return img;

        }

    }

}
