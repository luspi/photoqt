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

#include <cpp/pqc_providerimgurhistory.h>
// TODO!!!
// #include <scripts/qmlcpp/pqc_scriptsshareimgur.h>

QQuickImageResponse *PQCAsyncImageProviderImgurHistory::requestImageResponse(const QString &url, const QSize &requestedSize) {

    PQCAsyncImageResponseImgurHistory *response = new PQCAsyncImageResponseImgurHistory(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    pool.start(response);
    return response;

}

PQCAsyncImageResponseImgurHistory::PQCAsyncImageResponseImgurHistory(const QString &url, const QSize &requestedSize) {
    m_url = url;
    m_requestedSize = requestedSize;
    setAutoDelete(false);
}

PQCAsyncImageResponseImgurHistory::~PQCAsyncImageResponseImgurHistory() {}

QQuickTextureFactory *PQCAsyncImageResponseImgurHistory::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQCAsyncImageResponseImgurHistory::run() {

    // TODO!!!
    // m_image = PQCScriptsShareImgur::get().getPastUploadThumbnail(m_url);

    Q_EMIT finished();

}
