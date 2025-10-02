/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <pqc_loadimage_qt.h>
#include <pqc_imagecache.h>
#include <pqc_settingscpp.h>
#include <scripts/cpp/pqc_scriptsimages.h>
#include <scripts/cpp/pqc_scriptscolorprofiles.h>
#include <pqc_notify_cpp.h>
#include <QSize>
#include <QImage>
#include <QFileInfo>
#include <QSvgRenderer>
#include <QImageReader>
#include <QPainter>
#include <QtDebug>
#include <QMimeDatabase>

PQCLoadImageQt::PQCLoadImageQt() {
}

QSize PQCLoadImageQt::loadSize(QString filename) {

    // Suffix, for easier access later-on
    QString suffix = QFileInfo(filename).suffix().toLower();

    if(suffix == "svg") {

        // For reading SVG files
        QSvgRenderer svg;

        // Loading SVG file
        svg.load(filename);

        // Invalid vector graphic
        if(!svg.isValid()) {
            qWarning() << "Error: invalid svg file";
            return QSize();
        }

        // Store the width/height for later use
        return svg.defaultSize();

    } else {

        // For all other supported file types
        QImageReader reader;

        // Setting QImageReader
        reader.setFileName(filename);

        // This loads the image properly even if the extension is wrong
        QMimeDatabase db;
        QMimeType mimetype = db.mimeTypeForFile(filename, QMimeDatabase::MatchContent);
        if(!mimetype.isValid()) {
            qWarning() << "Error: invalid mime type received";
            return QSize();
        }
        QStringList mime = mimetype.name().split("/");
        if(mime.size() == 2 && mime.at(0) == "image")
            reader.setFormat(mime.at(1).toUtf8());

        reader.setAutoTransform(PQCSettingsCPP::get().getMetadataAutoRotation());

        bool imgAlreadyLoaded = false;

        // Store the width/height for later use
        QSize origSize = reader.size();
        // check if we need to read the image in full to get the original size
        if(origSize.width() == -1 || origSize.height() == -1) {
            QImage img;
            reader.read(&img);
            return img.size();
        }

        // the reported size is not rotated automatically, we need to take care of this ourselves
        if(PQCSettingsCPP::get().getMetadataAutoRotation()) {
            QImageIOHandler::Transformations trans = reader.transformation();
            switch(trans) {
                case QImageIOHandler::TransformationRotate90:
                case QImageIOHandler::TransformationRotate270:
                case QImageIOHandler::TransformationFlipAndRotate90:
                case QImageIOHandler::TransformationMirrorAndRotate90: {
                    origSize = QSize(origSize.height(), origSize.width());
                    break;
                }
                default:
                    break;
            }
        }

        return origSize;

    }

}

QString PQCLoadImageQt::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

    QString errormsg = "";

    // Suffix, for easier access later-on
    QString suffix = QFileInfo(filename).suffix().toLower();

    if(suffix == "svg" || suffix == "svgz") {

        // For reading SVG files
        QSvgRenderer svg;

        // Loading SVG file
        svg.load(filename);

        // Invalid vector graphic
        if(!svg.isValid()) {
            errormsg = "Error: invalid svg file";
            qWarning() << errormsg;
            return errormsg;
        }

        // Store the width/height for later use
        origSize = svg.defaultSize();

        // Render SVG into pixmap
        if(maxSize.width() > 5 || maxSize.height() > 5)
            img = QImage(svg.defaultSize().scaled(maxSize, Qt::KeepAspectRatio), QImage::Format_ARGB32);
        else
            img = QImage(svg.defaultSize(), QImage::Format_ARGB32);
        img.fill(::Qt::transparent);
        QPainter painter(&img);
        svg.render(&painter);

        return "";

    } else {

        // For all other supported file types
        QImageReader reader;

        reader.setAllocationLimit(0);

        // Setting QImageReader
        reader.setFileName(filename);

        // this loads the image properly even if the extension is wrong
        QMimeDatabase db;
        QMimeType mimetype = db.mimeTypeForFile(filename, QMimeDatabase::MatchContent);
        if(!mimetype.isValid()) {
            errormsg = "invalid mime type received";
            qWarning() << "Error:" << errormsg;
            return errormsg;
        }
        QStringList mime = mimetype.name().split("/");
        if(mime.size() == 2 && mime.at(0) == "image")
            reader.setFormat(mime.at(1).toUtf8());

        reader.setAutoTransform(PQCSettingsCPP::get().getMetadataAutoRotation());

        bool imgAlreadyLoaded = false;

        bool colorProfileAlreadyApplied = false;

        // Store the width/height for later use
        origSize = reader.size();
        // check if we need to read the image in full to get the original size
        if(!origSize.isValid()) {
            reader.read(&img);
            imgAlreadyLoaded = true;
            origSize = img.size();
            if(!img.isNull()) {
                colorProfileAlreadyApplied = true;
                PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
                PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
            }
        }

        // If QImageReader cannot read the image does not mean all hope is lost
        if(!reader.canRead()) {

            errormsg = "unable to read image with reader, trying direct QImage";
            qDebug() << errormsg;

            // It is possible that QImage can load an image directly even if QImageReader cannot
            img.load(filename);
            imgAlreadyLoaded = true;
            origSize = img.size();

            if(img.isNull()) {
                errormsg = "image reader and QImage unable to read image";
                qWarning() << errormsg;
                return errormsg;
            } else {
                errormsg = "";
                colorProfileAlreadyApplied = true;
                PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
                PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
            }
        }

        // check if we need to scale the image
        if(maxSize.isValid() && origSize.isValid() && !maxSize.isNull() && !origSize.isNull()) {

            QSize dispSize = origSize;
            if(dispSize.width() > maxSize.width() || dispSize.height() > maxSize.height())
                dispSize = dispSize.scaled(maxSize, Qt::KeepAspectRatio);

            // scaling
            if(imgAlreadyLoaded)
                img = img.scaled(dispSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
            else
                reader.setScaledSize(dispSize);

        }

        if(!imgAlreadyLoaded && reader.canRead() && suffix != "jxl") {
            reader.read(&img);
            if(!img.isNull() && img.size() == origSize) {
                colorProfileAlreadyApplied = true;
                PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
                PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
            }
        }

        // If an error occurred
        if(img.isNull()) {
            errormsg = reader.errorString();
            qWarning() << errormsg;
            return errormsg;
        }

        if(!colorProfileAlreadyApplied)
            PQCScriptsColorProfiles::get().applyColorProfile(filename, img);

        return "";

    }

}
