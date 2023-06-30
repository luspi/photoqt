#ifndef PQCSCRIPTSFILESPATHS_H
#define PQCSCRIPTSFILESPATHS_H

#include <QObject>

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

    Q_INVOKABLE QString cleanPath(QString path);
    Q_INVOKABLE QString pathWithNativeSeparators(QString path);
    Q_INVOKABLE QString getSuffix(QString path, bool lowerCase = true);
    Q_INVOKABLE QString getFilename(QString fullpath);
    Q_INVOKABLE QDateTime getFileModified(QString path);
    Q_INVOKABLE QString getFileType(QString path);
    Q_INVOKABLE QString getFileSizeHumanReadable(QString path);
    Q_INVOKABLE QString toPercentEncoding(QString str);
    Q_INVOKABLE QString goUpOneLevel(QString path);
    Q_INVOKABLE QString getWindowsDriveLetter(QString path);
    Q_INVOKABLE QStringList getFoldersIn(QString path);

private:
    PQCScriptsFilesPaths();

};

#endif
