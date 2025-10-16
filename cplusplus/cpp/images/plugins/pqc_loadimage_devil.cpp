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

#include <cpp/pqc_loadimage_devil.h>
#include <cpp/pqc_imagecache.h>
#include <cpp/pqc_cscriptscolorprofiles.h>

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

    // THIS IS CURRENTLY SLIGHTLY HACKY:
    // DevIL loads the image and then writes it to a temporary jpg file.
    // This file is then loaded by Qt's built in image plugin and returned to the user
    // TODO: PASSING IMAGE DIRECTLY FROM DEVIL TO QIMAGE!

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
    ilLoadImage(filename.toStdWString().c_str());
#else
    ilLoadImage(filename.toStdString().c_str());
#endif

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

/*
    // this would be the way to load images directly from DevIL into QImage,
    // but DevIL seems has some issues with being used simultaneously from different threads
    // this *will* make PhotoQt crash often (possibly not always)
    ILubyte *bt = ilGetData();
    if(bt == NULL) LOG << "bt is NULL!!" << NL;
    QImage tmpimg(bt, width, height, QImage::Format_ARGB32);
    if(tmpimg.isNull()) LOG << "QImage is NULL!!" << NL;

    QImage img;

    // If image needs to be scaled down, do so now
    if(maxSize.width() > 5 && maxSize.height() > 5) {
        double q = 1;
        if(width > maxSize.width())
            q = (double)maxSize.width()/(double)width;
        if(height*q > maxSize.height())
            q = (double)maxSize.height()/(double)height;
        img = tmpimg.scaled(width*q, height*q);
    } else
        img = tmpimg.copy();

    ilBindImage(0);
    ilDeleteImages(1, &imageID);
*/

    // This is the temporary file we will load the image into
    QString tempimage = QDir::tempPath() + "/photoqtdevil.ppm";

    // Make sure DevIL can overwrite any previously created file
    ilEnable(IL_FILE_OVERWRITE);

    // Save the decoded image to this temporary file
#ifdef WIN32
    if(!ilSaveImage(tempimage.toStdWString().c_str())) {
#else
    if(!ilSaveImage(tempimage.toStdString().c_str())) {
#endif
        // If it fails, return error image
        ilBindImage(0);
        ilDeleteImages(1, &imageID);
        errormsg = checkForError();
        if(errormsg == "")
            errormsg = "Failed to save image decoded with DevIL!";
        qWarning() << errormsg;
        return errormsg;
    }

    errormsg = checkForError();
    if(errormsg != "") {
        qWarning() << errormsg;
        return errormsg;
    }

    // Create reader for temporary image
    QImageReader reader(tempimage);

    // If image needs to be scaled down, do so now
    if(maxSize.width() > 5 && maxSize.height() > 5) {

        QSize dispSize = QSize(width, height);

        if(dispSize.width() > maxSize.width() || dispSize.height() > maxSize.height())
            dispSize = dispSize.scaled(maxSize, Qt::KeepAspectRatio);

        reader.setScaledSize(dispSize);
    }

    // Clear the DevIL memory
    ilBindImage(0);
    ilDeleteImages(1, &imageID);

    // Return read image file
    img = reader.read();
    QFile(tempimage).remove();

    if(img.isNull() || img.size() == QSize(1,1)) {
        errormsg = "Failed to load image with DevIL (unknown error)!";
        qWarning() << errormsg;
        return errormsg;
    }

    if(img.size() == origSize) {
        PQCCScriptsColorProfiles::get().applyColorProfile(filename, img);
        PQCImageCache::get().saveImageToCache(filename, PQCCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
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
