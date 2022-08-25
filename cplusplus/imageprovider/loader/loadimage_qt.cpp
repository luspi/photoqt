/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#include "loadimage_qt.h"

PQLoadImageQt::PQLoadImageQt() {
    errormsg = "";
}

QSize PQLoadImageQt::loadSize(QString filename) {

    QSize s;
    load(filename, QSize(), s, true);
    return s;

}

QImage PQLoadImageQt::load(QString filename, QSize maxSize, QSize &origSize, bool stopAfterSize) {

    DBG << CURDATE << "PQLoadImageQt::load()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** maxSize = " << maxSize.width() << "x" << maxSize.height() << NL
        << CURDATE << "** stopAfterSize = " << stopAfterSize << NL;

    errormsg = "";

    // For reading SVG files
    QSvgRenderer svg;
    QImage svg_image;

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

        // Store the width/height for later use
        origSize = svg.defaultSize();

        if(stopAfterSize) return QImage();

        // Render SVG into pixmap
        svg_image = QImage(svg.defaultSize(), QImage::Format_RGB32);
        svg_image.fill(::Qt::transparent);
        QPainter painter(&svg_image);
        svg.render(&painter);

        return svg_image;

    } else {

        // Setting QImageReader
        reader.setFileName(filename);

        // Fix: this loads the image properly even if the extension is wrong
        QMimeType mimetype = db.mimeTypeForFile(filename, QMimeDatabase::MatchContent);
        if(!mimetype.isValid()) {
            errormsg = "invalid mime type received";
            LOG << CURDATE << "PQLoadImageQt::load(): Error: " << errormsg.toStdString() << NL;
            return QImage();
        }
        QStringList mime = mimetype.name().split("/");
        if(mime.size() == 2 && mime.at(0) == "image")
            reader.setFormat(mime.at(1).toUtf8());

        reader.setAutoTransform(PQSettings::get()["metadataAutoRotation"].toBool());

        QImage img;

        bool imgAlreadyLoaded = false;

        // Store the width/height for later use
        origSize = reader.size();
        // check if we need to read the image in full to get the original size
        if(origSize.width() == -1 || origSize.height() == -1) {
            reader.read(&img);
            imgAlreadyLoaded = true;
            origSize = img.size();
        }

        if(stopAfterSize) return QImage();


        // check if we need to scale the image
        if(maxSize.width() > -1 && origSize.width() > 0 && origSize.height() > 0) {

            int dispWidth = origSize.width();
            int dispHeight = origSize.height();

            if(reader.autoTransform() && reader.transformation().testFlag(QImageIOHandler::TransformationRotate90)) {
                QSize tmp = maxSize;
                maxSize.setWidth(tmp.height());
                maxSize.setHeight(tmp.width());
            }

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

            // scaling
            if(imgAlreadyLoaded) {
                // we dont scale it here when we read the full image before to allow for caching in loadimage.cpp (it will be scaled after that point)
                // img = img.scaled(dispWidth, dispHeight);
            } else
                reader.setScaledSize(QSize(dispWidth,dispHeight));

        }

        // Eventually load the image
        if(!reader.canRead()) {
            errormsg = "image reader unable to read image";
            LOG << CURDATE << "PQLoadImageQt::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        if(!imgAlreadyLoaded)
            reader.read(&img);

        // If an error occured
        if(img.isNull()) {
            errormsg = reader.errorString();
            LOG << CURDATE << "PQLoadImageQt::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        return img;

    }

}
