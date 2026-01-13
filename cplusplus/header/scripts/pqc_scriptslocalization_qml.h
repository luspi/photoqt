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
#include <scripts/pqc_scriptslocalization.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsLocalizationQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsLocalization)

public:
    PQCScriptsLocalizationQML() {}

    Q_INVOKABLE QStringList getAvailableTranslations() {
        return PQCScriptsLocalization::get().getAvailableTranslations();
    }
    Q_INVOKABLE void updateTranslation(QString code) {
        PQCScriptsLocalization::get().updateTranslation(code);
    }
    Q_INVOKABLE QString getNameForLocalizationCode(QString code) {
        return PQCScriptsLocalization::get().getNameForLocalizationCode(code);
    }
    Q_INVOKABLE QString getCurrentTranslation() {
        return PQCScriptsLocalization::get().getCurrentTranslation();
    }

};
