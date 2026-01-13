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
#include <scripts/pqc_scriptsclipboard.h>

class QClipboard;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsClipboardQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsClipboard)

public:
    PQCScriptsClipboardQML() {
        connect(&PQCScriptsClipboard::get(), &PQCScriptsClipboard::clipboardUpdated, this, &PQCScriptsClipboardQML::clipboardUpdated);
    }

    Q_INVOKABLE bool areFilesInClipboard() {
        return PQCScriptsClipboard::get().areFilesInClipboard();
    }
    Q_INVOKABLE void copyFilesToClipboard(QStringList files) {
        PQCScriptsClipboard::get().copyFilesToClipboard(files);
    }
    Q_INVOKABLE QStringList getListOfFilesInClipboard() {
        return PQCScriptsClipboard::get().getListOfFilesInClipboard();
    }
    Q_INVOKABLE void copyTextToClipboard(QString txt, bool removeHTML= false) {
        PQCScriptsClipboard::get().copyTextToClipboard(txt, removeHTML);
    }
    Q_INVOKABLE QString getTextFromClipboard() {
        return PQCScriptsClipboard::get().getTextFromClipboard();
    }

Q_SIGNALS:
    void clipboardUpdated();

};
