/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

import QtQuick 2.9

PQFileTypeTile {

    title: "DevIL"

    available: PQImageFormats.getAvailableEndingsWithDescriptionDevIL()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsDevIL()
    currentlyEnabled: PQImageFormats.enabledFileformatsDevIL
    projectWebpage: ["openil.sourceforge.net", "http://openil.sourceforge.net"]
    description: em.pty+qsTranslate("settingsmanager_filetypes", "The Developer's Image Library (DevIL) supports a large number of image formats, many of which have been successfully tested with PhotoQt.")

    iconsource: "/settingsmanager/filetypes/devil.jpg"

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsDevIL = c
        }

    }

    Component.onCompleted: {
        resetChecked()
    }
}
