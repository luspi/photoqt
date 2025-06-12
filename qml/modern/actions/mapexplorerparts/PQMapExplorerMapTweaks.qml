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
import org.photoqt.qml

Rectangle {

    id: explorertweaks

    color: PQCLook.baseColor // qmllint disable unqualified

    property real minZoomLevel: 0
    property real maxZoomLevel: 1

    property alias contextmenu: resetbutton.contextmenu

    Row {

        x: 10
        y: (parent.height-height)/2
        spacing: 10

        PQText {

            y: (parent.height-height)/2

            id: zoomtext

            text: qsTranslate("mapexplorer", "Map zoom:")

        }

        PQSlider {

            y: (parent.height-height)/2

            from: explorertweaks.minZoomLevel
            to: explorertweaks.maxZoomLevel
            stepSize: 0.1
            value: mapexplorer_top.mapZoomLevel // qmllint disable unqualified

            onValueChanged: {
                mapexplorer_top.mapZoomLevel = value // qmllint disable unqualified
            }
        }

    }

    PQButtonIcon {
        id: resetbutton
        x: parent.width-width-mapexplorer_top.closebuttonWidth/2 // qmllint disable unqualified
        y: (parent.height-height)/2
        source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg" // qmllint disable unqualified
        //: The view here is the map layout in the map explorer
        tooltip: qsTranslate("mapexplorer", "Reset view")
        onClicked: {
            mapexplorer_top.resetMap() // qmllint disable unqualified
            mapexplorer_top.resetWidth()
        }
    }

    Rectangle {

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: "#aaaaaa"
    }

}
