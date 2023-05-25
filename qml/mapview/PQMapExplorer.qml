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
            loadImages()
            if(finishShow)
                PQLocation.storeMapState(map.zoomLevel, map.center.latitude, map.center.longitude)
        }

        onCenterChanged: {
            if(finishShow)
                PQLocation.storeMapState(map.zoomLevel, map.center.latitude, map.center.longitude)
        }

        MapItemView {

            model: 0//locationmodel

            delegate: MapQuickItem {

                id: deleg

                anchorPoint.x: container.width/2
                anchorPoint.y: container.height/2

                visible: true

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
                            source: "image://thumb/" + handlingGeneral.toPercentEncoding(filename)
                            Rectangle {
                                anchors.centerIn: parent
                                width: numlabel.width+8
                                height: numlabel.height+4
                                color: "#88000000"
                                visible: howmany>1
                                PQText {
                                    x: 4
                                    y: 2
                                    id: numlabel
                                    font.weight: baselook.boldweight
                                    anchors.centerIn: parent
                                    text: howmany
                                }
                            }
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    map.curZ += 1
                                    deleg.z = map.curZ
                                }
                            }
                        }
                    }

            }

        }

    }

    Connections {
        target: loader
        onMapExplorerPassOn: {
            if(what == "show") {
                map.curZ = 0
                opacity = 1
                variables.visibleItem = "mapexplorer"

                var dat = PQLocation.getMapState()
                console.log(dat)
                map.zoomLevel = dat[0]
                map.center.latitude = dat[1]
                map.center.longitude = dat[2]
                finishShow = true
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

    function loadImages() {
/*
        // There are four steps
        var levels = [1,5,8,10]

        // find the appropriate detail level for the current setting
        var detaillevel = 1
        if(map.zoomLevel > map.maximumZoomLevel-levels[levels.length-1]) {
            for(var l in levels) {
                var diff = map.maximumZoomLevel-levels[l]
                if(map.zoomLevel > diff) {
                    detaillevel = levels.length-l
                    break
                }
            }
        }

        if(detaillevel == currentDetailLevel)
            return
        currentDetailLevel = detaillevel

        var dat = PQLocation.getImages(detaillevel)

        mdl.clear()

        for(var i in dat)
        mdl.append({latitude: dat[i][0],
                    longitude: dat[i][1],
                    howmany: dat[i][2],
                    filename: dat[i][3]})
*/
    }

}
