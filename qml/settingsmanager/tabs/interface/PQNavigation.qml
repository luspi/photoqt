/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "navigation buttons")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Some buttons to help with navigation. These can come in handy when, e.g., operating with a touch screen.")
    expertmodeonly: false
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: navcheck1
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_interface", "buttons next to window buttons")
            }
            PQCheckbox {
                id: navcheck2
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_interface", "floating buttons")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            navcheck1.checked = PQSettings.interfaceNavigationTopRight
            navcheck2.checked = PQSettings.interfaceNavigationFloating
        }

        onSaveAllSettings: {

            PQSettings.interfaceNavigationTopRight = navcheck1.checked
            PQSettings.interfaceNavigationFloating = navcheck2.checked

            if(navcheck2.checked)
                loader.ensureItIsReady("navigationfloating")
        }

    }

}
