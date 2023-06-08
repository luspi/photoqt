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
import "../../elements"

Rectangle {

    id: explorertweaks

    color: "#333333"

    property real minZoomLevel: 0
    property real maxZoomLevel: 1

    Row {

        x: 10
        y: (parent.height-height)/2
        spacing: 10

        PQText {

            y: (parent.height-height)/2

            id: zoomtext

            text: em.pty+qsTranslate("mapexplorer", "Zoom:")

        }

        PQSlider {

            y: (parent.height-height)/2

            from: minZoomLevel
            to: maxZoomLevel
            stepSize: 0.1
            value: mapexplorer_top.mapZoomLevel
            tooltip: Math.round(100*((value-from)/(to-from)))
            toolTipSuffix: "%"

            onValueChanged: {
                mapexplorer_top.mapZoomLevel = value
                // we set the focus to some random element (one that doesn't aid in catching key events (otherwise we catch them twice))
                // this avoids the case where left/right arrow would cause inadvertently a zoom in/out event
                variables.forceActiveFocus()
            }
        }

    }

    PQButton {
        id: resetbutton
        x: parent.width-width-closebutton.width/2
        y: (parent.height-height)/2
        imageButtonSource: "/mapview/reset.svg"
        //: The view here is the map layout in the map explorer
        tooltip: em.pty+qsTranslate("mapexplorer", "Reset view")
        onClicked: {
            map.resetMap()
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
