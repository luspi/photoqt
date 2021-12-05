#ifndef PQVALIDATE_H
#define PQVALIDATE_H

#include <QObject>
#include <QtSql>
#include "../logger.h"

class PQValidate : public QObject {

    Q_OBJECT

public:
    PQValidate(QObject *parent = nullptr);

    bool validateSettingsDatabase();

};

#endif // PQVALIDATE_H
