#ifndef PQSTARTUP_H
#define PQSTARTUP_H

#include <QObject>
#include <QFile>
#include <QtSql>
#include <QMessageBox>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QDesktopServices>

#include "../configfiles.h"
#include "../logger.h"

class PQStartup : public QDialog {

    Q_OBJECT

public:
    PQStartup(const int check, QWidget *parent = nullptr);

    // 0: no update
    // 1: update
    // 2: fresh install
    static int check();

protected:
    virtual void hideEvent(QHideEvent *e);
    int checker;

private slots:
    void linkClicked(const QString &url);

    void setupFresh();
    void performChecksAndMigrations();

};



#endif // PQSTARTUP_H
