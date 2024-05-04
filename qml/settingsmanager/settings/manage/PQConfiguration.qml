/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import QtQuick.Controls

import PQCNotify
import PQCScriptsConfig

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        width: parent.width

        spacing: 10

        PQSetting {

            id: set_reset

            //: Settings title
            title: qsTranslate("settingsmanager", "Reset settings and shortcuts")

            helptext: qsTranslate("settingsmanager", "Here the various configurations of PhotoQt can be reset to their defaults. Once you select one of the below categories you have a total of 5 seconds to cancel the action. After the 5 seconds are up the respective defaults will be set. This cannot be undone.")

            content: [

                PQButton {
                    text: qsTranslate("settingsmanager", "reset settings")
                    width: Math.min(400, set_reset.rightcol)
                    enabled: cancel.height===0
                    onClicked: {
                        cancel.action = "settings"
                        cancel.show()
                    }
                },

                PQButton {
                    text: qsTranslate("settingsmanager", "reset shortcuts")
                    width: Math.min(400, set_reset.rightcol)
                    enabled: cancel.height===0
                    onClicked: {
                        cancel.action = "shortcuts"
                        cancel.show()
                    }
                },

                PQButton {
                    text: qsTranslate("settingsmanager", "reset enabled file formats")
                    width: Math.min(400, set_reset.rightcol)
                    enabled: cancel.height===0
                    onClicked: {
                        cancel.action = "formats"
                        cancel.show()
                    }
                },

                Item {

                    id: cancel

                    width: set_reset.rightcol
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
                                    PQCNotify.resetSettingsToDefault()
                                else if(cancel.action === "shortcuts")
                                    PQCNotify.resetShortcutsToDefault()
                                else if(cancel.action === "formats")
                                    PQCNotify.resetFormatsToDefault()

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

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_expimp

            //: Settings title
            title: qsTranslate("settingsmanager", "Export/Import configuration")

            helptext: qsTranslate("settingsmanager", "Here you can create a backup of the configuration for backup or for moving it to another install of PhotoQt. You can import a local backup below. After importing a backup file PhotoQt will automatically close as it will need to be restarted for the changes to take effect.")

            content: [

                PQButton {
                    text: qsTranslate("settingsmanager", "export configuration")
                    width: Math.min(400, set_expimp.rightcol)
                    onClicked:
                        PQCScriptsConfig.exportConfigTo("")
                },

                PQButton {
                    text: qsTranslate("settingsmanager", "import configuration")
                    width: Math.min(400, set_expimp.rightcol)
                    onClicked: {
                        if(PQCScriptsConfig.importConfigFrom("")) {
                            PQCScriptsConfig.inform(qsTranslate("settingsmanager", "Restart required"),
                                                    qsTranslate("settingsmanager", "PhotoQt will now quit as it needs to be restarted for the changes to take effect."))
                            toplevel.quitPhotoQt()
                        }
                    }
                }

            ]
        }


    }

    Component.onCompleted:
        load()

    function checkDefault() {}

    function load() {}

    function applyChanges() {}

    function revertChanges() {
        load()
    }

}
