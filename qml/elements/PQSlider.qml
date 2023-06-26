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
import QtQuick.Controls

Slider {

    id: control

    orientation: Qt.Horizontal

    implicitHeight: 20

    stepSize: 1.0
    property real wheelStepSize: 1.0

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: PQCLook.baseColorDisabled

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.enabled ? PQCLook.highlightColor : PQCLook.highlightColorDisabled
            radius: 2
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            propagateComposedEvents: true
            onClicked: mouse.accepted = false
            onDoubleClicked: mouse.accepted = false
            onPressAndHold: mouse.accepted = false
            onPressed: mouse.accepted = false
            onWheel: {
                if(wheel.angleDelta.y > 0)
                    control.value -= control.wheelStepSize
                else
                    control.value += control.wheelStepSize
            }
        }

    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: control.implicitHeight
        implicitHeight: control.implicitHeight
        radius: control.implicitHeight/2
        color: control.enabled ? PQCLook.baseColorContrast : PQCLook.baseColorDisabled
        border.color: PQCLook.highlightColor
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: control.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            propagateComposedEvents: true
            onClicked: (mouse) => { mouse.accepted = false }
            onDoubleClicked: (mouse) => { mouse.accepted = false }
            onPressAndHold: (mouse) => { mouse.accepted = false }
            onPressed: (mouse) => { mouse.accepted = false }
            onWheel: (wheel) => {
                if(wheel.angleDelta.y > 0)
                    control.value -= control.wheelStepSize
                else
                    control.value += control.wheelStepSize
            }
        }
    }

}
