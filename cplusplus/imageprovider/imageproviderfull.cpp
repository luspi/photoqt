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
#include "loader/loadimage_archive.h"
#include "loader/loadimage_unrar.h"

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
    mimetypes = new MimeTypes;

    pixmapcache = new QPixmapCache;
    pixmapcache->setCacheLimit(8*1024*std::max(0, std::min(1000, settings->pixmapCache)));

    // Value of -1 means we need to check next time
    foundExternalUnrar = -1;

}

ImageProviderFull::~ImageProviderFull() {
    delete settings;
    delete imageformats;
    delete mimetypes;
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

    if(!QFileInfo(filename).exists() &&
       !filename.contains("::PQT1::") && !filename.contains("::PQT2::") &&
       !filename.contains("::ARCHIVE1::") && !filename.contains("::ARCHIVE2::")) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it doesn't exist!");
        LOG << CURDATE << "ImageProviderFull: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "ImageProviderFull: Filename: " << filename.toStdString() << NL;
        return PLoadImage::ErrorImage::load(err);
    }

    // Which GraphicsEngine should we use?
    QString whatToUse = whatDoIUse(filename);

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
            if(requestedSize.width() > 2 && requestedSize.height() > 2 &&
               ret.width() > requestedSize.width() && ret.height() > requestedSize.height())
                return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

            // return full version
            return ret;

        }

    }

    // Try to use XCFtools for XCF (if enabled)
    if(whatToUse == "xcftools")
        ret = PLoadImage::XCF::load(filename,maxSize);

    // Try to use GraphicsMagick (if available)
    else if(whatToUse == "gm")
        ret = PLoadImage::GraphicsMagick::load(filename, maxSize);

    // Try to use libraw (if available)
    else if(whatToUse == "raw")
        ret = PLoadImage::Raw::load(filename, maxSize);

    // Try to use DevIL (if available)
    else if(whatToUse == "devil")
        ret = PLoadImage::Devil::load(filename, maxSize);

    // Try to use FreeImage (if available)
    else if(whatToUse == "freeimage")
        ret = PLoadImage::FreeImage::load(filename, maxSize);

    else if(whatToUse == "poppler")
        ret = PLoadImage::PDF::load(filename, maxSize, settings->pdfQuality);

    else if(whatToUse == "unrar")
        ret = PLoadImage::UNRAR::load(filename, maxSize);

    else if(whatToUse == "archive")
        ret = PLoadImage::Archive::load(filename, maxSize);

    // Try to use Qt
    else
        ret = PLoadImage::Qt::load(filename,maxSize,settings->metaApplyRotation);

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

    QString useThisFilename = filename;
    if(filename.contains("::PQT1::") && filename.contains("::PQT2::"))
        useThisFilename = filename.split("::PQT1::").at(0) + filename.split("::PQT2::").at(1);

    QString mime = mimedb.mimeTypeForFile(useThisFilename).name();

    QFileInfo info(useThisFilename);

    /***********************************************************/
    // Qt image plugins

    if(imageformats->getEnabledFileformatsQt().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesQt().contains(mime))
        return "qt";


    /***********************************************************/
    // PDF with poppler library

    if(imageformats->getEnabledFileformatsPoppler().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesPoppler().contains(mime))
        return "poppler";


    /***********************************************************/
    // xcftools

    if(imageformats->getEnabledFileformatsXCFTools().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesXCFTools().contains(mime))
        return "xcftools";


    /***********************************************************/
    // unrar

#ifdef Q_OS_LINUX
    QString suffix = info.suffix().toLower();
    if(settings->archiveUseExternalUnrar &&
       (((suffix == "rar" || suffix == "cbr") && imageformats->getEnabledFileformatsArchive().contains("*."+suffix)) ||
        (mime == "application/vnd.rar" && mimetypes->getEnabledMimeTypesArchive().contains(mime)))) {
        // The first time we get here we check whether unrar is available or not
        if(foundExternalUnrar == -1) {
            QProcess which;
            which.setStandardOutputFile(QProcess::nullDevice());
            which.start("which unrar");
            which.waitForFinished();
            foundExternalUnrar = which.exitCode() ? 0 : 1;
        }
        if(foundExternalUnrar == 1)
            return "unrar";
    }
#endif


    /***********************************************************/
    // Archive

    if(imageformats->getEnabledFileformatsArchive().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesArchive().contains(mime))
        return "archive";



#ifdef RAW

    /***********************************************************/
    // libraw library

    if(imageformats->getEnabledFileformatsRAW().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesRAW().contains(mime))
        return "raw";

#endif

#ifdef GM

    /***********************************************************/
    // GraphicsMagick library

    if(imageformats->getEnabledFileformatsGm().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesGm().contains(mime))
        return "gm";

    if(imageformats->getEnabledFileformatsGmGhostscript().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesGmGhostscript().contains(mime))
        return "gm";

#endif

#ifdef DEVIL

    /***********************************************************/
    // DevIL library

    if(imageformats->getEnabledFileformatsDevIL().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesDevIL().contains(mime))
        return "devil";

#endif

#ifdef FREEIMAGE

    /***********************************************************/
    // FreeImage library

    if(imageformats->getEnabledFileformatsFreeImage().contains("*." + info.suffix().toLower()) ||
       mimetypes->getEnabledMimeTypesFreeImage().contains(mime))
        return "freeimage";

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
    if(path.endsWith(".pdf") || path.endsWith(".epdf")) fn = QString("%1%2").arg(fn).arg(settings->pdfQuality);
    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();
}
