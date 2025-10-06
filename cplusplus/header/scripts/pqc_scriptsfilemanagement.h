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

class PQCScriptsFileManagement : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFileManagement& get() {
        static PQCScriptsFileManagement instance;
        return instance;
    }

    PQCScriptsFileManagement(PQCScriptsFileManagement const&)     = delete;
    void operator=(PQCScriptsFileManagement const&) = delete;

    bool copyFileToHere(QString filename, QString targetdir);
    bool deletePermanent(QString filename);
    bool moveFileToTrash(QString filename);

    bool canThisBeScaled(QString filename);
    void scaleImage(QString sourceFilename, QString targetFilename, int uniqueid, QSize targetSize, int targetQuality);

    bool renameFile(QString dir, QString oldName, QString newName);
    bool copyFile(QString filename, QString targetFilename);
    bool moveFile(QString filename, QString targetFilename);

    void cropImage(QString sourceFilename, QString targetFilename, int uniqueid, QPointF topLeft, QPointF botRight);
    bool canThisBeCropped(QString filename);

    QString undoLastAction(QString action);
    void recordAction(QString actions, QVariantList args);

    int askForDeletion();

private:
    PQCScriptsFileManagement();
    ~PQCScriptsFileManagement();

    QString undoCurFolder;
    QList<QVariantList> undoTrash;

Q_SIGNALS:
    void scaleCompleted(bool success);
    void cropCompleted(bool success);

};

#endif
