#ifndef PQHANDLINGEXTERNAL_H
#define PQHANDLINGEXTERNAL_H

#include <QObject>
#include <QFileDialog>
#include <QTextStream>
#include <archive.h>
#include <archive_entry.h>
#include "../logger.h"

class PQHandlingExternal : public QObject {

    Q_OBJECT

public:
    bool exportConfigTo(QString path);
    bool importConfigFrom(QString path);

};

#endif // PQHANDLINGEXTERNAL_H
