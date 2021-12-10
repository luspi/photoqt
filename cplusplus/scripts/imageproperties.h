/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef PQIMAGEPROPERTIES_H
#define PQIMAGEPROPERTIES_H

#include <QObject>
#include <QImageReader>
#include <QUrl>
#include "../logger.h"
#include "../settings/imageformats.h"

#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

class PQImageProperties : public QObject {

    Q_OBJECT

public:
    explicit PQImageProperties(QObject *parent = nullptr);

    Q_INVOKABLE bool isAnimated(QString path);
    Q_INVOKABLE bool isPopplerDocument(QString path);
    Q_INVOKABLE bool isArchive(QString path);
    Q_INVOKABLE bool isVideo(QString path);
    Q_INVOKABLE int getDocumentPages(QString path);

};

#endif // PQIMAGEPROPERTIES_H
