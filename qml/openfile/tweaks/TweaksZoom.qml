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
import "../../elements"

Item {

    anchors.left: up.right
    anchors.leftMargin: 20
    height: parent.height
    width: zoom_txt.width+zoom_slider.width

    property alias tweaksZoomSlider: zoom_slider

    Text {
        id: zoom_txt
        color: "white"
        font.bold: true
        y: (parent.height-height)/2
        //: As in 'Zoom the files shown'
        text: em.pty+qsTr("Zoom:")
        anchors.right: zoom_slider.left
        anchors.rightMargin: 5
    }

    CustomSlider {
        id: zoom_slider
        width: 200
        y: (parent.height-height)/2
        anchors.right: parent.right
        minimumValue: 10
        maximumValue: 50
        tickmarksEnabled: true
        stepSize: 1
        scrollStep: 1
        tooltip: em.pty+qsTr("Move slider to adjust the size of files")
        value: settings.openZoomLevel
        Behavior on value { NumberAnimation { duration: variables.animationSpeed } }
        onValueChanged:
            // we use start and not restart to still update the zoom level regularly
            if(zoomSaveTimer != null)
               zoomSaveTimer.start()
    }

    // save zoom level after short timeout
    Timer {
        id: zoomSaveTimer
        interval: 100
        repeat: false
        onTriggered:
            settings.openZoomLevel = zoom_slider.value
    }

}
