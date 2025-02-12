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
#ifndef PQCASYNCIMAGEPROVIDERTOOLTIPTHUMB_H
#define PQCASYNCIMAGEPROVIDERTOOLTIPTHUMB_H

#include <QQuickAsyncImageProvider>
#include <QThreadPool>
#include <QMimeDatabase>

class PQCAsyncImageResponseThumb;

class PQCAsyncImageProviderTooltipThumb : public QQuickAsyncImageProvider {

public:
    QQuickImageResponse *requestImageResponse(const QString &url, const QSize &requestedSize) override;

private:
    QThreadPool pool;
};

class PQCAsyncImageResponseTooltipThumb : public QQuickImageResponse, public QRunnable {

public:
    PQCAsyncImageResponseTooltipThumb(const QString &url, const QSize &requestedSize);
    ~PQCAsyncImageResponseTooltipThumb();

    QQuickTextureFactory *textureFactory() const override;

    void run() override;
    void loadImage();

    QString m_url;
    QSize m_requestedSize;
    QImage m_image;

    QMimeDatabase mimedb;

private:
    PQCAsyncImageResponseThumb *loader;

};

#endif // PQCASYNCIMAGEPROVIDERTOOLTIPTHUMB_H
