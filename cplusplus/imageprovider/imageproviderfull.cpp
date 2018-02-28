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

#include "imageproviderfull.h"

ImageProviderFull::ImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

    settings = new SlimSettingsReadOnly;
    fileformats = new FileFormats;

    pixmapcache = new QCache<QByteArray, QImage>;
    pixmapcache->setMaxCost(8*1024*std::max(0, std::min(1000, settings->pixmapCache)));

    loaderGM = new LoadImageGM;
    loaderQT = new LoadImageQt;
    loaderRAW = new LoadImageRaw;
    loaderXCF = new LoadImageXCF;

}

ImageProviderFull::~ImageProviderFull() {
    delete settings;
    delete fileformats;
    delete pixmapcache;
}

QImage ImageProviderFull::requestImage(const QString &filename_encoded, QSize *, const QSize &requestedSize) {

    QString full_filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());
#ifdef Q_OS_WIN
    // It is not always clear whether the file url prefix comes with two or three slashes
    // This makes sure that in Windows the file always starts with something like C:/path and not /C:/path
    while(full_filename.startsWith("/"))
        full_filename = full_filename.remove(0,1);
#endif
    QString filename = full_filename;

    if(!QFileInfo(filename).exists()) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it doesn't exist!");
        LOG << CURDATE << "ImageProviderFull: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "ImageProviderFull: Filename: " << filename.toStdString() << NL;
        return ErrorImage::load(err);
    }

    // Which GraphicsEngine should we use?
    QString whatToUse = whatDoIUse(filename);

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "ImageProviderFull: Using graphics engine: "
            << (whatToUse=="gm" ? "GraphicsMagick" : (whatToUse=="qt" ? "ImageReader" : (whatToUse=="raw" ? "LibRaw" : "External Tool")))
            << " [" << whatToUse.toStdString() << "]" << NL;

    // We use a pointer to be able to use it for caching
    QImage *ret = new QImage;

    // the unique key for caching
    QByteArray cachekey = getUniqueCacheKey(filename);

    // if image was already once loaded
    if(pixmapcache->contains(cachekey)) {

        // re-load image
        ret = pixmapcache->object(cachekey);

        // if valid...
        if(!ret->isNull()) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "ImageProviderFull: Loading full image from pixmap cache: " << QFileInfo(filename).fileName().toStdString() << NL;

            // return scaled version
            if(requestedSize.width() > 2 && requestedSize.height() > 2 && ret->width() > requestedSize.width() && ret->height() > requestedSize.height())
                return ret->scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

            // return full version
            return *ret;

        }

    }

    // Try to use XCFtools for XCF (if enabled)
    if(whatToUse == "xcftools")
        *ret = loaderXCF->load(filename,maxSize);

    // Try to use GraphicsMagick (if available)
    else if(whatToUse == "gm")
        *ret = loaderGM->load(filename, maxSize);

    // Try to use libraw (if available)
    else if(whatToUse == "raw")
        *ret = loaderRAW->load(filename, maxSize);

    // Try to use Qt
    else
        *ret = loaderQT->load(filename,maxSize,settings->metaApplyRotation);

    // insert image into cache
    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "ImageProviderFull: Inserting full image into pixmap cache: " << QFileInfo(filename).fileName().toStdString() << NL;
    pixmapcache->insert(cachekey, ret, ret->width()*ret->height()*ret->depth()/(8*1024));

    // return scaled version
    if(requestedSize.width() > 2 && requestedSize.height() > 2 && ret->width() > requestedSize.width() && ret->height() > requestedSize.height())
        return ret->scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // return full version
    return *ret;

}

QString ImageProviderFull::whatDoIUse(QString filename) {

    if(filename.trimmed() == "") return "qt";

    /***********************************************************/
    // Qt image plugins

    foreach(QString qt, fileformats->formats_qt) {
        if(filename.toLower().endsWith(qt.remove(0,1)))
            return "qt";
    }
    foreach(QString qt, fileformats->formats_kde) {
        if(filename.toLower().endsWith(qt.remove(0,1)))
            return "qt";
    }
    if((fileformats->formats_extras.contains("*.psb") && filename.endsWith(".psb")) ||
       (fileformats->formats_extras.contains("*.psd") && filename.endsWith(".psd")))
        return "qt";


    /***********************************************************/
    // xcftools

    if((fileformats->formats_extras.contains("*.xcf") && filename.endsWith(".xcf")))
        return "xcftools";



#ifdef RAW

    /***********************************************************/
    // libraw library

    foreach(QString raw, fileformats->formats_raw) {
        if(filename.toLower().endsWith(raw.remove(0,1)))
            return "raw";
    }

#endif

#ifdef GM

    /***********************************************************/
    // GraphicsMagick is our swiss army knife, if nothing else then this should hopefully be able to load the image

    return "gm";

#endif

    /***********************************************************/
    // If GraphicsMagick is disabled, we default to the built-in Qt image plugins

    return "qt";

}

QByteArray ImageProviderFull::getUniqueCacheKey(QString path) {
    path = path.remove("image://full/");
    path = path.remove("file:/");
    QFileInfo info(path);
    QString fn = QString("%1%2").arg(path).arg(info.lastModified().toMSecsSinceEpoch());
    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();
}
