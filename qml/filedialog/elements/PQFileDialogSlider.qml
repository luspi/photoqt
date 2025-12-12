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

Slider {

    id: control

    orientation: Qt.Horizontal
    live: true

    implicitHeight: _horizontal ? 20 : (extraWide ? 300 : (extraSmall ? 150 : 200))
    implicitWidth: _horizontal ? (extraWide ? 300 : (extraSmall ? 150 : 200)) : 20

    stepSize: 1.0
    property real wheelStepSize: 1.0

    property bool _horizontal: (orientation==Qt.Horizontal)

    property bool handleContainsMouse: false
    property bool sliderContainsMouse: false
    property bool backgroundContainsMouse: false

    property bool reverseWheelChange: false

    property bool extraSmall: false
    property bool extraWide: false

    property string suffix: ""
    property string tooltip: ""

    snapMode: Slider.SnapAlways

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        z: parent.z-1
        onEntered: {
            control.backgroundContainsMouse = true
        }
        onExited: {
            control.backgroundContainsMouse = false
        }
    }

    background: Rectangle {
        x: control._horizontal ? control.leftPadding : (control.leftPadding + control.availableWidth / 2 - width / 2)
        y: control._horizontal ? (control.topPadding + control.availableHeight / 2 - height / 2) : control.topPadding
        implicitWidth: control._horizontal ? 200 : 6
        implicitHeight: control._horizontal ? 6 : 200
        width: control._horizontal ? control.availableWidth : implicitWidth
        height: control._horizontal ? implicitHeight : control.availableHeight
        radius: 2
        color: PQCLook.baseBorder

        Rectangle {
            width: control._horizontal ? (control.visualPosition * (parent.width-control.implicitHandleWidth)) : parent.width
            height: control._horizontal ? parent.height : (control.visualPosition * (parent.height-control.implicitHandleHeight))
            color: palette.text
            opacity: control.enabled ? 1 : 0.6
            radius: 2
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            propagateComposedEvents: true
            onClicked: (mouse) => { mouse.accepted = false }
            onDoubleClicked: (mouse) => { mouse.accepted = false }
            onPressAndHold: (mouse) => { mouse.accepted = false }
            onPressed: (mouse) => { mouse.accepted = false }
            onEntered: {
                control.sliderContainsMouse = true
            }
            onExited: {
                control.sliderContainsMouse = false
            }
            onWheel: (wheel) => {
                // if(!control.wheelEnabled) return
                if(control.reverseWheelChange) {
                    if(wheel.angleDelta.y > 0)
                        control.value += control.wheelStepSize
                    else
                        control.value -= control.wheelStepSize
                } else {
                    if(wheel.angleDelta.y > 0)
                        control.value -= control.wheelStepSize
                    else
                        control.value += control.wheelStepSize
                }
            }
        }

    }

    handle: Rectangle {
        x: control._horizontal ? (control.leftPadding + control.visualPosition * (control.availableWidth - width)) : (control.leftPadding + control.availableWidth / 2 - width / 2)
        y: control._horizontal ? (control.topPadding + control.availableHeight / 2 - height / 2) : (control.topPadding + control.visualPosition * (control.availableHeight - height))
        implicitWidth: control._horizontal ? control.implicitHeight : control.implicitWidth
        implicitHeight: control._horizontal ? control.implicitHeight : control.implicitWidth
        radius: control.implicitHeight/2
        color: palette.text
        border.color: palette.base
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: control.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            propagateComposedEvents: true
            onClicked: (mouse) => { mouse.accepted = false }
            onDoubleClicked: (mouse) => { mouse.accepted = false }
            onPressAndHold: (mouse) => { mouse.accepted = false }
            onPressed: (mouse) => { mouse.accepted = false }
            onEntered: control.handleContainsMouse = true
            onExited: control.handleContainsMouse = false
            onWheel: (wheel) => {
                if(!control.wheelEnabled) return
                if(control.reverseWheelChange) {
                    if(wheel.angleDelta.y > 0)
                        control.value += control.wheelStepSize
                    else
                        control.value -= control.wheelStepSize
                } else {
                    if(wheel.angleDelta.y > 0)
                        control.value -= control.wheelStepSize
                    else
                        control.value += control.wheelStepSize
                }
            }
        }
    }

    property int _defaultValue
    Component.onCompleted: {
        _defaultValue = value
    }

    function saveDefault() {
        _defaultValue = value
    }

    function setDefault(val : int) {
        _defaultValue = val
    }

    function loadAndSetDefault(val : int) {
        value = val
        _defaultValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==value
    }

}
