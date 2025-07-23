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
import PhotoQt.Modern

Rectangle {

    id: control

    implicitHeight: 40
    implicitWidth: 40

    opacity: enabled ? 1 : 0.5
    radius: 5

    property string overrideBaseColor: PQCLook.baseColor

    property alias source: icon.source
    property bool mouseOver: mousearea.containsMouse
    property bool down: false
    property bool checkable: false
    property bool checked: false
    property alias tooltip: mousearea.text
    property alias tooltipPartialTransparency: mousearea.tooltipPartialTransparency
    property real iconScale: 0.75
    property bool enableContextMenu: true
    property var dragTarget: undefined
    property bool dragActive: mousearea.drag.active

    property alias contextmenu: menu

    color: ((down||checked)&&enabled ? PQCLook.baseColorActive : (mouseOver&&enabled ? PQCLook.baseColorHighlight : overrideBaseColor)) 
    Behavior on color { ColorAnimation { duration: 150 } }

    signal clicked(var pos)
    signal rightClicked(var pos)

    Image {

        id: icon

        source: control.source
        smooth: false

        sourceSize: Qt.size(control.height*control.iconScale,control.height*control.iconScale)

        x: (parent.width-width)/2
        y: (parent.height-height)/2

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        drag.target: control.dragTarget
        text: control.tooltip
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onPressed: (mouse) => {
            if(mouse.button === Qt.RightButton)
                return
            if(control.checkable)
                control.checked = !control.checked
            else
                control.down = true
        }
        onReleased: {
            if(!control.checkable)
                control.down = false
        }
        onClicked: (mouse) => {
            if(control.enableContextMenu && mouse.button === Qt.RightButton) {
                menu.origPoint = Qt.point(mousearea.mouseX, mousearea.mouseY)
                menu.popup()
            } else if(mouse.button === Qt.RightButton)
                control.rightClicked(Qt.point(mousearea.mouseX, mousearea.mouseY))
            else {
                control.clicked(Qt.point(mousearea.mouseX, mousearea.mouseY))
            }
        }
    }

    PQMenu {
        id: menu
        property point origPoint
        PQMenuItem {
            visible: text!=""
            enabled: false
            font.italic: true
            text: mousearea.text
        }
        PQMenuItem {
            text: qsTranslate("buttongeneric", "Activate button")
            onTriggered: {
                control.clicked(menu.origPoint)
                if(control.checkable)
                    control.checked = !control.checked
            }
        }
    }

}
