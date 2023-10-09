/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include <pqc_loadimage_freeimage.h>
#include <pqc_imagecache.h>

#include <QString>
#include <QImage>
#include <QSize>
#include <QtDebug>

#ifdef FREEIMAGE
#include <FreeImagePlus.h>
#endif

PQCLoadImageFreeImage::PQCLoadImageFreeImage() {}

QSize PQCLoadImageFreeImage::loadSize(QString filename) {

#ifdef FREEIMAGE

    fipImage image;
    if(!image.load(filename.toStdString().c_str())) {
        qWarning() << "Error loading image:" << filename;
        return QSize();
    }

    FREE_IMAGE_FORMAT fif = image.getFIF();

    // if that didn't work, we look at the filename
    if(fif == FIF_UNKNOWN)
        fif = fipImage::identifyFIF(filename.toStdString().c_str());

    // If loading the image failed for any other reason, return error image
    if(fif == FIF_UNKNOWN) {
        qWarning() << "Unknown file type (FIF_UNKNOWN)";
        return QSize();
    }

    // the width/height of the image, needed to ensure we respect the maxSize further down
    return QSize(image.getWidth(), image.getHeight());

#else

    return QSize();

#endif

}

QString PQCLoadImageFreeImage::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize = " << maxSize;

#ifdef FREEIMAGE

    fipImage image;
    if(!image.load(filename.toStdString().c_str())) {
        QString errormsg = "Error loading image: " + filename;
        qWarning() << errormsg;
        return errormsg;
    }

    FREE_IMAGE_FORMAT fif = image.getFIF();

    // if that didn't work, we look at the filename
    if(fif == FIF_UNKNOWN)
        fif = fipImage::identifyFIF(filename.toStdString().c_str());

    // If loading the image failed for any other reason, return error image
    if(fif == FIF_UNKNOWN) {
        QString errormsg = "Unknown file type (FIF_UNKNOWN)";
        qWarning() << errormsg;
        return errormsg;
    }

    // the width/height of the image, needed to ensure we respect the maxSize further down
    origSize = QSize(image.getWidth(), image.getHeight());

    // This will be the access handler for the data that we can load into QImage
    fipMemoryIO stream;
    if(!image.saveToMemory(FIF_PPM, stream)) {
        QString errormsg = "Unable to save to memory";
        qWarning() << errormsg;
        return errormsg;
    }

    // These will be the raw data (and its size) that we are after
    BYTE *mem_buffer = nullptr;
    DWORD size_in_bytes = 0;

    if(!stream.acquire(&mem_buffer, &size_in_bytes)) {
        QString errormsg = "Unable to load image from memory";
        qWarning() << errormsg;
        return errormsg;
    }

    // Load data into QImage
    img = QImage::fromData(QByteArray::fromRawData((char*)mem_buffer, size_in_bytes));

    if(img.isNull()) {
        QString errormsg = "Loading FreeImage image into QImage resulted in NULL image";
        qWarning() << errormsg;
        return errormsg;
    }

    PQCImageCache::get().saveImageToCache(filename, &img);

    // Scale image if necessary
    if(maxSize.width() != -1) {

        QSize finalSize = origSize;

        if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
            finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

        img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    }

    // return full image
    return "";

#endif

    origSize = QSize(-1,-1);
    QString errormsg = "Failed to load image, FreeImage not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

}
