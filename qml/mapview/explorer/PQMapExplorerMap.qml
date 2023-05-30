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

Map {

    id: map

    center: QtPositioning.coordinate(49.01, 8.40) // Karlsruhe
    zoomLevel: 10

    property int curZ: 0

    Plugin {
        id: osmPlugin
        name: "osm"
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

    plugin: (PQSettings.mapviewProvider=="googlemaps" ? googlePlugin : (PQSettings.mapviewProvider=="esri" ? esriPlugin : osmPlugin))

    gesture.acceptedGestures: MapGestureArea.PinchGesture|MapGestureArea.PanGesture|MapGestureArea.FlickGesture

    onZoomLevelChanged: {
        if(!finishShow) return
        computeDetailLevel()
    }

    property real visibleLatitudeLeft: -180
    property real visibleLatitudeRight: 180
    property real visibleLongitudeLeft: -180
    property real visibleLongitudeRight: 180

    Timer {
        id: updateVisibleRegion
        interval: 500
        repeat: true
        running: mapexplorer_top.visible
        onTriggered: {
            execute()
        }
        function execute() {
            map.visibleLatitudeLeft = map.visibleRegion.boundingGeoRectangle().topLeft.latitude
            map.visibleLongitudeLeft = map.visibleRegion.boundingGeoRectangle().topLeft.longitude
            map.visibleLatitudeRight = map.visibleRegion.boundingGeoRectangle().bottomRight.latitude
            map.visibleLongitudeRight= map.visibleRegion.boundingGeoRectangle().bottomRight.longitude
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

    property int detaillevel: 0

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

            anchorPoint.x: container.width/2
            anchorPoint.y: container.height/2

            opacity: (x > -width && x < map.width && y > -height && y < map.height) && (lvls.indexOf(""+map.detaillevel) != -1) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

            coordinate: QtPositioning.coordinate(latitude, longitude)

            property var lvls

            sourceItem:
                Rectangle {
                    id: container
                    width: 68
                    height: 68
                    color: "white"
                    property var keys: Object.keys(labels)
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
                        model: container.keys.length
                        Rectangle {
                            x: parent.width-width*0.8
                            y: -height*0.2
                            width: numlabel.width+20
                            height: numlabel.height+4
                            color: "#0088ff"
                            radius: height/4
                            visible: labels[container.keys[index]]>1 && map.detaillevel==container.keys[index]
                            PQText {
                                id: numlabel
                                x: 10
                                y: 2
                                font.weight: baselook.boldweight
                                anchors.centerIn: parent
                                text: labels[container.keys[index]]
                            }
                        }
                    }
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: "<img src='" + image.source + "'><br><br>" +
                                 " <b>" + handlingFileDir.getFileNameFromFullPath(filename) + "</b>" +
                                 (labels[map.detaillevel]>1 ? (" + " + (labels[map.detaillevel]-1) + "") : "")
                        onEntered: {
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

    Image {
        id: zoomInButton
        x: (parent.width-width-zoomOutButton.width-20)
        y: 10
        width: 32
        height: 32
        sourceSize.width: 32
        sourceSize.height: 32
        source: "/mapview/zoomin.svg"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: "Zoom in"
            onClicked: {
                smoothZoom.from = map.zoomLevel
                smoothZoom.to = Math.min(map.maximumZoomLevel, map.zoomLevel+0.5)
                smoothZoom.start()
            }
        }
    }

    Image {
        id: zoomOutButton
        x: (parent.width-width-10)
        y: 10
        width: 32
        height: 32
        sourceSize.width: 32
        sourceSize.height: 32
        source: "/mapview/zoomout.svg"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: "Zoom out"
            onClicked: {
                smoothZoom.from = map.zoomLevel
                smoothZoom.to = Math.max(map.minimumZoomLevel, map.zoomLevel-0.5)
                smoothZoom.start()
            }
        }
    }

    Image {
        id: resetButton
        x: 10
        y: 10
        width: 32
        height: 32
        sourceSize.width: 32
        sourceSize.height: 32
        source: "/mapview/reset.svg"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: "Reset view"
            onClicked: {

                smoothCenterLat.from = map.center.latitude
                smoothCenterLat.to = (PQLocation.minimumLocation.x+PQLocation.maximumLocation.x)/2

                smoothCenterLon.from = map.center.longitude
                smoothCenterLon.to = (PQLocation.minimumLocation.y+PQLocation.maximumLocation.y)/2

                smoothZoom.from = map.zoomLevel
                smoothZoom.to = 10

                smoothZoom.start()
                smoothCenterLat.start()
                smoothCenterLon.start()

            }
        }

    }

    NumberAnimation {
        id: smoothZoom
        duration: 200
        target: map
        property: "zoomLevel"
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

    function computeDetailLevel() {
        for(var i = 0; i < steps.length; ++i) {
            if(map.zoomLevel > steps[i][1]) {
                detaillevel = i
                break
            }
        }
    }

    function clearModel() {
        mdl.clear()
    }

    function resetCurZ() {
        curZ = 0
    }

    function addItem(lat, lon, fn, lvl, lbl) {

        mdl.append({"latitude": lat,
                    "longitude": lon,
                    "filename": fn,
                    "levels": lvl,
                    "labels": lbl
                   })

    }

    function setMapCenter(lat, lon) {
        map.center.latitude = lat
        map.center.longitude = lon
    }

    function updateVisibleRegionNow() {
        updateVisibleRegion.execute()
    }

    function showHighlightMarkerAt(lat, lon) {
        highlightMarker.showAt(lat, lon)
    }

    function hideHightlightMarker() {
        highlightMarker.hide()
    }

}
