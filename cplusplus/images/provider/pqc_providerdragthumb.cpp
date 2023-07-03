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

#include <pqc_providerdragthumb.h>
#include <pqc_providerthumb.h>
#include <pqc_providericon.h>
#include <pqc_settings.h>
#include <pqc_imageformats.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <QPainter>
#include <QImage>

QQuickImageResponse *PQCAsyncImageProviderDragThumb::requestImageResponse(const QString &url, const QSize &requestedSize) {

    PQCAsyncImageResponseDragThumb *response = new PQCAsyncImageResponseDragThumb(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    QThreadPool::globalInstance()->setMaxThreadCount(qMax(1,PQCSettings::get()["thumbnailsMaxNumberThreads"].toInt()));
    pool.start(response);
    return response;
}

/***********************************************************/

PQCAsyncImageResponseDragThumb::PQCAsyncImageResponseDragThumb(const QString &url, const QSize &requestedSize) {
    m_path = url;
    setAutoDelete(false);
}

PQCAsyncImageResponseDragThumb::~PQCAsyncImageResponseDragThumb() {
}

QQuickTextureFactory *PQCAsyncImageResponseDragThumb::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQCAsyncImageResponseDragThumb::run() {

    qDebug() << "m_path =" << m_path;

    if(QFileInfo(m_path).isDir()) {

        PQCProviderIcon provider;
        m_image = provider.requestImage("folder_listicon", new QSize, QSize(128,128));

    } else if(PQCScriptsFilesPaths::get().isExcludeDirFromCaching(m_path)) {

        PQCProviderIcon provider;
        m_image = provider.requestImage(m_path, new QSize, QSize(128,128));

    } else {

        PQCAsyncImageResponseThumb loader(m_path, QSize(128,128));
        loader.loadImage();
        m_image = loader.m_image;

    }

    Q_EMIT finished();

}
