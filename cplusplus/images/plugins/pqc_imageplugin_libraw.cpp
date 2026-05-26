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

#include <pqc_imageplugin_libraw.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_imagecache.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMRAW
#include <libraw/libraw.h>
#endif

PQCImagePluginLibraw::PQCImagePluginLibraw(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginLibraw::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const bool PQCImagePluginLibraw::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const QSet<QString> PQCImagePluginLibraw::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginLibraw::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginLibraw::loadSize(QString path) {

#ifdef PQMRAW

    LibRaw raw;

    // Open the RAW image
    int ret = raw.open_file(QFile::encodeName(path));
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        qWarning() << "Failed to run open_file:" << libraw_strerror(ret);
        return QSize();
    }

    return QSize(raw.imgdata.sizes.width, raw.imgdata.sizes.height);

#endif

    return QSize();

}

const QImage PQCImagePluginLibraw::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

#ifdef PQMRAW

    bool useThumb = false;
    bool useHalf = false;

    LibRaw raw;
    libraw_processed_image_t *rawimg;

    // Some settings to improve speed
    // Since we don't care about manipulating RAW images but only want to display
    // them, we can optimise for speed
    raw.imgdata.params.user_qual = 2;
    raw.imgdata.params.use_camera_wb = 1;

    // We apply EXIF orientation ourselves.
    raw.imgdata.params.user_flip = 0;

    // Open the RAW image
    int ret = raw.open_file((const char*)(QFile::encodeName(path)).constData());
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        const QString msg = QString("Failed to run open_file: %1").arg(libraw_strerror(ret));
        qWarning() << msg;
        error += msg % "\n";
        return QImage();
    }

    // If either dimension is set to 0 (or actually -1), then the full image is supposed to be loaded
    if(!requestedSize.isEmpty()) {

        // Depending on the RAW image anf the requested image size, we can opt for the thumbnail or half size if that's enough
        if(raw.imgdata.thumbnail.twidth >= requestedSize.width() && raw.imgdata.thumbnail.theight >= requestedSize.height())
            useThumb = true;
        else if(raw.imgdata.sizes.iwidth >= requestedSize.width()*2 && raw.imgdata.sizes.iheight >= requestedSize.height()*2) {
            useHalf = true;
            raw.imgdata.params.half_size = 1;
        }

    }

    // sometimes the embedded thumb is as large as the actual raw image
    // if that's the case we can simply load the embedded thumbnail
    // we only do this if the raw image is larger than 1000x1000 pixels
    if(!useThumb && PQCSettingsCPP::get().getFiletypesRAWUseEmbeddedIfAvailable() &&
        raw.imgdata.sizes.width > 1000 && raw.imgdata.sizes.height > 1000 &&
        raw.imgdata.thumbnail.twidth > 0 && raw.imgdata.thumbnail.theight > 0) {

        // we allow for a small margin of difference in sizes
        const double diff = qMax(qAbs(static_cast<double>(raw.imgdata.sizes.width-raw.imgdata.thumbnail.twidth)/raw.imgdata.sizes.width),
                                 qAbs(static_cast<double>(raw.imgdata.sizes.height-raw.imgdata.thumbnail.theight)/raw.imgdata.sizes.height));

        // we allow a size margin of 2.5%
        if(diff <= 0.025)
            useThumb = true;

    }

    // Unpack the RAW thumbnail if thumbnail requested
    if(useThumb)
        ret = raw.unpack_thumb();

    // If thumbnail failed or full image wanted, unpack full
    if(!useThumb || ret != LIBRAW_SUCCESS)
        ret = raw.unpack();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        const QString msg = QString("Failed to run %1: %2").arg((useThumb ? "unpack_thumb" : "unpack"), libraw_strerror(ret));
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    // Post-process image. Not necessary for embedded preview...
    if(!useThumb) ret = raw.dcraw_process();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        const QString msg = QString("Failed to run dcraw_process: %1").arg(libraw_strerror(ret));
        qWarning() << msg;
        error += msg % "\n";
        return QImage();
    }

    // Create processed image
    if(useThumb) rawimg = raw.dcraw_make_mem_thumb(&ret);
    else rawimg = raw.dcraw_make_mem_image(&ret);

    // check for success
    if(!rawimg || ret != LIBRAW_SUCCESS) {
        raw.recycle();
        const QString msg = QString("Failed to create memory image: %1").arg(libraw_strerror(ret));
        qWarning() << msg;
        error += msg % "\n";
        return QImage();
    }

    QImage img;

    // This means, that the structure contains an in-memory image of JPEG file.
    // Only type, data_size and data fields are valid (and nonzero).
    if(rawimg->type == LIBRAW_IMAGE_JPEG) {

        // The return image is loaded from the QByteArray above
        if(!img.loadFromData(reinterpret_cast<const uchar*>(rawimg->data),
                              static_cast<int>(rawimg->data_size))) {
            raw.dcraw_clear_mem(rawimg);
            raw.recycle();
            const QString msg = "Failed to load JPEG data!";
            qWarning() << msg;
            error += msg % "\n";
            return QImage();
        }

    } else {

        const int width  = rawimg->width;
        const int height = rawimg->height;
        const int colors = rawimg->colors;
        const int bits   = rawimg->bits;

        // 8-bit RGB image
        if(colors == 3 && bits == 8) {

            img = QImage(width, height, QImage::Format_RGB888);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                const QString msg = "Failed to allocate QImage.";
                qWarning() << msg;
                error += msg % "\n";
                return QImage();
            }

            const int stride = width * 3;

            for(int y = 0; y < height; ++y)
                memcpy(img.scanLine(y), rawimg->data + y*stride, stride);

            // 16-bit RGB image
        } else if(colors == 3 && bits == 16) {

            img = QImage(width, height, QImage::Format_RGBX64);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                const QString msg = "Failed to allocate QImage.";
                qWarning() << msg;
                error += msg % "\n";
                return QImage();
            }

            const uint16_t* src = reinterpret_cast<uint16_t*>(rawimg->data);

            for(int y = 0; y < height; ++y) {
                QRgba64* dst = reinterpret_cast<QRgba64*>(img.scanLine(y));
                for(int x = 0; x < width; ++x) {
                    const int idx = (y * width + x) * 3;
                    dst[x] = qRgba64(src[idx + 0], src[idx + 1], src[idx + 2], 65535);
                }
            }

            // 8-bit grayscale
        } else if(colors == 1 && bits == 8) {

            img = QImage(width, height, QImage::Format_Grayscale8);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                const QString msg = "Failed to allocate QImage.";
                qWarning() << msg;
                error += msg % "\n";
                return QImage();
            }

            for(int y = 0; y < height; ++y)
                memcpy(img.scanLine(y), rawimg->data + y*width, width);

            // 16-bit grayscale
        } else if(colors == 1 && bits == 16) {

            img = QImage(width, height, QImage::Format_Grayscale16);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                const QString msg = "Failed to allocate QImage.";
                qWarning() << msg;
                error += msg % "\n";
                return QImage();
            }

            const uint16_t* src = reinterpret_cast<uint16_t*>(rawimg->data);

            for(int y = 0; y < height; ++y) {
                uint16_t* dst = reinterpret_cast<uint16_t*>(img.scanLine(y));
                memcpy(dst, src + y*width, width*sizeof(uint16_t));
            }

            // unsupported image format
        } else {

            raw.dcraw_clear_mem(rawimg);
            raw.recycle();

            const QString msg = QString("Unsupported RAW output format (colors=%1 bits=%2)").arg(colors).arg(bits);
            qWarning() << msg;
            error += msg % "\n";
            return QImage();

        }

    }

    // Clean up memory
    raw.dcraw_clear_mem(rawimg);
    raw.recycle();

    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation()) {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(path, img);
    }

    origSize = img.size();

    if(!useThumb && !useHalf) {

        if(!img.isNull()) {

            PQCScriptsColorProfiles::get().applyColorProfile(path, img);
            PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);

            // Scale image if necessary
            if(requestedSize.isValid() && !requestedSize.isNull()) {
                return img.scaled(requestedSize, Qt::KeepAspectRatio,
                                  (PQCSettingsCPP::get().getImageviewRescalingSmooth() ?
                                      Qt::SmoothTransformation :
                                      Qt::FastTransformation));
            }
        }

    }

    return img;

#endif

    return QImage();

}

void PQCImagePluginLibraw::setEnabled(QString suffix, QString mimetype, bool enabled) {

}

/***********************************************/

void PQCImagePluginLibraw::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/libraw_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
    } else {
        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();
    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"dcr", "kdc", "drf", "k25", "dcs", "dc2", "kc2", "arw", "crw", "crr",
                     "cr2", "cr3", "dng", "srf", "mrw", "sr2", "arq", "nef", "nrw", "orf",
                     "ori", "pef", "ptx", "raf", "3fr", "fff", "ari", "bay", "cap", "eip",
                     "liq", "iiq", "erf", "mdc", "mef", "mfw", "mos", "pxn", "raw", "rwl",
                     "rw2", "gpr", "srw", "bmq", "cs1", "dxo", "rdc", "rwz", "sti", "x3f"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"dcr", "Kodak Cineon Raw Image Format"},
        {"kdc", "Kodak Cineon Raw Image Format"},
        {"drf", "Kodak Cineon Raw Image Format"},
        {"k25", "Kodak Cineon Raw Image Format"},
        {"dcs", "Kodak Cineon Raw Image Format"},
        {"dc2", "Kodak Cineon Raw Image Format"},
        {"kc2", "Kodak Cineon Raw Image Format"},
        {"arw", "Sony Digital Camera Alpha Raw Image Format"},
        {"crw", "Canon Digital Camera Raw Image Format"},
        {"crr", "Canon Digital Camera Raw Image Format"},
        {"cr2", "Canon Digital Camera Raw Image Format"},
        {"cr3", "Canon Digital Camera Raw Image Format"},
        {"dng", "Adobe Digital Negative Raw Image Format"},
        {"srf", "Sony (Minolta) Raw Image Format"},
        {"mrw", "Sony (Minolta) Raw Image Format"},
        {"sr2", "Sony (Minolta) Raw Image Format"},
        {"arq", "Sony (Minolta) Raw Image Format"},
        {"nef", "Nikon Digital SLR Camera Raw Image Format"},
        {"nrw", "Nikon Digital SLR Camera Raw Image Format"},
        {"orf", "Olympus Digital Camera Raw Image Format"},
        {"ori", "Olympus Digital Camera Raw Image Format"},
        {"pef", "Pentax Raw Image Format"},
        {"ptx", "Pentax Raw Image Format"},
        {"raf", "Fuji CCD Raw Image Format"},
        {"3fr", "Hasselblad Raw Image Format"},
        {"fff", "Hasselblad Raw Image Format"},
        {"ari", "ARRIFLEX Raw Image Format"},
        {"bay", "Casio Raw Image Format"},
        {"cap", "Phase One Raw Image Format"},
        {"eip", "Phase One Raw Image Format"},
        {"liq", "Phase One Raw Image Format"},
        {"iiq", "Phase One Raw Image Format"},
        {"erf", "Epson Raw Image Format"},
        {"mdc", "Minolta/Agfa Raw Image Format"},
        {"mef", "Mamiya Raw Image Format"},
        {"mfw", "Mamiya Raw Image Format"},
        {"mos", "Leaf Raw Image Format"},
        {"pxn", "Logitech Raw Image Format"},
        {"raw", "Leica Raw Image Format"},
        {"rwl", "Leica Raw Image Format"},
        {"rw2", "Panasonic Raw Image Format"},
        {"gpr", "GoPro GPR Raw Image Format"},
        {"srw", "Samsung Raw Image Format"},
        {"bmq", "NuCore RAW image file"},
        {"cs1", "CaptureShop 1-shot Raw Image"},
        {"dxo", "DxO PureRaw"},
        {"rdc", "Rollei RAW Image"},
        {"rwz", "Rawzor RAW image"},
        {"sti", "Sinar CaptureShop RAW image"},
        {"x3f", "Sigma Digital Camera Raw Image"},
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/libraw_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
    } else {
        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();
    }

    // then we store ALL supported mimetypes
    m_allMimetypes = {"image/x-canon-crw",
                      "image/x-canon-cr2",
                      "image/x-olympus-orf",
                      "image/x-pentax-pef"};

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    Q_EMIT formatsUpdated();

}

void PQCImagePluginLibraw::saveFormats() {

    // TODO

}
