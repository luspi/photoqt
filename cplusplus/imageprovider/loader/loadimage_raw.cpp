#include "loader.h"

// The metadata is needed at multiple different locations in the code.
// At least up to v0.26, Exiv2 does not support reading metadata in parallel (causes crashes).
// This function ensures that there is always only at most one call to readMetadata() at any time.
void PLoadImage::safelyReadMetadata(Exiv2::Image::AutoPtr *image) {

    QLockFile lock(ConfigFiles::EXIV2_LOCK_FILE());

    // After 2s we just go ahead, something might have gone wrong.
    if(!lock.tryLock(2000))
        LOG << CURDATE << "PLoadImage::Raw::load(): safelyReadMetadata(): WARNING: Unable to lock Exiv2::readMetadata(), potential cause for crash!" << NL;

    (*image)->readMetadata();

    // Free up access
    lock.unlock();

}

QImage PLoadImage::Raw(QString filename, QSize maxSize, bool loadEmbeddedThumbnail, bool neededForThumbnails) {

#ifdef EXIV2

    // If enabled, we try to load the preview image stored in the EXIF metadata (if there is one)
    if(loadEmbeddedThumbnail) {

        try {

            // First we access the metadata
            auto image  = Exiv2::ImageFactory::open(filename.toStdString());

            // Read the metadata
            safelyReadMetadata(&image);

            // Then we get a list of all the preview images stored in the metadata
            Exiv2::PreviewManager previewManager(*image);
            Exiv2::PreviewPropertiesList previewPropList = previewManager.getPreviewProperties();

            // These three variables are used to find the largest preview image
            QSize bestPreviewSize(0,0);
            size_t bestPreviewPos = 0;
            bool previewFound = false;

            if(neededForThumbnails)
                bestPreviewSize = QSize(99999,99999);
            // We loop over each one (typically there are at most 2 or 3 only)
            for(size_t num = 0; num < previewPropList.size(); ++num) {

                // Get the current properties
                Exiv2::PreviewProperties prop = previewPropList[num];

                int propW = static_cast<int>(prop.width_);
                int propH = static_cast<int>(prop.height_);

                // If a thumbnail is to be loaded, we actually look for the smallest available preview
                if(neededForThumbnails && propW < bestPreviewSize.width() && propH < bestPreviewSize.height()) {
                    bestPreviewSize = QSize(propW, propH);
                    bestPreviewPos = num;
                    previewFound = true;
                // If we have one that is bigger than what we had before, save it
                } else if(!neededForThumbnails && propW > bestPreviewSize.width() && propH > bestPreviewSize.height()) {
                    bestPreviewSize = QSize(propW, propH);
                    bestPreviewPos = num;
                    previewFound = true;
                }

            }

            // Any image smaller than this can just as well be read from actual data
            // This also avoids the case when only tiny preview images are stored in exif data
            QSize minSizeForPreview(640,480);
            if(neededForThumbnails)
                minSizeForPreview = QSize(64, 64);

            // If we found any preview image:
            if(previewFound) {

                // Load the preview image into a QByteArray
                Exiv2::PreviewImage previmg = previewManager.getPreviewImage(previewPropList[bestPreviewPos]);
                QByteArray data = QByteArray(reinterpret_cast<const char*>(previmg.pData()), static_cast<int>(previmg.size()));

                // From the QByteArray we can load the image data
                QImage ret;
                if(ret.loadFromData(data) && !ret.isNull()) {

                    // If preview image is not too small
                    if(bestPreviewSize.width() >= minSizeForPreview.width() && bestPreviewSize.height() >= minSizeForPreview.height()) {

                        // Scale if necessary
                        if(maxSize.width() > 5 && maxSize.height() > 5 && (ret.width() > maxSize.width() || ret.height() > maxSize.height()))
                            return ret.scaled(maxSize, ::Qt::KeepAspectRatio, ::Qt::SmoothTransformation);

                        // Return successfully loaded image!
                        return ret;

                    }

                }

            }

        } catch (Exiv2::Error& e) {
            // Something went wrong. We let the user know but also continue on loading the file using libraw
            LOG << CURDATE << "PLoadImage::Raw::load() - ERROR loading preview thumbnail from exiv data (caught exception): " << e.what() << NL;
        }

    }

#endif

#ifdef RAW

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageRaw: Load image using LibRaw: " << QFileInfo(filename).fileName().toStdString() << NL;

    // Later we decide according to thumbnail/image size whether to load thumbnail or half/full image
    bool thumb = false;
    bool half = false;

    // The LibRaw instance
    LibRaw raw;
    raw.recycle();

    // Some settings to improve speed
    // Since we don't care about manipulating RAW images but only want to display
    // them, we can optimise for speed
    raw.imgdata.params.user_qual = 2;
    raw.imgdata.params.use_rawspeed = 1;
    raw.imgdata.params.use_camera_wb = 1;

    // Open the RAW image
    int ret = raw.open_file(reinterpret_cast<const char*>(QFile::encodeName(filename).constData()));
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        return PErrorImage::load(QString("LibRaw: failed to run open_file: %1").arg(libraw_strerror(ret)));
    }

    // If either dimension is set to 0 (or actually -1), then the full image is supposed to be loaded
    if(maxSize.width() > 0 && maxSize.height() > 0) {

        // Depending on the RAW image anf the requested image size, we can opt for the thumbnail or half size if that's enough
        if(raw.imgdata.thumbnail.twidth >= maxSize.width() && raw.imgdata.thumbnail.theight >= maxSize.height() &&
           raw.imgdata.thumbnail.tformat != LIBRAW_THUMBNAIL_UNKNOWN)
            thumb = true;
        else if(raw.imgdata.sizes.iwidth >= maxSize.width()*2 && raw.imgdata.sizes.iheight >= maxSize.height()) {
            half = true;
            raw.imgdata.params.half_size = 1;
        }

    }

    // Unpack the RAW image/thumbnail
    if(thumb) ret = raw.unpack_thumb();
    else ret = raw.unpack();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        return PErrorImage::load(QString("LibRaw: failed to run %1: %2").arg(thumb ? "unpack_thumb" : "unpack")
                                            .arg(libraw_strerror(ret)));
    }

    // Post-process image. Not necessary for embedded preview...
    if(!thumb) ret = raw.dcraw_process();

    if (ret != LIBRAW_SUCCESS) {
        raw.recycle();
        return PErrorImage::load(QString("LibRaw: failed to run dcraw_process: %1").arg(libraw_strerror(ret)));
    }

    // Create processed image
    libraw_processed_image_t* img;
    if(thumb) img = raw.dcraw_make_mem_thumb(&ret);
    else img = raw.dcraw_make_mem_image(&ret);


    // This will hold the loaded image data
    QByteArray imgData;


    QImage image;

    // This means, that the structure contains an in-memory image of JPEG file.
    // Only type, data_size and data fields are valid (and nonzero).
    if(img->type == LIBRAW_IMAGE_JPEG) {

        // The return image is loaded from the QByteArray above
        if(!image.loadFromData(img->data, static_cast<int>(img->data_size), "JPEG")) {
            raw.recycle();
            return PErrorImage::load("Failed to load JPEG data from LibRaw!");
        }

    } else {

        // Create a header and load the image data into QByteArray
        QString header = QString::fromUtf8("P%1\n%2 %3\n%4\n")
                         .arg(img->colors == 3 ? QLatin1String("6") : QLatin1String("5"))
                         .arg(img->width)
                         .arg(img->height)
                         .arg((1 << img->bits)-1);
        imgData.append(header.toLatin1());

        if(img->colors == 3)
            imgData.append(QByteArray(reinterpret_cast<const char*>(img->data), static_cast<int>(img->data_size)));
        else {
            QByteArray imgData_tmp;
           // img->colors == 1 (Grayscale) : convert to RGB
            for(size_t i = 0 ; i < img->data_size ; ++i) {
                for(int j = 0 ; j < 3 ; ++j)
                    imgData_tmp.append(static_cast<char>(img->data[i]));
            }
            imgData.append(imgData_tmp);
        }

        if(imgData.isEmpty()) {
            raw.recycle();
            return PErrorImage::load("Failed to load " +
                                                QString(half ? "half preview" : (thumb ? "thumbnail" : "image")) +
                                                " from LibRaw!");
        }

        // The return image is loaded from the QByteArray above
        if(!image.loadFromData(imgData)) {
            raw.recycle();
            return PErrorImage::load("Failed to load PPM data from LibRaw!");
        }

    }

    // Clean up memory
    raw.dcraw_clear_mem(img);
    raw.recycle();

    if(maxSize.width() > 5 && maxSize.height() > 5 && (image.width() > maxSize.width() || image.height() > maxSize.height()))
        return image.scaled(maxSize, ::Qt::KeepAspectRatio, ::Qt::SmoothTransformation);

    return image;

#else
    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageRaw: PhotoQt was compiled without LibRaw support, returning error image" << NL;

    return PLoadImage::ErrorImage::load("ERROR! PhotoQt was compiled without LibRaw support!");
#endif


}