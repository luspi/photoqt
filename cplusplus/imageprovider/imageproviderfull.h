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

#ifndef IMAGEPROVIDERFULL_H
#define IMAGEPROVIDERFULL_H

#include <QQuickImageProvider>
#include <QFileInfo>
#include <QtSvg/QtSvg>
#include "pixmapcache.h"
#include "../settings/fileformats.h"
#include "../settings/settings.h"
#include "../logger.h"

#include "loader/loadimage_qt.h"
#include "loader/loadimage_gm.h"
#include "loader/loadimage_xcf.h"
#include "loader/loadimage_raw.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#include "../scripts/gmimagemagick.h"
#endif

class ImageProviderFull : public QQuickImageProvider {

public:
    explicit ImageProviderFull();
    ~ImageProviderFull();

    QImage requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize);

private:
    bool verbose;

    QSize maxSize;
    Settings *settings;
    FileFormats *fileformats;

    QString qtfiles;
    QString gmfiles;
    QString extrasfiles;
    QString rawfiles;

    LoadImageGM *loaderGM;
    LoadImageQt *loaderQT;
    LoadImageRaw *loaderRAW;
    LoadImageXCF *loaderXCF;

    QCache<QByteArray,QPixmap> *pixmapcache;


    QString whatDoIUse(QString filename);

#ifdef GM
    GmImageMagick imagemagick;
#endif

    QByteArray getUniqueCacheKey(QString path);

};


#endif // IMAGEPROVIDERFULL_H
