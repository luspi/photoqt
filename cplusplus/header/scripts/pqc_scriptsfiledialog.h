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
#include <QHash>
#include <QMutex>

class QJSValue;

class PQCScriptsFileDialog : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFileDialog& get() {
        static PQCScriptsFileDialog instance;
        return instance;
    }

    PQCScriptsFileDialog(PQCScriptsFileDialog const&)     = delete;
    void operator=(PQCScriptsFileDialog const&) = delete;

    // get data
    QVariantList getDevices();
    QVariantList getPlaces(bool performEmptyCheck = true);
    QString getUniquePlacesId();

    // last location
    // this value is set in PQCFileFolderModel::setFolderFileDialog() when the custom filedialog is used
    QString getLastLocation();
    // The following one ONLY needs to be called from the integrated ui IF the native filedialog is used!
    void setLastLocation(QString fname);

    // count folder files
    unsigned int getNumberOfFilesInFolder(const QString &path);

    // places methods
    void movePlacesEntry(QString id, bool moveDown, int howmany);
    void addPlacesEntry(QString path, int pos, QString titlestring = "", QString icon = "folder", bool isSystemItem = false);
    void hidePlacesEntry(QString id, bool hidden);
    void deletePlacesEntry(QString id);

    // quickly move between folders
    QString getSiblingFolder(QString currentFolder, const int direction);

private:
    PQCScriptsFileDialog();
    ~PQCScriptsFileDialog();

    mutable QMutex cacheMutex;
    QHash<QString,int> cacheNumberOfFilesInFolder;

};
