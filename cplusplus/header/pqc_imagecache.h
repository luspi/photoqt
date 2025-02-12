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

#ifndef PQCIMAGECACHE_H
#define PQCIMAGECACHE_H

#include <QObject>

class PQCImageCache : public QObject {

public:
    static PQCImageCache& get();

    PQCImageCache(PQCImageCache const&)     = delete;
    void operator=(PQCImageCache const&) = delete;

    QString getUniqueCacheKey(QString filename, QString profileName);
    bool getCachedImage(QString filename, QString profileName, QImage &img);
    bool saveImageToCache(QString filename, QString profileName, QImage *img);

private:
    PQCImageCache(QObject *parent = nullptr);
    ~PQCImageCache();

    QCache<QString,QImage> *cache;
    int maxcost;

private Q_SLOTS:
    void resetData();

};

#endif // PQIMAGELOADERHELPER_H
