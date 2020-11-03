#ifndef PQSTARTUP_H
#define PQSTARTUP_H

#include "startup/folders.h"
#include "startup/screenshots.h"
#include "startup/shortcuts.h"

namespace PQStartup {

    static void PQStartup() {
        ::PQStartup::Folders::ensureConfigDataFoldersExist();
        ::PQStartup::Screenshots::getAndStore();
        ::PQStartup::Shortcuts::createDefaultShortcuts();
    }

}

#endif // PQSTARTUP_H
