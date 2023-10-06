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

#ifndef PQIMAGEPROPERTIES_H
#define PQIMAGEPROPERTIES_H

#include <QtGlobal>

#ifdef Q_OS_WIN
#undef WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#endif

#include <QObject>
#include <QImageReader>
#include <QUrl>
#include "../logger.h"
#include "../settings/imageformats.h"
#include "../imageprovider/loadimage.h"
#include "handlingfiledir.h"

#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif
#ifdef QTPDF
#include <QtPdf>
#endif

class PQImageProperties : public QObject {

    Q_OBJECT

public:
    explicit PQImageProperties(QObject *parent = nullptr);
    ~PQImageProperties();

    Q_INVOKABLE bool isAnimated(QString path);
    Q_INVOKABLE bool isPDFDocument(QString path);
    Q_INVOKABLE bool isArchive(QString path);
    Q_INVOKABLE bool isVideo(QString path);
    Q_INVOKABLE int getDocumentPages(QString path);
    Q_INVOKABLE QSize getImageResolution(QString path);

private:
    PQLoadImage *loader;
    PQHandlingFileDir handlingFileDir;

};

#endif // PQIMAGEPROPERTIES_H
