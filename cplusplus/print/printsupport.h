#ifndef PQPRINTSUPPORT_H
#define PQPRINTSUPPORT_H

#include <QObject>
#include <QtPrintSupport/QtPrintSupport>
#include "../imageprovider/imageproviderfull.h"

class PQPrintSupport : public QObject {

    Q_OBJECT

public:
    PQPrintSupport() {
        imageprovider = nullptr;
    }
    Q_INVOKABLE void printFile(QString filename);

private:
    PQImageProviderFull *imageprovider;

};

#endif // PQPRINT_H
