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

#ifndef PQCSCRIPTSFILEMANAGEMENT_H
#define PQCSCRIPTSFILEMANAGEMENT_H

#include <QObject>
#include <QtQmlIntegration>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCScriptsFileManagement : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCScriptsFileManagement();
    ~PQCScriptsFileManagement();

    Q_INVOKABLE bool copyFileToHere(QString filename, QString targetdir);
    Q_INVOKABLE bool deletePermanent(QString filename);
    Q_INVOKABLE bool moveFileToTrash(QString filename);

    Q_INVOKABLE void exportImage(QString sourceFilename, QString targetFilename, int uniqueid);
    Q_INVOKABLE bool canThisBeScaled(QString filename);
    Q_INVOKABLE void scaleImage(QString sourceFilename, QString targetFilename, int uniqueid, QSize targetSize, int targetQuality);

    Q_INVOKABLE bool renameFile(QString dir, QString oldName, QString newName);
    Q_INVOKABLE bool copyFile(QString filename, QString targetFilename);
    Q_INVOKABLE bool moveFile(QString filename, QString targetFilename);

    Q_INVOKABLE void cropImage(QString sourceFilename, QString targetFilename, int uniqueid, QPointF topLeft, QPointF botRight);
    Q_INVOKABLE bool canThisBeCropped(QString filename);

Q_SIGNALS:
    void exportCompleted(bool success);
    void scaleCompleted(bool success);
    void cropCompleted(bool success);

};

#endif
