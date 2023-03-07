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

import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {

    id: tile

    color: chk.checked ? "#555555" : (hovered ? "#3a3a3a" : "#222222")
    Behavior on color { ColorAnimation { duration: 150 } }

    radius: 5

    property int overrideWidth: 0
    width: overrideWidth!=0 ? overrideWidth : (secondText=="" ? 250 : 505)
    height: chk.height+20
    clip: true

    property bool hovered: false

    property alias text: chk.text
    property alias checked: chk.checked

    property alias secondText: chk_2.text
    property alias secondChecked: chk_2.checked

    property string tooltip: chk.text

    signal rightClicked()

    Row {

        x: 10
        spacing: 10

        PQCheckbox {
            id: chk
            y: 10
            width: 230

            tooltip: ""

            onRightClicked: tile.rightClicked()

            PQMouseArea {
                id: checkmousearea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.NoButton

                onEntered:
                    tile.hovered = true
                onExited:
                    tile.hovered = false

                tooltip: tile.tooltip
                tooltipDelay: 1000

            }

        }

        Item {
            width: 5
            height: 1
        }

        PQCheckbox {
            id: chk_2
            visible: secondText!=""
            y: 10
            width: 230
            text: secondText
            enabled: chk.checked

            tooltip: ""

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.NoButton

                onEntered:
                    tile.hovered = true
                onExited:
                    tile.hovered = false

                tooltip: chk_2.text
                tooltipDelay: 1000

            }
        }

    }

}
