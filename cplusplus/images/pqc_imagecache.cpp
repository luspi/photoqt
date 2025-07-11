/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <pqc_imagecache.h>
#include <pqc_settingscpp.h>
#include <pqc_notify.h>

PQCImageCache &PQCImageCache::get() {
    static PQCImageCache instance;
    return instance;
}

PQCImageCache::PQCImageCache(QObject *parent) : QObject(parent) {
    maxcost = PQCSettingsCPP::get().getImageviewCache();
    cache = new QCache<QString,QImage>;
    cache->setMaxCost(maxcost);
    connect(&PQCNotify::get(), &PQCNotify::resetSessionData, this, &PQCImageCache::resetData);
}

PQCImageCache::~PQCImageCache() {
    delete cache;
}

QString PQCImageCache::getUniqueCacheKey(QString filename, QString profileName) {
    return QCryptographicHash::hash(QString("%1%2%3").arg(filename, profileName).arg(QFileInfo(filename).lastModified().toSecsSinceEpoch()).toUtf8(),QCryptographicHash::Md5).toHex();
}

bool PQCImageCache::getCachedImage(QString filename, QString profileName, QImage &img) {

    const QString key = getUniqueCacheKey(filename, profileName);
    if(cache->contains(key)) {
        img = *cache->object(key);
        return true;
    }

    return false;

}

bool PQCImageCache::saveImageToCache(QString filename, QString profileName, QImage *img) {

    // we need to use a copy of the image here as otherwise img will have two owners (BAD idea!)
    QImage *n = new QImage(*img);
    const int s = static_cast<int>(n->sizeInBytes()/(1024.0*1024.0));
    return cache->insert(getUniqueCacheKey(filename, profileName), n, qMin(maxcost, qMax(1,s)));

}

void PQCImageCache::resetData() {
    qDebug() << "";
    cache->clear();
    delete cache;
    cache = new QCache<QString,QImage>;
    cache->setMaxCost(maxcost);
}
