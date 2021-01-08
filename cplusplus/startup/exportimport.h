/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

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
