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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

PQComboBox {

    id: control

    property string mainEntryText: ""

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    implicitWidth: extrawide ? 300 : (extrasmall ? 100 : 200)

    property bool extrawide: false
    property bool extrasmall: false

    property int elide: Text.ElideRight

    property bool transparentBackground: false

    signal entryUpdated(var index)

    delegate: Item {
        id: deleg
        required property int index
        required property string txt
        required property int checked
        property bool highlighted: chk.hovered
        width: parent.width
        height: chk.height+8

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            opacity: enabled ? 1 : 0.3
            visible: deleg.highlighted
            color: control.palette.highlight
            radius: 5
        }
        Row {
            spacing: 0
            x: 4
            y: 4
            width: parent.width-8
            height: parent.height-8
            PQCheckBox {
                id: chk
                checked: deleg.checked
                elide: Text.ElideMiddle
                onCheckedChanged: {
                    control.model.get(deleg.index).checked = (checked ? 1 : 0)
                    control.entryUpdated(deleg.index)
                }
            }
            PQText {
                y: (chk.height-height)/2
                text: deleg.txt
                font.pointSize: (PQCLook.fontSize+PQCLook.fontSizeS)/2
                color: deleg.highlighted ? control.palette.highlightedText : control.palette.text
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged:
                deleg.highlighted = containsMouse
            onClicked: chk.checked = !chk.checked
        }

    }

    PQToolTip {
        visible: control.hovered
        text: control.mainEntryText==="" ? control.displayText : control.mainEntryText
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: control.mainEntryText==="" ? control.displayText : control.mainEntryText
        font: control.font
        color: control.palette.text
        style: control.highlighted ? Text.Sunken : Text.Normal
        styleColor: control.palette.disabled.text
        verticalAlignment: Text.AlignVCenter
        elide: control.elide
    }

    property int _defaultValue
    Component.onCompleted: {
        _defaultValue = currentIndex
    }

    function saveDefault() {
        _defaultValue = currentIndex
    }

    function setDefault(val : int) {
        _defaultValue = val
    }

    function loadAndSetDefault(val : int) {
        currentIndex = val
        _defaultValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==currentIndex
    }

}
