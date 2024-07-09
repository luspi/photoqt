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

#include <scripts/pqc_scriptsundo.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_filefoldermodel.h>

#include <QVariant>
#include <QFile>

PQCScriptsUndo::PQCScriptsUndo() {

    curFolder = "";
    actions.clear();

    connect(&PQCFileFolderModel::get(), &PQCFileFolderModel::currentFileChanged, this, [=]() {
        QString newFolder = PQCScriptsFilesPaths::get().getDir(PQCFileFolderModel::get().getCurrentFile());
        if(curFolder != newFolder) {
            curFolder = newFolder;
            clearActions();
        }
    });

}

PQCScriptsUndo::~PQCScriptsUndo() {}

void PQCScriptsUndo::clearActions() {
    actions.clear();
}

void PQCScriptsUndo::recordAction(QVariantList args) {
    actions.push_back(args);
}

QString PQCScriptsUndo::undoLastAction() {

    qDebug() << "";

    if(actions.isEmpty())
        return "";

    QVariantList act = actions.takeLast();

    if(act.at(0).toString() == "trash") {

        QFile origFile(act.at(1).toString());
        QFile delFile(act.at(2).toString());
        
        if(origFile.exists()) {

            // re-add action to list
            actions.push_back(act);

            return QString("-%1").arg(tr("File with original filename already exists", "filemanagement"));

        }

        if(delFile.rename(origFile.fileName())) {

            PQCFileFolderModel::get().setFileInFolderMainView(act.at(1).toString());

            return tr("File restored from Trash", "filemanagement");

        }

    }

    // re-add action to list
    actions.push_back(act);

    return QString("-%1: %2").arg(tr("Unknown last action"), act.at(0).toString());

}
