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
#include <QQmlEngine>
#include <QSize>
#include <QPointF>
#include <scripts/pqc_scriptsfilemanagement.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsFileManagementQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsFileManagement)

public:
    PQCScriptsFileManagementQML() {
        connect(&PQCScriptsFileManagement::get(), &PQCScriptsFileManagement::scaleCompleted, this, &PQCScriptsFileManagementQML::scaleCompleted);
        connect(&PQCScriptsFileManagement::get(), &PQCScriptsFileManagement::cropCompleted, this, &PQCScriptsFileManagementQML::cropCompleted);
    }

    Q_INVOKABLE bool copyFileToHere(QString filename, QString targetdir) {
        return PQCScriptsFileManagement::get().copyFileToHere(filename, targetdir);
    }
    Q_INVOKABLE bool deletePermanent(QString filename) {
        return PQCScriptsFileManagement::get().deletePermanent(filename);
    }
    Q_INVOKABLE bool moveFileToTrash(QString filename) {
        return PQCScriptsFileManagement::get().moveFileToTrash(filename);
    }

    Q_INVOKABLE bool renameFile(QString dir, QString oldName, QString newName) {
        return PQCScriptsFileManagement::get().renameFile(dir, oldName, newName);
    }
    Q_INVOKABLE bool copyFile(QString filename, QString targetFilename) {
        return PQCScriptsFileManagement::get().copyFile(filename, targetFilename);
    }
    Q_INVOKABLE bool moveFile(QString filename, QString targetFilename) {
        return PQCScriptsFileManagement::get().moveFile(filename, targetFilename);
    }

    Q_INVOKABLE QString undoLastAction(QString action) {
        return PQCScriptsFileManagement::get().undoLastAction(action);
    }
    void recordAction(QString actions, QVariantList args) {
        PQCScriptsFileManagement::get().recordAction(actions, args);
    }

    Q_INVOKABLE int askForDeletion() {
        return PQCScriptsFileManagement::get().askForDeletion();
    }

Q_SIGNALS:
    void scaleCompleted(bool success);
    void cropCompleted(bool success);

};
