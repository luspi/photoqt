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
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "window mode")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Whether to run PhotoQt in window mode or fullscreen.")
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: mode_enable
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_interface", "run in window mode")
            }
            PQCheckbox {
                id: mode_enable_deco
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_interface", "show window decoration")
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            mode_enable.checked = PQSettings.interfaceWindowMode
            mode_enable_deco.checked = PQSettings.interfaceWindowDecoration
        }

        onSaveAllSettings: {
            PQSettings.interfaceWindowMode = mode_enable.checked
            PQSettings.interfaceWindowDecoration = mode_enable_deco.checked
        }

    }

}
