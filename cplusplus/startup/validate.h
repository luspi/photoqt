#ifndef PQVALIDATE_H
#define PQVALIDATE_H

#include <QObject>
#include <QtSql>
#include "../logger.h"

class PQValidate : public QObject {

    Q_OBJECT

public:
    PQValidate(QObject *parent = nullptr);

    bool validate();

private:
    bool validateSettingsDatabase();
    bool validateShortcutsDatabase();

};

#endif // PQVALIDATE_H
