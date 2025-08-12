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
import PhotoQt.CPlusPlus
import PhotoQt.Modern

Item {

    id: control_top

    width: 300
    height: model.length*50

    property int currentIndex: 0
    property list<string> model: []

    SystemPalette { id: pqtPalette }

    Column {

        Repeater {

            id: repeater
            model: control_top.model.length

            Rectangle {

                id: deleg

                required property int modelData

                property bool active: modelData === control_top.currentIndex
                property bool hovered: false
                width: control_top.width
                height: 48
                color: active ? PQCLook.baseBorder : (hovered ? pqtPalette.alternateBase : pqtPalette.base)
                border.width: 1
                border.color: PQCLook.baseBorder

                PQText {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: control_top.model[deleg.modelData]
                    color: pqtPalette.text
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                        control_top.currentIndex = deleg.modelData
                    onEntered:
                        deleg.hovered = true
                    onExited:
                        deleg.hovered = false
                }

            }

        }

    }

}
