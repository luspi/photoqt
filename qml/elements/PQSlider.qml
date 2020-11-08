/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

Slider {

    id: control

    orientation: Qt.Horizontal

    stepSize: 1.0

    hoverEnabled: true

    implicitHeight: 20

    property real wheelStepSize: 1.0

    property int divideToolTipValue: 1
    property alias tooltip: handletooltip.text
    property string toolTipPrefix: ""
    property string toolTipSuffix: ""
    property bool handleToolTipEnabled: true
    property bool sliderToolTipEnabled: true

    property int overrideBackgroundHeight: -1

    property int convertToolTipValueToTimeWithDuration: -1

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: overrideBackgroundHeight==-1 ? 6 : overrideBackgroundHeight
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: "#565656"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.enabled ? "#eeeeee" : "#666666"
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
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        color: control.enabled ? (control.pressed ? "#f0f0f0" : "#f6f6f6") : "#777777"
        border.color: "#bdbebf"
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: control.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
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

    PQToolTip {
        id: handletooltip
        parent: control.handle
        visible: control.pressed&&handleToolTipEnabled&&text!=""
        delay: 0
        text: convertToolTipValueToTimeWithDuration == -1
                    ? (toolTipPrefix + (control.value/divideToolTipValue) + toolTipSuffix)
                    : (toolTipPrefix + handlingGeneral.convertSecsToProperTime(control.value/divideToolTipValue, convertToolTipValueToTimeWithDuration) + toolTipSuffix)
    }

    PQToolTip {
        id: slidertooltip
        parent: control
        visible: control.hovered&&sliderToolTipEnabled&&!handletooltip.visible&&text!=""
        delay: 0
        text: handletooltip.text
    }

}
