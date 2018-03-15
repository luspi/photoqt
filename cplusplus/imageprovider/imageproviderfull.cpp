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
#include "loader/loadimage_devil.h"
#include "loader/loadimage_gm.h"
#include "loader/loadimage_qt.h"
#include "loader/loadimage_xcf.h"
#include "loader/loadimage_poppler.h"

// Both the libraw and the freeimage library have typedefs for INT64 and UINT64.
// As we never use them directly, we can redefine one of them (here for libraw) to use a different name and thus avoid the clash.
#define INT64 INT64_SOMETHINGELSE
#define UINT64 UINT64_SOMETHINGELSE
#include "loader/loadimage_raw.h"
#undef INT64
#undef UINT64
#include "loader/loadimage_freeimage.h"

ImageProviderFull::ImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

    settings = new SlimSettingsReadOnly;
    imageformats = new ImageFormats;

    pixmapcache = new QPixmapCache;
    pixmapcache->setCacheLimit(8*1024*std::max(0, std::min(1000, settings->pixmapCache)));

}

ImageProviderFull::~ImageProviderFull() {
    delete settings;
    delete imageformats;
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

    if(!QFileInfo(filename).exists() && !filename.contains("__::pqt::__")) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it doesn't exist!");
        LOG << CURDATE << "ImageProviderFull: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "ImageProviderFull: Filename: " << filename.toStdString() << NL;
        return LoadImage::ErrorImage::load(err);
    }

    // Which GraphicsEngine should we use?
    QString whatToUse = whatDoIUse(filename);
    qDebug() << "whatToUse =" << whatToUse;

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "ImageProviderFull: Using graphics engine: "
            << (whatToUse=="gm" ? "GraphicsMagick" : (whatToUse=="qt" ? "ImageReader" : (whatToUse=="raw" ? "LibRaw" : "External Tool")))
            << " [" << whatToUse.toStdString() << "]" << NL;

    // The return image
    QImage ret;

    // the unique key for caching
    QByteArray cachekey = getUniqueCacheKey(filename);

    // if image was already once loaded
    QPixmap retPix;
    if(pixmapcache->find(cachekey, &retPix)) {

        // re-load image
        ret = retPix.toImage();

        // if valid...
        if(!ret.isNull()) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "ImageProviderFull: Loading full image from pixmap cache: " << QFileInfo(filename).fileName().toStdString() << NL;

            // return scaled version
            if(requestedSize.width() > 2 && requestedSize.height() > 2 && ret.width() > requestedSize.width() && ret.height() > requestedSize.height())
                return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

            // return full version
            return ret;

        }

    }

    // Try to use XCFtools for XCF (if enabled)
    if(whatToUse == "xcftools")
        ret = LoadImage::XCF::load(filename,maxSize);

    // Try to use GraphicsMagick (if available)
    else if(whatToUse == "gm")
        ret = LoadImage::GraphicsMagick::load(filename, maxSize);

    // Try to use libraw (if available)
    else if(whatToUse == "raw")
        ret = LoadImage::Raw::load(filename, maxSize);

    // Try to use DevIL (if available)
    else if(whatToUse == "devil")
        ret = LoadImage::Devil::load(filename, maxSize);

    // Try to use FreeImage (if available)
    else if(whatToUse == "freeimage")
        ret = LoadImage::FreeImage::load(filename, maxSize);

    else if(whatToUse == "poppler")
        ret = LoadImage::PDF::load(filename, maxSize);

    // Try to use Qt
    else
        ret = LoadImage::Qt::load(filename,maxSize,settings->metaApplyRotation);

    // if returned image is not an error image ...
    if(ret.text("error") != "error") {

        // ... insert image into cache
        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "ImageProviderFull: Inserting full image into pixmap cache: " << QFileInfo(filename).fileName().toStdString() << NL;
        pixmapcache->insert(cachekey, QPixmap::fromImage(ret));

    }

    // return scaled version
    if(requestedSize.width() > 2 && requestedSize.height() > 2 && ret.width() > requestedSize.width() && ret.height() > requestedSize.height())
        return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // return full version
    return ret;

}

QString ImageProviderFull::whatDoIUse(QString filename) {

    if(filename.trimmed() == "") return "qt";

    /***********************************************************/
    // PDF with poppler library

    if((imageformats->getEnabledFileformatsPoppler().contains("*.pdf") && filename.toLower().endsWith(".pdf")) || (imageformats->getEnabledFileformatsPoppler().contains("*.epdf") && filename.toLower().endsWith(".epdf")))
        return "poppler";

    /***********************************************************/
    // Qt image plugins

    foreach(QString qt, imageformats->getEnabledFileformatsQt()) {
        if(filename.toLower().endsWith(qt.remove(0,1)))
            return "qt";
    }


    /***********************************************************/
    // xcftools

    if((imageformats->getEnabledFileformatsXCFTools().contains("*.xcf") && filename.endsWith(".xcf")))
        return "xcftools";



#ifdef RAW

    /***********************************************************/
    // libraw library

    foreach(QString raw, imageformats->getEnabledFileformatsRAW()) {
        if(filename.toLower().endsWith(raw.remove(0,1)))
            return "raw";
    }

#endif

#ifdef GM

    /***********************************************************/
    // GraphicsMagick library

    foreach(QString gm, imageformats->getEnabledFileformatsGm()) {
        if(filename.toLower().endsWith(gm.remove(0,1)))
            return "gm";
    }

#endif

#ifdef DEVIL

    /***********************************************************/
    // DevIL library

    foreach(QString devil, imageformats->getEnabledFileformatsDevIL()) {
        if(filename.toLower().endsWith(devil.remove(0,1)))
            return "devil";
    }

#endif

#ifdef FREEIMAGE

    /***********************************************************/
    // FreeImage library

    foreach(QString freeimage, imageformats->getEnabledFileformatsFreeImage()) {
        if(filename.toLower().endsWith(freeimage.remove(0,1)))
            return "freeimage";
    }

#endif

    /***********************************************************/
    // If the image was found, we default to GraphicsMagick if enabled, and otherwise to the Qt image plugins
#ifdef GM
    return "gm";
#endif
    return "qt";

}

QByteArray ImageProviderFull::getUniqueCacheKey(QString path) {
    path = path.remove("image://full/");
    path = path.remove("file:/");
    QFileInfo info(path);
    QString fn = QString("%1%2").arg(path).arg(info.lastModified().toMSecsSinceEpoch());
    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();
}
