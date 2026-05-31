/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <imageplugins/pqc_imageplugin_devil.h>
#include <pqc_settingscpp.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMDEVIL
#include <IL/il.h>
#endif

PQCImagePluginDevIL::PQCImagePluginDevIL() {

    setData({{"BMP: Microsoft Windows bitmap",
                    {{"bmp", "dib"}, {"image/bmp", "image/x-ms-bmp"}}},
             {"CUR: Microsoft Windows cursor format",
                    {{"cur"}, {"image/x-win-bitmap"}}},
             {"GIF: Graphics Interchange Format",
                    {{"gif"}, {"image/gif"}}},
             {"JPEG: Joint Photographic Experts Group JFIF format",
                    {{"jpeg", "jpg", "jpe", "jif"}, {"image/jpeg"}}},
             {"PBM: Portable bitmap format (black and white)",
                    {{"pbm"}, {"image/x-portable-anymap"}}},
             {"PGM: Portable graymap format (gray scale)",
                    {{"pgm"}, {"image/x-portable-greymap", "image/x-portable-anymap"}}},
             {"PPM: Portable pixmap format (color)",
                    {{"ppm", "pnm"}, {"image/x-portable-pixmap", "image/x-portable-anymap"}}},
             {"PNG: Portable Network Graphics",
                    {{"png"}, {"image/png"}}},
             {"Adobe PhotoShop",
                    {{"psd", "psb", "psdt"}, {"image/vnd.adobe.photoshop"}}},
             {"SGI images",
                    {{"rgba", "rgb", "sgi", "bw"}, {"image/sgi"}}},
             {"TGA: Truevision Targa image",
                    {{"tga", "icb", "vda", "vst"}, {"image/x-targa", "image/x-tga"}}},
             {"TIFF: Tagged Image File Format",
                    {{"tiff", "tif"}, {"image/tiff", "image/tiff-fx"}}},
             {"Dr. Halo",
                    {{"cut", "pal"}, {}}},
             {"Digital Imaging and Communications in Medicine (DICOM) image",
                    {{"dic", "dcm"}, {"application/dicom", "image/dicom-rle"}}},
             {"FITS: Flexible Image Transport System",
                    {{"fits", "fit", "fts"}, {"image/fits"}}},
             {"Photo CD",
                    {{"pcd", "pcds"}, {}}},
             {"Alias/Wavefront RLE image format",
                    {{"pix", "als", "alias"}, {}}},
             {"HDR: Radiance RGBE image format",
                    {{"rgbe", "hdr", "rad"}, {}}},
             {"DirectDraw Surface",
                    {{"dds"}, {}}},
             {"Heavy Metal: FAKK 2",
                    {{"ftx"}, {}}},
             {"Interchange File Format",
                    {{"iff"}, {}}},
             {"Interlaced Bitmap",
                    {{"lbm"}, {}}},
             {"Valve Texture Format",
                    {{"vtf"}, {}}},
             {"Microsoft Windows icon format",
                    {{"ico"}, {"image/vnd.microsoft.icon", "image/x-icon"}}}},
            "devil");

}

const QSize PQCImagePluginDevIL::loadSize(QString path) {

#ifdef PQMDEVIL

    QString errormsg = "";

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&devilMutex);

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        qWarning() << errormsg;
        return QSize();
    }

// load the passed on image file
#ifdef WIN32
    ilLoadImage(path.toStdWString().c_str());
#else
    ilLoadImage(path.toStdString().c_str());
#endif

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        qWarning() << errormsg;
        return QSize();
    }

    // get the width/height
    const int width  = ilGetInteger(IL_IMAGE_WIDTH);
    const int height = ilGetInteger(IL_IMAGE_HEIGHT);
    return QSize(width, height);

#endif

    return QSize();

}

const QImage PQCImagePluginDevIL::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path = " << path;
    qDebug() << "args: requestedSize = " << requestedSize;

    QString errormsg = "";

#ifdef PQMDEVIL

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&devilMutex);

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        error += errormsg % "\n";
        qWarning() << errormsg;
        return QImage();
    }

// load the passed on image file
#ifdef WIN32
    if(!ilLoadImage(path.toStdWString().c_str())) {
#else
    if(!ilLoadImage(path.toStdString().c_str())) {
#endif
        ilDeleteImages(1, &imageID);
        const QString err = "Failed to load image with DevIL";
        error += err % "\n";
        qWarning() << err;
        return QImage();
    }

    // convert to a predictable format Qt understands
    if(!ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE)) {
        ilDeleteImages(1, &imageID);
        const QString err = "Failed to convert image with DevIL";
        qWarning() << err;
        error += err % "\n";
        return QImage();
    }

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        error += errormsg % "\n";
        qWarning() << errormsg;
        return QImage();
    }

    // get the width/height
    const int width  = ilGetInteger(IL_IMAGE_WIDTH);
    const int height = ilGetInteger(IL_IMAGE_HEIGHT);
    origSize = QSize(width, height);

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        error += errormsg % "\n";
        qWarning() << errormsg;
        return QImage();
    }

    uchar* data = ilGetData();

    // DevIL owns the memory, so copy before deleting image
    QImage img = QImage(data, width, height, QImage::Format_RGBA8888).copy();

    if(img.isNull()) {
        const QString msg = "Failed to create QImage with DevIL (unknown error)!";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    bool imageIsScaled = false;

    if(!requestedSize.isEmpty()) {
        imageIsScaled = true;
        img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation()) {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(path, img);
    }

    if(!imageIsScaled)
        PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().applyColorProfile(path, img), img);

    return img;

#endif

    return QImage();

}

const bool PQCImagePluginDevIL::writeImage(QImage img, QString targetPath) {
    return false;
}

#ifdef PQMDEVIL
QString PQCImagePluginDevIL::checkForError() {
    ILenum err_enum = ilGetError();
    QString errormsg = "";
    while(err_enum != IL_NO_ERROR) {
        if(errormsg.isEmpty()) errormsg = "Error: ";
        else errormsg += ", ";
        errormsg += QString::number(err_enum);
        err_enum = ilGetError();
    }
    return errormsg;
}
#endif
