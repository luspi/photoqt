/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtLocation
import QtPositioning
import PQCLocation
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

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

    property bool gpsContextMenuIsOpen: false
    signal closeMenus()

    Plugin {

        id: osmPlugin

        name: "osm"

        PluginParameter {
            name: "osm.useragent"
            value: "PhotoQt Image Viewer"
        }

        PluginParameter {
            name: "osm.mapping.providersrepository.address"
            value: "https://osm.photoqt.org"
        }

        PluginParameter {
            name: "osm.mapping.highdpi_tiles";
            value: true
        }

    }

    Map {

        id: map

        anchors.fill: parent

        center: QtPositioning.coordinate(49.01, 8.40)
        zoomLevel: mapexplorer_top.mapZoomLevel

        property int curZ: 0

        plugin: osmPlugin

        activeMapType: supportedMapTypes[supportedMapTypes.length > 5 ? 5 : (supportedMapTypes.length-1)]

        property geoCoordinate startCentroid

        PinchHandler {
            id: pinch
            target: null
            onActiveChanged: if (active) {
                map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
            }
            onScaleChanged: (delta) => {
                map.zoomLevel += Math.log2(delta)
                map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
            }
        }

        WheelHandler {
            id: wheel
            // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
            // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
            // and we don't yet distinguish mice and trackpads on Wayland either
            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland" ?
                                 PointerDevice.Mouse | PointerDevice.TouchPad :
                                 PointerDevice.Mouse
            rotationScale: 1/40
            property: "zoomLevel"
        }

        DragHandler {
            id: drag
            target: null
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
        }

        onZoomLevelChanged: (zoomLevel) => {
            map_top.computeDetailLevel()
            if(zoomLevel !== mapexplorer_top.mapZoomLevel)
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
                var tl = map.visibleRegion.boundingGeoRectangle().topLeft
                var br = map.visibleRegion.boundingGeoRectangle().bottomRight
                map_top.visibleLatitudeLeft = tl.latitude
                map_top.visibleLongitudeLeft = tl.longitude
                map_top.visibleLatitudeRight = br.latitude
                map_top.visibleLongitudeRight= br.longitude
            }
        }

        PQMouseArea {
            id: mapmouse
            anchors.fill: parent
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            onClicked: (mouse) => {
                if(mouse.button === Qt.RightButton)
                    mapmenu.popup()
            }
            onDoubleClicked: (mouse) => {
                smoothZoom.stop()
                smoothZoom.from = map.zoomLevel
                smoothZoom.to = map.zoomLevel+1
                smoothZoom.start()
            }

            onPressAndHold: (mouse) => {
                mapmenu.popup(mapmouse.mapToItem(map, mouse.x, mouse.y))
            }
        }
        PQMenu {

            id: mapmenu

            property list<real> loc

            PQMenuItem {
                enabled: false
                //: The location here is a GPS location
                text: qsTranslate("mapexplorer", "Copy location to clipboard:")
            }

            PQMenuItem {
                id: menuitem_exact
                text: Math.round(1e2*mapmenu.loc[0])/1e2 + ", " + Math.round(1e2*mapmenu.loc[1])/1e2
                onTriggered: {
                    PQCScriptsClipboard.copyTextToClipboard(text)
                }
            }

            PQMenuItem {
                implicitHeight: (visible ? 40 : 0)
                visible: text!=menuitem_exact.text
                text: Math.round(1e5*mapmenu.loc[0])/1e5 + ", " + Math.round(1e5*mapmenu.loc[1])/1e5
                onTriggered: {
                    PQCScriptsClipboard.copyTextToClipboard(text)
                }
            }

            PQMenuItem {
                text: PQCScriptsMetaData.convertGPSDecimalToDegree(mapmenu.loc[0], mapmenu.loc[1])
                onTriggered: {
                    PQCScriptsClipboard.copyTextToClipboard(text)
                }
            }

            onAboutToShow: {
                var val = map.toCoordinate(Qt.point(mapmouse.mouseX, mapmouse.mouseY))
                mapmenu.loc = [val.latitude, val.longitude]
                map_top.gpsContextMenuIsOpen = true
                contextmarker.coordinate = val
            }
            onAboutToHide:
                map_top.gpsContextMenuIsOpen = false
            Connections {
                target: map_top
                function onCloseMenus() {
                    mapmenu.close()
                }
            }

        }

        MapQuickItem {

            id: contextmarker

            anchorPoint.x: curposImage.width*(61/256)
            anchorPoint.y: curposImage.height*(198/201)

            opacity: mapmenu.visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
            visible: opacity>0

            sourceItem:
                Image {
                    id: curposImage
                    width: 64
                    height: 50
                    mipmap: true
                    smooth: false
                    source: "qrc:/" + PQCLook.iconShade + "/maplocation.png"
                }

        }

        property list<var> steps: [
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
                    source: "qrc:/" + PQCLook.iconShade + "/maplocation.png"
                }

            function showAt(lat : real, lon : real) {
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

                required property string latitude
                required property string longitude
                required property string filename
                required property string levels
                required property var labels
                required property string display_latitude
                required property string display_longitude

                property list<string> keys: Object.keys(labels)

                anchorPoint.x: containerloader.width/2
                anchorPoint.y: containerloader.height/2

                opacity: (x > -width && x < map.width && y > -height && y < map.height) && (lvls.indexOf(map_top.detaillevel.toString()) !== -1) ? 1 : 0
                visible: opacity>0

                property bool showTruePos: keys.indexOf(map_top.detaillevel+"")!=-1 && labels[map_top.detaillevel]*1==1
                coordinate: QtPositioning.coordinate((showTruePos ? display_latitude : latitude), (showTruePos ? display_longitude : longitude))

                property var lvls: levels.split("_")

                sourceItem:
                Loader {
                    id: containerloader
                    active: deleg.visible
                    sourceComponent:
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
                            source: (!visible && source==="") ? "" : encodeURI("image://thumb/" + deleg.filename)
                        }
                        Repeater {
                            model: deleg.keys.length
                            Rectangle {
                                id: lbldeleg
                                required property int modelData
                                x: parent.width-width*0.8
                                y: -height*0.2
                                width: numlabel.width+20
                                height: numlabel.height+4
                                color: "#0088ff"
                                radius: height/4
                                visible: mdl.count>0 && deleg.labels[deleg.keys[modelData]]>1 && map_top.detaillevel===deleg.keys[modelData]
                                PQText {
                                    id: numlabel
                                    x: 10
                                    y: 2
                                    font.weight: PQCLook.fontWeightBold
                                    anchors.centerIn: parent
                                    text: deleg.labels[deleg.keys[lbldeleg.modelData]]
                                }
                            }
                        }
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            property bool tooltipSetup: false
                            text: ""
                            onEntered: {
                                if(!tooltipSetup) {
                                    text = (image.source===Qt.url("") ? "" : ("<img src='" + image.source + "'>")) + "<br><br>" +
                                                                        " <b>" + PQCScriptsFilesPaths.getFilename(deleg.filename) + "</b>" +
                                                                        ((deleg.labels[map_top.detaillevel]>1) ? (" + " + (deleg.labels[map_top.detaillevel]-1) + "") : "")
                                    tooltipSetup = true
                                }

                                map.curZ += 1
                                deleg.z = map.curZ
                            }
                            onClicked: {

                                smoothCenterLat.from = map.center.latitude
                                smoothCenterLat.to = deleg.latitude

                                smoothCenterLon.from = map.center.longitude
                                smoothCenterLon.to = deleg.longitude

                                smoothZoom.from = map.zoomLevel
                                smoothZoom.to = Math.min(map.zoomLevel+1, map.maximumZoomLevel)

                                smoothZoom.start()
                                smoothCenterLat.start()
                                smoothCenterLon.start()

                            }
                        }

                    }

                }

            }

        }

        Rectangle {
            width: gpspos.width+6
            height: gpspos.height+6
            color: "#bb000000"
            z: 5
            x: parent.width-width
            y: parent.height-height

            PQTextS {
                id: gpspos
                x: 3
                y: 3
                property list<double> loc: [Math.round(1e2*map.center.latitude)/1e2, Math.round(1e2*map.center.longitude)/1e2]
                text: loc[0] + ", " + loc[1]
                font.weight: PQCLook.fontWeightBold
            }

            PQMenu {
                id: gpsmenu
                onAboutToShow:
                    map_top.gpsContextMenuIsOpen = true
                onAboutToHide:
                    map_top.gpsContextMenuIsOpen = false
                Connections {
                    target: map_top
                    function onCloseMenus() {
                        gpsmenu.close()
                    }
                }

                property list<double> curLatLon: [0,0]
                Connections {
                    target: map
                    function onCenterChanged() {
                        gpslocTimer.restart()
                    }
                }

                Timer {
                    id: gpslocTimer
                    interval: 250
                    onTriggered: {
                        gpsmenu.curLatLon = [map.center.latitude, map.center.longitude]
                    }
                }

                PQMenuItem {
                    enabled: false
                    //: The location here is a GPS location
                    text: qsTranslate("mapexplorer", "Copy location to clipboard:")
                }

                PQMenuItem {
                    id: menuitem1
                    text: gpspos.loc[0] + ", " + gpspos.loc[1]
                    onTriggered: {
                        PQCScriptsClipboard.copyTextToClipboard(text)
                    }
                }

                PQMenuItem {
                    implicitHeight: (visible ? 40 : 0)
                    visible: text!=menuitem1.text
                    text: Math.round(1e5*gpsmenu.curLatLon[0])/1e5 + ", " + Math.round(1e5*gpsmenu.curLatLon[1])/1e5
                    onTriggered: {
                        PQCScriptsClipboard.copyTextToClipboard(text)
                    }
                }

                PQMenuItem {
                    text: PQCScriptsMetaData.convertGPSDecimalToDegree(gpsmenu.curLatLon[0], gpsmenu.curLatLon[1])
                    onTriggered: {
                        PQCScriptsClipboard.copyTextToClipboard(text)
                    }
                }
            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                //: The location here is a GPS location
                text: qsTranslate("mapexplorer", "Click to show a menu for copying location to clipboard.")
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: (mouse) => {
                    gpsmenu.popup()
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

        Component.onCompleted:  {
            maptweaks.minZoomLevel = minimumZoomLevel
            maptweaks.maxZoomLevel = maximumZoomLevel
        }

        Connections {

            target: map_top

            function onComputeDetailLevel() {
                var dl = -1
                for(var i = 0; i < map.steps.length; ++i) {
                    if(map.zoomLevel > map.steps[i][1]) {
                        dl = i
                        break
                    }
                }
                if(dl === -1)
                    dl = map.steps.length-1
                map_top.detaillevel = dl
            }

            function onClearModel() {
                mdl.clear()
            }

            function onResetCurZ() {
                map.curZ = 0
            }

            function onResetMap() {
                smoothCenterLat.from = map.center.latitude
                smoothCenterLat.to = (PQCLocation.minimumLocation.x+PQCLocation.maximumLocation.x)/2

                smoothCenterLon.from = map.center.longitude
                smoothCenterLon.to = (PQCLocation.minimumLocation.y+PQCLocation.maximumLocation.y)/2

                smoothZoom.from = map.zoomLevel
                smoothZoom.to = (mdl.count>0 ? ((map.maximumZoomLevel-map.minimumZoomLevel)*0.25) : map.minimumZoomLevel)

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

            function onAddItem(lat, lon, fn, lvl, lbl, full_lat, full_lon) {

                mdl.append({"latitude": lat,
                            "longitude": lon,
                            "filename": fn,
                            "levels": lvl,
                            "labels": lbl,
                            "display_latitude": full_lat,
                            "display_longitude": full_lon
                           })

            }

            function onSetMapCenter(lat : real, lon : real) {
                map.center.latitude = lat
                map.center.longitude = lon
            }

            function onSetMapCenterSmooth(lat : real, lon : real) {

                smoothCenterLat.from = map.center.latitude
                smoothCenterLat.to = lat

                smoothCenterLon.from = map.center.longitude
                smoothCenterLon.to = lon

                smoothCenterLat.start()
                smoothCenterLon.start()
            }

            function onSetMapZoomLevelSmooth(lvl : int) {

                smoothZoom.from = map.zoomLevel
                smoothZoom.to = lvl
                smoothZoom.start()

            }

            function onUpdateVisibleRegionNow() {
                updateVisibleRegion.execute()
            }

            function onShowHighlightMarkerAt(lat : real, lon : real) {
                highlightMarker.showAt(lat, lon)
            }

            function onHideHightlightMarker() {
                highlightMarker.hide()
            }

        }

    }

}
