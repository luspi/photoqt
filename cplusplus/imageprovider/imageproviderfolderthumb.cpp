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

    QDir dir(m_folder);

    QStringList checkForTheseFormats;
    const QStringList lst = PQImageFormats::get().getEnabledFormats();
    for(const QString &c : lst)
        checkForTheseFormats << QString("*.%1").arg(c);

    dir.setNameFilters(checkForTheseFormats);
    dir.setFilter(QDir::Files);

    int count = dir.count();

    // no images inside folder
    if(count == 0) {
        m_image = QImage(QSize(1,1), QImage::Format_ARGB32);
        Q_EMIT finished();
        return;
    }

    // get current image filename
    QString fname = dir.entryInfoList()[(m_index-1)%count].absoluteFilePath();

    // load thumbnail
    PQAsyncImageResponseThumb loader(fname,m_requestedSize);
    loader.loadImage();
    QImage thumb = loader.m_image;

    // scale to right size
    thumb = thumb.scaled(m_requestedSize, Qt::KeepAspectRatioByExpanding);

    // get folder image to be used as 'masking' image
    QIcon ico = QIcon::fromTheme("folder");
    QImage mask = QImage(ico.pixmap(m_requestedSize).toImage());
    if(mask.isNull())
        mask = QIcon(QString(":/filedialog/backupicons/folder.svg")).pixmap(m_requestedSize).toImage();

    // prepare return image
    m_image = QImage(mask.size(), QImage::Format_ARGB32);
    m_image.fill(Qt::transparent);

    // a small border will be shown around thumbnail images of this size
    int border = 4;

    // Loop over all rows
    for(int i = 0; i < mask.height(); ++i) {

        // Get the pixel data of row i of the image
        QRgb *rowData = (QRgb*)mask.scanLine(i);

        // Loop over all columns
        for(int j = 0; j < mask.width(); ++j) {

            // Get pixel data of pixel at column j in row i
            QRgb pixelData = rowData[j];

            // If there is something in this pixel, se thumbnail value
            if(qAlpha(pixelData) != 0) {
                m_image.setPixelColor(j,i,thumb.pixelColor(j, i));

            // otherwise we check if we are within some margin around thumbnail
            } else {

                int istart = qMax(0,i-border);
                int iend = qMin(mask.height()-1,i+border);
                int jstart = qMax(0,j-border);
                int jend = qMin(mask.width()-1,j+border);

                bool set = false;

                for(int ii = istart; ii < iend; ++ii) {
                    QRgb *rowData = (QRgb*)mask.scanLine(ii);
                    for(int jj = jstart; jj < jend; ++jj) {
                        QRgb pixelData = rowData[jj];
                        //
                        if(qAlpha(pixelData) != 0) {
                            set = true;
                            break;
                        }
                    }
                    if(set)
                        break;
                }

                // inside border, set border color
                if(set)
                    m_image.setPixelColor(j,i,Qt::white);
            }
        }

    }

    Q_EMIT finished();

}
