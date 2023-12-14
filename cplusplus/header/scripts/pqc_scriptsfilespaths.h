#ifndef PQCSCRIPTSFILESPATHS_H
#define PQCSCRIPTSFILESPATHS_H

#include <QObject>
#include <QDir>

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

    Q_INVOKABLE static QString cleanPath(QString path);
    Q_INVOKABLE static QString cleanPath_windows(QString path);
    Q_INVOKABLE QString pathWithNativeSeparators(QString path);
    Q_INVOKABLE QString getSuffix(QString path);
    Q_INVOKABLE QString getBasename(QString fullpath);
    Q_INVOKABLE QString getFilename(QString fullpath);
    Q_INVOKABLE QString getDir(QString fullpath);
    Q_INVOKABLE QDateTime getFileModified(QString path);
    Q_INVOKABLE QString getFileType(QString path);
    Q_INVOKABLE QString getFileSizeHumanReadable(QString path);
    Q_INVOKABLE QString toPercentEncoding(QString str);
    Q_INVOKABLE QString goUpOneLevel(QString path);
    Q_INVOKABLE QString getWindowsDriveLetter(QString path);
    Q_INVOKABLE QStringList getFoldersIn(QString path);
    Q_INVOKABLE QString getHomeDir();
    Q_INVOKABLE QString getTempDir();
    Q_INVOKABLE bool isFolder(QString path);
    Q_INVOKABLE bool doesItExist(QString path);
    Q_INVOKABLE bool isExcludeDirFromCaching(QString filename);
    Q_INVOKABLE void openInDefaultFileManager(QString filename);
    Q_INVOKABLE QString selectFileFromDialog(QString buttonlabel, QString preselectFile, int formatId, bool confirmOverwrite);
    Q_INVOKABLE void saveLogToFile(QString txt);
    Q_INVOKABLE QString openFileFromDialog(QString buttonlabel, QString preselectFile, QStringList endings);
    Q_INVOKABLE QString createTooltipFilename(QString fname);
    Q_INVOKABLE QString getExistingDirectory(QString startDir = QDir::homePath());
    Q_INVOKABLE QString findDropBoxFolder();
    Q_INVOKABLE QString findNextcloudFolder();
    Q_INVOKABLE QString findOwnCloudFolder();
    Q_INVOKABLE QString handleAnimatedImagePathAndEncode(QString path);
    Q_INVOKABLE void cleanupTemporaryAnimatedFiles();

private:
    PQCScriptsFilesPaths();

    int animatedImageTemporaryCounter;

};

#endif
