/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

ToolTip {
    id: control
    text: ""
    delay: 500

    property bool someTransparency: true

    property alias wrapMode: contentText.wrapMode
    property alias elide: contentText.elide

    font.pointSize: baselook.fontsize
    font.weight: baselook.normalweight

    contentItem: PQText {
        id: contentText
        text: control.text
        font: control.font
        textFormat: Text.StyledText
    }

    background: Rectangle {
        color: someTransparency ? "#f02d2d2d" : "#2f2f2f"
        border.color: "#dd666666"
    }

}
