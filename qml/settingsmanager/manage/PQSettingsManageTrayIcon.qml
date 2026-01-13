/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

import QtQuick
import PhotoQt

PQSetting {

    id: set_tric

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Tray Icon")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show a small icon in the system tray. The tray icon provides additional ways to control and interact with the application. It is also possible to hide PhotoQt to the system tray instead of closing. By default a colored version of the tray icon is used, but it is also possible to use a monochrome version.")

            showLineAbove: false

        },

        PQCheckBox {
            id: trayicon_show
            enforceMaxWidth: set_tric.contentWidth
            text: qsTranslate("settingsmanager", "Show tray icon")
            onCheckedChanged: set_tric.checkForChanges()
        },

        PQCheckBox {
            id: trayicon_mono
            enforceMaxWidth: set_tric.contentWidth
            enabled: trayicon_show.checked
            text: qsTranslate("settingsmanager", "monochrome icon")
            onCheckedChanged: set_tric.checkForChanges()
        },

        PQCheckBox {
            id: trayicon_hide
            enforceMaxWidth: set_tric.contentWidth
            enabled: trayicon_show.checked
            text: qsTranslate("settingsmanager", "hide to tray icon instead of closing")
            checked: (PQCSettings.interfaceTrayIcon===1)
            onCheckedChanged: set_tric.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                trayicon_show.checked = PQCSettings.getDefaultForInterfaceTrayIcon()
                trayicon_hide.checked = PQCSettings.getDefaultForInterfaceTrayIcon()
                trayicon_mono.checked = PQCSettings.getDefaultForInterfaceTrayIconMonochrome()

                set_tric.checkForChanges()

            }
        },

        /*************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Reset when hiding")

            helptext: qsTranslate("settingsmanager", "When hiding PhotoQt in the system tray, it is possible to reset PhotoQt to its initial state, thus freeing most of the memory tied up by caching. Note that this will also unload any loaded folder and image.")

        },

        PQCheckBox {
            id: trayicon_reset
            enforceMaxWidth: set_tric.contentWidth
            text: qsTranslate("settingsmanager", "reset session when hiding")
            onCheckedChanged: set_tric.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                trayicon_reset.checked = PQCSettings.getDefaultForInterfaceTrayIconHideReset()

                set_tric.checkForChanges()

            }
        }

    ]

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (trayicon_show.hasChanged() || trayicon_mono.hasChanged() ||
                                                      trayicon_hide.hasChanged() || trayicon_reset.hasChanged())

    }

    function load() {

        settingsLoaded = false

        trayicon_show.loadAndSetDefault(PQCSettings.interfaceTrayIcon>0)
        trayicon_hide.loadAndSetDefault(PQCSettings.interfaceTrayIcon===1)
        trayicon_mono.loadAndSetDefault(PQCSettings.interfaceTrayIconMonochrome)

        trayicon_reset.loadAndSetDefault(PQCSettings.interfaceTrayIconHideReset)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        if(trayicon_show.checked) {
            if(trayicon_hide.checked)
                PQCSettings.interfaceTrayIcon = 1
            else
                PQCSettings.interfaceTrayIcon = 2
        } else
            PQCSettings.interfaceTrayIcon = 0

        PQCSettings.interfaceTrayIconMonochrome = trayicon_mono.checked

        trayicon_show.saveDefault()
        trayicon_hide.saveDefault()
        trayicon_mono.saveDefault()

        PQCSettings.interfaceTrayIconHideReset = trayicon_reset.checked
        trayicon_reset.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
