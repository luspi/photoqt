#include "startupcheck.h"

int StartupCheck::ExportImport::handleExportImport(SingleInstance *a) {

    if(a->exportAndQuitNow != "") {
        GetAndDoStuffExternal external;
        QString ret = external.exportConfig(a->exportAndQuitNow);
        if(ret == "-")
            LOG << CURDATE << "Exporting was aborted by user... I will quit now!" << NL;
        else if(ret != "")
            LOG << CURDATE << "Exporting configuration failed!" << NL;
        else
            LOG << CURDATE << "Configuration successfully exported... I will quit now!" << NL;
        QMetaObject::invokeMethod(qApp, "quit", Qt::QueuedConnection);
        return a->exec();
    }
    if(a->importAndQuitNow != "") {
        GetAndDoStuffExternal external;
        QString ret = external.importConfig(a->importAndQuitNow);
        if(ret != "")
            LOG << CURDATE << "Importing configuration failed!" << NL;
        else
            LOG << CURDATE << "Configuration successfully imported... I will quit now!" << NL;
        QMetaObject::invokeMethod(qApp, "quit", Qt::QueuedConnection);
        return a->exec();
    }

    // return value of -1 means: just ignore this and keep going normally, nothing happened
    return -1;

}
