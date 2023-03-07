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
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "popout when needed")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Some elements require a minimum amount of space. When the window is smaller than that, those elements can be automatically popped out to provide the space they need.")
    expertmodeonly: true
    content: [
        PQCheckbox {
            id: popout_small
            text: em.pty+qsTranslate("settingsmanager_interface", "pop out when application window is small")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            popout_small.checked = PQSettings.interfacePopoutWhenWindowIsSmall
        }

        onSaveAllSettings: {
            PQSettings.interfacePopoutWhenWindowIsSmall = popout_small.checked
        }

    }

}
