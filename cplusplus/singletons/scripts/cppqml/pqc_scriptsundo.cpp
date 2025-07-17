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

#include <scripts/pqc_scriptsundo.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_filefoldermodel.h>

#include <QVariant>
#include <QFile>

PQCScriptsUndo::PQCScriptsUndo() {

    curFolder = "";
    trash.clear();

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
    trash.clear();
}

void PQCScriptsUndo::recordAction(QString action, QVariantList args) {

    if(action == "trash")
        trash.push_back(args);
    else
        qWarning() << "Unknown action:" << action;

}

QString PQCScriptsUndo::undoLastAction(QString action) {

    qDebug() << "args: action =" << action;

    if(action == "trash") {

        if(trash.isEmpty())
            return "";

        QVariantList act = trash.takeLast();

        QFile origFile(act.at(0).toString());
        QFile delFile(act.at(1).toString());

        QFileInfo info(act.at(1).toString());
        QFile infoFile(QDir::cleanPath(info.absolutePath() + "/../info/" + info.fileName() + ".trashinfo"));

        if(origFile.exists()) {

            // re-add action to list
            trash.push_back(act);

            return QString("-%1").arg(tr("File with original filename exists already", "filemanagement"));

        }

        if(delFile.rename(origFile.fileName())) {

            qDebug() << QString("Successfully restored file '%1' to '%2'").arg(act.at(1).toString(),act.at(0).toString());

            PQCFileFolderModel::get().setFileInFolderMainView(act.at(0).toString());

            if(!infoFile.remove()) {
                qWarning() << "Failed to remove .trashinfo file";
            }

            return tr("File restored from Trash", "filemanagement");

        }

        // re-add action to list
        trash.push_back(act);

        return QString("-%1: %2").arg(tr("Failed to recover file"), act.at(0).toString());

    }

    return QString("-%1: %2").arg(tr("Unknown action"), action);

}
