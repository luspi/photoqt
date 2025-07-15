/**************************************************************************
 **                                                                      **
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
import PQCExtensionsHandler

Row {

    id: setctrl

    width: parent.width

    property string extensionId: ""
    property alias settings: extsettings
    property alias content: cont.children

    property bool _showSetting: false

    signal hasChanged()
    signal resetToDefaults()

    ExtensionSettings {
        id: extsettings
        extensionId: setctrl.extensionId
    }

    Column {

        x: 15
        width: parent.width-30

        spacing: 10

        Rectangle {
            id: heading
            width: parent.width
            height: 50
            color: PQCLook.baseColorHighlight
            radius: 5
            Row {
                id: headingrow
                x: 5
                spacing: 5
                height: parent.height
                Image {
                    y: (parent.height-height)/2
                    height: heading.height*0.4
                    width: height
                    sourceSize: Qt.size(width, height)
                    rotation: setctrl._showSetting ? 90 : 0
                    Behavior on rotation { NumberAnimation { duration: 200 } }
                    source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg"
                }

                PQTextL {
                    y: (parent.height-height)/2
                    text: PQCExtensionsHandler.getExtensionName(setctrl.extensionId)
                    font.weight: PQCLook.fontWeightBold
                }
            }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: "<b>" + PQCExtensionsHandler.getExtensionDescription(setctrl.extensionId) + "</b><br><br>Author: " + PQCExtensionsHandler.getExtensionAuthor(setctrl.extensionId) + "<br>Contact:" + PQCExtensionsHandler.getExtensionContact(setctrl.extensionId)
                tooltipReference: headingrow
                onClicked: {
                    setctrl._showSetting = !setctrl._showSetting
                }
            }
        }

        Rectangle {
            id: contcol
            radius: 5
            width: parent.width
            height: flick.height
            clip: true
            opacity: height > 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: (opacity>0)
            color: PQCLook.baseColorActive
            Flickable {
                id: flick
                width: parent.width
                height: (setctrl._showSetting ? Math.min(500, cont.height) : 0)
                Behavior on height { NumberAnimation { duration: 200 } }
                contentHeight: cont.height
                Column {
                    id: cont
                    width: parent.width
                    spacing: 10
                }
            }
        }

    }

}
