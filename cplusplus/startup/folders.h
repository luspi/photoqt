#ifndef PQSTARTUP_FOLDERS_H
#define PQSTARTUP_FOLDERS_H

#include "../logger.h"

namespace PQStartup {

    namespace Folders {

        static void ensureConfigDataFoldersExist() {

            QDir dir(ConfigFiles::CONFIG_DIR());
            if(!dir.exists())
                dir.mkpath(ConfigFiles::CONFIG_DIR());

            dir.setCurrent(ConfigFiles::GENERIC_DATA_DIR());
            if(!dir.exists())
                dir.mkpath(ConfigFiles::GENERIC_DATA_DIR());

            dir.setCurrent(ConfigFiles::GENERIC_CACHE_DIR());
            if(!dir.exists())
                dir.mkpath(ConfigFiles::GENERIC_CACHE_DIR());

        }

    }

}

#endif // PQSTARTUP_FOLDERS_H
