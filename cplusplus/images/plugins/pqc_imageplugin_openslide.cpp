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

#include <imageplugins/pqc_imageplugin_openslide.h>
#include <pqc_settingscpp.h>
#include <pqc_scriptsother.h>
#include <pqc_scriptsimages.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMOPENSLIDE
#include <openslide/openslide.h>
#endif

PQCImagePluginOpenSlide::PQCImagePluginOpenSlide() {

#ifdef PQMOPENSLIDE

    setData({
        {44478,
             {{"ARGOS slides"}, {"avs"}, {""}}},
        {44477,
             {{"Aperio slides"}, {"svs"}, {""}}},
        {44479,
             {{"Hamamatsu slides"}, {"vms", "vmu", "ndpi"}, {""}}},
        {44480,
             {{"Huron slides"}, {"tif"}, {""}}},
        {44481,
             {{"Leica slides"}, {"scn"}, {""}}},
        {44482,
             {{"MIRAX slides"}, {"mrxs"}, {""}}},
        {44484,
             {{"Philips slides"}, {"tiff"}, {""}}},
        {44485,
             {{"Sakura slides"}, {"svslide"}, {""}}},
        {44486,
             {{"Trestle slides"}, {"tif"}, {""}}},
        {44487,
             {{"Ventana slides"}, {"bif", "tif"}, {""}}},
        {44488,
             {{"Zeiss slides"}, {"czi"}, {""}}},
        {44562,
             {{"Digital Imaging and Communications in Medicine (DICOM) image"}, {"dic", "dcm"}, {"application/dicom", "image/dicom-rle"}}}},
        "openslide", {});

#endif

}

const QSize PQCImagePluginOpenSlide::loadSize(QString path) {

#ifdef PQMOPENSLIDE

    // not an OpenSlide image
    if(openslide_detect_vendor(path.toLocal8Bit().constData()) == NULL) {
        qWarning() << "not an OpenSlide image";
        return {};
    }

    // attempt to open the slide
    openslide_t* slide = openslide_open(path.toLocal8Bit().constData());

    if(!slide) {
        qWarning() << "Failed to open slide";
        return {};
    }

    // check for any other error
    if(const char* err = openslide_get_error(slide)) {
        qWarning() << "Error opening slide:" << err;
        openslide_close(slide);
        return {};
    }

    // get original level-0 dimensions
    int64_t origWidth = 0;
    int64_t origHeight = 0;
    openslide_get_level_dimensions(slide, 0, &origWidth, &origHeight);

    if(origWidth <= 0 || origHeight <= 0) {
        qWarning() << "invalid slide dimensions:" << origWidth << "x" << origHeight;
        openslide_close(slide);
        return {};
    }

    openslide_close(slide);
    return QSize(origWidth, origHeight);

#endif

    return QSize();

}

const QImage PQCImagePluginOpenSlide::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path = " << path;
    qDebug() << "args: requestedSize = " << requestedSize;

#ifdef PQMOPENSLIDE

    // not an OpenSlide image
    if(openslide_detect_vendor(path.toLocal8Bit().constData()) == NULL) {
        qWarning() << "not an OpenSlide image";
        return {};
    }

    // attempt to open the slide
    openslide_t* slide = openslide_open(path.toLocal8Bit().constData());

    if(!slide) {
        const QString msg = "Failed to open slide";
        error += msg % "\n";
        qWarning() << msg;
        return {};
    }

    // check for any other error
    if(const char* err = openslide_get_error(slide)) {
        error += QString::fromUtf8(err) % "\n";
        qWarning() << "Error opening slide:" << err;
        openslide_close(slide);
        return {};
    }

    // get original level-0 dimensions
    int64_t origWidth = 0;
    int64_t origHeight = 0;
    openslide_get_level_dimensions(slide, 0, &origWidth, &origHeight);

    if(origWidth <= 0 || origHeight <= 0) {
        const QString msg = QString("invalid slide dimensions: %1 x %2").arg(origWidth).arg(origHeight);
        error += msg % "\n";
        qWarning() << msg;
        openslide_close(slide);
        return {};
    }

    origSize = QSize(origWidth, origHeight);

    // check whether we need to load the FULL resolution slide
    // or a downsampled version only
    QSize outputSize = (requestedSize.isEmpty() ? origSize : requestedSize);

    // slides images can be VERY large and consume many many GB of memory
    // thus we limit the output factor to a maximum of 8000x8000
    const int maxDim = 8000;
    if(outputSize.width() > maxDim || outputSize.height() > maxDim)
        outputSize = outputSize.scaled(maxDim, maxDim, Qt::KeepAspectRatio);

    // get downsample factor
    // example: 100000x80000 -> 1000x800  =>  ~100x downsample
    const double downsampleX = static_cast<double>(origWidth)/outputSize.width();
    const double downsampleY = static_cast<double>(origHeight)/outputSize.height();
    const double requestedDownsample = qMax(downsampleX, downsampleY);

    // get the best level from OpenSlide for downsample factor
    // this avoid reading full image if we don't need to (faster, less memory)
    int level = openslide_get_best_level_for_downsample(slide, requestedDownsample);

    if(level < 0 || level >= openslide_get_level_count(slide)) {
        const QString msg = QString("failed to select OpenSlide level, received: %1").arg(level);
        error += msg % "\n";
        qWarning() << msg;
        openslide_close(slide);
        return {};
    }

    const double levelDownsample = openslide_get_level_downsample(slide, level);

    int64_t levelWidth = 0;
    int64_t levelHeight = 0;
    openslide_get_level_dimensions(slide, level, &levelWidth, &levelHeight);

    if(levelWidth <= 0 || levelHeight <= 0) {
        const QString msg = QString("invalid OpenSlide level dimensions obtained: %1 x %2").arg(levelWidth).arg(levelHeight);
        error += msg % "\n";
        qWarning() << msg;
        openslide_close(slide);
        return {};
    }

    // this avoid allocating a very large buffer if requestedSize is larger than selected OpenSlide level
    const int readWidth = qMin(levelWidth, qMax(1, qCeil(origWidth/levelDownsample)));
    const int readHeight = qMin(levelHeight, qMax(1, qCeil(origHeight/levelDownsample)));

    // read image in dimension closest to requested size
    const int targetWidth = requestedSize.isEmpty() ? readWidth : qMin(readWidth, qCeil(outputSize.width()*levelDownsample / requestedDownsample));
    const int targetHeight = requestedSize.isEmpty() ? readHeight : qMin(readHeight, qCeil(outputSize.height()*levelDownsample / requestedDownsample));

    const int width = std::max(1, targetWidth);
    const int height = std::max(1, targetHeight);

    std::vector<uint32_t> pixels(width*height);

    // coordinates passed to openslide_read_region are always for level-0
    openslide_read_region(slide, pixels.data(),
                          0, 0, // x and y
                          level, width, height);

    if(const char* err = openslide_get_error(slide)) {
        error += QString::fromUtf8(err) % "\n";
        qWarning() << "Error reading region:" << err;
        openslide_close(slide);
        return {};
    }

    // OpenSlide returns a premultiplied ARGB32 image -> compatible with Qt!
    // Since QImage does not own pixels, we need to make a deep copy before freeing OpenSlide memory
    QImage result = QImage(reinterpret_cast<const uchar*>(pixels.data()), width, height, width * sizeof(uint32_t), QImage::Format_ARGB32).copy();

    openslide_close(slide);

    // no downsampling -> full image
    if(requestedSize.isEmpty()) {
        const QString prf = PQCScriptsColorProfiles::get().applyColorProfile(path, result);
        PQCImageCache::get().saveImageToCache(path, prf, result);
    }

    // scale if necessary
    if(!requestedSize.isEmpty() && result.size() != outputSize)
        return result.scaled(outputSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    return result;

#endif

    return QImage();

}
