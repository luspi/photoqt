#ifndef PQSTARTUP_H
#define PQSTARTUP_H

#include "startup/screenshots.h"

namespace PQStartup {

    static void PQStartup() {
        ::PQStartup::Screenshots::getAndStore();
    }

}

#endif // PQSTARTUP_H
