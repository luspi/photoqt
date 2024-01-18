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

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Reset settings and shortcuts")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Here the various configurations of PhotoQt can be reset to their defaults. Once you select one of the below categories you have a total of 5 seconds to cancel the action. After the 5 seconds are up the respective defaults will be set. This cannot be undone.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        PQButton {
            id: config_export
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "reset settings")
            width: 400
            enabled: !cancel.visible
            onClicked: {
                cancel.action = "settings"
                cancel.show()
            }
        }

        Item {
            width: 1
            height: 1
        }

        PQButton {
            id: config_import
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "reset shortcuts")
            width: 400
            enabled: !cancel.visible
            onClicked: {
                cancel.action = "shortcuts"
                cancel.show()
            }
        }

        Item {
            width: 1
            height: 1
        }

        PQButton {
            id: config_formats
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "reset enabled file formats")
            width: 400
            enabled: !cancel.visible
            onClicked: {
                cancel.action = "formats"
                cancel.show()
            }
        }

        /**********************************************************************/

        Item {
            width: 1
            height: 40
        }

        Column {

            id: cancel

            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

            property int timeout: 5
            property string action: ""

            width: parent.width
            spacing: 15

            PQTextL {
                id: cancel1
                x: (parent.width-width)/2
                text: qsTranslate("settingsmanager", "You can still cancel this action. Seconds remaining:")
            }

            PQTextXL {
                id: cancel2
                x: (parent.width-width)/2
                text: parent.timeout
            }

            PQButton {
                id: cancel3
                x: (parent.width-width)/2
                text: genericStringCancel
                onClicked: cancel.hide()
            }

            Timer {
                id: remaining
                interval: 1000
                running: cancel.visible&&!performingAction
                property bool performingAction: false
                repeat: true
                onTriggered: {
                    if(cancel.timeout == 1) {

                        performingAction = true

                        if(cancel.action === "settings")
                            PQCNotify.resetSettingsToDefault()
                        else if(cancel.action === "shortcuts")
                            PQCNotify.resetShortcutsToDefault()
                        else if(cancel.action === "formats")
                            PQCNotify.resetFormatsToDefault()

                        // do action

                        cancel.opacity = 0

                        performingAction = false

                    } else
                        cancel.timeout -= 1
                }
            }

            function show() {
                cancel.timeout = 5
                cancel.opacity = 1
            }
            function hide() {
                cancel.opacity = 0
            }

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
