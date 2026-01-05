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
#include <scripts/pqc_scriptsfilespaths.h>

// this class is heavily used in both C++ and QML code
// thus there is a wrapper for QML available

class PQCScriptsFilesPathsQML : public QObject {

    Q_OBJECT
    QML_NAMED_ELEMENT(PQCScriptsFilesPaths)
    QML_SINGLETON

public:
    PQCScriptsFilesPathsQML() {}
    ~PQCScriptsFilesPathsQML() {}

    // path methods
    Q_INVOKABLE static QString cleanPath(QString path)                        { return PQCScriptsFilesPaths::get().cleanPath(path); }
    Q_INVOKABLE static QString cleanPath_windows(QString path)                { return PQCScriptsFilesPaths::get().cleanPath_windows(path); }
    Q_INVOKABLE QString        pathWithNativeSeparators(QString path)         { return PQCScriptsFilesPaths::get().pathWithNativeSeparators(path); }
    Q_INVOKABLE QString        pathFromNativeSeparators(QString path)         { return PQCScriptsFilesPaths::get().pathFromNativeSeparators(path); }
    Q_INVOKABLE QString        toPercentEncoding(QString str)                 { return PQCScriptsFilesPaths::get().toPercentEncoding(str); }
    Q_INVOKABLE QString        fromPercentEncoding(QString str)               { return PQCScriptsFilesPaths::get().fromPercentEncoding(str); }
    Q_INVOKABLE QString        handleAnimatedImagePathAndEncode(QString path) { return PQCScriptsFilesPaths::get().handleAnimatedImagePathAndEncode(path); }
    Q_INVOKABLE QString        getSuffix(QString path)                        { return PQCScriptsFilesPaths::get().getSuffix(path); }
    Q_INVOKABLE QString        getSuffixLowerCase(QString path)               { return PQCScriptsFilesPaths::get().getSuffixLowerCase(path); }
    Q_INVOKABLE QString        getCompleteSuffix(QString path)                { return PQCScriptsFilesPaths::get().getCompleteSuffix(path); }
    Q_INVOKABLE QString        getCompleteSuffixLowerCase(QString path)       { return PQCScriptsFilesPaths::get().getCompleteSuffixLowerCase(path); }
    Q_INVOKABLE QString        getBasename(QString fullpath)                  { return PQCScriptsFilesPaths::get().getBasename(fullpath); }
    Q_INVOKABLE QString        getFilename(QString fullpath)                  { return PQCScriptsFilesPaths::get().getFilename(fullpath); }
    Q_INVOKABLE QString        getDir(QString fullpath)                       { return PQCScriptsFilesPaths::get().getDir(fullpath); }
    Q_INVOKABLE bool           isUrl(QString path)                            { return PQCScriptsFilesPaths::get().isUrl(path); }
    Q_INVOKABLE bool           areDirsTheSame(QString folder1, QString folder2) { return PQCScriptsFilesPaths::get().areDirsTheSame(folder1, folder2); }

    // folder methods
    Q_INVOKABLE bool        isFolder(QString path)                    { return PQCScriptsFilesPaths::get().isFolder(path); }
    Q_INVOKABLE QStringList getFoldersIn(QString path)                { return PQCScriptsFilesPaths::get().getFoldersIn(path); }
    Q_INVOKABLE QString     goUpOneLevel(QString path)                { return PQCScriptsFilesPaths::get().goUpOneLevel(path); }
    Q_INVOKABLE bool        isExcludeDirFromCaching(QString filename) { return PQCScriptsFilesPaths::get().isExcludeDirFromCaching(filename); }

    // file methods
    Q_INVOKABLE QDateTime getFileModified(QString path)              { return PQCScriptsFilesPaths::get().getFileModified(path); }
    Q_INVOKABLE QString   getFileType(QString path)                  { return PQCScriptsFilesPaths::get().getFileType(path); }
    Q_INVOKABLE QString   getFileSizeHumanReadable(QString path)     { return PQCScriptsFilesPaths::get().getFileSizeHumanReadable(path); }
    Q_INVOKABLE double    convertBytesToGB(const qint64 bytes)       { return PQCScriptsFilesPaths::get().convertBytesToGB(bytes); }
    Q_INVOKABLE QString   createTooltipFilename(QString fname)       { return PQCScriptsFilesPaths::get().createTooltipFilename(fname); }
    Q_INVOKABLE void      openInDefaultFileManager(QString filename) {        PQCScriptsFilesPaths::get().openInDefaultFileManager(filename); }

    // folder and file methods
    Q_INVOKABLE bool doesItExist(QString path)     { return PQCScriptsFilesPaths::get().doesItExist(path); }
    Q_INVOKABLE bool isOnNetwork(QString filename) { return PQCScriptsFilesPaths::get().isOnNetwork(filename); }

    // get some fixed directories
    Q_INVOKABLE QString getHomeDir()          { return PQCScriptsFilesPaths::get().getHomeDir(); }
    Q_INVOKABLE QString getTempDir()          { return PQCScriptsFilesPaths::get().getTempDir(); }
    Q_INVOKABLE QString findDropBoxFolder()   { return PQCScriptsFilesPaths::get().findDropBoxFolder(); }
    Q_INVOKABLE QString findNextcloudFolder() { return PQCScriptsFilesPaths::get().findNextcloudFolder(); }
    Q_INVOKABLE QString findOwnCloudFolder()  { return PQCScriptsFilesPaths::get().findOwnCloudFolder(); }

    // windows methods
    Q_INVOKABLE QString getWindowsDriveLetter(QString path) { return PQCScriptsFilesPaths::get().getWindowsDriveLetter(path); }


    // externally related
    Q_INVOKABLE QString     selectFileFromDialog(QString buttonlabel, QString preselectFile, int formatId, bool confirmOverwrite) {
        return PQCScriptsFilesPaths::get().selectFileFromDialog(buttonlabel, preselectFile, formatId, confirmOverwrite);
    }
    Q_INVOKABLE QString     selectFileFromDialog(QString buttonlabel, QString preselectFile, bool confirmOverwrite) {
        return PQCScriptsFilesPaths::get().selectFileFromDialog(buttonlabel, preselectFile, confirmOverwrite);
    }
    Q_INVOKABLE QString     selectFolderFromDialog(QString buttonlabel, QString preselectFolder) {
        return PQCScriptsFilesPaths::get().selectFolderFromDialog(buttonlabel, preselectFolder);
    }
    Q_INVOKABLE void        saveLogToFile(QString txt) {
        PQCScriptsFilesPaths::get().saveLogToFile(txt);
    }
    Q_INVOKABLE QString     openFileFromDialog(QString buttonlabel, QString preselectFile, QStringList endings) {
         return PQCScriptsFilesPaths::get().openFileFromDialog(buttonlabel, preselectFile, endings);
    }
    Q_INVOKABLE QStringList openFilesFromDialog(QString buttonlabel, QString preselectFile, QStringList endings) {
        return PQCScriptsFilesPaths::get().openFilesFromDialog(buttonlabel, preselectFile, endings);
    }
    Q_INVOKABLE QString     getExistingDirectory(QString startDir = QDir::homePath()) {
        return PQCScriptsFilesPaths::get().getExistingDirectory(startDir);
    }
    Q_INVOKABLE void        cleanupTemporaryFiles() {
        PQCScriptsFilesPaths::get().cleanupTemporaryFiles();
    }
    Q_INVOKABLE void        setThumbnailBaseCacheDir(QString dir) {
        PQCScriptsFilesPaths::get().setThumbnailBaseCacheDir(dir);
    }

    // navigating between folders
    Q_INVOKABLE QString getSiblingFile(const QString currentFile, const int direction, int remainingIteration, int remainingLevelUp, int remainingLevelDown) {
        return PQCScriptsFilesPaths::get().getSiblingFile(currentFile, direction, remainingIteration, remainingLevelUp, remainingLevelDown);
    }

};
