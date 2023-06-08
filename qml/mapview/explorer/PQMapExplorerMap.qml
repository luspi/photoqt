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
import "../../elements"

Item {

    id: map_top

    property real visibleLatitudeLeft: -180
    property real visibleLatitudeRight: 180
    property real visibleLongitudeLeft: -180
    property real visibleLongitudeRight: 180

    property int detaillevel: 0

    signal computeDetailLevel()
    signal clearModel()
    signal resetCurZ()
    signal resetMap()
    signal addItem(var lat, var lon, var fn, var lvl, var lbl, var full_lat, var full_lon)
    signal setMapCenter(var lat, var lon)
    signal setMapCenterSmooth(var lat, var lon)
    signal setMapZoomLevelSmooth(var lvl)
    signal updateVisibleRegionNow()
    signal showHighlightMarkerAt(var lat, var lon)
    signal hideHightlightMarker()

    function reloadLoader() {
        explorerMapLoader.active = false
        reloadExplorerMapAfterTimeout.restart()
    }

    Timer {
        id: reloadExplorerMapAfterTimeout
        interval: 100
        repeat: false
        onTriggered: {
            explorerMapLoader.active = true
        }
    }

    // this is loaded from the web if needed
    property string osmUrl: "https://tile.openstreetmap.org/"

    property string currentPlugin: { currentPlugin = getCurrentPlugin() }

    function getCurrentPlugin() {
        if(PQSettings.mapviewProvider=="googlemaps" && osmPlugin.availableServiceProviders.indexOf("googlemaps")!=-1)
            return "googlemaps"
        if(PQSettings.mapviewProvider=="esri" && osmPlugin.availableServiceProviders.indexOf("esri")!=-1)
            return "esri"
        if(PQSettings.mapviewProvider=="mapboxgl" && osmPlugin.availableServiceProviders.indexOf("mapboxgl")!=-1)
            return "mapboxgl"
        return "osm"
    }

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

    Loader {

        id: explorerMapLoader

        anchors.fill: map_top

        sourceComponent: mapComponent

    }

    Component {

        id: mapComponent

        Map {

            id: map

            anchors.fill: parent

            center: QtPositioning.coordinate(49.01, 8.40)
            zoomLevel: mapexplorer_top.mapZoomLevel

            property int curZ: 0

            plugin: currentPlugin=="osm"
                        ? osmPlugin
                        : (currentPlugin == "mapboxgl"
                            ? mapboxPlugin
                            : (currentPlugin == "esri"
                                ? esriPlugin
                                : googlemapsPlugin))

            onZoomLevelChanged: {
                if(!finishShow) return
                computeDetailLevel()
                if(zoomLevel != mapexplorer_top.mapZoomLevel)
                    mapexplorer_top.mapZoomLevel = zoomLevel
            }

            Timer {
                id: updateVisibleRegion
                interval: 500
                repeat: true
                running: mapexplorer_top.visible
                onTriggered: {
                    execute()
                }
                function execute() {
                    map_top.visibleLatitudeLeft = map.visibleRegion.boundingGeoRectangle().topLeft.latitude
                    map_top.visibleLongitudeLeft = map.visibleRegion.boundingGeoRectangle().topLeft.longitude
                    map_top.visibleLatitudeRight = map.visibleRegion.boundingGeoRectangle().bottomRight.latitude
                    map_top.visibleLongitudeRight= map.visibleRegion.boundingGeoRectangle().bottomRight.longitude
                }
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

            MapQuickItem {

                id: highlightMarker

                anchorPoint.x: highlightImage.width*(61/256)
                anchorPoint.y: highlightImage.height*(198/201)

                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 100 } }
                visible: opacity>0

                property real latitude
                property real longitude
                Behavior on latitude { NumberAnimation { duration: 100 } }
                Behavior on longitude { NumberAnimation { duration: 100 } }
                coordinate: QtPositioning.coordinate(latitude, longitude)

                z: map.curZ+1

                sourceItem:
                    Image {
                        id: highlightImage
                        width: 64
                        height: 50
                        mipmap: true
                        smooth: false
                        source: "/mapview/mapmarker.png"
                    }

                function showAt(lat, lon) {
                    highlightMarker.latitude = lat
                    highlightMarker.longitude = lon
                    highlightMarker.opacity = 1
                }

                function hide() {
                    highlightMarker.opacity = 0
                }

            }

            MapItemView {

                model: ListModel { id: mdl }

                opacity: highlightMarker.visible ? 0.5 : 1
                Behavior on opacity { NumberAnimation { duration: 100 } }

                delegate: MapQuickItem {

                    id: deleg

                    property var keys: Object.keys(labels)

                    anchorPoint.x: container.width/2
                    anchorPoint.y: container.height/2

                    opacity: (x > -width && x < map.width && y > -height && y < map.height) && (lvls.indexOf(""+map_top.detaillevel) != -1) ? 1 : 0
                    visible: opacity>0

                    property bool showTruePos: keys.indexOf(map_top.detaillevel+"")!=-1 && labels[map_top.detaillevel]*1==1
                    coordinate: QtPositioning.coordinate((showTruePos ? display_latitude : latitude), (showTruePos ? display_longitude : longitude))

                    property var lvls

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
                                source: (!visible && source=="") ? "" : ("image://thumb/" + handlingGeneral.toPercentEncoding(filename))
                            }
                            Repeater {
                                model: deleg.keys.length
                                Rectangle {
                                    x: parent.width-width*0.8
                                    y: -height*0.2
                                    width: numlabel.width+20
                                    height: numlabel.height+4
                                    color: "#0088ff"
                                    radius: height/4
                                    visible: mdl.count>0 && labels[deleg.keys[index]]>1 && map_top.detaillevel==deleg.keys[index]
                                    PQText {
                                        id: numlabel
                                        x: 10
                                        y: 2
                                        font.weight: baselook.boldweight
                                        anchors.centerIn: parent
                                        text: labels[deleg.keys[index]]
                                    }
                                }
                            }
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                property bool tooltipSetup: false
                                tooltip: ""
                                onEntered: {
                                    if(!tooltipSetup) {
                                        tooltip = (image.source=="" ? "" : ("<img src='" + image.source + "'>")) + "<br><br>" +
                                                                            " <b>" + handlingFileDir.getFileNameFromFullPath(filename) + "</b>" +
                                                                            ((labels[map_top.detaillevel]>1) ? (" + " + (labels[map_top.detaillevel]-1) + "") : "")
                                        tooltipSetup = true
                                    }

                                    map.curZ += 1
                                    deleg.z = map.curZ
                                }
                                onClicked: {

                                    smoothCenterLat.from = map.center.latitude
                                    smoothCenterLat.to = latitude

                                    smoothCenterLon.from = map.center.longitude
                                    smoothCenterLon.to = longitude

                                    smoothZoom.from = map.zoomLevel
                                    smoothZoom.to = Math.min(map.zoomLevel+1, map.maximumZoomLevel)

                                    smoothZoom.start()
                                    smoothCenterLat.start()
                                    smoothCenterLon.start()

                                }
                            }

                            Component.onCompleted: {
                                lvls = levels.split("_")
                            }

                        }

                }

            }

            NumberAnimation {
                id: smoothZoom
                duration: 200
                target: mapexplorer_top
                property: "mapZoomLevel"
            }

            NumberAnimation {
                id: smoothCenterLat
                duration: 200
                target: map
                property: "center.latitude"
            }

            NumberAnimation {
                id: smoothCenterLon
                duration: 200
                target: map
                property: "center.longitude"
            }

            NumberAnimation {
                id: smoothRotation
                duration: 200
                target: map
                property: "bearing"
            }

            NumberAnimation {
                id: smoothTilt
                duration: 200
                target: map
                property: "tilt"
            }

            Timer {
                id: setMapType
                interval: 50
                onTriggered: {
                    if(currentPlugin != "osm")
                        return
                    for(var i in map.supportedMapTypes) {
                        if(map.supportedMapTypes[i].name.localeCompare("Custom URL Map") === 0)
                            map.activeMapType = map.supportedMapTypes[i]
                    }
                }
            }

            Component.onCompleted:  {
                maptweaks.minZoomLevel = minimumZoomLevel
                maptweaks.maxZoomLevel = maximumZoomLevel
                setMapType.start()
            }

            Connections {

                target: map_top

                onComputeDetailLevel: {
                    for(var i = 0; i < steps.length; ++i) {
                        if(map.zoomLevel > steps[i][1]) {
                            map_top.detaillevel = i
                            break
                        }
                    }
                }

                onClearModel: {
                    mdl.clear()
                }

                onResetCurZ: {
                    map.curZ = 0
                }

                onResetMap: {
                    smoothCenterLat.from = map.center.latitude
                    smoothCenterLat.to = (PQLocation.minimumLocation.x+PQLocation.maximumLocation.x)/2

                    smoothCenterLon.from = map.center.longitude
                    smoothCenterLon.to = (PQLocation.minimumLocation.y+PQLocation.maximumLocation.y)/2

                    smoothZoom.from = map.zoomLevel
                    smoothZoom.to = (mdl.count>0 ? ((map.maximumZoomLevel-map.minimumZoomLevel)*0.3) : map.minimumZoomLevel)

                    smoothRotation.from = map.bearing
                    smoothRotation.to = 0

                    smoothTilt.from = map.tilt
                    smoothTilt.to = 0

                    smoothZoom.start()
                    smoothCenterLat.start()
                    smoothCenterLon.start()
                    smoothRotation.start()
                    smoothTilt.start()

                }

                onAddItem: {

                    mdl.append({"latitude": lat,
                                "longitude": lon,
                                "filename": fn,
                                "levels": lvl,
                                "labels": lbl,
                                "display_latitude": full_lat,
                                "display_longitude": full_lon
                               })

                }

                onSetMapCenter: {
                    map.center.latitude = lat
                    map.center.longitude = lon
                }

                onSetMapCenterSmooth: {

                    smoothCenterLat.from = map.center.latitude
                    smoothCenterLat.to = lat

                    smoothCenterLon.from = map.center.longitude
                    smoothCenterLon.to = lon

                    smoothCenterLat.start()
                    smoothCenterLon.start()
                }

                onSetMapZoomLevelSmooth: {

                    smoothZoom.from = map.zoomLevel
                    smoothZoom.to = lvl
                    smoothZoom.start()

                }

                onUpdateVisibleRegionNow: {
                    updateVisibleRegion.execute()
                }

                onShowHighlightMarkerAt: {
                    highlightMarker.showAt(lat, lon)
                }

                onHideHightlightMarker: {
                    highlightMarker.hide()
                }

            }

        }

    }

}
