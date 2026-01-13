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

RadioButton {

    id: control

    property int elide: enforceMaxWidth==0 ? Text.ElideNone : Text.ElideRight

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    width: (enforceMaxWidth===0 ? implicitWidth : Math.min(enforceMaxWidth, implicitWidth))

    indicator: Rectangle {
        implicitWidth: 16
        implicitHeight: 16
        x: control.leftPadding
        y: (parent.height-height)/2
        radius: 10
        color: palette.base
        border.width: 1
        border.color: control.checked ? palette.highlight : palette.disabled.text

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: control.checked
            color: palette.highlight
            opacity: 0.3
        }

        Rectangle {
            width: 6
            height: 6
            x: 5
            y: 5
            radius: 5
            color: palette.text
            visible: control.checked
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: palette.text
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    property string tooltip: text

    property int enforceMaxWidth: 0

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        visible: control.hovered && text !== ""
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
