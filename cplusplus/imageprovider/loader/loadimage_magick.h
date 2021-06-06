/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef PQLOADIMAGEMAGICK_H
#define PQLOADIMAGEMAGICK_H

#include <QFile>
#include <QImage>

#include "../../settings/imageformats.h"
#include "../../logger.h"

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
#include <Magick++.h>
#endif

class PQLoadImageMagick {

public:
    PQLoadImageMagick() {
        errormsg = "";
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
        image = Magick::Image();
#endif
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize, bool onlyLoadMagickImage = false) {

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)

        errormsg = "";

        QSize finalSize;

        // We first read the image into memory
        QFile file(filename);
        if(!file.open(QIODevice::ReadOnly)) {
            errormsg = "QFile::open() failed.";
            LOG << CURDATE << "PQLoadImageMagick::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // Prepare Magick
        QString suf = QFileInfo(filename).suffix().toUpper();
        image = Magick::Image();

        QMimeDatabase db;
        QString mimetype = db.mimeTypeForFile(filename).name();

        QStringList mgs;
        if(suf != "") {
            mgs = QStringList() << suf.toUpper();
            if(PQImageFormats::get().getMagick().keys().contains(suf.toLower()))
                mgs = PQImageFormats::get().getMagick().value(suf.toLower()).toStringList();
        }
        if(mimetype != "") {
            if(PQImageFormats::get().getMagickMimeType().keys().contains(mimetype)) {
                const QStringList lst = PQImageFormats::get().getMagickMimeType().value(mimetype).toStringList();
                for(const QString &mt : lst)
                    if(!mgs.contains(mt))
                        mgs << mt;
            }
        }

        // if nothing else worked try without any magick, maybe this will help...
        mgs << "";

        int howOftenFailed = 0;
        for(int i = 0; i < mgs.length(); ++i) {

            try {

                // set current magick
                image.magick(mgs.at(i).toUpper().toStdString());

                // Read image into Magick
                image.read(filename.toStdString());

                // done with the loop if we manage to get here.
                break;

            } catch(Magick::Exception &e) {

                ++howOftenFailed;
                LOG << CURDATE << "PQLoadImageMagick::load(): Exception (1): " << e.what() << NL;
                errormsg += QString("<div style='margin-bottom: 5px'>%1</div>").arg(e.what());

            }

        }

        // no attempt was successful -> stop here
        if(howOftenFailed == mgs.length()) {
            // no need to add anything to the errormsg variable here, it already contains the errors from the loop above
            LOG << CURDATE << "PQLoadImageMagick::load(): Failed to read image" << NL;
            return QImage();
        }

        try {

            finalSize = QSize(image.columns(), image.rows());
            *origSize = finalSize;

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

            // this stops after successfully loading the image into Magick.
            if(!onlyLoadMagickImage) {

                // Write Magick as BMP to memory
                // We used to use PNG here, but BMP is waaaayyyyyy faster (even faster than JPG)
                // PPM can be even faster but causes some formats to fail.
                Magick::Blob ob;
                image.magick("BMP");
                image.write(&ob);

                // And load JPG from memory into QImage
                const QByteArray imgData((char*)(ob.data()),ob.length());
                QImage img = QImage::fromData(imgData);

                // And we're done!
                return img;

            } else
                return QImage();

        } catch(Magick::Exception &e) {
            errormsg = e.what();
            LOG << CURDATE << "PQLoadImageMagick::load(): Exception (2): " << errormsg.toStdString() << NL;
            return QImage();
        }

#endif

        errormsg = "Failed to load image, ImageMagick/GraphicsMagick not supported by this build of PhotoQt!";
        LOG << CURDATE << "PQLoadImageMagick::load(): " << errormsg.toStdString() << NL;
        return QImage();

    }

    QString errormsg;
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
    Magick::Image image;
#endif


};

#endif // PQLOADIMAGEMAGICK_H
