/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {

    id: but

    property bool pressedDown: false
    property bool hovered: false
    property int fontsize: 13
    property string overrideFontColor: ""
    property string overrideBackgroundColor: ""
    property int wrapMode: Text.NoWrap
    property string tooltip: text
    property bool fontBold: false

    height: 2.5*fontsize

    signal clickedButton()
    signal rightClickedButton(var pos)

    style: ButtonStyle {

        background: Rectangle {
            anchors.fill: parent
            color: overrideBackgroundColor!="" ?
                       overrideBackgroundColor :
                       control.enabled ?
                           (control.pressedDown ?
                                colour.button_bg_pressed :
                                (control.hovered ?
                                     colour.button_bg_hovered :
                                     colour.button_bg)) :
                           colour.button_bg_disabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
            radius: variables.global_item_radius
        }

        label: Text {
            id: txt
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: fontsize
            wrapMode: but.wrapMode
            color: overrideFontColor!="" ?
                       overrideFontColor :
                       control.enabled ?
                           ((control.hovered || control.pressedDown) ?
                                colour.button_text_active :
                                colour.button_text) :
                           colour.button_text_disabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
            text: "  " + control.text + "  "
            font.bold: fontBold
        }

    }

    ToolTip {

        text: parent.tooltip
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: but.pressedDown = true
        onReleased: but.pressedDown = false
        onEntered: but.hovered = true
        onExited: but.hovered = false
        onClicked: {
            if(mouse.button == Qt.LeftButton)
                clickedButton()
            else
                rightClickedButton(Qt.point(mouse.x, mouse.y))
        }

    }

}
