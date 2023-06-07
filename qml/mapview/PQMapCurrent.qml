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
import "../templates"

PQTemplateIntegrated {

    id: hist_top

    popout: PQSettings.interfacePopoutMapCurrent
    geometry: Qt.rect(PQSettings.mapviewCurrentPosition.x,
                      PQSettings.mapviewCurrentPosition.y,
                      PQSettings.mapviewCurrentSize.width,
                      PQSettings.mapviewCurrentSize.height)
    toBeShown: PQSettings.mapviewCurrentVisible
    itemname: "mapcurrent"
    darkBackgroundManageIcons: true
    radius: 0

    thisIsBlur: mapcurrent

    onPopoutChanged:
        PQSettings.interfacePopoutMapCurrent = popout

    onGeometryChanged: {
        PQSettings.mapviewCurrentPosition = Qt.point(geometry.x, geometry.y)
        PQSettings.mapviewCurrentSize = Qt.size(geometry.width, geometry.height)
    }

    onToBeShownChanged:
        PQSettings.mapviewCurrentVisible = toBeShown

    onWheelEvent:
        wheelReceived(delta)

    onVisibleChanged:
        updateMap()

    Plugin {
        id: mapPlugin
        parameters: [
            PluginParameter {
                name: "osm.useragent"
                value: "PhotoQt Image Viewer"
            },
            PluginParameter {
                name: "googlemaps.maps.apikey"
                value: (PQSettings.mapviewProviderGoogleMapsToken=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderGoogleMapsToken))
            },
            PluginParameter {
                name: "esri.token"
                value: (PQSettings.mapviewProviderEsriAPIKey=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderEsriAPIKey))
            },
            PluginParameter {
                name: "mapboxgl.access_token"
                value: (PQSettings.mapviewProviderMapboxAccessToken=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderMapboxAccessToken))
            }
        ]
        Component.onCompleted: {
            if(PQSettings.mapviewProvider=="googlemaps" && availableServiceProviders.indexOf("googlemaps")!=-1)
                name = "googlemaps"
            else if(PQSettings.mapviewProvider=="esri" && availableServiceProviders.indexOf("esri")!=-1)
                name = "esri"
            else if(PQSettings.mapviewProvider=="mapboxgl" && availableServiceProviders.indexOf("mapboxgl")!=-1)
                name = "mapboxgl"
            else
                name = "osm"
        }
    }

    property bool noLocation: true
    property real latitude: 49.00937
    property real longitude: 8.40444

    content: [

        Item {

            anchors.fill: parent

            Map {

                id: map

                anchors.fill: parent
                anchors.margins: PQSettings.interfacePopoutMapCurrent ? 0 : 2

                opacity: noLocation ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0

                plugin: mapPlugin

                center {
                    latitude: latitude
                    longitude: longitude
                }

                gesture.enabled: PQSettings.interfacePopoutMapCurrent

                Behavior on center.latitude { NumberAnimation { duration: 500 } }
                Behavior on center.longitude { NumberAnimation { duration: 500 } }

                zoomLevel: 12
                Behavior on zoomLevel { NumberAnimation { duration: 100 } }

                MapQuickItem {

                    id: marker

                    anchorPoint.x: container.width*(61/256)
                    anchorPoint.y: container.height*(198/201)

                    visible: true

                    coordinate: QtPositioning.coordinate(latitude, longitude)

                    sourceItem:
                        Image {
                            id: container
                            width: 64
                            height: 50
                            mipmap: true
                            smooth: false
                            source: "/mapview/mapmarker.png"
                        }
                }

            }

            PQTextL {
                anchors.centerIn: parent
                text: em.pty+qsTranslate("mapcurrent", "No location data")

                opacity: noLocation ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
            }

        }

    ]

    Connections {
        target: filefoldermodel
        onCurrentFilePathChanged:
            updateMap()
    }

    Connections {
        target: PQSettings
        onMapviewCurrentVisibleChanged:
            updateMap()
    }

    Component.onCompleted:
        updateMap()

    function wheelReceived(delta) {

        if(noLocation) return
        if(delta.y < 0)
            map.zoomLevel = Math.max(map.minimumZoomLevel, map.zoomLevel-0.5)
        else
            map.zoomLevel = Math.min(map.maximumZoomLevel, map.zoomLevel+0.5)

    }

    function updateMap() {

        // map is disabled
        if(!PQSettings.mapviewCurrentVisible || filefoldermodel.current == -1)
            return

        var pos = cppmetadata.getGPSDataOnly(filefoldermodel.currentFilePath)

        // this value means: no gps data
        if(pos.x == 9999 || pos.y == 9999) {
            noLocation = true
            return
        }

        latitude = pos.x
        longitude = pos.y
        noLocation = false
    }

}
