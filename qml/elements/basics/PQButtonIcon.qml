/**************************************************************************
 **                                                                      **
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
import QtQuick.Controls
import PhotoQt

Loader {

    id: loader

    property string tooltip: ""
    property string source: ""
    property real iconScale: isModern ? 0.75 : 1
    property int tooltipWidth: 0
    property int tooltipDelay: 0
    property int cursorShape: Qt.ArrowCursor

    property bool down: false
    property bool hovered: false

    property bool enableContextMenu: true

    property Item dragTarget

    property bool checkable: false
    property bool checked: false

    signal clicked()
    signal rightClicked()

    property bool isModern: PQCSettings.generalInterfaceVariant==="modern"

    sourceComponent: isModern ? modern_button : integrated_button

    Component {

        id: modern_button

        Rectangle {

            id: control

            implicitHeight: 40
            implicitWidth: 40

            opacity: enabled ? 1 : 0.5
            radius: 5

            color: ((loader.down||loader.checked)&&enabled ? palette.highlight : (loader.hovered&&enabled ? palette.alternateBase : palette.button))
            Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 150 } }

            Image {

                id: icon

                source: loader.source
                smooth: false

                sourceSize: Qt.size(control.height*loader.iconScale,control.height*loader.iconScale)

                x: (parent.width-width)/2
                y: (parent.height-height)/2

            }

            PQMouseArea {
                id: mousearea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: loader.dragTarget
                text: loader.tooltip
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onEntered:
                    loader.hovered = true
                onExited:
                    loader.hovered = false
                onPressed: (mouse) => {
                    if(mouse.button === Qt.RightButton)
                        return
                    if(loader.checkable)
                        loader.checked = !loader.checked
                    else
                        loader.down = true
                }
                onReleased: {
                    if(!loader.checkable)
                        loader.down = false
                }
                onClicked: (mouse) => {
                    if(loader.enableContextMenu && mouse.button === Qt.RightButton) {
                        menu.popup()
                    } else if(mouse.button === Qt.RightButton) {
                        loader.rightClicked()
                    } else {
                        loader.clicked()
                    }
                }
            }

            PQMenu {
                id: menu
                PQMenuItem {
                    visible: text!==""
                    enabled: false
                    text: loader.tooltip
                }
                PQMenuItem {
                    text: qsTranslate("buttongeneric", "Activate button")
                    onTriggered: {
                        loader.clicked()
                        if(loader.checkable)
                            loader.checked = !loader.checked
                    }
                }
            }

        }

    }

    Component {

        id: integrated_button

        Button {

            id: control

            implicitHeight: 40
            implicitWidth: 40

            onDownChanged:
                loader.down = down
            onHoveredChanged:
                loader.hovered = hovered

            onClicked:
                loader.clicked()

            checked: loader.checked
            checkable: loader.checkable
            onCheckedChanged: {
                if(loader.checked !== checked)
                    loader.checked = checked
                checked = Qt.binding(function() { return loader.checked })
            }

            opacity: enabled ? 1 : 0.5

            flat: true

            Image {
                anchors.fill: parent
                anchors.margins: 5
                smooth: true
                mipmap: true
                sourceSize: Qt.size(width, height)
                source: loader.source
                scale: loader.iconScale
            }

            MouseArea {
                id: mousearea
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                drag.target: loader.dragTarget
                cursorShape: loader.cursorShape
                onClicked: (mouse) => {
                    if(loader.enableContextMenu)
                        menu.popup()
                    else
                        loader.rightClicked()
                }
            }

            PQToolTip {

                id: ttip

                x: (parent != null ? (parent.width-width)/2 : 0)
                y: -height-5

                text: loader.tooltip

                Component.onCompleted: {
                    loader.tooltipDelay = delay
                    loader.tooltipWidth = width
                }

            }

            PQMenu {
                id: menu
                PQMenuItem {
                    enabled: false
                    text: loader.tooltip
                }
                PQMenuItem {
                    text: qsTranslate("buttongeneric", "Activate button")
                    onTriggered: {
                        loader.clicked()
                        if(loader.checkable)
                            loader.checked = !loader.checked
                    }
                }
            }

        }

    }

}
