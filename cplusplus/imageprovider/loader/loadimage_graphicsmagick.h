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

#ifndef PQLOADIMAGEGRAPHICSMAGICK_H
#define PQLOADIMAGEGRAPHICSMAGICK_H

#include <QFile>
#include <QImage>

#include "../../logger.h"

#ifdef GRAPHICSMAGICK
#include <GraphicsMagick/Magick++.h>
#endif

class PQLoadImageGraphicsMagick {

public:
    PQLoadImageGraphicsMagick() {
        errormsg = "";

        sufToMagick.insert("x", QStringList() << "AVS");

        sufToMagick.insert("ct1", QStringList() << "CALS");
        sufToMagick.insert("cal", QStringList() << "CALS");
        sufToMagick.insert("ras", QStringList() << "CALS" << "SUN");
        sufToMagick.insert("ct2", QStringList() << "CALS");
        sufToMagick.insert("ct3", QStringList() << "CALS");
        sufToMagick.insert("nif", QStringList() << "CALS");
        sufToMagick.insert("ct4", QStringList() << "CALS");
        sufToMagick.insert("c4",  QStringList() << "CALS");

        sufToMagick.insert("acr",   QStringList() << "DCM");
        sufToMagick.insert("dicom", QStringList() << "DCM");
        sufToMagick.insert("dic",   QStringList() << "DCM");

        sufToMagick.insert("pct", QStringList() << "PICT");
        sufToMagick.insert("pic", QStringList() << "PICT" << "HDR");

        sufToMagick.insert("pal", QStringList() << "PIX");
        sufToMagick.insert("wbm", QStringList() << "WBMP");
        sufToMagick.insert("jpe", QStringList() << "JPEG");
        sufToMagick.insert("mif", QStringList() << "MIFF");

        sufToMagick.insert("alb", QStringList() << "PWP");
        sufToMagick.insert("sfw", QStringList() << "PWP");
        sufToMagick.insert("pwm", QStringList() << "PWP");

        sufToMagick.insert("bw", QStringList() << "SGI");
        sufToMagick.insert("rgb", QStringList() << "SGI");
        sufToMagick.insert("rgba", QStringList() << "SGI");

        sufToMagick.insert("rast", QStringList() << "SUN");
        sufToMagick.insert("rs", QStringList() << "SUN");
        sufToMagick.insert("sr", QStringList() << "SUN");
        sufToMagick.insert("scr", QStringList() << "SUN");
        sufToMagick.insert("im1", QStringList() << "SUN");
        sufToMagick.insert("im8", QStringList() << "SUN");
        sufToMagick.insert("im24", QStringList() << "SUN");
        sufToMagick.insert("im32", QStringList() << "SUN");

        sufToMagick.insert("icb", QStringList() << "TGA");
        sufToMagick.insert("vda", QStringList() << "TGA");
        sufToMagick.insert("vst", QStringList() << "TGA");

        sufToMagick.insert("vic", QStringList() << "VICAR");
        sufToMagick.insert("img", QStringList() << "VICAR");
        sufToMagick.insert("bm", QStringList() << "XBM");
        sufToMagick.insert("kdc", QStringList() << "DCR");
        sufToMagick.insert("gv", QStringList() << "DOR");
        sufToMagick.insert("g4", QStringList() << "FAX");
        sufToMagick.insert("rgbe", QStringList() << "HDR");
        sufToMagick.insert("xyze", QStringList() << "HDR");
        sufToMagick.insert("rad", QStringList() << "HDR");
        sufToMagick.insert("p7", QStringList() << "XV");
        sufToMagick.insert("tif", QStringList() << "TIFF");

    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

#ifdef GRAPHICSMAGICK

        errormsg = "";

        QSize finalSize;

        // We first read the image into memory
        QFile file(filename);
        if(!file.open(QIODevice::ReadOnly)) {
            errormsg = "ERROR opening file, returning empty image";
            LOG << CURDATE << "PQLoadImageGraphicsMagick::load(): ERROR opening file, returning empty image" << NL;
            return QImage();
        }

        // Prepare Magick
        QString suf = QFileInfo(filename).suffix().toUpper();
        Magick::Image image;

        QStringList mgs = QStringList() << suf.toLower();
        if(sufToMagick.keys().contains(suf.toLower()))
            mgs = sufToMagick.value(suf.toLower());

        int howOftenFailed = 0;
        for(int i = 0; i < mgs.length(); ++i) {

            try {

                // set current magick
                image.magick(mgs.at(i).toUpper().toStdString());
                // Read image into Magick
                image.read(filename.toStdString());

            } catch(Magick::Exception &e) {

                ++howOftenFailed;
                LOG << CURDATE << "PQLoadImageImageMagick::load(): Exception: " << e.what() << NL;
                if(errormsg != "") errormsg += "<br><br>";
                errormsg += QString("ImageMagick Exception (2): %1").arg(e.what());

            }

        }

        // no attempt was successful -> stop here
        if(howOftenFailed == mgs.length())
            return QImage();

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

            // Write Magick as BMP to memory
            // We used to use PNG here, but BMP is waaaayyyyyy faster (even faster than JPG)
            Magick::Blob ob;
            image.magick("PPM");
            image.write(&ob);

            // And load JPG from memory into QImage
            const QByteArray imgData((char*)(ob.data()),ob.length());
            QImage img = QImage::fromData(imgData);

            // And we're done!
            return img;

        } catch(Magick::Exception &e) {
            LOG << CURDATE << "PQLoadImageGraphicsMagick::load(): Exception: " << e.what() << NL;
            errormsg = QString("GraphicsMagick Exception: %1").arg(e.what());
            return QImage();
        }

#endif

        errormsg = "Failed to load image with GraphicsMagick!";
        return QImage();

    }

    QString errormsg;

private:
    QMap<QString, QStringList> sufToMagick;

};

#endif // PQLOADIMAGEGRAPHICSMAGICK_H
