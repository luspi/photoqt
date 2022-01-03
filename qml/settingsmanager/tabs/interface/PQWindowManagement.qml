/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
    title: em.pty+qsTranslate("settingsmanager_interface", "window management")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Some basic window management properties.")
    expertmodeonly: true
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: wm_manage
                text: em.pty+qsTranslate("settingsmanager_interface", "manage window through quick info labels")
            }

            PQCheckbox {
                id: wm_save
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_interface", "save and restore window geometry")
            }
            PQCheckbox {
                id: wm_keep
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_interface", "keep above other windows")
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            wm_manage.checked = PQSettings.interfaceLabelsManageWindow
            wm_save.checked = PQSettings.interfaceSaveWindowGeometry
            wm_keep.checked = PQSettings.interfaceKeepWindowOnTop
        }

        onSaveAllSettings: {
            PQSettings.interfaceLabelsManageWindow = wm_manage.checked
            PQSettings.interfaceSaveWindowGeometry = wm_save.checked
            PQSettings.interfaceKeepWindowOnTop = wm_keep.checked
        }

    }

}
