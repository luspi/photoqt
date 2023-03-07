/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "imageproviderfull.h"
#include "../settings/settings.h"

PQImageProviderFull::PQImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

    foundExternalUnrar = -1;

    loader = new PQLoadImage;
    load_err = new PQLoadImageErrorImage;

}

PQImageProviderFull::~PQImageProviderFull() {
    delete loader;
    delete load_err;
}

QImage PQImageProviderFull::requestImage(const QString &filename_encoded, QSize *origSize, const QSize &requestedSize) {

    DBG << CURDATE << "PQImageProviderFull::requestImage()" << NL
        << CURDATE << "** filename = " << filename_encoded.toStdString() << NL
        << CURDATE << "** requestedSize = " << requestedSize.width() << "x" << requestedSize.height() << NL;

    QString full_filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());
#ifdef Q_OS_WIN
    // It is not always clear whether the file url prefix comes with two or three slashes
    // This makes sure that in Windows the file always starts with something like C:/path and not /C:/path
    // If the filename starts with two slashes, then it likely is a network location and we need to leave the slashes untouched.
    if(!full_filename.startsWith("//")) {
        while(full_filename.startsWith("/"))
            full_filename = full_filename.remove(0,1);
    }
#endif
    QString filename = full_filename;

    QString filenameForChecking = filename;
    if(filenameForChecking.contains("::PQT::"))
        filenameForChecking = filenameForChecking.split("::PQT::").at(1);
    if(filenameForChecking.contains("::ARC::"))
        filenameForChecking = filenameForChecking.split("::ARC::").at(1);

    if(!QFileInfo::exists(filenameForChecking)) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it does not exist!");
        LOG << CURDATE << "PQImageProviderFull: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "PQImageProviderFull: Filename: " << filenameForChecking.toStdString() << NL;
        return load_err->load(err);
    }

    // Load image
    QImage ret;
    QString err = loader->load(filename, requestedSize, *origSize, ret);

    // if returned image is not an error image ...
    if(ret.isNull())
        ret = load_err->load(err);

    // return scaled version
    if(requestedSize.width() > 2 && requestedSize.height() > 2 && origSize->width() > requestedSize.width() && origSize->height() > requestedSize.height())
        return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // return full version
    return ret;

}

QByteArray PQImageProviderFull::getUniqueCacheKey(QString path) {

    DBG << CURDATE << "PQImageProviderFull::getUniqueCacheKey() " << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    path = path.remove("image://full/");
    path = path.remove("file:///");

    QFileInfo info(path);
    QString fn = QString("%1%2").arg(path).arg(info.lastModified().toMSecsSinceEpoch());

    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();

}
