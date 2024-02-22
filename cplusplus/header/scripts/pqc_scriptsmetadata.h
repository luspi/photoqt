/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#ifndef PQCSCRIPTSMETADATA_H
#define PQCSCRIPTSMETADATA_H

#include <QObject>

class PQCScriptsMetaData : public QObject {

    Q_OBJECT

public:
    static PQCScriptsMetaData& get() {
        static PQCScriptsMetaData instance;
        return instance;
    }
    ~PQCScriptsMetaData();

    PQCScriptsMetaData(PQCScriptsMetaData const&)     = delete;
    void operator=(PQCScriptsMetaData const&) = delete;

    QString analyzeDateTimeOriginal(const QString val);
    QString analyzeExposureTime(const QString val);
    QString analyzeFlash(const QString val);
    QString analyzeSceneCaptureType(const QString val);
    QString analyzeFocalLength(const QString val);
    QString analyzeFNumber(const QString val);
    QString analyzeLightSource(const QString val);
    QString analyzeGPS(QString latRef, QString lat, QString lonRef, QString lon);
    QPointF convertGPSToDecimal(QString gpsLatRef, QString gpsLat, QString gpsLonRef, QString gpsLon);

    Q_INVOKABLE int getExifOrientation(QString path);

    Q_INVOKABLE QString convertGPSToDecimalForOpenStreetMap(QString gps);
    Q_INVOKABLE QPointF convertGPSToPoint(QString gps);

    Q_INVOKABLE QVariantList getFaceTags(QString filename);
    Q_INVOKABLE void setFaceTags(QString filename, QVariantList tags);

private:
    PQCScriptsMetaData();

};

#endif
