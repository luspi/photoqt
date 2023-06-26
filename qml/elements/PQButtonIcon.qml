/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

Rectangle {

    id: control

    implicitHeight: 40
    implicitWidth: 40

    opacity: enabled ? 1 : 0.3
    radius: 5

    property string source: ""
    property bool mouseOver: false
    property bool down: false
    property bool checkable: false
    property bool checked: false

    color: ((down||checked) ? PQCLook.baseColor50 : (mouseOver ? PQCLook.baseColor75 : PQCLook.baseColor))
    Behavior on color { ColorAnimation { duration: 150 } }

    signal clicked()

    Image {

        id: icon

        source: control.source

        sourceSize: Qt.size(control.height*0.75,control.height*0.75)

        x: (parent.width-width)/2
        y: (parent.height-height)/2

    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered:
            control.mouseOver = true
        onExited:
            control.mouseOver = false
        onPressed: {
            if(checkable)
                checked = !checked
            else
                control.down = true
        }
        onReleased: {
            if(!checkable)
                control.down = false
        }
        onClicked:
            control.clicked()
    }

}
