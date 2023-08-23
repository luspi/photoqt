#include <scripts/pqc_scriptsother.h>
#include <QMessageBox>
#include <QDateTime>

PQCScriptsOther::PQCScriptsOther() {}

PQCScriptsOther::~PQCScriptsOther() {}

qint64 PQCScriptsOther::getTimestamp() {
    return QDateTime::currentMSecsSinceEpoch();
}
