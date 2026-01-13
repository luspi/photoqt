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
#ifndef PQCASYNCIMAGEPROVIDERDRAGTHUMB_H
#define PQCASYNCIMAGEPROVIDERDRAGTHUMB_H

#include <QQuickAsyncImageProvider>
#include <QThreadPool>
#include <QFileInfoList>

/*****************************************************/
/*****************************************************/
class PQCAsyncImageProviderDragThumb : public QQuickAsyncImageProvider {

public:
    QQuickImageResponse *requestImageResponse(const QString &url, const QSize &requestedSize) override;

private:
    QThreadPool pool;
};

/*****************************************************/
/*****************************************************/
class PQCAsyncImageResponseDragThumb : public QQuickImageResponse, public QRunnable {

public:
    PQCAsyncImageResponseDragThumb(const QString &url, const QSize &requestedSize);
    ~PQCAsyncImageResponseDragThumb();

    QQuickTextureFactory *textureFactory() const override;

    void run() override;

    QString m_path;
    int m_howmany;
    QImage m_image;

};

#endif // PQCASYNCIMAGEPROVIDERDRAGTHUMB_H
