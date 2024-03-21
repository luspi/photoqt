/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

SpinBox {
    id: control

    editable: true
    live: true

    width: 160
    height: 30

    property alias liveValue: txtinp.text

    Timer {
        interval: 100
        running: true
        onTriggered:
            control.widthChanged()
    }

    contentItem: TextInput {
        id: txtinp
        text: control.value
        font: control.font
        color: enabled ? PQCLook.textColor : PQCLook.textColorHighlight
        Behavior on color { ColorAnimation { duration: 200 } }
        selectionColor: PQCLook.baseColorActive
        selectedTextColor: PQCLook.textColorActive
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
        color: control.enabled ? (control.up.pressed ? PQCLook.baseColorActive : PQCLook.baseColorAccent) : PQCLook.baseColorAccent
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: PQCLook.baseColorHighlight
        border.width: 1

        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize * 2
            color: control.enabled ? PQCLook.textColor : PQCLook.textColorHighlight
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
        color: control.enabled ? (control.down.pressed ? PQCLook.baseColorActive : PQCLook.baseColorAccent) : PQCLook.baseColorAccent
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: PQCLook.baseColorHighlight
        border.width: 1

        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize * 2
            color: control.enabled ? PQCLook.textColor : PQCLook.textColorHighlight
            Behavior on color { ColorAnimation { duration: 200 } }
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 140
        color: PQCLook.baseColorHighlight
    }

    property int _defaultValue
    Component.onCompleted: {
        _defaultValue = value
    }

    function saveDefault() {
        _defaultValue = value
    }

    function setDefault(val) {
        _defaultValue = val
    }

    function loadAndSetDefault(val) {
        value = val
        _defaultValue = val
    }

    function hasChanged() {
        return _defaultValue!==value
    }

}
