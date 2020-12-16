/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQLOADIMAGEQT_H
#define PQLOADIMAGEQT_H

#include <QImage>
#include <QtSvg>

#include "../../logger.h"
#include "../../settings/settings.h"

class PQLoadImageQt {

public:
    PQLoadImageQt() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

        errormsg = "";

        // For reading SVG files
        QSvgRenderer svg;
        QPixmap svg_pixmap;

        // For all other supported file types
        QImageReader reader;

        // Suffix, for easier access later-on
        QString suffix = QFileInfo(filename).suffix().toLower();

        if(suffix == "svg") {

            // Loading SVG file
            svg.load(filename);

            // Invalid vector graphic
            if(!svg.isValid()) {
                LOG << CURDATE << "LoadImageQt: reader svg - Error: invalid svg file" << NL;
                return QImage(); // PQLoadImage::ErrorImage::load("The file doesn't contain a valid vector graphic");
            }

            // Render SVG into pixmap
            svg_pixmap = QPixmap(svg.defaultSize());
            svg_pixmap.fill(::Qt::transparent);
            QPainter painter(&svg_pixmap);
            svg.render(&painter);

            // Store the width/height for later use
            *origSize = svg.defaultSize();

            return svg_pixmap.toImage();

        } else {

            // Setting QImageReader
            reader.setFileName(filename);

            // Fix: this loads the image properly even if the extension is wrong
            QMimeDatabase db;
            QStringList mime = db.mimeTypeForFile(filename, QMimeDatabase::MatchContent).name().split("/");
            if(mime.size() == 2 && mime.at(0) == "image")
                reader.setFormat(mime.at(1).toUtf8());

            reader.setAutoTransform(PQSettings::get().getMetaApplyRotation());

            // Store the width/height for later use
            *origSize = reader.size();

            // return image
            QImage *img = new QImage;

            bool readImageEarly = false;
            if(origSize->width() == -1 || origSize->height() == -1)
                readImageEarly = true;

            if(readImageEarly) {
                reader.read(img);
                *origSize = img->size();
            }

            if(maxSize.width() > -1 && origSize->width() > 0 && origSize->height() > 0) {

                int dispWidth = origSize->width();
                int dispHeight = origSize->height();

                double q;

                if(dispWidth > maxSize.width()) {
                    q = maxSize.width()/(dispWidth*1.0);
                    dispWidth = static_cast<int>(dispWidth*q);
                    dispHeight = static_cast<int>(dispHeight*q);
                }

                // If thumbnails are kept visible, then we need to subtract their height from the absolute height otherwise they overlap with main image
                if(dispHeight > maxSize.height()) {
                    q = maxSize.height()/(dispHeight*1.0);
                    dispWidth = static_cast<int>(dispWidth*q);
                    dispHeight = static_cast<int>(dispHeight*q);
                }

                reader.setScaledSize(QSize(dispWidth,dispHeight));

            }

            if(!readImageEarly) {
                // Eventually load the image
                reader.read(img);
            }

            // If an error occured
            if(img->isNull()) {
                errormsg = reader.errorString();
                LOG << CURDATE << "LoadImageQt: reader qt - Error: '" << QFileInfo(filename).fileName().toStdString() << "' failed to load: " << errormsg.toStdString() << NL;
                return QImage();
            }

            return *img;

        }

    }

    QString errormsg;

};

#endif
