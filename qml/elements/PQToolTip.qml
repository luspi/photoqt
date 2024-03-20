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

ToolTip {

    id: control
    text: ""
    delay: 500

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    property bool partialTransparency: true
    property bool enforceWidthLimit: true
    property int pw: 0

    contentItem: PQText {
        id: contentText
        text: control.text
        font: control.font
        textFormat: Text.RichText
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Timer {
            id: calcWidth
            interval: 200
            running: enforceWidthLimit
            repeat: true
            onTriggered: {
                if(control.pw === 0)
                    control.pw = contentText.paintedWidth
                else {
                    control.width = Math.min(500, control.pw+20)
                    stop()
                }
            }
        }
    }

    background: Rectangle {
        color: partialTransparency ? PQCLook.transColor : PQCLook.baseColor
        border.color: PQCLook.inverseColorHighlight
    }

}
