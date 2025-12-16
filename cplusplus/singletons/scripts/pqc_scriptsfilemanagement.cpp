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

#include <scripts/pqc_scriptsfilemanagement.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_filefoldermodelCPP.h>
#include <pqc_configfiles.h>
#include <pqc_imageformats.h>
#include <pqc_loadimage.h>
#include <QtDebug>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QStorageInfo>
#include <QDirIterator>
#include <QImageWriter>
#include <QImageReader>
#include <QtConcurrent/QtConcurrentRun>
#include <QFileDialog>
#include <QMessageBox>
#include <QPushButton>
#ifdef Q_OS_WIN
#include <thread>
#else
#include <unistd.h>
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif
#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

#ifdef PQMFLATPAKBUILD
#include <gio/gio.h>
#endif

PQCScriptsFileManagement::PQCScriptsFileManagement() {

    undoCurFolder = "";
    undoTrash.clear();

    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::currentFileChanged, this, [=]() {
        QString newFolder = PQCScriptsFilesPaths::get().getDir(PQCFileFolderModelCPP::get().getCurrentFile());
        if(undoCurFolder != newFolder) {
            undoCurFolder = newFolder;
            undoTrash.clear();
        }
    });

}

PQCScriptsFileManagement::~PQCScriptsFileManagement() {}

bool PQCScriptsFileManagement::copyFileToHere(QString filename, QString targetdir) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetdir =" << targetdir;

    QFileInfo info(filename);
    if(!info.exists())
        return false;

    QString targetFilename = QString("%1/%2").arg(targetdir, info.fileName());
    QFileInfo targetinfo(targetFilename);

    // file copied to itself
    if(targetFilename == filename)
        return true;

    if(targetinfo.exists()) {
        QFile tf(targetFilename);
        tf.remove();
    }

    QFile f(filename);
    return f.copy(targetFilename);

}

bool PQCScriptsFileManagement::deletePermanent(QString filename) {

    qDebug() << "args: filename = " << filename;

    QFileInfo info(filename);
    if(info.isDir()) {
        QDir dir(filename);
        if(!dir.removeRecursively()) {
            qWarning() << "Failed to delete folder recursively!";
            return false;
        }
        return true;
    }
    QFile file(filename);
    return file.remove();

}

bool PQCScriptsFileManagement::moveFileToTrash(QString filename) {

    qDebug() << "args: filename = " << filename;


#ifdef Q_OS_WIN
    QString deletedFilename = "";
    QFile file(filename);
    // we need to call moveToTrash on a different QFile object, otherwise the exists() check will return false
    // even while the file isn't deleted as it is seen as opened by PhotoQt
    QFile f(filename);
    bool ret = f.moveToTrash();
    int count = 0;
    while(file.exists() && count < 20) {
        QFile f(filename);
        ret = f.moveToTrash();
        if(ret && deletedFilename == "")
            deletedFilename = f.fileName();
        std::this_thread::sleep_for(std::chrono::milliseconds(250));
        ++count;
    }
    recordAction("trash", {filename, deletedFilename});
    return ret;
#else

#ifndef PQMFLATPAKBUILD

    // this does not work with Flatpak, checked 2024-04-03
    QString trashFile = "";
    bool rettrash = QFile::moveToTrash(filename, &trashFile);
    if(rettrash)
        recordAction("trash", {filename, trashFile});
    return rettrash;

#else

    // for flatpaks we use GIO trash function as this has support for the trash portal

    GFile *file = g_file_new_for_path(filename.toStdString().c_str());
    GError *error = nullptr;
    bool success = g_file_trash(file, nullptr, &error);

    if(!success) {
        qWarning() << "Failed to move file to trash:" << error->message;
        g_error_free(error);
    }

    g_object_unref(file);

    return success;

#endif

#endif

}

bool PQCScriptsFileManagement::renameFile(QString dir, QString oldName, QString newName) {

    qDebug() << "args: dir =" << dir;
    qDebug() << "args: oldName =" << oldName;
    qDebug() << "args: newName =" << newName;

    QFile file(dir + "/" + oldName);
    return file.rename(dir + "/" + newName);

}

bool PQCScriptsFileManagement::copyFile(QString filename, QString targetFilename) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetFilename =" << targetFilename;

    // if the target is the same as source, then we're done
    if(filename == targetFilename)
        return true;

    // if a file by the target filename already exists, then we need to remove it first
    if(QFileInfo::exists(targetFilename)) {
        if(!QFile::remove(targetFilename)) {
            qWarning() << "ERROR: File existing with this name could not be removed first.";
            return false;
        }
    }

    // copy source file to target filename
    QFile file(filename);
    if(!file.copy(targetFilename)) {
        qWarning() << "ERROR: The file could not be copied to its new location.";
        return false;
    }

    return true;

}

bool PQCScriptsFileManagement::moveFile(QString filename, QString targetFilename) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetFilename =" << targetFilename;

    // if the target is the same as source, then we're done
    if(filename == targetFilename)
        return true;

    // if a file by the target filename already exists, then we need to remove it first
    if(QFileInfo::exists(targetFilename)) {
        if(!QFile::remove(targetFilename)) {
            qWarning() << "ERROR: File existing with this name could not be removed first.";
            return false;
        }
    }

    // copy source file to target filename
    QFile file(filename);
    if(!file.copy(targetFilename)) {
        qWarning() << "ERROR: The file could not be copied to its new location.";
        return false;
    }

    if(!file.remove()) {
        qWarning() << "ERROR: The file was successfully copied to new location but the old file could not be removed.";
        return false;
    }

    return true;

}

void PQCScriptsFileManagement::recordAction(QString action, QVariantList args) {

    if(action == "trash")
        undoTrash.push_back(args);
    else
        qWarning() << "Unknown action:" << action;

}

QString PQCScriptsFileManagement::undoLastAction(QString action) {

    qDebug() << "args: action =" << action;

    if(action == "trash") {

        if(undoTrash.isEmpty())
            return "";

        QVariantList act = undoTrash.takeLast();

        QFile origFile(act.at(0).toString());
        QFile delFile(act.at(1).toString());

        QFileInfo info(act.at(1).toString());
        QFile infoFile(QDir::cleanPath(info.absolutePath() + "/../info/" + info.fileName() + ".trashinfo"));

        if(origFile.exists()) {

            // re-add action to list
            undoTrash.push_back(act);

            return QString("-%1").arg(tr("File with original filename exists already", "filemanagement"));

        }

        if(delFile.rename(origFile.fileName())) {

            qDebug() << QString("Successfully restored file '%1' to '%2'").arg(act.at(1).toString(),act.at(0).toString());

            PQCFileFolderModelCPP::get().setFileInFolderMainView(act.at(0).toString());

            if(!infoFile.remove()) {
                qWarning() << "Failed to remove .trashinfo file";
            }

            return tr("File restored from Trash", "filemanagement");

        }

        // re-add action to list
        undoTrash.push_back(act);

        return QString("-%1: %2").arg(tr("Failed to recover file"), act.at(0).toString());

    }

    return QString("-%1: %2").arg(tr("Unknown action"), action);

}

// 0 := cancel
// 1 := trash
// 2 := delete permanently
int PQCScriptsFileManagement::askForDeletion() {

    QMessageBox box;
    box.setIcon(QMessageBox::Question);
    box.setModal(true);
    box.setWindowModality(Qt::ApplicationModal);
    box.setWindowFlag(Qt::WindowStaysOnTopHint);
    box.setWindowTitle(tr("Delete?"));
    box.setText(tr("Are you sure you want to delete this file?"));
    box.setInformativeText(tr("You can either move the file to trash (default) or delete it permanently."));

    QAbstractButton* butTrash = box.addButton(tr("Move to trash"), QMessageBox::AcceptRole);
    QAbstractButton* butPerma = box.addButton(tr("Delete permanently"), QMessageBox::AcceptRole);
    box.addButton(tr("Cancel"), QMessageBox::RejectRole);

    QFont ft = butTrash->font();
    ft.setBold(true);
    butTrash->setFont(ft);

    box.exec();

    if(box.clickedButton() == butTrash)
        return 1;
    else if(box.clickedButton() == butPerma)
        return 2;

    return 0;

}
