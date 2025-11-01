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
#include <QHash>
#include <QQmlEngine>
#include <QThreadPool>
#include <scripts/pqc_scriptsfiledialog.h>

class QJSValue;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsFileDialogQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsFileDialog)

public:
    PQCScriptsFileDialogQML() {}

    // get data
    Q_INVOKABLE QVariantList getDevices() {
        return PQCScriptsFileDialog::get().getDevices();
    }
    Q_INVOKABLE QVariantList getPlaces(bool performEmptyCheck = true) {
        return PQCScriptsFileDialog::get().getPlaces(performEmptyCheck);
    }

    // last location
    // this value is set in PQCFileFolderModel::setFolderFileDialog() when the custom filedialog is used
    Q_INVOKABLE QString getLastLocation() {
        return PQCScriptsFileDialog::get().getLastLocation();
    }
    // The following one ONLY needs to be called from the integrated ui IF the native filedialog is used!
    Q_INVOKABLE void setLastLocation(QString fname) {
        PQCScriptsFileDialog::get().setLastLocation(fname);
    }

    // count folder files
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path) {
        QThreadPool::globalInstance()->start([=]() {
            unsigned int ret = PQCScriptsFileDialog::get().getNumberOfFilesInFolder(path);
            Q_EMIT figuredOutNumberOfFilesInFolder(path, ret);
        });
    }

    // places methods
    Q_INVOKABLE void movePlacesEntry(QString id, bool moveDown, int howmany) {
        PQCScriptsFileDialog::get().movePlacesEntry(id, moveDown, howmany);
    }
    Q_INVOKABLE void addPlacesEntry(QString path, int pos, QString titlestring = "", QString icon = "folder", bool isSystemItem = false) {
        PQCScriptsFileDialog::get().addPlacesEntry(path, pos, titlestring, icon, isSystemItem);
    }
    Q_INVOKABLE void hidePlacesEntry(QString id, bool hidden) {
        PQCScriptsFileDialog::get().hidePlacesEntry(id, hidden);
    }
    Q_INVOKABLE void deletePlacesEntry(QString id) {
        PQCScriptsFileDialog::get().deletePlacesEntry(id);
    }

    // quickly move between folders
    Q_INVOKABLE QString getSiblingFolder(QString currentFolder, const int direction) {
        return PQCScriptsFileDialog::get().getSiblingFolder(currentFolder, direction);
    }

Q_SIGNALS:
    void figuredOutNumberOfFilesInFolder(const QString &path, const unsigned int &num);

};
