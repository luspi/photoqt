/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#pragma once

#include <QObject>
#include <QQmlEngine>
#include <scripts/pqc_scriptsmetadata.h>

class PQCScriptsMetaDataQML : public QObject {

    Q_OBJECT
    QML_NAMED_ELEMENT(PQCScriptsMetaData)
    QML_SINGLETON

public:
    PQCScriptsMetaDataQML() {}
    ~PQCScriptsMetaDataQML() {}

    Q_INVOKABLE int getExifOrientation(QString path) { return PQCScriptsMetaData::get().getExifOrientation(path); }

    Q_INVOKABLE QString convertGPSToDecimalForOpenStreetMap(QString gps)  { return PQCScriptsMetaData::get().convertGPSToDecimalForOpenStreetMap(gps); }
    Q_INVOKABLE QString convertGPSDecimalToDegree(double lat, double lon) { return PQCScriptsMetaData::get().convertGPSDecimalToDegree(lat, lon); }

    Q_INVOKABLE bool areFaceTagsSupported(QString filename)           { return PQCScriptsMetaData::get().areFaceTagsSupported(filename); }
    Q_INVOKABLE QVariantList getFaceTags(QString filename)            { return PQCScriptsMetaData::get().getFaceTags(filename); }
    Q_INVOKABLE void setFaceTags(QString filename, QVariantList tags) { return PQCScriptsMetaData::get().setFaceTags(filename, tags); }

};
