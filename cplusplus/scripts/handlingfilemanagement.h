#ifndef PQHANDLINGFILEMANAGEMENT_H
#define PQHANDLINGFILEMANAGEMENT_H

#include <QObject>
#include <QFile>

#include "../logger.h"

class PQHandlingFileManagement : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool renameFile(QString dir, QString oldName, QString newName);
};

#endif // PQHANDLINGFILEMANAGEMENT_H
