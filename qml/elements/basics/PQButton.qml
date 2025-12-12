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
import QtQuick.Controls
import PhotoQt

Loader {

    id: loader

    property string tooltip: ""

    signal clicked()
    signal rightClicked()

    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringOk: qsTranslate("buttongeneric", "Ok")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringCancel: qsTranslate("buttongeneric", "Cancel")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringSave: qsTranslate("buttongeneric", "Save")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringClose: qsTranslate("buttongeneric", "Close")

    property string text: ""
    property int horizontalAlignment: Text.AlignHCenter
    property bool flat: false

    property int fontPointSize: loader.smallerVersion ? PQCLook.fontSize : PQCLook.fontSizeL
    property int fontWeight: loader.smallerVersion ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold

    property bool sizeToText: false

    property bool forceHovered: false
    property bool enableContextMenu: true

    property int forceWidth: 0
    property bool extraWide: false
    property bool extraextraWide: false
    property bool extraSmall: false

    property bool enableRadiusModern: true

    property bool smallerVersion: false

    property bool isModern: PQCSettings.generalInterfaceVariant==="modern"

    sourceComponent: isModern ? modern_button : integrated_button

    /*******************************************************/
    /*******************************************************/
    // the modern version

    Component {

        id: modern_button

        Rectangle {

            id: modern_rect

            property int padding: loader.extraextraWide ? 300 : (loader.extraWide ? 100 : 40)

            property bool down: mouseArea.containsPress
            property bool hovered: mouseArea.containsMouse

            implicitWidth: loader.forceWidth>0 ? loader.forceWidth : (txt.width + padding)
            implicitHeight: loader.smallerVersion ? 30 : 40
            opacity: enabled ? 1 : 0.6
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            radius: loader.enableRadiusModern ? 5 : 0

            border.color: PQCLook.baseBorder
            border.width: 1

            color: (down ? palette.highlight : ((hovered||loader.forceHovered)&&enabled ? palette.alternateBase : palette.button))
            Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 150 } }

            PQText {
                id: txt
                x: (parent.width-width)/2
                y: (parent.height-height)/2
                width: loader.forceWidth ? loader.forceWidth-20 : undefined
                elide: loader.forceWidth ? Text.ElideRight : Text.ElideNone
                text: loader.text
                font.pointSize: loader.fontPointSize
                font.weight: loader.fontWeight
                opacity: enabled ? 1.0 : 0.6
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: palette.text
            }

            PQMouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: loader.text
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        loader.clicked()
                    else {
                        if(loader.enableContextMenu)
                            menu.popup()
                        else
                            loader.rightClicked()
                    }
                }
            }

            PQMenu {
                id: menu
                PQMenuItem {
                    enabled: false
                    text: loader.text
                }
                PQMenuItem {
                    text: qsTranslate("buttongeneric", "Activate button")
                    onTriggered: {
                        loader.clicked()
                    }
                }
            }


        }

    }

    /*******************************************************/
    /*******************************************************/
    // the integrated version

    Component {

        id: integrated_button

        Button {

            id: control

            text: loader.text
            flat: loader.flat

            font.pointSize: loader.fontPointSize
            font.weight: loader.fontWeight

            function onClicked() {
                loader.clicked()
            }

            contentItem: Text {
                text: control.text
                font: control.font
                color: palette.text
                horizontalAlignment: loader.horizontalAlignment
                verticalAlignment: Text.AlignVCenter
                elide: loader.sizeToText ? Text.ElideNone : Text.ElideRight
                onWidthChanged: {
                    if(loader.sizeToText)
                        control.width = implicitWidth+control.leftPadding+control.rightPadding+10
                }
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                color: PQCScriptsConfig.amIOnWindows() ? palette.button :
                                                         (control.down||loader.forceHovered ? palette.highlight : palette.button)
                border.color: PQCLook.baseBorder
                border.width: control.flat ? 0 : 1
                radius: 2
            }
            leftPadding: loader.extraSmall ? 10 : (loader.extraextraWide ? 300 : (loader.extraWide ? 100 : 40))
            rightPadding: leftPadding

            onHoveredChanged: {
                if(hovered && loader.tooltip !== "")
                    PQCNotify.showToolTip(loader.tooltip, mapToGlobal(0, -15))
                else
                    PQCNotify.hideToolTip(loader.tooltip)
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    if(loader.enableContextMenu)
                        menu.popup()
                    else
                        loader.rightClicked()
                }
            }

            PQMenu {
                id: menu
                PQMenuItem {
                    enabled: false
                    text: control.text
                }
                PQMenuItem {
                    text: qsTranslate("buttongeneric", "Activate button")
                    onTriggered: {
                        loader.clicked()
                    }
                }
            }

        }

    }

}
