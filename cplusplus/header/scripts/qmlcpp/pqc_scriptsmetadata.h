/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

/*************************************************************/
/*************************************************************/
//
// this class is used in both C++ and QML code
// thus there is a WRAPPER for QML available
//
/*************************************************************/
/*************************************************************/

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
    QPointF convertGPSToPoint(QString gps);

    /***************************************************************/
    // only the following will be called from QML (through wrapper)

    int getExifOrientation(QString path);

    QString convertGPSToDecimalForOpenStreetMap(QString gps);
    QString convertGPSDecimalToDegree(double lat, double lon);

    bool areFaceTagsSupported(QString filename);
    QVariantList getFaceTags(QString filename);
    void setFaceTags(QString filename, QVariantList tags);

private:
    PQCScriptsMetaData();

};

#endif
