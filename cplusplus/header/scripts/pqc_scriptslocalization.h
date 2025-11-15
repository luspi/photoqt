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
#pragma once

#include <QObject>
#include <QMap>

/*************************************************************/
/*************************************************************/
//
// this class is used directly on from C++
// from QML they are accessed through method in PQCScriptsConfig
//
/*************************************************************/
/*************************************************************/

class QTranslator;

class PQCScriptsLocalization : public QObject {

    Q_OBJECT

public:
    static PQCScriptsLocalization& get();
    virtual ~PQCScriptsLocalization();

    PQCScriptsLocalization(PQCScriptsLocalization const&)     = delete;
    void operator=(PQCScriptsLocalization const&) = delete;

    QStringList getAvailableTranslations();
    void updateTranslation(QString code);
    QString getNameForLocalizationCode(QString code);
    QString getCurrentTranslation();
    QString getActiveTranslationCode();

private:
    PQCScriptsLocalization();

    QTranslator *trans;
    QString currentTranslation;
    QMap<QString,QString> langNames;

};
