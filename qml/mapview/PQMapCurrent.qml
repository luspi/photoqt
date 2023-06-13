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

    id: map_top

    popout: PQSettings.interfacePopoutMapCurrent
    geometry: Qt.rect(PQSettings.mapviewCurrentPosition.x,
                      PQSettings.mapviewCurrentPosition.y,
                      PQSettings.mapviewCurrentSize.width,
                      PQSettings.mapviewCurrentSize.height)
    toBeShown: PQSettings.mapviewCurrentVisible&&filefoldermodel.current!=-1
    itemname: "mapcurrent"
    darkBackgroundManageIcons: true
    radius: 0

    disableAllMouseInteraction: popout

    additionalAction: [
        Image {

            id: explorerimage
            width: 25
            height: 25

            source: "/mainmenu/mapmarker.svg"
            sourceSize: Qt.size(width, height)

            opacity: explorermouse.containsMouse ? 0.8 : 0.1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQMouseArea {
                id: explorermouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:
                    loader.show("mapexplorer")
            }

            Rectangle {
                anchors.fill: explorerimage
                radius: width/2
                z: -1
                visible: darkBackgroundManageIcons
                color: "#88000000"
                opacity: explorerimage.opacity
            }

        }

    ]

    thisIsBlur: mapcurrent

    onPopoutChanged:
        PQSettings.interfacePopoutMapCurrent = popout

    onGeometryChanged: {
        PQSettings.mapviewCurrentPosition = Qt.point(geometry.x, geometry.y)
        PQSettings.mapviewCurrentSize = Qt.size(geometry.width, geometry.height)
    }

    onToBeShownChanged:
        PQSettings.mapviewCurrentVisible = toBeShown

    onVisibleChanged:
        updateMap()

    onResized: {
        latitude += 1e-10
        latitude -= 1e-10
    }

    property bool noLocation: true
    property real latitude: 49.00937
    property real longitude: 8.40444

    property string osmUrl: "https://tile.openstreetmap.org/"
    property string currentPlugin: { currentPlugin = getCurrentPlugin() }

    /////////////////////////////////////////////////////////////////////////////
    // We need separate plugins below as some parameters interfer with others

    Plugin {

        id: osmPlugin

        name: "osm"

        PluginParameter {
            name: "osm.useragent"
            value: "PhotoQt Image Viewer"
        }
        PluginParameter {
            name: "osm.mapping.custom.host"
            value: osmUrl
        }
        PluginParameter {
            name: "osm.mapping.custom.datacopyright"
            value: "<a href='https://openstreetmap.org/copyright'>OpenStreetMap</a>"

        }

    }

    Plugin {

        id: googlemapsPlugin

        name: "googlemaps"

        PluginParameter {
            name: "googlemaps.maps.apikey"
            value: (PQSettings.mapviewProviderGoogleMapsToken=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderGoogleMapsToken))
        }

    }

    Plugin {

        id: esriPlugin

        name: "esri"

        PluginParameter {
            name: "esri.token"
            value: (PQSettings.mapviewProviderEsriAPIKey=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderEsriAPIKey))
        }

    }

    Plugin {

        id: mapboxPlugin

        name: "mapboxgl"

        PluginParameter {
            name: "mapboxgl.access_token"
            value: (PQSettings.mapviewProviderMapboxAccessToken=="" ? "xxxxx" : handlingGeneral.decryptString(PQSettings.mapviewProviderMapboxAccessToken))
        }

    }

    content: [

        Item {

            anchors.fill: parent

            Loader {

                id: mapLoader

                anchors.fill: parent

                sourceComponent: mapComponent

            }

            Component {

                id: mapComponent

                Map {

                    id: map

                    anchors.fill: parent
                    anchors.margins: PQSettings.interfacePopoutMapCurrent ? 0 : 2

                    opacity: noLocation ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    visible: opacity>0

                    plugin: currentPlugin=="osm"
                                ? osmPlugin
                                : (currentPlugin == "mapboxgl"
                                    ? mapboxPlugin
                                    : (currentPlugin == "esri"
                                        ? esriPlugin
                                        : googlemapsPlugin))

                    center {
                        latitude: latitude
                        longitude: longitude
                    }

                    gesture {
                        enabled: PQSettings.interfacePopoutMapCurrent
                        acceptedGestures: MapGestureArea.PinchGesture|MapGestureArea.PanGesture|MapGestureArea.FlickGesture
                    }

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

                    Connections {
                        target: map_top
                        onWheelEvent: {
                            if(noLocation) return
                            if(delta.y < 0)
                                map.zoomLevel = Math.max(map.minimumZoomLevel, map.zoomLevel-0.5)
                            else
                                map.zoomLevel = Math.min(map.maximumZoomLevel, map.zoomLevel+0.5)
                        }
                    }

                    Component.onCompleted:
                        setMapType.start()

                    Timer {
                        id: setMapType
                        interval: 50
                        onTriggered: {
                            if(currentPlugin != "osm")
                                return
                            for(var i in map.supportedMapTypes) {
                                if(supportedMapTypes[i].name.localeCompare("Custom URL Map") === 0)
                                    activeMapType = supportedMapTypes[i]
                            }
                        }
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
        onMapviewProviderChanged: {
            mapLoader.active = false
            currentPlugin = getCurrentPlugin()
            reloadMapAfterTimeout.restart()
        }
    }

    Timer {
        id: reloadMapAfterTimeout
        interval: 100
        repeat: false
        onTriggered: {
            mapLoader.active = true
        }
    }

    Component.onCompleted: {
        updateMap()
    }

    function getCurrentPlugin() {
        if(PQSettings.mapviewProvider=="googlemaps" && osmPlugin.availableServiceProviders.indexOf("googlemaps")!=-1)
            return "googlemaps"
        if(PQSettings.mapviewProvider=="esri" && osmPlugin.availableServiceProviders.indexOf("esri")!=-1)
            return "esri"
        if(PQSettings.mapviewProvider=="mapboxgl" && osmPlugin.availableServiceProviders.indexOf("mapboxgl")!=-1)
            return "mapboxgl"
        return "osm"
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
