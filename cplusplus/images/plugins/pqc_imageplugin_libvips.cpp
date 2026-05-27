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

#include <pqc_imageplugin_libvips.h>
#include <pqc_settingscpp.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMLIBVIPS
#include <vips/vips.h>
#endif

PQCImagePluginLibVips::PQCImagePluginLibVips(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginLibVips::getDescription(QString suffix) {
    return suffix2description.value(suffix.toLower(), "");
}

const QSet<QString> PQCImagePluginLibVips::getSuffixesForFormatByDescription(QString description) {
    QSet<QString> ret;
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            ret.insert(suf);
    }
    return ret;
}

const bool PQCImagePluginLibVips::supportsFormatByDescription(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return true;
    }
    return false;
}

const bool PQCImagePluginLibVips::isEnabled(QString description) {
    for(const auto &[suf, desc] : std::as_const(suffix2description).asKeyValueRange()) {
        if(desc == description)
            return m_suffixes.contains(suf);
    }
    return false;
}

const QSet<QString> PQCImagePluginLibVips::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginLibVips::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginLibVips::loadSize(QString path) {

#ifdef PQMLIBVIPS

    // we only need the metadata here, never the full image
    VipsImage *in = vips_image_new_from_file(path.toStdString().c_str(),
                                             "access", VIPS_ACCESS_RANDOM,
                                             "fail_on", VIPS_FAIL_ON_TRUNCATED,
                                             NULL);

    if(!in) {
        qDebug() << "vips_image_new_from_file: failed to load image from file)";
        return QSize();
        return QSize();
    }

    const QSize size(vips_image_get_width(in), vips_image_get_height(in));

    g_object_unref(in);

    return size;

#endif

    return QSize();

}

const QImage PQCImagePluginLibVips::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path = " << path;
    qDebug() << "args: requestedSize = " << requestedSize;

#ifdef PQMLIBVIPS

    // we use the C API as the equivalent C++ API calls led to crash on subsequent call

    // attempt to the load the image
    VipsImage *vimg = vips_image_new_from_file(path.toStdString().c_str(), "access", VIPS_ACCESS_SEQUENTIAL, NULL);
    if(!vimg) {
        const QString msg = "vips_image_new_from_file: failed to load image from file";
        error += msg % "\n";
        qDebug() << msg;
        return QImage();
    }

    // store original size
    origSize = QSize(vimg->Xsize, vimg->Ysize);

    // ensure a Qt-friendly format
    if(vips_image_hasalpha(vimg) == 0) {
        VipsImage *tmp;
        if(vips_addalpha(vimg, &tmp, NULL)) {
            const QString msg = "vips_image_hasalpha failed";
            error += msg % "\n";
            qDebug() << msg;
            return QImage();
        }
        g_object_unref(vimg);
        vimg = tmp;
    }

    // convert to uchar RGBA
    VipsImage *memImg = vips_image_copy_memory(vimg);
    if(!memImg) {
        g_object_unref(vimg);
        const QString msg = "vips_image_copy_memory failed";
        error += msg % "\n";
        qDebug() << msg;
        return QImage();
    }

    // construct qimage with clean-up function
    QImage img = QImage(memImg->data,
                        origSize.width(), origSize.height(), origSize.width()*memImg->Bands,
                        QImage::Format_RGBA8888,
                        [](void *p) { g_object_unref(VIPS_IMAGE(p)); },
                        memImg).copy();

    // apply transformations if any
    const QString suf = QFileInfo(path).suffix().toLower();
    if(PQCSettingsCPP::get().getMetadataAutoRotation() && suf != "heif" && suf != "heic") {
        PQCScriptsImages::get().applyExifOrientation(path, img);
    }

    // apply color profile if any
    PQCScriptsColorProfiles::get().applyColorProfile(path, img);

    // cache the image
    PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);

    // clean up memory
    g_object_unref(vimg);

    // scale image if necessary
    if(!requestedSize.isEmpty()) {
        return img.scaled(origSize.scaled(requestedSize, Qt::KeepAspectRatio),
                          Qt::IgnoreAspectRatio,
                          (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
    }

    return img;

#endif

    return QImage();

}

void PQCImagePluginLibVips::setEnabled(QString description, bool enabled) {

}

/***********************************************/

void PQCImagePluginLibVips::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/libvips_suffixes";
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
    m_allSuffixes = {"exr", "gif", "jpeg2000", "j2k", "jp2", "jpc", "jpx", "jpeg",
                     "jpg", "jpe", "jif", "pbm", "pgm", "png", "ppm", "pnm", "svg",
                     "svgz", "tiff", "tif", "fits", "fit", "fts", "webp", "rgbe",
                     "hdr", "rad", "heif", "heic", "pfm"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"exr",      "OpenEXR"},
        {"gif",      "GIF: Graphics Interchange Format"},
        {"jpeg2000", "JPEG-2000"},
        {"j2k",      "JPEG-2000"},
        {"jp2",      "JPEG-2000"},
        {"jpc",      "JPEG-2000"},
        {"jpx",      "JPEG-2000"},
        {"jpeg",     "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpg",      "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpe",      "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jif",      "JPEG: Joint Photographic Experts Group JFIF format"},
        {"pbm",      "PBM: Portable bitmap format (black and white)"},
        {"pgm",      "PGM: Portable graymap format (gray scale)"},
        {"png",      "PNG: Portable Network Graphics"},
        {"ppm",      "PPM: Portable pixmap format (color)"},
        {"pnm",      "PPM: Portable pixmap format (color)"},
        {"svg",      "SVG: Scalable Vector Graphics"},
        {"svgz",     "SVG: Scalable Vector Graphics"},
        {"tiff",     "TIFF: Tagged Image File Format"},
        {"tif",      "TIFF: Tagged Image File Format"},
        {"fits",     "FITS: Flexible Image Transport System"},
        {"fit",      "FITS: Flexible Image Transport System"},
        {"fts",      "FITS: Flexible Image Transport System"},
        {"webp",     "WEBP: Google web image format"},
        {"rgbe",     "HDR: Radiance RGBE image format"},
        {"hdr",      "HDR: Radiance RGBE image format"},
        {"rad",      "HDR: Radiance RGBE image format"},
        {"heif",     "HEIF: High Efficiency Image Format"},
        {"heic",     "HEIF: High Efficiency Image Format"},
        {"pfm",      "Portable Float Map"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/libvips_mimetypes";
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
    m_allMimetypes = {"image/x-exr", "image/gif", "image/jp2", "image/jpx", "image/jpm",
                      "image/jpeg", "image/x-portable-anymap", "image/x-portable-greymap",
                      "image/x-portable-anymap", "image/png", "image/x-portable-pixmap",
                      "image/x-portable-anymap", "image/svg+xml", "image/tiff", "image/tiff-fx",
                      "image/fits", "image/webp", "image/heic", "image/heif"};

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    mimetype2description = {
        {"image/x-exr",              "OpenEXR"},
        {"image/gif",                "GIF: Graphics Interchange Format"},
        {"image/jp2,",               "JPEG-2000"},
        {"image/jpx",                "JPEG-2000"},
        {"image/jpm",                "JPEG-2000"},
        {"image/jpeg",               "JPEG: Joint Photographic Experts Group JFIF format"},
        {"image/x-portable-anymap",  "PBM: Portable bitmap format (black and white)"},
        {"image/x-portable-greymap", "PGM: Portable graymap format (gray scale)"},
        {"image/x-portable-anymap",  "PGM: Portable graymap format (gray scale)"},
        {"image/png",                "PNG: Portable Network Graphics"},
        {"image/x-portable-pixmap",  "PPM: Portable pixmap format (color)"},
        {"image/x-portable-anymap",  "PPM: Portable pixmap format (color)"},
        {"image/svg+xml",            "SVG: Scalable Vector Graphics"},
        {"image/tiff",               "TIFF: Tagged Image File Format"},
        {"image/tiff-fx",            "TIFF: Tagged Image File Format"},
        {"image/fits",               "FITS: Flexible Image Transport System"},
        {"image/webp",               "WEBP: Google web image format"},
        {"image/heic",               "HEIF: High Efficiency Image Format"},
        {"image/heif",               "HEIF: High Efficiency Image Format"}
    };

    Q_EMIT formatsUpdated();

}

void PQCImagePluginLibVips::saveFormats() {

    // TODO

}
