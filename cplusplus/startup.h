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

#ifndef PQSTARTUP_H
#define PQSTARTUP_H

#include "startup/folders.h"
#include "startup/screenshots.h"
#include "startup/shortcuts.h"
#include "startup/contextmenu.h"
#include "startup/imageformats.h"
#include "startup/settings.h"

namespace PQStartup {

    static void PQStartup() {
        ::PQStartup::Folders::ensureConfigDataFoldersExist();
        ::PQStartup::Screenshots::getAndStore();
        ::PQStartup::Shortcuts::createDefaultShortcuts();
        ::PQStartup::ContextMenu::createDefault();
        ::PQStartup::ImageFormats::ensureImageFormatsDatabaseExists();
        ::PQStartup::Settings::updateNameChanges();
    }

}

#endif // PQSTARTUP_H
