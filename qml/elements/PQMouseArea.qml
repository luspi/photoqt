/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

MouseArea {

    id: tooltip_top

    property alias text: control.text
    property bool followCursor: true
    property alias delay: control.delay

    hoverEnabled: true

    Timer {
        id: showToolTip
        interval: 250
        onTriggered: {
            if(tooltip_top.containsMouse && tooltip_top.text != "")
                control.visible = true
        }
    }

    onEntered: {
        showToolTip.restart()
    }

    onExited: {
        showToolTip.stop()
        control.visible = false
    }

    ToolTip {

        id: control
        text: ""
        delay: 500

        x: followCursor ? tooltip_top.mouseX : (parent.width-width)/2
        y: followCursor ? tooltip_top.mouseY-height : (-height-5)

        font.pointSize: PQCLook.fontSize
        font.weight: PQCLook.fontWeightNormal

        contentItem: PQText {
            id: contentText
            text: control.text
            font: control.font
            textFormat: Text.RichText
        }

        background: Rectangle {
            color: PQCLook.baseColor
            border.color: PQCLook.inverseColorHighlight
        }

    }

}
