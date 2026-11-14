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

Control {

    id: control

    /***************************************/
    // public API

    // basic slider properties
    property real from: 0.0
    property real to: 100.0
    property real value: from
    property real stepSize: 0.0

    property string suffix: ""
    property string tooltip: ""

    // most of the time we need a horizontal one
    property int orientation: Qt.Horizontal

    // optional logarithmic scaling of the slider
    property bool logarithmicScale: false

    // some properties
    // hovered is automatically provided by Control
    property bool pressed: mouseArea.pressed

    // the position of the marker
    readonly property real position: valueToPosition(value)

    // some styling
    property int handleSize: 18
    property real trackThickness: 4.0

    // the colors are taken from the palette
    readonly property color trackColor: palette.mid
    readonly property color progressColor: palette.highlight
    readonly property color handleColor: palette.base
    readonly property color handleBorderColor: palette.highlight
    readonly property color disabledTrackColor: palette.mid
    readonly property color disabledProgressColor: palette.disabled.highlight
    readonly property color disabledHandleColor: palette.mid

    // wheel/keyboard enable?
    property bool keyboardEnabled: true
    wheelEnabled: true

    // the wheel step size, adapted dynamically unless a manual stepSize is provided
    property real wheelStepSize: (stepSize > 0 ? stepSize : (to-from)/100.)

    // some general signals sliders have
    signal moved()
    signal valueModified()

    /***************************************/
    // configuration

    readonly property bool _horizontal: (orientation === Qt.Horizontal)

    implicitWidth: _horizontal ? 200 : 32
    implicitHeight: _horizontal ? 32 : 200

    padding: handleSize / 2

    // accept focus by tabbing and clicking
    focusPolicy: Qt.StrongFocus

    /***************************************/
    // value handling

    // make sure the value is in the valid range of values
    function clampValue(v) {
        return Math.max(Math.min(from, to), Math.min(Math.max(from, to), v))
    }

    // normalize the value based on the configuration
    function normalizeValue(v) {
        v = clampValue(v)
        if(stepSize > 0) {
            v = from + Math.round((v-from)/stepSize) * stepSize
            v = clampValue(v)
        }
        return v
    }

    // transform the value using log function
    function transformedValue(v) {
        if(v !== 0)
            return Math.log(v)
        return 0
    }

    // transform the value back from the log using the exp function
    function inverseTransformedValue(v) {
        return Math.exp(v)
    }

    // convert actual value into normalized slider position
    function valueToPosition(v) {

        v = clampValue(v)

        if(!control.logarithmicScale)
            return (v-from)/(to-from)

        const _f = transformedValue(from)
        const _t = transformedValue(to)
        const _v = transformedValue(v)

        return Math.max(0, Math.min(1, (_v - _f) / (_t - _f)))
    }

    // convert normalized slider position into actual value
    function positionToValue(p) {

        p = Math.max(0, Math.min(1, p))

        if(!control.logarithmicScale)
            return from + p*(to-from)

        const _f = transformedValue(from)
        const _t = transformedValue(to)

        return inverseTransformedValue(_f + p*(_t-_f))
    }

    function setPosition(p) {

        const newValue = normalizeValue(positionToValue(p))

        if(newValue !== value) {
            value = newValue
            moved()
        }
    }

    function increase() {
        const amount = stepSize > 0 ? stepSize : (to-from)/100
        setPosition(valueToPosition(value+amount))
    }

    function decrease() {
        const amount = stepSize > 0 ? stepSize : (to-from)/100
        setPosition(valueToPosition(value-amount))
    }

    function setToMinimum() {
        value = from
        moved()
    }

    function setToMaximum() {
        value = to
        moved()
    }

    /***************************************/
    // property validation

    onValueChanged: {
        const normalized = normalizeValue(value)
        if(normalized !== value)
            value = normalized
    }

    onFromChanged: {
        value = normalizeValue(value)
    }

    onToChanged: {
        value = normalizeValue(value)
    }

    /***************************************/
    // background and handle items

    contentItem: Item {

        id: sliderContent

        // mouse and touch interaction
        PQMouseArea {

            id: mouseArea

            anchors.fill: parent

            text: (control.tooltip==="" ? Math.round(control.value) : control.tooltip) + control.suffix

            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

            function positionFromMouse(mouse) {
                let p
                if(control._horizontal) {
                    const available = width - control.handleSize
                    p = available > 0 ? (mouse.x-control.handleSize/2)/available : 0
                    if(Qt.application.layoutDirection === Qt.RightToLeft)
                        p = 1.0 - p
                } else {
                    const available = height -control.handleSize
                    // vertical sliders increase from bottom to top
                    p = available > 0 ? 1.0-(mouse.y-control.handleSize/2)/available : 0
                }
                return Math.max(0, Math.min(1, p))

            }

            onPressed: function(mouse) {
                control.forceActiveFocus()
                control.setPosition(positionFromMouse(mouse))
            }

            onPositionChanged: function(mouse) {
                if(pressed)
                    control.setPosition(positionFromMouse(mouse))
            }

            onReleased: {
                control.valueModified()
            }

            onWheel: function(wheel) {
                if(!control.wheelEnabled || !control.enabled) {
                    return
                }
                if(wheel.angleDelta.y > 0) {
                    control.increase()
                } else if(wheel.angleDelta.y < 0) {
                    control.decrease()
                }
                control.valueModified()
                wheel.accepted = true

            }
        }

        // the track
        Rectangle {

            id: track

            color: control.enabled ? control.trackColor : control.disabledTrackColor
            border.width: control.enabled ? 0 : 1
            border.color: control.trackColor
            radius: height/2

            x: control._horizontal ? control.handleSize/2 : (parent.width-width)/2
            y: control._horizontal ? (parent.height-height)/2 : control.handleSize/2
            width: control._horizontal ? Math.max(0, parent.width-control.handleSize) : control.trackThickness
            height: control._horizontal ? control.trackThickness : Math.max(0, parent.height-control.handleSize)

        }

        // the progress indicator
        Rectangle {

            id: progress

            color: control.enabled ? control.progressColor : control.disabledProgressColor
            radius: track.radius

            x: track.x
            y: control._horizontal ? track.y : track.y + track.height*(1-control.position)
            width: control._horizontal ? track.width*control.position : track.width
            height: control._horizontal ? track.height : track.height*control.position

        }

        // the handle
        Rectangle {

            id: handle

            x: control._horizontal ? (track.x + track.width*control.position - width/2) : ((parent.width - width)/2)
            y: control._horizontal ? ((parent.height-height)/2) : (track.y+track.height*(1-control.position)-height/2)
            width: control.handleSize
            height: control.handleSize

            radius: width/2
            color: control.enabled ? control.handleColor : control.disabledHandleColor
            border.width: 1
            border.color: control.enabled ? control.handleBorderColor : control.disabledTrackColor

            scale: control.pressed ? 1.12 : (control.hovered ? 1.05 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100 } }

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
