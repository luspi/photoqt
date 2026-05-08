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

#include <pqc_loadimage_devil.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_notify_cpp.h>
#include <pqc_settingscpp.h>

#include <QSize>
#include <QtDebug>
#include <QDir>
#include <QImageReader>

#ifdef PQMDEVIL
#include <IL/il.h>
#endif

PQCLoadImageDevil::PQCLoadImageDevil() {}

QSize PQCLoadImageDevil::loadSize(QString filename) {

#ifdef PQMDEVIL

    QString errormsg = "";

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&PQCLoadImageDevilMutex::get().devilMutex);

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    errormsg = checkForError();
    if(errormsg != "") {
        qWarning() << errormsg;
        return QSize();
    }

    // load the passed on image file
#ifdef WIN32
    ilLoadImage(filename.toStdWString().c_str());
#else
    ilLoadImage(filename.toStdString().c_str());
#endif

    errormsg = checkForError();
    if(errormsg != "") {
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

QString PQCLoadImageDevil::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename = " << filename;
    qDebug() << "args: maxSize = " << maxSize;

    QString errormsg = "";

#ifdef PQMDEVIL

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&PQCLoadImageDevilMutex::get().devilMutex);

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    errormsg = checkForError();
    if(errormsg != "") {
        qWarning() << errormsg;
        return errormsg;
    }

    // load the passed on image file
#ifdef WIN32
    if(!ilLoadImage(filename.toStdWString().c_str())) {
#else
    if(!ilLoadImage(filename.toStdString().c_str())) {
#endif
        ilDeleteImages(1, &imageID);
        QString err = "Failed to load image with DevIL";
        qWarning() << err;
        return err;
    }

    // convert to a predictable format Qt understands
    if(!ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE)) {
        ilDeleteImages(1, &imageID);
        QString err = "Failed to convert image with DevIL";
        qWarning() << err;
        return err;
    }

    errormsg = checkForError();
    if(errormsg != "") {
        qWarning() << errormsg;
        return errormsg;
    }

    // get the width/height
    const int width  = ilGetInteger(IL_IMAGE_WIDTH);
    const int height = ilGetInteger(IL_IMAGE_HEIGHT);
    origSize = QSize(width, height);

    errormsg = checkForError();
    if(errormsg != "") {
        qWarning() << errormsg;
        return errormsg;
    }

    uchar* data = ilGetData();

    img = QImage(data, width, height, QImage::Format_RGBA8888);

    // DevIL owns the memory, so copy before deleting image
    img = img.copy();

    if(img.isNull()) {
        errormsg = "Failed to create QImage with DevIL (unknown error)!";
        qWarning() << errormsg;
        return errormsg;
    }

    bool imageIsScaled = false;

    if(maxSize.isValid() && !maxSize.isNull()) {
        imageIsScaled = true;
        img = img.scaled(maxSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation()) {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(filename, img);
    }

    if(!imageIsScaled) {
        PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
        PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
    }

    return "";

#endif

    origSize = QSize(-1,-1);
    errormsg = "Failed to load image, DevIL not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

}

#ifdef PQMDEVIL
QString PQCLoadImageDevil::checkForError() {
    ILenum err_enum = ilGetError();
    QString errormsg = "";
    while(err_enum != IL_NO_ERROR) {
        if(errormsg == "") errormsg = "Error: ";
        else errormsg += ", ";
        errormsg += QString::number(err_enum);
        err_enum = ilGetError();
    }
    return errormsg;
}
#endif
