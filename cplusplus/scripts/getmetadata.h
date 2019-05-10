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

#ifndef GETMETADATA_H
#define GETMETADATA_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QVariantMap>
#include <QUrl>
#include <QImageReader>

#include "../settings/slimsettingsreadonly.h"
#include "../logger.h"

#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

class GetMetaData : public QObject {

    Q_OBJECT

public:
    explicit GetMetaData(QObject *parent = 0);
    ~GetMetaData();

    Q_INVOKABLE QVariantMap getExiv2(QString path);

    QString exifExposureTime(QString value);
    QString exifFNumberFLength(QString value);
    QString exifPhotoTaken(QString value);

    QString exifLightSource(QString value);
    QString exifFlash(QString value);
    QString exifSceneType(QString value);

    QStringList exifGps(QString gpsLonRef, QString gpsLon, QString gpsLatRef, QString gpsLat);

private:
    SlimSettingsReadOnly *settings;

};


#endif // GETMETADATA_H
