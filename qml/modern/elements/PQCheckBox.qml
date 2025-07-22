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
import PhotoQt

CheckBox {

    id: control
    text: ""
    property int elide: enforceMaxWidth==0 ? Text.ElideNone : Text.ElideRight

    font.pointSize: PQCLook.fontSize      
    font.weight: PQCLook.fontWeightNormal 
    property string color: enabled ? PQCLook.textColor : PQCLook.textColorDisabled 

    property string tooltip: text

    // if the checkbox is embedded with an outside mouse area, this allows for passing on hovered events
    property bool extraHovered: false

    property int enforceMaxWidth: 0

    indicator: Rectangle {
        implicitWidth: 22
        implicitHeight: 22
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        opacity: enabled ? 1.0 : 0.3
        Behavior on opacity { NumberAnimation { duration: 200 } }

        border.color: PQCLook.inverseColor 
        color: PQCLook.baseColorHighlight  
        radius: 2
        Rectangle {
            width: 10
            height: 10
            anchors.centerIn: parent
            visible: control.checked
            color: PQCLook.inverseColor 
            radius: 2
        }
    }

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        text: control.tooltip
    }

    contentItem: PQText {
        text: control.text
        width: (control.enforceMaxWidth===0 ? implicitWidth : Math.min(control.enforceMaxWidth-25, implicitWidth))
        elide: control.elide
        font: control.font
        color: control.color
        opacity: control.checked ? 1.0 : 0.7
        Behavior on opacity { NumberAnimation { duration: 200 } }
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
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
