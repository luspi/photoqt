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

#include <imageplugins/pqc_imageplugin_libvips.h>
#include <pqc_settingscpp.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMLIBVIPS
#include <vips/vips.h>
#endif

PQCImagePluginLibVips::PQCImagePluginLibVips() {

    setData({
            {12444,
                 {{"FITS: Flexible Image Transport System"}, {"fits","fit","fts"}, {"image/fits"}}},
            {52412,
                 {{"GIF: Graphics Interchange Format"}, {"gif"}, {"image/gif"}}},
            {11113,
                 {{"HDR: Radiance RGBE image format"}, {"rgbe","hdr","rad"}, {""}}},
            {22226,
                 {{"HEIF: High Efficiency Image Format"}, {"heif","heic"}, {"image/heic","image/heif"}}},
            {13245,
                 {{"JPEG-2000"}, {"jpeg2000","j2k","jp2","jpc","jpx"}, {"image/jp2","image/jpx","image/jpm"}}},
            {11485,
                 {{"JPEG: Joint Photographic Experts Group JFIF format"}, {"jpeg","jpg","jpe","jif"}, {"image/jpeg"}}},
            {74586,
                 {{"OpenEXR"}, {"exr"}, {"image/x-exr"}}},
            {16685,
                 {{"PBM: Portable bitmap format (black and white)"}, {"pbm"}, {"image/x-portable-anymap"}}},
            {85444,
                 {{"PGM: Portable graymap format (gray scale)"}, {"pgm"}, {"image/x-portable-greymap","image/x-portable-anymap"}}},
            {46215,
                 {{"PNG: Portable Network Graphics"}, {"png"}, {"image/png"}}},
            {77521,
                 {{"PPM: Portable pixmap format (color)"}, {"ppm","pnm"}, {"image/x-portable-pixmap","image/x-portable-anymap"}}},
            {44444,
                 {{"Portable Float Map"}, {"pfm"}, {""}}},
            {26112,
                 {{"SVG: Scalable Vector Graphics"}, {"svg","svgz"}, {"image/svg+xml"}}},
            {44462,
                 {{"TIFF: Tagged Image File Format"}, {"tiff","tif"}, {"image/tiff","image/tiff-fx"}}},
            {28282,
                 {{"WEBP: Google web image format"}, {"webp"}, {"image/webp"}}}},
            "libvips",
            {13245});

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

    // cache the image
    PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().applyColorProfile(path, img), img);

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

const bool PQCImagePluginLibVips::writeImage(QImage img, QString targetPath) {
    return false;
}
