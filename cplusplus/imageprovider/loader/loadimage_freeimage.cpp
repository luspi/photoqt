#include "loader.h"

QImage PLoadImage::FreeImage(QString filename, QSize maxSize) {

#ifdef FREEIMAGE

    // Reset variables at start, set handler for log output
    static QString freeimageErrorMessage = "";
    static FREE_IMAGE_FORMAT freeimageErrorFormat = FIF_UNKNOWN;
    FreeImage_SetOutputMessage([](FREE_IMAGE_FORMAT fif, const char *message) { freeimageErrorMessage = message; freeimageErrorFormat = fif; });

    // Get image format
    // First we try to get it through file type...
    FREE_IMAGE_FORMAT fif = FreeImage_GetFileType(filename.toStdString().c_str(), 0);
    // .. and if that didn't work, we look at the filename
    if(fif == FIF_UNKNOWN)
        fif = FreeImage_GetFIFFromFilename(filename.toStdString().c_str());

    // If an error occured (caught by output handler), return error image
    if(freeimageErrorMessage != "")
        return PErrorImage::load(QString("FreeImage failed to get image type: %1 (image type: %2)")
                                            .arg(freeimageErrorMessage).arg(freeimageErrorFormat));
    // If loading the image failed for any other reason, return error image
    if(fif == FIF_UNKNOWN)
        return PErrorImage::load("FreeImage failed to load image! Unknown file type...");

    // This will be the handler for the image data
    FIBITMAP *dib = nullptr;

    // If the image is supported for reading...
    if(FreeImage_FIFSupportsReading(fif)) {

        // Load the image with the previously detected type
        dib = FreeImage_Load(fif, filename.toStdString().c_str());

        // Error check!
        if(freeimageErrorMessage != "")
            return PErrorImage::load(QString("FreeImage failed to load image: %1 (image type: %2)")
                                                .arg(freeimageErrorMessage).arg(freeimageErrorFormat));

        // If anything else went wrong, return error image
        if(dib == nullptr)
            return PErrorImage::load("FreeImage ERROR: Loading failed, nullptr returned!");

    // If reading of this format is not supported, return error image
    } else
        return PErrorImage::load("FreeImage ERROR: FIF not supported!");

    // the width/height of the image, needed to ensure we respect the maxSize further down
    int width  = static_cast<int>(FreeImage_GetWidth(dib));
    int height = static_cast<int>(FreeImage_GetHeight(dib));

    // This will be the access handler for the data that we can load into QImage
    FIMEMORY *stream = FreeImage_OpenMemory();

    // FreeImage can only save 24-bit highcolor or 8-bit greyscale/palette bitmaps as JPEG, so we need to make sure to convert it to that
    dib = FreeImage_ConvertTo24Bits(dib);

    // Error check!
    if(freeimageErrorMessage != "")
        return PErrorImage::load(QString("FreeImage failed to convert image to 24bits: %1 (image type: %2)")
                                            .arg(freeimageErrorMessage).arg(freeimageErrorFormat));

    // We save the image to memory as BMP as Qt can understand BMP very well
    // Note: BMP seems to be about 10 times faster than JPEG!
    FreeImage_SaveToMemory(FIF_BMP, dib, stream);

    // Error check!
    if(freeimageErrorMessage != "")
        return PErrorImage::load(QString("FreeImage failed to save image to memory as JPEG: %1 (image type: %2)")
                                                .arg(freeimageErrorMessage).arg(freeimageErrorFormat));

    // Free up some memory
    FreeImage_Unload(dib);

    // These will be the raw data (and its size) that we are after
    BYTE *mem_buffer = nullptr;
    DWORD size_in_bytes = 0;

    // Acquire the memory and fill the above variables
    FreeImage_AcquireMemory(stream, &mem_buffer, &size_in_bytes);

    // Error check!
    if(freeimageErrorMessage != "")
        return PErrorImage::load(QString("FreeImage failed to acquire memory: %1 (image type: %2)")
                                            .arg(freeimageErrorMessage).arg(freeimageErrorFormat));

    // Load the raw JPEG data into the QByteArray ...
    QByteArray array = QByteArray::fromRawData(reinterpret_cast<char*>(mem_buffer), static_cast<int>(size_in_bytes));
    // ... and load QByteArray into QImage
    QImage img = QImage::fromData(array);

    // If image needs to be scaled down, return scaled down version
    if(maxSize.width() > 5 && maxSize.height() > 5)
        if(width > maxSize.width() || height > maxSize.height())
            return img.scaled(maxSize, ::Qt::KeepAspectRatio);

    // return full image
    return img;

#else

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageFreeImage: PhotoQt was compiled without FreeImage support, returning error image" << NL;
    return PErrorImage::load("Failed to load image, FreeImage not supported by this build of PhotoQt!");

#endif

}
