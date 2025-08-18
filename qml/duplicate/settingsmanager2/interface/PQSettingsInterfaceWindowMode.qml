/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Column {

    id: setting_top

    width: parent.width

    PQSetting {

        id: set_windowmode

        helptext: qsTranslate("settingsmanager", "There are two main states that the application window can be in. It can either be in fullscreen mode or in window mode. In fullscreen mode, PhotoQt will act more like a floating layer that allows you to quickly look at images. In window mode, PhotoQt can be used in combination with other applications. When in window mode, it can also be set to always be above any other windows, and to remember the window geometry in between sessions.")

        //: A settings title
        title: qsTranslate("settingsmanager", "Fullscreen or window mode")

        content: [

            Flow {
                width: set_windowmode.width
                PQRadioButton {
                    id: fsmode
                    text: qsTranslate("settingsmanager", "fullscreen mode")
                    onCheckedChanged: set_windowmode.checkForChanges()
                }

                PQRadioButton {
                    id: wmmode
                    text: qsTranslate("settingsmanager", "window mode")
                    onCheckedChanged: set_windowmode.checkForChanges()
                }
            },

            Item {
                width: 1
                height: 5
            },

            Column {

                spacing: 15
                width: set_windowmode.width

                enabled: wmmode.checked
                height: enabled ? (keeptop.height+rememgeo.height+wmdeco_show.height+2*15) : 0
                Behavior on height { NumberAnimation { duration: 200 } }
                opacity: enabled ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }


                PQCheckBox {
                    id: keeptop
                    enforceMaxWidth: set_windowmode.width
                    text: qsTranslate("settingsmanager", "keep above other windows")
                    onCheckedChanged: set_windowmode.checkForChanges()
                }
                PQCheckBox {
                    id: rememgeo
                    enforceMaxWidth: set_windowmode.width
                    //: remember the geometry of PhotoQts window between sessions
                    text: qsTranslate("settingsmanager", "remember its geometry ")
                    onCheckedChanged: set_windowmode.checkForChanges()
                }
                PQCheckBox {
                    id: wmdeco_show
                    enforceMaxWidth: set_windowmode.width
                    text: qsTranslate("settingsmanager", "enable window decoration")
                    onCheckedChanged: set_windowmode.checkForChanges()
                }

            }

        ]

        onResetToDefaults: {

            var wmmode_val = PQCSettings.getDefaultForInterfaceWindowMode()
            var keeptop_val = PQCSettings.getDefaultForInterfaceKeepWindowOnTop()
            var rememgeo_val = PQCSettings.getDefaultForInterfaceSaveWindowGeometry()
            var wmdeco_val = PQCSettings.getDefaultForInterfaceWindowDecoration()

            fsmode.checked = (wmmode_val===0)
            wmmode.checked = (wmmode_val===1)

            keeptop.checked = (keeptop_val===1)
            rememgeo.checked = (rememgeo_val===1)
            wmdeco_show.checked = (wmdeco_val===1)

            thisSettingHasChanged = false

        }

        onThisSettingHasChangedChanged:
            setting_top.checkForChanges()

        function handleEscape() {}

        function checkForChanges() {
            if(!settingsLoaded) return
            thisSettingHasChanged = (wmmode.hasChanged() || keeptop.hasChanged() || rememgeo.hasChanged() || wmdeco_show.hasChanged())
        }

        function load() {

            settingsLoaded = false

            fsmode.loadAndSetDefault(!PQCSettings.interfaceWindowMode)
            wmmode.loadAndSetDefault(!fsmode.checked)

            keeptop.loadAndSetDefault(PQCSettings.interfaceKeepWindowOnTop)
            rememgeo.loadAndSetDefault(PQCSettings.interfaceSaveWindowGeometry)

            wmdeco_show.loadAndSetDefault(PQCSettings.interfaceWindowDecoration)

            thisSettingHasChanged = false
            settingsLoaded = true

        }

        function applyChanges() {

            PQCSettings.interfaceWindowMode = wmmode.checked

            PQCSettings.interfaceKeepWindowOnTop = keeptop.checked
            PQCSettings.interfaceSaveWindowGeometry = rememgeo.checked

            PQCSettings.interfaceWindowDecoration = wmdeco_show.checked

            fsmode.saveDefault()
            wmmode.saveDefault()

            keeptop.saveDefault()
            rememgeo.saveDefault()

            wmdeco_show.saveDefault()

        }

    }

    function checkForChanges() {
        PQCConstants.settingsManagerSettingChanged = set_windowmode.thisSettingHasChanged
    }

}
