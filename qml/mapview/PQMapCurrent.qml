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

    id: map_top

    PQBlurBackground {
        thisis: mapcurrent
        radius: 10
        isPoppedOut: PQSettings.interfacePopoutMapCurrent
    }

    x: PQSettings.interfacePopoutMapCurrent ? 0 : PQSettings.mapviewCurrentPosition.x
    y: PQSettings.interfacePopoutMapCurrent ? 0 : PQSettings.mapviewCurrentPosition.y
    width: PQSettings.interfacePopoutMapCurrent ? parentWidth : PQSettings.mapviewCurrentSize.width
    height: PQSettings.interfacePopoutMapCurrent ? parentHeight : PQSettings.mapviewCurrentSize.height

    property int parentWidth: 0
    property int parentHeight: 0

    // at startup toplevel width/height is zero causing the x/y of the map to be set to 0
    property bool startupDelay: true

    onXChanged:
        saveGeometryTimer.restart()
    onYChanged:
        saveGeometryTimer.restart()
    onWidthChanged:
        saveGeometryTimer.restart()
    onHeightChanged:
        saveGeometryTimer.restart()

    opacity: (PQSettings.interfacePopoutMapCurrent||(PQSettings.mapviewCurrentVisible)) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    onVisibleChanged:
        updateMap()

    property bool noLocation: true
    property real latitude: 49.00937
    property real longitude: 8.40444

    Rectangle {
        anchors.fill: parent
        color: "#88000000"
    }

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
        anchors.margins: PQSettings.interfacePopoutMapCurrent ? 0 : 2

        opacity: noLocation ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        plugin: (PQSettings.mapviewProvider=="googlemaps" ? googlePlugin : (PQSettings.mapviewProvider=="esri" ? esriPlugin : osmPlugin))

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
                    source: "/image/mapmarker.png"
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

    PQMouseArea {
        anchors.fill: parent
        enabled: !PQSettings.interfacePopoutMapCurrent
        hoverEnabled: true
        drag.target: parent
        cursorShape: Qt.SizeAllCursor
        onWheel: {
            if(noLocation) return
            if(wheel.angleDelta.y < 0)
                map.zoomLevel = Math.max(map.minimumZoomLevel, map.zoomLevel-0.5)
            else
                map.zoomLevel = Math.min(map.maximumZoomLevel, map.zoomLevel+0.5)
        }
    }

    Rectangle {
        anchors.fill: closeimage
        radius: width/2
        color: "#88000000"
        opacity: closeimage.opacity
    }

    Image {

        id: closeimage

        x: parent.width-width+5
        y: -5
        width: 25
        height: 25

        visible: !PQSettings.interfacePopoutMapCurrent

        source: "/other/close.svg"
        sourceSize: Qt.size(width, height)

        opacity: closemouse.containsMouse ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked:
                PQSettings.mapviewCurrentVisible = !PQSettings.mapviewCurrentVisible
        }

    }

    PQMouseArea {

        id: resizeBotRight

        enabled: !PQSettings.interfacePopoutMapCurrent

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: Qt.SizeFDiagCursor

        onPositionChanged: {
            if(pressed) {
                map_top.width += (mouse.x-resizeBotRight.width)
                map_top.height += (mouse.y-resizeBotRight.height)
                if(map_top.width < 100)
                    map_top.width = 100
                if(map_top.height < 100)
                    map_top.height = 100

            }
        }

    }

    Rectangle {
        anchors.fill: popinimage
        anchors.margins: -2
        radius: 2
        color: "#88000000"
        opacity: popinimage.opacity
    }

    Image {
        id: popinimage
        x: (PQSettings.interfacePopoutMapCurrent ? 5 : 0)
        y: PQSettings.interfacePopoutMapCurrent ? 5 : 0
        width: 15
        height: 15
        source: "/popin.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutMapCurrent ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutMapCurrent)
                    mapcurrent_window.storeGeometry()
                PQSettings.interfacePopoutMapCurrent = !PQSettings.interfacePopoutMapCurrent
                loader.ensureItIsReady("mapcurrent")
            }
        }
    }

    Connections {
        target: filefoldermodel
        onCurrentFilePathChanged:
            updateMap()
    }

    // this makes sure that a change in the window geometry does not leeds to the element being outside the visible area
    Connections {
        target: toplevel
        onWidthChanged: {
            if(map_top.x < 0)
                map_top.x = 0
            else if(map_top.x > toplevel.width-map_top.width)
                map_top.x = toplevel.width-map_top.width
        }
        onHeightChanged: {
            if(map_top.y < 0)
                map_top.y = 0
            else if(map_top.y > toplevel.height-map_top.height)
                map_top.y = toplevel.height-map_top.height
        }
    }

    Connections {
        target: PQSettings
        onMapviewCurrentVisibleChanged:
            updateMap()
    }

    Timer {
        // at startup toplevel width/height is zero causing the x/y of the histogram to be set to 0
        running: true
        repeat: false
        interval: 250
        onTriggered:
            startupDelay = false
    }

    Timer {
        id: saveGeometryTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: {
            if(!PQSettings.interfacePopoutMapCurrent && !startupDelay) {
                PQSettings.mapviewCurrentPosition = Qt.point(Math.max(0, Math.min(map_top.x, toplevel.width-map_top.width)), Math.max(0, Math.min(map_top.y, toplevel.height-map_top.height)))
                PQSettings.mapviewCurrentSize = Qt.size(map_top.width, map_top.height)
            }
        }
    }

    Component.onCompleted:
        updateMap()

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
