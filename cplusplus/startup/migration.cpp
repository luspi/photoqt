#include "startupcheck.h"

void StartupCheck::Migration::migrateIfNecessary() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Migration" << NL;

    QFile oldDisabledImageFormats(QString("%1/fileformats.disabled").arg(ConfigFiles::CONFIG_DIR()));
    if(oldDisabledImageFormats.exists()) {

        if(oldDisabledImageFormats.remove())
            LOG << CURDATE << "StartupCheck::Migration: old file with disabled image formats removed" << NL;
        else
            LOG << CURDATE << "StartupCheck::Migration: old file with disabled image formats could not be removed" << NL;

    }

}
