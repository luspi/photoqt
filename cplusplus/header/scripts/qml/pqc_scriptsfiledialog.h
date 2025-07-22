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

#ifndef PQCSCRIPTSFILEDIALOG_H
#define PQCSCRIPTSFILEDIALOG_H

#include <QObject>
#include <QHash>
#include <QQmlEngine>

class QJSValue;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCScriptsFileDialog : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCScriptsFileDialog();
    ~PQCScriptsFileDialog();

    // get data
    Q_INVOKABLE QVariantList getDevices();
    Q_INVOKABLE QVariantList getPlaces(bool performEmptyCheck = true);
    QString getUniquePlacesId();

    // last location
    // this value is set in PQCFileFolderModel::setFolderFileDialog()
    Q_INVOKABLE QString getLastLocation();

    // count folder files
    unsigned int _getNumberOfFilesInFolder(QString path);
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path, const QJSValue &callback);

    // places methods
    Q_INVOKABLE void movePlacesEntry(QString id, bool moveDown, int howmany);
    Q_INVOKABLE void addPlacesEntry(QString path, int pos, QString titlestring = "", QString icon = "folder", bool isSystemItem = false);
    Q_INVOKABLE void hidePlacesEntry(QString id, bool hidden);
    Q_INVOKABLE void deletePlacesEntry(QString id);

private:
    QHash<QString,int> cacheNumberOfFilesInFolder;

};

#endif
