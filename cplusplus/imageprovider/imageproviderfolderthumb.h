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
#ifndef PQASYNCIMAGEPROVIDERFOLDERTHUMB_H
#define PQASYNCIMAGEPROVIDERFOLDERTHUMB_H

#include <QQuickAsyncImageProvider>
#include <QThreadPool>
#include <QMimeDatabase>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QDateTime>

/*****************************************************/
/*****************************************************/
class PQAsyncImageProviderFolderThumb : public QQuickAsyncImageProvider {

public:
    QQuickImageResponse *requestImageResponse(const QString &url, const QSize &requestedSize) override;

private:
    QThreadPool pool;
};

/*****************************************************/
/*****************************************************/
class PQAsyncImageResponseFolderThumbCache : public QObject {

    Q_OBJECT

public:
    static PQAsyncImageResponseFolderThumbCache& get() {
        static PQAsyncImageResponseFolderThumbCache instance;
        return instance;
    }
    ~PQAsyncImageResponseFolderThumbCache() {

    }

    PQAsyncImageResponseFolderThumbCache(PQAsyncImageResponseFolderThumbCache const&)     = delete;
    void operator=(PQAsyncImageResponseFolderThumbCache const&) = delete;

    bool loadFromCache(QString foldername, int numEnabledFormats, QFileInfoList &entries) {
        QString key = QString("%1::%2::%3").arg(foldername).arg(numEnabledFormats).arg(QFileInfo(foldername).lastModified().toMSecsSinceEpoch());
        if(cache.contains(key)) {
            entries = cache.value(key);
            return true;
        }
        return false;
    }
    void saveToCache(QString foldername, int numEnabledFormats, QFileInfoList &entries) {
        QString key = QString("%1::%2::%3").arg(foldername).arg(numEnabledFormats).arg(QFileInfo(foldername).lastModified().toMSecsSinceEpoch());
        cache.insert(key, entries);
    }

private:
    PQAsyncImageResponseFolderThumbCache() {
        cache.clear();
    }
    QHash<QString,QFileInfoList> cache;

};

/*****************************************************/
/*****************************************************/
class PQAsyncImageResponseFolderThumb : public QQuickImageResponse, public QRunnable {

public:
    PQAsyncImageResponseFolderThumb(const QString &url, const QSize &requestedSize);
    ~PQAsyncImageResponseFolderThumb();

    QQuickTextureFactory *textureFactory() const override;

    void run() override;

    QString m_url;
    QString m_folder;
    int m_index;
    QSize m_requestedSize;
    QImage m_image;

};

#endif // PQASYNCIMAGEPROVIDERFOLDERTHUMB_H
