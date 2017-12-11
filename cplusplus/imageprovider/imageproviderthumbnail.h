/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef IMAGEPROVIDERTHUMBS_H
#define IMAGEPROVIDERTHUMBS_H

#include <QQuickImageProvider>
#include <QtSql/QtSql>
#include <QPainter>
#include <QTextDocument>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include "../settings/settings.h"

#include "imageproviderfull.h"

class ImageProviderThumbnail : public QQuickImageProvider {

public:
    explicit ImageProviderThumbnail();
    ~ImageProviderThumbnail();

    QImage requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize);

private:
    QSqlDatabase db;
    Settings *settings;

    ImageProviderFull *imageproviderfull;

    QImage getThumbnailImage(QByteArray filename);

    bool dbTransactionStarted;
    bool dontCreateThumbnailNew;

    QHash<QString,QSize> allSizes;

    int origwidth;
    int origheight;

};

#endif // IMAGEPROVIDERTHUMBS_H
