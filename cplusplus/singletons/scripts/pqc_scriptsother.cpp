#include <scripts/pqc_scriptsother.h>
#include <QMessageBox>

PQCScriptsOther::PQCScriptsOther() {}

PQCScriptsOther::~PQCScriptsOther() {}

bool PQCScriptsOther::confirm(QString title, QString text) {
    return QMessageBox::question(nullptr, title, text)==QMessageBox::Yes;
}

void PQCScriptsOther::inform(QString title, QString text) {
    QMessageBox::information(nullptr, title, text);
}
