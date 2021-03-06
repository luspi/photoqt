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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title. The hot edge refers to the area along the edges of PhotoQt where the mouse cursor triggers an action (e.g., showing the thumbnails or the main menu)
    title: em.pty+qsTranslate("settingsmanager_interface", "quick navigation")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Some buttons to help with quick navigation. These can come in handy when, e.g., operating with a touch screen.")
    expertmodeonly: false
    content: [
        PQCheckbox {
            id: navcheck
            text: em.pty+qsTranslate("settingsmanager_interface", "Show quick navigation buttons")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            navcheck.checked = PQSettings.quickNavigation
        }

        onSaveAllSettings: {
            PQSettings.quickNavigation = navcheck.checked
            if(navcheck.checked)
                loader.ensureItIsReady("quicknavigation")
        }

    }

}
