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
#include <QDir>
#include <QTimer>

class PQCScriptsFilesPaths : public QObject {

    Q_OBJECT

public:
    static PQCScriptsFilesPaths& get();
    virtual ~PQCScriptsFilesPaths();

    PQCScriptsFilesPaths(PQCScriptsFilesPaths const&)     = delete;
    void operator=(PQCScriptsFilesPaths const&) = delete;

    // path methods
    QString cleanPath(QString path);
    QString cleanPath_windows(QString path);
    QString pathWithNativeSeparators(QString path);
    QString pathFromNativeSeparators(QString path);
    QString toPercentEncoding(QString str);
    QString handleAnimatedImagePathAndEncode(QString path);
    QString getSuffix(QString path);
    QString getSuffixLowerCase(QString path);
    QString getBasename(QString fullpath);
    QString getFilename(QString fullpath);
    QString getDir(QString fullpath);
    bool    isUrl(QString path);

    // folder methods
    bool        isFolder(QString path);
    QStringList getFoldersIn(QString path);
    QString     goUpOneLevel(QString path);
    bool        isExcludeDirFromCaching(QString filename);

    // file methods
    QDateTime getFileModified(QString path);
    QString   getFileType(QString path);
    QString   getFileSizeHumanReadable(QString path);
    QString   createTooltipFilename(QString fname);
    void      openInDefaultFileManager(QString filename);

    // folder and file methods
    bool doesItExist(QString path);
    bool isOnNetwork(QString filename);

    // get some fixed directories
    QString getHomeDir();
    QString getTempDir();
    QString findDropBoxFolder();
    QString findNextcloudFolder();
    QString findOwnCloudFolder();

    // windows methods
    QString getWindowsDriveLetter(QString path);

    // externally related
    QString     selectFileFromDialog(QString buttonlabel, QString preselectFile, bool confirmOverwrite);
    QString     selectFileFromDialog(QString buttonlabel, QString preselectFile, int formatId, bool confirmOverwrite);
    QString     selectFolderFromDialog(QString buttonlabel, QString preselectFolder);
    void        saveLogToFile(QString txt);
    QString     openFileFromDialog(QString buttonlabel, QString preselectFile, QStringList endings);
    QStringList openFilesFromDialog(QString buttonlabel, QString preselectFile, QStringList endings);
    QString     getExistingDirectory(QString startDir = QDir::homePath());
    void        cleanupTemporaryFiles();
    void        setThumbnailBaseCacheDir(QString dir);


private:
    PQCScriptsFilesPaths();

    int animatedImageTemporaryCounter;

    QTimer networkSharesTimer;
    QStringList networkshares;

private Q_SLOTS:
    void detectNetworkShares();

};
