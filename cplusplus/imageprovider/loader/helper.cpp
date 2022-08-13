/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "helper.h"

PQLoadImageHelper::PQLoadImageHelper() {
    maxcost = PQSettings::get()["imageviewCache"].toInt();
    cache =  new QCache<QString,QImage>;
    cache->setMaxCost(maxcost);
}

PQLoadImageHelper::~PQLoadImageHelper() {
    delete cache;
}

QString PQLoadImageHelper::getUniqueCacheKey(QString filename) {
    return QCryptographicHash::hash(QString("%1%2").arg(filename).arg(QFileInfo(filename).lastModified().toMSecsSinceEpoch()).toUtf8(),QCryptographicHash::Md5).toHex();
}

bool PQLoadImageHelper::getCachedImage(QString filename, QImage &img) {

    if(cache->contains(getUniqueCacheKey(filename))) {
        img = *cache->object(getUniqueCacheKey(filename));
        return true;
    }

    return false;

}

bool PQLoadImageHelper::saveImageToCache(QString filename, QImage *img) {

    // we need to use a copy of the image here as otherwise img will have two owners (BAD idea!)
    QImage *n = new QImage(*img);
#if QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    const int s = static_cast<int>(n->sizeInBytes()/(1024.0*1024.0));
#else
    const int s = static_cast<int>(n->byteCount()/(1024.0*1024.0));
#endif
    return cache->insert(getUniqueCacheKey(filename), n, qMin(maxcost, qMax(1,s)));

}

bool PQLoadImageHelper::ensureImageFitsMaxSize(QImage &img, QSize maxSize) {

    if(maxSize.width() < 3 || maxSize.height() < 3)
        return false;

    if(img.width() > maxSize.width() || img.height() > maxSize.height()) {
        img = img.scaled(maxSize.width(), maxSize.height(), ::Qt::KeepAspectRatio, ::Qt::SmoothTransformation);
        return true;
    }

    return false;

}
