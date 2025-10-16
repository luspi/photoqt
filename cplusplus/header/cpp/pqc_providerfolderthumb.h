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
#ifndef PQCASYNCIMAGEPROVIDERFOLDERTHUMB_H
#define PQCASYNCIMAGEPROVIDERFOLDERTHUMB_H

#include <QQuickAsyncImageProvider>
#include <QThreadPool>
#include <QFileInfoList>

/*****************************************************/
/*****************************************************/
class PQCAsyncImageProviderFolderThumb : public QQuickAsyncImageProvider {

public:
    QQuickImageResponse *requestImageResponse(const QString &url, const QSize &requestedSize) override;

private:
    QThreadPool pool;
};

/*****************************************************/
/*****************************************************/
class PQCAsyncImageResponseFolderThumbCache : public QObject {

    Q_OBJECT

public:
    static PQCAsyncImageResponseFolderThumbCache& get();

    PQCAsyncImageResponseFolderThumbCache(PQCAsyncImageResponseFolderThumbCache const&)     = delete;
    void operator=(PQCAsyncImageResponseFolderThumbCache const&) = delete;

    bool loadFromCache(QString foldername, int numEnabledFormats, QFileInfoList &entries);
    void saveToCache(QString foldername, int numEnabledFormats, QFileInfoList &entries);

private:
    PQCAsyncImageResponseFolderThumbCache();
    QHash<QString,QFileInfoList> cache;

};

/*****************************************************/
/*****************************************************/
class PQCAsyncImageResponseFolderThumb : public QQuickImageResponse, public QRunnable {

public:
    PQCAsyncImageResponseFolderThumb(const QString &url, const QSize &requestedSize);
    ~PQCAsyncImageResponseFolderThumb();

    QQuickTextureFactory *textureFactory() const override;

    void run() override;

    QString m_url;
    QString m_folder;
    int m_index;
    QSize m_requestedSize;
    QImage m_image;

};

#endif // PQASYNCIMAGEPROVIDERFOLDERTHUMB_H
