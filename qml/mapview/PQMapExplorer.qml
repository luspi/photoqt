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
import "../elements"

Item {

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    property int currentDetailLevel: -1

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    property bool finishShow: false

    Plugin {
        id: osmPlugin
        name: "osm"//PQSettings.mapviewProvider
        parameters: [
            PluginParameter {
                name: "osm.useragent"
                value: "PhotoQt Image Viewer"
            }
        ]
    }

    Plugin {
        id: googlePlugin
        name: "googlemaps"
        parameters: [
            PluginParameter {
                name: "googlemaps.maps.apikey"
                value: (PQSettings.mapviewProviderGoogleMapsToken=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderGoogleMapsToken))
            }
        ]
    }

    Plugin {
        id: esriPlugin
        name: "esri"
        parameters: [
            PluginParameter {
                name: "esri.token"
                value: (PQSettings.mapviewProviderEsriAPIKey=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderEsriAPIKey))
            }
        ]
    }

    Map {

        id: map

        anchors.fill: parent
        center: QtPositioning.coordinate(49.01, 8.40) // Karlsruhe
        zoomLevel: 1

        property int curZ: 0

        plugin: (PQSettings.mapviewProvider=="googlemaps" ? googlePlugin : (PQSettings.mapviewProvider=="esri" ? esriPlugin : osmPlugin))

        onZoomLevelChanged: {
            if(finishShow)
                PQLocation.storeMapState(map.zoomLevel, map.center.latitude, map.center.longitude)
            for(var i = 0; i < steps.length; ++i) {
                if(map.zoomLevel > steps[i][1]) {
                    detaillevel = i
                    break
                }
            }
        }

        onCenterChanged: {
            if(finishShow)
                PQLocation.storeMapState(map.zoomLevel, map.center.latitude, map.center.longitude)
        }

        property var steps: [
            [0.001, 16.5],
            [0.005, 14],
            [0.01, 13],
            [0.02, 12],
            [0.05, 11],
            [0.1, 10],
            [0.2, 9],
            [0.5, 7.5],
            [1, 6.5],
            [2, 5.5],
            [4, 4.5],
            [8, 3.5],
            [12, 1],
        ]

        property int detaillevel: 0

        MapItemView {

            model: ListModel { id: mdl }

            delegate: MapQuickItem {

                id: deleg

                anchorPoint.x: container.width/2
                anchorPoint.y: container.height/2

                visible: (x > -width && x < map.width && y > -height && y < map.height) && map.detaillevel==details

                coordinate: QtPositioning.coordinate(latitude, longitude)

                sourceItem:
                    Rectangle {
                        id: container
                        width: 68
                        height: 68
                        color: "white"
                        Image {
                            id: image
                            x: 2
                            y: 2
                            width: 64
                            height: 64
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: width
                            sourceSize.height: height
                            mipmap: true
                            cache: true
                            asynchronous: true
                            source: "image://thumb/" + handlingGeneral.toPercentEncoding(filename)
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    map.curZ += 1
                                    deleg.z = map.curZ
                                }
                            }
                        }
                        Rectangle {
                            x: parent.width-width*0.8
                            y: -height*0.2
                            width: numlabel.width+14
                            height: numlabel.height+4
                            color: "#0088ff"
                            radius: height/2
                            visible: howmany>1
                            PQText {
                                x: 7
                                y: 2
                                id: numlabel
                                font.weight: baselook.boldweight
                                anchors.centerIn: parent
                                text: howmany
                            }
                        }
                    }

            }

        }

    }

    Text {
        x: (parent.width-width)-10
        y: 10
        font.bold: true
        text: "Zoom: " + map.zoomLevel
    }

    Connections {
        target: loader
        onMapExplorerPassOn: {
            if(what == "show") {
                map.curZ = 0
                opacity = 1
                variables.visibleItem = "mapexplorer"
                var dat = PQLocation.getMapState()
                map.zoomLevel = dat[0]
                map.center.latitude = dat[1]
                map.center.longitude = dat[2]
                finishShow = true
                PQLocation.detailLevel = 0
                PQLocation.scanForLocations(filefoldermodel.entriesMainView)
                PQLocation.processSummary(handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath))
                loadImageBG.start()
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

    Timer {
        id: loadImageBG
        interval: 250
        repeat: false
        running: false
        onTriggered:
            loadImages()
    }

    function loadImages() {

//        var steps = [
//            [0.001, 16.5],
//            [0.005, 14],
//            [0.01, 13],
//            [0.02, 12],
//            [0.05, 11],
//            [0.1, 10],
//            [0.2, 9],
//            [0.5, 7.5],
//            [1, 6.5],
//            [2, 5.5],
//            [4, 4.5],
//            [8, 3.5],
//            [12, 1],
//        ]

//        var detaillevel = steps.length-1
//        for(var i = 0; i < steps.length; ++i) {
//            if(map.zoomLevel > steps[i][1]) {
//                detaillevel = i
//                break
//            }
//        }

//        if(detaillevel == currentDetailLevel)
//            return

//        currentDetailLevel = detaillevel


        mdl.clear()

        for(var det = 0; det < 13; ++det) {
            PQLocation.detailLevel = det
            var tmp = PQLocation.imageList;
            for(var i in tmp) {
                var dat = tmp[i]
                mdl.append({latitude: dat[0],
                            longitude: dat[1],
                            howmany: dat[2],
                            filename: dat[3],
                            details: det})
            }
        }

    }

}
