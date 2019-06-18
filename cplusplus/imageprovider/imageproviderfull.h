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
#include "../settings/imageformats.h"
#include "../logger.h"

class PQImageProviderFull : public QQuickImageProvider {

public:
    explicit PQImageProviderFull();
    ~PQImageProviderFull();

    QImage requestImage(const QString &filename_encoded, QSize *origSize, const QSize &requestedSize);

private:
    QPixmapCache *pixmapcache;
    PQImageFormats *imageformats;

    QString whatDoIUse(QString filename);

    QByteArray getUniqueCacheKey(QString path);

    int foundExternalUnrar;

};


#endif // IMAGEPROVIDERFULL_H
