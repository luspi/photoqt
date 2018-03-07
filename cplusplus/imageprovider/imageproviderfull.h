/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#ifndef IMAGEPROVIDERFULL_H
#define IMAGEPROVIDERFULL_H

#include <QQuickImageProvider>
#include <QFileInfo>
#include <QtSvg/QtSvg>
#include "pixmapcache.h"
#include "../settings/imageformats.h"
#include "../settings/slimsettingsreadonly.h"
#include "../logger.h"


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
    QSize maxSize;
    SlimSettingsReadOnly *settings;
    ImageFormats *imageformats;

    QCache<QByteArray,QImage> *pixmapcache;


    QString whatDoIUse(QString filename);

#ifdef GM
    GmImageMagick imagemagick;
#endif

    QByteArray getUniqueCacheKey(QString path);

};


#endif // IMAGEPROVIDERFULL_H
