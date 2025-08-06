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
import PhotoQt.Modern

SpinBox {
    id: control

    editable: true

    width: 160
    height: 30

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property alias liveValue: txtinp.value

    property string tooltip: liveValue + tooltipSuffix
    property string tooltipSuffix: ""

    Timer {
        interval: 100
        running: true
        onTriggered:
            control.widthChanged()
    }

    contentItem: TextInput {
        id: txtinp
        property int value: control.value
        text: control.value
        onTextChanged: {
            value = parseInt(text)
            control.value = value
        }
        font: control.font
        color: enabled ? pqtPalette.text : pqtPaletteDisabled.text
        Behavior on color { ColorAnimation { duration: 200 } }
        selectionColor: PQCLook.highlight
        selectedTextColor: PQCLook.highlightedText
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        z: 3
        implicitWidth: 40
        implicitHeight: parent.height
        color: control.enabled ? (control.up.pressed ? pqtPalette.text : pqtPalette.base) : pqtPalette.button
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: PQCLook.baseBorder
        border.width: 1

        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize * 2
            color: control.up.pressed ? pqtPalette.base : (control.enabled ? pqtPalette.text : pqtPaletteDisabled.text)
            Behavior on color { ColorAnimation { duration: 200 } }
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        z: 3
        implicitWidth: 40
        implicitHeight: parent.height
        color: control.enabled ? (control.down.pressed ? pqtPalette.text : pqtPalette.base) : pqtPalette.button
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: PQCLook.baseBorder
        border.width: 1

        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize * 2
            color: control.down.pressed ? pqtPalette.base : (control.enabled ? pqtPalette.text : pqtPaletteDisabled.text)
            Behavior on color { ColorAnimation { duration: 200 } }
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 140
        color: pqtPalette.base
    }

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        visible: control.hovered
        text: control.tooltip
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
        liveValue = val
        _defaultValue = val
    }

    function setValue(val : int) {
        value = val
        liveValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==liveValue
    }

}
