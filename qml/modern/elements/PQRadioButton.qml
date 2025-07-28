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
import QtQuick.Controls.Basic
import PhotoQt.Modern
import PhotoQt.Shared

RadioButton {

    id: control
    text: ""
    property int elide: enforceMaxWidth==0 ? Text.ElideNone : Text.ElideRight

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    property string tooltip: text

    property int enforceMaxWidth: 0

    SystemPalette { id: pqtPalette }

    indicator: Rectangle {
        implicitWidth: 22
        implicitHeight: 22
        radius: 13
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        border.color: pqtPalette.text
        color: pqtPalette.base
        opacity: enabled ? 1 : 0.6
        Rectangle {
            width: 10
            height: 10
            radius: 5
            anchors.centerIn: parent
            visible: control.checked
            color: pqtPalette.text
        }
    }

    contentItem: PQText {
        text: control.text
        elide: control.elide
        width: (control.enforceMaxWidth===0 ? implicitWidth : Math.min(control.enforceMaxWidth-25, implicitWidth))
        font: control.font
        opacity: enabled ? 1.0 : 0.4
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        text: control.tooltip
    }

    property bool _defaultChecked
    Component.onCompleted: {
        _defaultChecked = checked
    }

    function saveDefault() {
        _defaultChecked = checked
    }

    function setDefault(chk : bool) {
        _defaultChecked = chk
    }

    function loadAndSetDefault(chk : bool) {
        checked = chk
        _defaultChecked = chk
    }

    function hasChanged() : bool {
        return _defaultChecked!==checked
    }

}
