#include "handlingfilemanagement.h"
#include <QtDebug>

bool PQHandlingFileManagement::renameFile(QString dir, QString oldName, QString newName) {

    QFile file(dir + "/" + oldName);
    return file.rename(dir + "/" + newName);

}
