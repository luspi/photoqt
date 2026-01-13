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
#include <scripts/pqc_scriptscolorprofiles.h>

class QFile;

class PQCScriptsColorProfilesQML : public QObject {

    Q_OBJECT
    QML_NAMED_ELEMENT(PQCScriptsColorProfiles)
    QML_SINGLETON

public:
    PQCScriptsColorProfilesQML() {}
    ~PQCScriptsColorProfilesQML() {}

    Q_INVOKABLE QStringList getImportedColorProfiles()               { return PQCScriptsColorProfiles::get().getImportedColorProfiles(); }
    Q_INVOKABLE QStringList getColorProfiles()                       { return PQCScriptsColorProfiles::get().getColorProfiles(); }
    Q_INVOKABLE QStringList getColorProfileDescriptions()            { return PQCScriptsColorProfiles::get().getColorProfileDescriptions(); }
    Q_INVOKABLE QString     getColorProfileID(int index)             { return PQCScriptsColorProfiles::get().getColorProfileID(index); }
    Q_INVOKABLE void        setColorProfile(QString path, int index) {        PQCScriptsColorProfiles::get().setColorProfile(path, index); }
    Q_INVOKABLE QString     getColorProfileFor(QString path)         { return PQCScriptsColorProfiles::get().getColorProfileFor(path); }
    Q_INVOKABLE bool        importColorProfile()                     { return PQCScriptsColorProfiles::get().importColorProfile(); }
    Q_INVOKABLE bool        removeImportedColorProfile(int index)    { return PQCScriptsColorProfiles::get().removeImportedColorProfile(index); }
    Q_INVOKABLE QString     detectVideoColorProfile(QString path)    { return PQCScriptsColorProfiles::get().detectVideoColorProfile(path); }

};
