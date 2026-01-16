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

#include <pqc_providermipmap.h>
#include <pqc_settingscpp.h>
#include <pqc_configfiles.h>
#include <pqc_loadimage.h>
#include <pqc_providerthumb.h>
#include <QPainter>

QQuickImageResponse *PQCAsyncImageProviderMipMap::requestImageResponse(const QString &url, const QSize &requestedSize) {

    PQCAsyncImageResponseMipMap *response = new PQCAsyncImageResponseMipMap(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    QThreadPool::globalInstance()->setMaxThreadCount(qMax(1,PQCSettingsCPP::get().getThumbnailsMaxNumberThreads()));
    pool.start(response);
    return response;
}

PQCAsyncImageResponseMipMap::PQCAsyncImageResponseMipMap(const QString &url, const QSize &requestedSize) : m_requestedSize(requestedSize) {
    m_url = url;
    setAutoDelete(false);
    loader = new PQCAsyncImageResponseThumb(url, requestedSize);
}

PQCAsyncImageResponseMipMap::~PQCAsyncImageResponseMipMap() {
    delete loader;
}

QQuickTextureFactory *PQCAsyncImageResponseMipMap::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQCAsyncImageResponseMipMap::run() {
    loadImage();
}

void PQCAsyncImageResponseMipMap::loadImage() {

    qDebug() << "";

    loader->loadImage();
    m_image = loader->m_image.scaled(m_requestedSize, Qt::KeepAspectRatio);

    // aaaaand done!
    Q_EMIT finished();

}
