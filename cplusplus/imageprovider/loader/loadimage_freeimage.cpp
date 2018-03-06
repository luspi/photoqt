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

#include "loadimage_freeimage.h"

// We need to use a header AND source file here, as otherwise the linker has problems with the static members,
// but they are necessary as this is how FreeImage passes on error messages
QString LoadImageFreeImage::errorMessage = "";
FREE_IMAGE_FORMAT LoadImageFreeImage::errorFormat = FIF_UNKNOWN;

QImage LoadImageFreeImage::load(QString filename, QSize maxSize) {

#ifdef FREEIMAGE

    // Reset variables at start, set handler for log output
    errorMessage = "";
    errorFormat = FIF_UNKNOWN;
    FreeImage_SetOutputMessage([](FREE_IMAGE_FORMAT fif, const char *message) { errorMessage = message; errorFormat = fif; });

    // Get image format
    // First we try to get it through file type...
    FREE_IMAGE_FORMAT fif = FreeImage_GetFileType(filename.toStdString().c_str(), 0);
    // .. and if that didn't work, we look at the filename
    if(fif == FIF_UNKNOWN)
        fif = FreeImage_GetFIFFromFilename(filename.toStdString().c_str());

    // If an error occured (caught by output handler), return error image
    if(errorMessage != "")
        return ErrorImage::load(QString("FreeImage failed to get image type: %1 (image type: %2)").arg(errorMessage).arg(errorFormat));
    // If loading the image failed for any other reason, return error image
    if(fif == FIF_UNKNOWN)
        return ErrorImage::load("FreeImage failed to load image! Unknown file type...");

    // This will be the handler for the image data
    FIBITMAP *dib = nullptr;

    // If the image is supported for reading...
    if(FreeImage_FIFSupportsReading(fif)) {

        // Load the image with the previously detected type
        dib = FreeImage_Load(fif, filename.toStdString().c_str());

        // Error check!
        if(errorMessage != "")
            return ErrorImage::load(QString("FreeImage failed to load image: %1 (image type: %2)").arg(errorMessage).arg(errorFormat));

        // If anything else went wrong, return error image
        if(dib == nullptr)
            return ErrorImage::load("FreeImage ERROR: Loading failed, nullptr returned!");

    // If reading of this format is not supported, return error image
    } else
        return ErrorImage::load("FreeImage ERROR: FIF not supported!");

    // This will be the access handler for the data that we can load into QImage
    FIMEMORY *stream = FreeImage_OpenMemory();

    // FreeImage can only save 24-bit highcolor or 8-bit greyscale/palette bitmaps as JPEG, so we need to make sure to convert it to that
    dib = FreeImage_ConvertTo24Bits(dib);

    // Error check!
    if(errorMessage != "")
        return ErrorImage::load(QString("FreeImage failed to convert image to 24bits: %1 (image type: %2)").arg(errorMessage).arg(errorFormat));

    // We save the image to memory as JPEG as Qt can understand JPEG very well
    FreeImage_SaveToMemory(FIF_JPEG, dib, stream);

    // Error check!
    if(errorMessage != "")
        return ErrorImage::load(QString("FreeImage failed to save image to memory as JPEG: %1 (image type: %2)").arg(errorMessage).arg(errorFormat));

    // Free up some memory
    FreeImage_Unload(dib);

    // These will be the raw data (and its size) that we are after
    BYTE *mem_buffer = nullptr;
    DWORD size_in_bytes = 0;

    // Acquire the memory and fill the above variables
    FreeImage_AcquireMemory(stream, &mem_buffer, &size_in_bytes);

    // Error check!
    if(errorMessage != "")
        return ErrorImage::load(QString("FreeImage failed to acquire memory: %1 (image type: %2)").arg(errorMessage).arg(errorFormat));

    // Load the raw JPEG data into the QByteArray ...
    QByteArray array = QByteArray::fromRawData((char*)mem_buffer, size_in_bytes);
    // ... and load QByteArray into QImage
    return QImage::fromData(array);

#endif

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageFreeImage: PhotoQt was compiled without FreeImage support, returning error image" << NL;
    return ErrorImage::load("Failed to load image, FreeImage not supported by this build of PhotoQt!");

}
