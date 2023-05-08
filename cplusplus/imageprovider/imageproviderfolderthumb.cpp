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

#include "imageproviderfolderthumb.h"
#include <QPainter>
#include <QImage>
#include "../settings/imageformats.h"
#include "../settings/settings.h"
#include "./imageproviderthumb.h"

QQuickImageResponse *PQAsyncImageProviderFolderThumb::requestImageResponse(const QString &url, const QSize &requestedSize) {

    DBG << CURDATE << "PQAsyncImageProviderThumb::requestImageResponse()" << NL
        << CURDATE << "** url = " << url.toStdString() << NL;

    PQAsyncImageResponseFolderThumb *response = new PQAsyncImageResponseFolderThumb(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    QThreadPool::globalInstance()->setMaxThreadCount(qMax(1,PQSettings::get()["thumbnailsMaxNumberThreads"].toInt()));
    pool.start(response);
    return response;
}

PQAsyncImageResponseFolderThumb::PQAsyncImageResponseFolderThumb(const QString &url, const QSize &requestedSize) {

    m_requestedSize = requestedSize;

    if(m_requestedSize == QSize(-1,-1)) {
        m_requestedSize.setWidth(256);
        m_requestedSize.setHeight(256);
    }
    m_index = url.split(":://::")[1].toInt();
    m_folder = url.split(":://::")[0];

    setAutoDelete(false);

}

PQAsyncImageResponseFolderThumb::~PQAsyncImageResponseFolderThumb() {
}

QQuickTextureFactory *PQAsyncImageResponseFolderThumb::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQAsyncImageResponseFolderThumb::run() {

    DBG << CURDATE << "PQAsyncImageResponseFolderThumb::run() " << NL;

    if(m_index == 0) {
        m_image = QImage(QSize(1,1), QImage::Format_ARGB32);
        Q_EMIT finished();
        return;
    }


    // get folder contents
    QString fname;
    int count;

    // we cache fileinfo lists to speed up subsequent lodings
    QFileInfoList fileinfolist;
    const int checknum = PQImageFormats::get().getEnabledFormatsNum();
    if(!PQAsyncImageResponseFolderThumbCache::get().loadFromCache(m_folder, checknum, fileinfolist)) {

        QDir dir(m_folder);

        QStringList checkForTheseFormats;
        const QStringList lst = PQImageFormats::get().getEnabledFormats();
        for(const QString &c : lst)
            checkForTheseFormats << QString("*.%1").arg(c);

        dir.setNameFilters(checkForTheseFormats);
        dir.setFilter(QDir::Files);

        count = dir.count();
        fileinfolist = dir.entryInfoList();

        QCollator collator;
        collator.setNumericMode(true);
        std::sort(fileinfolist.begin(), fileinfolist.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });


        PQAsyncImageResponseFolderThumbCache::get().saveToCache(m_folder, checknum, fileinfolist);

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
    PQAsyncImageResponseThumb loader(fname,m_requestedSize);
    loader.loadImage();
    QImage thumb = loader.m_image;

    // scale to right size
    if(PQSettings::get()["openfileFolderContentThumbnailsScaleCrop"].toBool()) {
        thumb = thumb.scaled(m_requestedSize, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
        const int xoff = (thumb.width()-m_requestedSize.width())/2;
        const int yoff = (thumb.height()-m_requestedSize.height())/2;
        m_image = thumb.copy(xoff, yoff, m_requestedSize.width(), m_requestedSize.height());
    } else
        m_image = thumb;

    Q_EMIT finished();

}
