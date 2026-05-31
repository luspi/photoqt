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

#include <QCache>
#include <QFileInfo>
#include <QImage>
#include <pqc_imagecache.h>
#include <pqc_settingscpp.h>
#include <pqc_notify_cpp.h>

PQCImageCache &PQCImageCache::get() {
    static PQCImageCache instance;
    return instance;
}

PQCImageCache::PQCImageCache(QObject *parent) : QObject(parent) {
    maxcost = PQCSettingsCPP::get().getImageviewCache();
    cache = new QCache<size_t,QImage>;
    cache->setMaxCost(maxcost);
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::resetSessionData, this, &PQCImageCache::resetData);
}

PQCImageCache::~PQCImageCache() {
    delete cache;
}

size_t PQCImageCache::getUniqueCacheKey(QString filename, QString profileName) {
    return qHashMulti(QFileInfo(filename).lastModified().toSecsSinceEpoch(), filename, profileName);
}

bool PQCImageCache::getCachedImage(QString filename, QString profileName, QImage &img) {

    const size_t key = getUniqueCacheKey(filename, profileName);
    QImage *tmp = cache->object(key);
    if(tmp != nullptr) {
        img = *tmp;
        return true;
    }

    return false;

}

bool PQCImageCache::saveImageToCache(QString filename, QString profileName, QImage &img) {

    // 1024*1024 = 1048576
    // removing one in the numerator ensures rounding up
    const int s = static_cast<int>((img.sizeInBytes()+1048575)/(1048576.0));
    return cache->insert(getUniqueCacheKey(filename, profileName), new QImage(img), qMin(maxcost, qMax(1,s)));

}

void PQCImageCache::resetData() {
    qDebug() << "";
    cache->clear();
    delete cache;
    cache = new QCache<size_t,QImage>;
    cache->setMaxCost(maxcost);
}
