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
import QtLocation 5.12
import QtPositioning 5.12

Item {

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Plugin {
        id: mapPlugin
        name: "osm" // "mapboxgl", "esri", ...
        // specify plugin parameters if necessary
        // PluginParameter {
        //     name:

        //     value:
        // }
    }

    Map {
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(49.01, 8.40) // Karlsruhe
        zoomLevel: 1

        Repeater {
            id: rpt

            model: filefoldermodel.countMainView

            MapQuickItem {
                id: marker
                anchorPoint.x: image.width/2
                anchorPoint.y: image.height/2

                visible: false

//                coordinate: QtPositioning.coordinate(59.91, 10.75)

                sourceItem: Image {
                    id: image
                    width: 64
                    height: 64
                    sourceSize.width: width
                    sourceSize.height: height
                    source: "image://full/" + handlingGeneral.toPercentEncoding(filefoldermodel.entriesMainView[index])
                }

                Component.onCompleted: {
                    var pos = cppmetadata.getGPSDataOnly(filefoldermodel.entriesMainView[index])
                    console.log(pos)
                    coordinate = QtPositioning.coordinate(pos.x, pos.y)
                    visible = true
                }

            }

        }

    }

    Connections {
        target: loader
        onMapViewPassOn: {
            if(what == "show") {
                opacity = 1
                variables.visibleItem = "mapview"
                showCurrentFolderOnMap()
            } else if(what == "hide") {
                opacity = 0
            } else if(what == "keyevent") {
//                if(param[0] == Qt.Key_Escape)
//                    button_cancel.clicked()
//                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
//                    button_start.clicked()
            }
        }
    }

    function showCurrentFolderOnMap() {
        
//        cppmetadata.getGPSDataOnly(filefoldermodel.currentFilePath)
//        rpt.

    }

}
