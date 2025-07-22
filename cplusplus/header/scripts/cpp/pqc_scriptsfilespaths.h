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

#ifndef PQCSCRIPTSFILESPATHS_H
#define PQCSCRIPTSFILESPATHS_H

#include <QObject>
#include <QDir>
#include <QTimer>

/*************************************************************/
/*************************************************************/
//
// this class is heavily used in both C++ and QML code
// thus there is a WRAPPER for QML available
//
/*************************************************************/
/*************************************************************/

class PQCScriptsFilesPaths : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFilesPaths& get() {
        static PQCScriptsFilesPaths instance;
        return instance;
    }
    ~PQCScriptsFilesPaths();

    PQCScriptsFilesPaths(PQCScriptsFilesPaths const&)     = delete;
    void operator=(PQCScriptsFilesPaths const&) = delete;

    // path methods
    Q_INVOKABLE static QString cleanPath(QString path);
    Q_INVOKABLE static QString cleanPath_windows(QString path);
    Q_INVOKABLE QString        pathWithNativeSeparators(QString path);
    Q_INVOKABLE QString        pathFromNativeSeparators(QString path);
    Q_INVOKABLE QString        toPercentEncoding(QString str);
    Q_INVOKABLE QString        handleAnimatedImagePathAndEncode(QString path);
    Q_INVOKABLE QString        getSuffix(QString path);
    Q_INVOKABLE QString        getSuffixLowerCase(QString path);
    Q_INVOKABLE QString        getBasename(QString fullpath);
    Q_INVOKABLE QString        getFilename(QString fullpath);
    Q_INVOKABLE QString        getDir(QString fullpath);
    Q_INVOKABLE bool           isUrl(QString path);

    // folder methods
    Q_INVOKABLE bool        isFolder(QString path);
    Q_INVOKABLE QStringList getFoldersIn(QString path);
    Q_INVOKABLE QString     goUpOneLevel(QString path);
    Q_INVOKABLE bool        isExcludeDirFromCaching(QString filename);

    // file methods
    Q_INVOKABLE QDateTime getFileModified(QString path);
    Q_INVOKABLE QString   getFileType(QString path);
    Q_INVOKABLE QString   getFileSizeHumanReadable(QString path);
    Q_INVOKABLE QString   createTooltipFilename(QString fname);
    Q_INVOKABLE void      openInDefaultFileManager(QString filename);

    // folder and file methods
    Q_INVOKABLE bool doesItExist(QString path);
    Q_INVOKABLE bool isOnNetwork(QString filename);

    // get some fixed directories
    Q_INVOKABLE QString getHomeDir();
    Q_INVOKABLE QString getTempDir();
    Q_INVOKABLE QString findDropBoxFolder();
    Q_INVOKABLE QString findNextcloudFolder();
    Q_INVOKABLE QString findOwnCloudFolder();

    // windows methods
    Q_INVOKABLE QString getWindowsDriveLetter(QString path);

    // externally related
    Q_INVOKABLE QString     selectFileFromDialog(QString buttonlabel, QString preselectFile, int formatId, bool confirmOverwrite);
    Q_INVOKABLE QString     selectFolderFromDialog(QString buttonlabel, QString preselectFolder);
    Q_INVOKABLE void        saveLogToFile(QString txt);
    Q_INVOKABLE QString     openFileFromDialog(QString buttonlabel, QString preselectFile, QStringList endings);
    Q_INVOKABLE QStringList openFilesFromDialog(QString buttonlabel, QString preselectFile, QStringList endings);
    Q_INVOKABLE QString     getExistingDirectory(QString startDir = QDir::homePath());
    Q_INVOKABLE void        cleanupTemporaryFiles();
    Q_INVOKABLE void        setThumbnailBaseCacheDir(QString dir);


private:
    PQCScriptsFilesPaths();

    int animatedImageTemporaryCounter;

    QTimer networkSharesTimer;
    QStringList networkshares;

private Q_SLOTS:
    void detectNetworkShares();

};

#endif
