#ifndef PQHANDLINGFILEMANAGEMENT_H
#define PQHANDLINGFILEMANAGEMENT_H

#include <QObject>
#include <QFile>
#include <QUrl>
#include <QStorageInfo>
#include <QFileDialog>
#ifndef Q_OS_WIN
#include <unistd.h>
#endif

#include "../logger.h"

class PQHandlingFileManagement : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool renameFile(QString dir, QString oldName, QString newName);
    Q_INVOKABLE bool deleteFile(QString filename, bool permanent);
    Q_INVOKABLE QString copyFile(QString filename);
    Q_INVOKABLE QString moveFile(QString filename);
};

#endif // PQHANDLINGFILEMANAGEMENT_H
