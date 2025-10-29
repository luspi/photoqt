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
import PhotoQt

PQSetting {

    id: set_mana

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Reset PhotoQt")

            helptext: qsTranslate("settingsmanager", "Here the various configurations of PhotoQt can be reset to their defaults. Once you select one of the below categories you have a total of 5 seconds to cancel the action. After the 5 seconds are up the respective defaults will be set. This cannot be undone.")

            showLineAbove: false

        },

        PQButton {
            id: butresetSet
            text: qsTranslate("settingsmanager", "reset settings")
            width: Math.min(400, set_mana.contentWidth)
            enabled: cancel.height===0
            onClicked: {
                cancel.action = "settings"
                cancel.show()
            }
        },

        PQButton {
            id: butresetSh
            text: qsTranslate("settingsmanager", "reset shortcuts")
            width: Math.min(400, set_mana.contentWidth)
            enabled: cancel.height===0
            onClicked: {
                cancel.action = "shortcuts"
                cancel.show()
            }
        },

        PQButton {
            id: butresetFf
            text: qsTranslate("settingsmanager", "reset enabled file formats")
            width: Math.min(400, set_mana.contentWidth)
            enabled: cancel.height===0
            onClicked: {
                cancel.action = "formats"
                cancel.show()
            }
        },

        Item {

            id: cancel

            width: set_mana.contentWidth
            height: enabled ? cancelcol.height : 0
            opacity: enabled ? 1 : 0
            clip: true
            enabled: false

            Behavior on height { NumberAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            property string action: ""
            property int timeout: 5

            Column {

                id: cancelcol

                spacing: 15

                PQTextL {
                    text: qsTranslate("settingsmanager", "You can still cancel this action.")
                }

                PQTextL {
                    //: Please don't forget the placeholder. It will be replaced by the number of seconds.
                    text: qsTranslate("settingsmanager", "%1 seconds remaining!").arg(cancel.timeout)
                }

                PQButton {
                    id: butcancelaction
                    text: genericStringCancel
                    onClicked: cancel.hide()
                }

            }

            Timer {
                id: remaining
                interval: 1000
                running: cancel.visible&&!performingAction&&cancel.action!=""
                property bool performingAction: false
                repeat: true
                onTriggered: {
                    if(cancel.timeout === 1) {

                        performingAction = true

                        if(cancel.action === "settings")
                            PQCSettings.resetToDefault()
                        else if(cancel.action === "shortcuts")
                            PQCShortcuts.resetToDefault()
                        else if(cancel.action === "formats")
                            PQCImageFormats.resetToDefault()

                        cancel.action = ""

                        cancel.hide()

                        performingAction = false

                    } else
                        cancel.timeout -= 1
                }
            }

            function show() {
                timeout = 5
                remaining.performingAction = false
                enabled = true
            }
            function hide() {
                cancel.action = ""
                enabled = false
            }

        },

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Export/Import configuration")

            helptext: qsTranslate("settingsmanager", "Here you can create a backup of the configuration for backup or for moving it to another install of PhotoQt. You can import a local backup below. After importing a backup file PhotoQt will automatically close as it will need to be restarted for the changes to take effect.")

        },

        PQButton {
            id: butexport
            text: qsTranslate("settingsmanager", "export configuration")
            width: Math.min(400, set_mana.contentWidth)
            onClicked: {

                PQCShortcuts.closeDatabase()
                PQCSettings.closeDatabase()
                PQCImageFormats.closeDatabase()

                PQCScriptsConfig.exportConfigTo("")

                PQCShortcuts.reopenDatabase()
                PQCSettings.reopenDatabase()
                PQCImageFormats.reopenDatabase()

            }
        },

        PQButton {
            id: butimport
            text: qsTranslate("settingsmanager", "import configuration")
            width: Math.min(400, set_mana.contentWidth)
            onClicked: {

                PQCShortcuts.closeDatabase()
                PQCSettings.closeDatabase()
                PQCImageFormats.closeDatabase()

                if(PQCScriptsConfig.importConfigFrom("")) {
                    PQCScriptsConfig.inform(qsTranslate("settingsmanager", "Restart required"),
                                            qsTranslate("settingsmanager", "PhotoQt will now quit as it needs to be restarted for the changes to take effect."))
                    PQCNotify.photoQtQuit()
                } else {
                    PQCScriptsConfig.inform(qsTranslate("settingsmanager", "Import failed"),
                                            qsTranslate("settingsmanager", "The configuration could not be imported."))
                }
            }
        }

    ]

    function handleEscape() {}

    function checkForChanges() {}

    function load() {}

    function applyChanges() {}

}
