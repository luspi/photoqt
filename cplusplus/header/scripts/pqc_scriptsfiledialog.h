/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

class QJSValue;

class PQCScriptsFileDialog : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFileDialog& get() {
        static PQCScriptsFileDialog instance;
        return instance;
    }
    ~PQCScriptsFileDialog();

    PQCScriptsFileDialog(PQCScriptsFileDialog const&)     = delete;
    void operator=(PQCScriptsFileDialog const&) = delete;

    Q_INVOKABLE QVariantList getDevices();
    Q_INVOKABLE QVariantList getPlaces(bool performEmptyCheck = true);
    QString getUniquePlacesId();
    Q_INVOKABLE bool setLastLocation(QString path);
    Q_INVOKABLE QString getLastLocation();
    unsigned int _getNumberOfFilesInFolder(QString path);
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path, const QJSValue &callback);
    Q_INVOKABLE void movePlacesEntry(QString id, bool moveDown, int howmany);
    Q_INVOKABLE void addPlacesEntry(QString path, int pos, QString titlestring = "", QString icon = "folder", bool isSystemItem = false);
    Q_INVOKABLE void hidePlacesEntry(QString id, bool hidden);
    Q_INVOKABLE void deletePlacesEntry(QString id);

private:
    PQCScriptsFileDialog();
    QHash<QString,int> cacheNumberOfFilesInFolder;

};

#endif
