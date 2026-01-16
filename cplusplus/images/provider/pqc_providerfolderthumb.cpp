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

#include <pqc_providerfolderthumb.h>
#include <pqc_providerthumb.h>
#include <pqc_settingscpp.h>
#include <pqc_imageformats.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <QPainter>
#include <QImage>
#include <QCollator>

QQuickImageResponse *PQCAsyncImageProviderFolderThumb::requestImageResponse(const QString &url, const QSize &requestedSize) {

    PQCAsyncImageResponseFolderThumb *response = new PQCAsyncImageResponseFolderThumb(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    QThreadPool::globalInstance()->setMaxThreadCount(qMax(1,PQCSettingsCPP::get().getThumbnailsMaxNumberThreads()));
    pool.start(response);
    return response;
}

/***********************************************************/

PQCAsyncImageResponseFolderThumbCache& PQCAsyncImageResponseFolderThumbCache::get() {
    static PQCAsyncImageResponseFolderThumbCache instance;
    return instance;
}
PQCAsyncImageResponseFolderThumbCache::PQCAsyncImageResponseFolderThumbCache() {
    cache.clear();
}
bool PQCAsyncImageResponseFolderThumbCache::loadFromCache(QString foldername, int numEnabledFormats, QFileInfoList &entries) {
    QString key = QString("%1::%2::%3").arg(foldername).arg(numEnabledFormats).arg(QFileInfo(foldername).lastModified().toMSecsSinceEpoch());
    if(cache.contains(key)) {
        entries = cache.value(key);
        return true;
    }
    return false;
}
void PQCAsyncImageResponseFolderThumbCache::saveToCache(QString foldername, int numEnabledFormats, QFileInfoList &entries) {
    QString key = QString("%1::%2::%3").arg(foldername).arg(numEnabledFormats).arg(QFileInfo(foldername).lastModified().toMSecsSinceEpoch());
    cache.insert(key, entries);
}

/***********************************************************/

PQCAsyncImageResponseFolderThumb::PQCAsyncImageResponseFolderThumb(const QString &url, const QSize &requestedSize) {

    m_requestedSize = requestedSize;
    m_index = url.split(":://::")[1].toInt();
    m_folder = url.split(":://::")[0];

    setAutoDelete(false);

}

PQCAsyncImageResponseFolderThumb::~PQCAsyncImageResponseFolderThumb() {
}

QQuickTextureFactory *PQCAsyncImageResponseFolderThumb::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQCAsyncImageResponseFolderThumb::run() {

    if(m_index == 0 || PQCScriptsFilesPaths::get().isExcludeDirFromCaching(m_folder)) {
        m_image = QImage(QSize(1,1), QImage::Format_ARGB32);
        Q_EMIT finished();
        return;
    }

    // get folder contents
    QString fname;
    int count;

    // we cache fileinfo lists to speed up subsequent lodings
    QFileInfoList fileinfolist;
    const int checknum = PQCImageFormats::get().getEnabledFormatsNum();
    if(!PQCAsyncImageResponseFolderThumbCache::get().loadFromCache(m_folder, checknum, fileinfolist)) {

        QDir dir(m_folder);

        QStringList checkForTheseFormats;
        const QStringList lst = PQCImageFormats::get().getEnabledFormats();
        for(const QString &c : lst)
            checkForTheseFormats << QString("*.%1").arg(c);

        dir.setNameFilters(checkForTheseFormats);
        dir.setFilter(QDir::Files);

        count = dir.count();
        fileinfolist = dir.entryInfoList();

        QCollator collator;
#ifndef PQMWITHOUTICU
        collator.setNumericMode(true);
#endif
        std::sort(fileinfolist.begin(), fileinfolist.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });

        PQCAsyncImageResponseFolderThumbCache::get().saveToCache(m_folder, checknum, fileinfolist);

    } else
        count = fileinfolist.length();

    // no images inside folder
    if(count == 0) {
        m_image = QImage(QSize(1,1), QImage::Format_ARGB32);
        Q_EMIT finished();
        return;
    }

    // get current image filename
    fname = fileinfolist[(m_index-1)%count].absoluteFilePath();

    // load thumbnail
    PQCAsyncImageResponseThumb loader(fname,m_requestedSize);
    loader.loadImage();
    m_image = loader.m_image;

    Q_EMIT finished();

}
