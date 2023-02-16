/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
#ifndef PQASYNCIMAGEPROVIDERTHUMB_H
#define PQASYNCIMAGEPROVIDERTHUMB_H

#include <QQuickAsyncImageProvider>
#include <QThreadPool>
#include <QMimeDatabase>
#include <QCryptographicHash>
#include "../settings/imageformats.h"
#include "loadimage.h"

class PQAsyncImageProviderThumb : public QQuickAsyncImageProvider {

public:
    QQuickImageResponse *requestImageResponse(const QString &url, const QSize &requestedSize) override;

private:
    QThreadPool pool;
};

class PQAsyncImageResponseThumb : public QQuickImageResponse, public QRunnable {

public:
    PQAsyncImageResponseThumb(const QString &url, const QSize &requestedSize);
    ~PQAsyncImageResponseThumb();

    QQuickTextureFactory *textureFactory() const override;

    void run() override;

    QString m_url;
    bool m_fixedSize;
    QSize m_requestedSize;
    QImage m_image;

private:
    QMimeDatabase mimedb;

    int foundExternalUnrar;

    QString whatDoIUse(QString filename);

    PQLoadImage *loader;
    PQLoadImageErrorImage *load_err;

};

#endif // PQASYNCIMAGEPROVIDERTHUMB_H
