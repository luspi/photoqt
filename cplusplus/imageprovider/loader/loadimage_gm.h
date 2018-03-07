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

#ifndef LOADIMAGE_MAGICK_H
#define LOADIMAGE_MAGICK_H

#include <QFile>
#include <QFileInfo>
#include "../../logger.h"
#include "errorimage.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#include "../../scripts/gmimagemagick.h"
#endif

class LoadImageGM {

public:

    LoadImageGM() { }

    QImage load(QString filename, QSize maxSize) {

#ifdef GM

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "LoadImageGM: Loading image using GraphicsMagick: " << QFileInfo(filename).fileName().toStdString() << NL;

        GmImageMagick imagemagick;
        QSize finalSize;

        // We first read the image into memory
        QFile file(filename);
        if(!file.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "LoadImageGM: reader gm - ERROR opening file, returning empty image" << NL;
            return QImage();
        }
        char *data = new char[file.size()];
        qint64 s = file.read(data, file.size());

        // A return value of -1 means error
        if (s == -1) {
            delete[] data;
            LOG << CURDATE << "LoadImageGM: reader gm - ERROR reading image file data" << NL;
            return QImage();
        }
        // Read image into blob
        Magick::Blob blob(data, file.size());
        try {

            // Prepare Magick
            QString suf = QFileInfo(filename).suffix().toUpper();
            Magick::Image image;
            image = imagemagick.setImageMagick(image,suf);

            // Read image into Magick
            image.read(blob);

            finalSize = QSize(image.columns(), image.rows());

            // Scale image if necessary
            if(maxSize.width() != -1) {

                double q;

                if(finalSize.width() > maxSize.width()) {
                        q = maxSize.width()/(finalSize.width()*1.0);
                        finalSize.setWidth(finalSize.width()*q);
                        finalSize.setHeight(finalSize.height()*q);
                }
                if(finalSize.height() > maxSize.height()) {
                    q = maxSize.height()/(finalSize.height()*1.0);
                    finalSize.setWidth(finalSize.width()*q);
                    finalSize.setHeight(finalSize.height()*q);
                }

                // For small images we can use the faster algorithm, as the quality is good enough for that
                if(finalSize.width() < 300 && finalSize.height() < 300)
                    image.thumbnail(Magick::Geometry(finalSize.width(),finalSize.height()));
                else
                    image.scale(Magick::Geometry(finalSize.width(),finalSize.height()));

            }

            // Write Magick as BMP to memory
            // We used to use PNG here, but BMP is waaaayyyyyy faster (even faster than JPG)
            Magick::Blob ob;
            image.magick("BMP");
            image.write(&ob);

            // And load JPG from memory into QImage
            const QByteArray imgData((char*)(ob.data()),ob.length());
            QImage img((maxSize.width() > -1 ? maxSize : finalSize), QImage::Format_ARGB32);
            img.loadFromData(imgData);

            // And we're done!
            delete[] data;
            return img;

        } catch(Magick::Exception &error_) {
            delete[] data;
            LOG << CURDATE << "LoadImageGM: reader gm Error: " << error_.what() << NL;
            return ErrorImage::load(QString(error_.what()));
        }

#else
        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "LoadImageGM: PhotoQt was compiled without GraphicsMagick support, returning error image" << NL;
#endif

        return ErrorImage::load("Failed to load image with GraphicsMagick!");

    }

};

#endif // LOADIMAGE_MAGICK_H
