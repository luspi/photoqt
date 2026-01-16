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
import PhotoQt

Item {

    id: control

    width: spinrow.width
    height: spinrow.height

    property int minval: 1
    property int maxval: 10

    property bool editMode: false

    property int value: spinbox.value

    Row {

        id: spinrow

        spacing: 5

        opacity: control.editMode ? 1 : 0
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        visible: opacity>0

        PQSpinBox {
            id: spinbox
            width: 75
            from: control.minval
            to: control.maxval
        }
        PQButton {
            text: "Save"
            height: spinbox.height
            extraSmall: true
            smallerVersion: true
            sizeToText: true
            onClicked:
                control.editMode = false
        }
    }

    PQButton {
        id: button

        anchors.fill: parent

        opacity: control.editMode ? 0 : 1
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        visible: opacity>0

        text: spinbox.value
        smallerVersion: true

        onClicked:
            control.editMode = true

    }

    function saveDefault() {
        button.clicked()
        spinbox.saveDefault()
    }

    function setDefault(val : int) {
        spinbox.setDefault(val)
    }

    function loadAndSetDefault(val : int) {
        acceptValue()
        spinbox.loadAndSetDefault(val)
    }

    function setValue(val : int) {
        spinbox.setValue(val)
    }

    function hasChanged() : bool {
        return spinbox.hasChanged()
    }

    function acceptValue() {
        control.editMode = false
    }

    function increase() {
        spinbox.value += 1
    }
    function decrease() {
        spinbox.value -= 1
    }

}
