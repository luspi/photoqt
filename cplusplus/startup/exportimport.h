#ifndef PQSTARTUP_EXPORTIMPORT_H
#define PQSTARTUP_EXPORTIMPORT_H

#include "../logger.h"
#include "../scripts/handlingexternal.h"

namespace PQStartup {

    namespace Export {

        static void perform(QString path) {
            PQHandlingExternal external;
            bool ret = external.exportConfigTo(path);
            if(ret)
                LOG << CURDATE << "Configuration successfully exported... I will quit now!" << NL;
            else
                LOG << CURDATE << "Configuration was not exported... I will quit now!" << NL;
        }

    }

    namespace Import {

        static void perform(QString path) {
            PQHandlingExternal external;
            bool ret = external.importConfigFrom(path);
            if(ret)
                LOG << CURDATE << "Configuration successfully imported... I will quit now!" << NL;
            else
                LOG << CURDATE << "Configuration was not imported... I will quit now!" << NL;
        }

    }

}

#endif // STARTUPCHECK_EXPORTIMPORT_H
