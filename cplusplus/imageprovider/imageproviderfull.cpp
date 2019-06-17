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
#include "loader/loadimage_qt.h"
#include "loader/loadimage_gm.h"
#include "loader/loadimage_xcf.h"
#include "../settings/settings.h"

PQImageProviderFull::PQImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

    pixmapcache = new QPixmapCache;
    pixmapcache->setCacheLimit(8*1024*std::max(0, std::min(1000, PQSettings::get().getPixmapCache())));

    imageformats = new PQImageFormats;

}

PQImageProviderFull::~PQImageProviderFull() {
    delete pixmapcache;
    delete imageformats;
}

QImage PQImageProviderFull::requestImage(const QString &filename_encoded, QSize *origSize, const QSize &requestedSize) {

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
        return PQLoadImage::ErrorImage::load(err);
    }

    // Which GraphicsEngine should we use?
    QString whatToUse = whatDoIUse(filename);

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

            // return scaled version
            if(requestedSize.width() > 2 && requestedSize.height() > 2 &&
               ret.width() > requestedSize.width() && ret.height() > requestedSize.height())
                return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

            // return full version
            return ret;

        }

    }

    QString err = "";

    if(whatToUse == "gm") {
        ret = PQLoadImage::GraphicsMagick::load(filename, requestedSize, origSize);
        err = PQLoadImage::GraphicsMagick::errormsg;
    } else if(whatToUse == "xcftools") {
            ret = PQLoadImage::XCF::load(filename, requestedSize, origSize);
            err = PQLoadImage::XCF::errormsg;
    } else {
        ret = PQLoadImage::Qt::load(filename, requestedSize, origSize);
        err = PQLoadImage::Qt::errormsg;
    }

    // if returned image is not an error image ...
    if(!ret.isNull()) {

        // ... insert image into cache
        pixmapcache->insert(cachekey, QPixmap::fromImage(ret));

    } else
        return PQLoadImage::ErrorImage::load(err);

    // return scaled version
    if(requestedSize.width() > 2 && requestedSize.height() > 2 && origSize->width() > requestedSize.width() && origSize->height() > requestedSize.height())
        return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // return full version
    return ret;

}

QString PQImageProviderFull::whatDoIUse(QString filename) {

    if(filename.trimmed() == "") return "qt";

    QString useThisFilename = filename;
    QFileInfo info(useThisFilename);

    if(info.suffix().toLower() == "svg" || info.suffix().toLower() == "svgz")
        return "svg";

    if(imageformats->getEnabledFileformatsQt().contains("*." + info.suffix().toLower()))
        return "qt";

    if(imageformats->getEnabledFileformatsXCF().contains("*." + info.suffix().toLower()))
        return "xcftools";

    if(imageformats->getEnabledFileformatsGm().contains("*." + info.suffix().toLower()))
        return "gm";

    return "qt";

}

QByteArray PQImageProviderFull::getUniqueCacheKey(QString path) {
    path = path.remove("image://full/");
    path = path.remove("file:/");
    QFileInfo info(path);
    QString fn = QString("%1%2").arg(path).arg(info.lastModified().toMSecsSinceEpoch());
    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();
}
