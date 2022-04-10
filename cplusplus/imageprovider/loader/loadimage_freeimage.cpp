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

#include "loadimage_freeimage.h"

PQLoadImageFreeImage::PQLoadImageFreeImage() {
    errormsg = "";
#ifdef FREEIMAGE
    freeImageErrorMessage = *"\0";
    freeImageErrorFormat = FIF_UNKNOWN;
#endif
}

QSize PQLoadImageFreeImage::loadSize(QString filename) {

    QSize s;
    load(filename, QSize(), &s, true);
    return s;

}

QImage PQLoadImageFreeImage::load(QString filename, QSize maxSize, QSize *origSize, bool stopAfterSize) {

#ifdef FREEIMAGE

    // Reset variables at start, set handler for log output
    errormsg = "";
    freeImageErrorMessage = *"\0";
    freeImageErrorFormat = FIF_UNKNOWN;
    FreeImage_SetOutputMessage([](FREE_IMAGE_FORMAT fif, const char *message) { freeImageErrorMessage = *(const_cast<char*>(message)); freeImageErrorFormat = fif; });

    // Get image format
    // First we try to get it through file type...
    FREE_IMAGE_FORMAT fif = FreeImage_GetFileType(filename.toStdString().c_str(), 0);

    // If an error occured (caught by output handler), return error image
    if(freeImageErrorMessage != *"\0") {
        errormsg = QString("FreeImage_GetFileType: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // .. and if that didn't work, we look at the filename
    if(fif == FIF_UNKNOWN)
        fif = FreeImage_GetFIFFromFilename(filename.toStdString().c_str());

    // If an error occured (caught by output handler), return error image
    if(freeImageErrorMessage != *"\0") {
        errormsg = QString("FreeImage_GetFIFFromFilename: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // If loading the image failed for any other reason, return error image
    if(fif == FIF_UNKNOWN) {
        errormsg = "Unknown file type (FIF_UNKNOWN)";
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // This will be the handler for the image data
    FIBITMAP *dib = nullptr;

    // If the image is supported for reading...
    if(FreeImage_FIFSupportsReading(fif)) {

        // Load the image with the previously detected type
        dib = FreeImage_Load(fif, filename.toStdString().c_str());

        // Error check!
        if(freeImageErrorMessage != *"\0") {
            errormsg = QString("FreeImage_FIFSupportsReading: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
            LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // If anything else went wrong, return error image
        if(dib == nullptr) {
            errormsg = "FreeImage_FIFSupportsReading: Loading failed, nullptr returned!";
            LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

    // If reading of this format is not supported, return error image
    } else {
        errormsg = "FreeImage_FIFSupportsReading: FIF not supported!";
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // the width/height of the image, needed to ensure we respect the maxSize further down
    int width  = FreeImage_GetWidth(dib);
    int height = FreeImage_GetHeight(dib);
    *origSize = QSize(width, height);

    if(stopAfterSize) {
        FreeImage_Unload(dib);
        return QImage();
    }

    // This will be the access handler for the data that we can load into QImage
    FIMEMORY *stream = FreeImage_OpenMemory();

    // Error check!
    if(freeImageErrorMessage != *"\0") {
        errormsg = QString("FreeImage_OpenMemory: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // We save the image to memory as BMP as Qt can understand BMP very well
    // Note: BMP seems to be about 10 times faster than JPEG!
    FreeImage_SaveToMemory(FIF_BMP, dib, stream);

    // Error check!
    if(freeImageErrorMessage != *"\0") {
        errormsg = QString("FreeImage_SaveToMemory: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // Free up some memory
    FreeImage_Unload(dib);

    // These will be the raw data (and its size) that we are after
    BYTE *mem_buffer = nullptr;
    DWORD size_in_bytes = 0;

    // Acquire the memory and fill the above variables
    FreeImage_AcquireMemory(stream, &mem_buffer, &size_in_bytes);

    // Error check!
    if(freeImageErrorMessage != *"\0") {
        errormsg = QString("FreeImage_AcquireMemory: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // Load the raw JPEG data into the QByteArray ...
    QByteArray array = QByteArray::fromRawData((char*)mem_buffer, size_in_bytes);
    // ... and load QByteArray into QImage
    QImage img = QImage::fromData(array);

    if(img.isNull()) {
        errormsg = "Loading FreeImage image into QImage resulted in NULL image";
        LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // return full image
    return img;

#endif
    errormsg = "Failed to load image, FreeImage not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImageFreeImage::load(): " << errormsg.toStdString() << NL;
    return QImage();

}
