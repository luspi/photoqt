#ifndef PQLOADIMAGEFREEIMAGE_H
#define PQLOADIMAGEFREEIMAGE_H

#include <QImage>
#ifdef FREEIMAGE
#include <FreeImagePlus.h>
#endif

#ifdef FREEIMAGE
static QString freeImageErrorMessage;
static FREE_IMAGE_FORMAT freeImageErrorFormat;
#endif

class PQLoadImageFreeImage {

public:
    PQLoadImageFreeImage() {
        errormsg = "";
        freeImageErrorMessage = "";
        freeImageErrorFormat = FIF_UNKNOWN;
    }

    QImage load(QString filename, QSize maxSize, QSize *origSize) {

#ifdef FREEIMAGE

        // Reset variables at start, set handler for log output
        errormsg = "";
        freeImageErrorMessage = "";
        freeImageErrorFormat = FIF_UNKNOWN;
        FreeImage_SetOutputMessage([](FREE_IMAGE_FORMAT fif, const char *message) { freeImageErrorMessage = message; freeImageErrorFormat = fif; });

        // Get image format
        // First we try to get it through file type...
        FREE_IMAGE_FORMAT fif = FreeImage_GetFileType(filename.toStdString().c_str(), 0);
        // .. and if that didn't work, we look at the filename
        if(fif == FIF_UNKNOWN)
            fif = FreeImage_GetFIFFromFilename(filename.toStdString().c_str());

        // If an error occured (caught by output handler), return error image
        if(freeImageErrorMessage != "") {
            errormsg = QString("FreeImage failed to get image type: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
            return QImage();
        }

        // If loading the image failed for any other reason, return error image
        if(fif == FIF_UNKNOWN) {
            errormsg = "FreeImage failed to load image! Unknown file type...";
            return QImage();
        }

        // This will be the handler for the image data
        FIBITMAP *dib = nullptr;

        // If the image is supported for reading...
        if(FreeImage_FIFSupportsReading(fif)) {

            // Load the image with the previously detected type
            dib = FreeImage_Load(fif, filename.toStdString().c_str());

            // Error check!
            if(freeImageErrorMessage != "") {
                errormsg = QString("FreeImage failed to load image: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
                return QImage();
            }

            // If anything else went wrong, return error image
            if(dib == nullptr) {
                errormsg = "FreeImage ERROR: Loading failed, nullptr returned!";
                return QImage();
            }

        // If reading of this format is not supported, return error image
        } else {
            errormsg = "FreeImage ERROR: FIF not supported!";
            return QImage();
        }

        // the width/height of the image, needed to ensure we respect the maxSize further down
        int width  = FreeImage_GetWidth(dib);
        int height = FreeImage_GetHeight(dib);
        *origSize = QSize(width, height);

        // This will be the access handler for the data that we can load into QImage
        FIMEMORY *stream = FreeImage_OpenMemory();

        // FreeImage can only save 24-bit highcolor or 8-bit greyscale/palette bitmaps as JPEG, so we need to make sure to convert it to that
        dib = FreeImage_ConvertTo24Bits(dib);

        // Error check!
        if(freeImageErrorMessage != "") {
            errormsg = QString("FreeImage failed to convert image to 24bits: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
            return QImage();
        }

        // We save the image to memory as BMP as Qt can understand BMP very well
        // Note: BMP seems to be about 10 times faster than JPEG!
        FreeImage_SaveToMemory(FIF_BMP, dib, stream);

        // Error check!
        if(freeImageErrorMessage != "") {
            errormsg = QString("FreeImage failed to save image to memory as JPEG: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
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
        if(freeImageErrorMessage != "") {
            errormsg = QString("FreeImage failed to acquire memory: %1 (image type: %2)").arg(freeImageErrorMessage).arg(freeImageErrorFormat);
            return QImage();
        }

        // Load the raw JPEG data into the QByteArray ...
        QByteArray array = QByteArray::fromRawData((char*)mem_buffer, size_in_bytes);
        // ... and load QByteArray into QImage
        QImage img = QImage::fromData(array);

        // If image needs to be scaled down, return scaled down version
        if(maxSize.width() > 5 && maxSize.height() > 5)
            if(width > maxSize.width() || height > maxSize.height())
                return img.scaled(maxSize, ::Qt::KeepAspectRatio);

        // return full image
        return img;

#endif
        errormsg = "Failed to load image, FreeImage not supported by this build of PhotoQt!";
        return QImage();

    }

    QString errormsg;

};

#endif // PQLOADIMAGEFREEIMAGE_H
