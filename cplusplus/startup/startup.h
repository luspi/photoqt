#ifndef PQSTARTUP_H
#define PQSTARTUP_H

#include <QObject>
#include <QFile>
#include <QtSql>
#include <QMessageBox>

#include "../scripts/handlingexternal.h"
#include "../configfiles.h"
#include "../logger.h"
#include "../settings/imageformats.h"

class PQStartup : public QObject {

    Q_OBJECT

public:
    PQStartup(QObject *parent = nullptr);

    // 0: no update
    // 1: update
    // 2: fresh install
    static int check();

    Q_INVOKABLE void setupFresh(int defaultPopout);
    Q_INVOKABLE void performChecksAndMigrations();

    static void exportData(QString path);
    static void importData(QString path);

private:
    bool checkIfBinaryExists(QString exec);
    bool migrateContextmenuToDb();
    bool migrateSettingsToDb();
    bool migrateShortcutsToDb();

};



#endif // PQSTARTUP_H
