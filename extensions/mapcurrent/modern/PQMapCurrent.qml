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

import QtQuick
import QtLocation
import QtPositioning

import PQCFileFolderModel
import PQCScriptsCrypt
import PQCScriptsMetaData
import PQCExtensionsHandler

import PhotoQt

import "../../../qml/modern/elements"

PQTemplateFloating {

    id: mapcurrent_top

    onXChanged: {
        if(dragActive)
            storeSize.restart()
    }
    onYChanged: {
        if(dragActive)
            storeSize.restart()
    }
    onWidthChanged: {
        if(resizeActive)
            storeSize.restart()
    }
    onHeightChanged: {
        if(resizeActive)
            storeSize.restart()
    }

    Timer {
        id: storeSize
        interval: 200
        onTriggered: {
            PQCSettings.extensions.MapCurrentPosition = Qt.point(mapcurrent_top.x, mapcurrent_top.y)
            PQCSettings.extensions.MapCurrentSize = Qt.size(mapcurrent_top.width, mapcurrent_top.height)
        }
    }

    states: [
        State {
            name: "popout"
            PropertyChanges {
                mapcurrent_top.x: 0
                mapcurrent_top.y: 0
                mapcurrent_top.width: mapcurrent_top.parentWidth
                mapcurrent_top.height: mapcurrent_top.parentHeight
            }
        }

    ]

    PQShadowEffect { masterItem: mapcurrent_top }

    popout: PQCSettings.extensions.MapCurrentPopout
    forcePopout: PQCConstants.windowWidth  < PQCExtensionsHandler.getMinimumRequiredWindowSize("mapcurrent").width ||
                 PQCConstants.windowHeight < PQCExtensionsHandler.getMinimumRequiredWindowSize("mapcurrent").height
    shortcut: "__showMapCurrent"
    tooltip: PQCSettings.extensions.MapCurrentPopout||forcePopout ? "" : qsTranslate("mapcurrent", "Click-and-drag to move.")
    blur_thisis: "mapcurrent"

    allowWheel: true
    darkBackgroundManageIcons: !noloc.visible && !nofileloaded.visible

    property real noLocationZoomBefore: 12
    property bool noLocation: true
    property real latitude: 49.00937
    property real longitude: 8.40444

    onPopoutChanged: {
        if(popout !== PQCSettings.extensions.MapCurrentPopout)
            PQCSettings.extensions.MapCurrentPopout = popout
    }

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

    content: [

        Map {
            id: map
            anchors.fill: parent
            plugin: osmPlugin
            center {
                latitude: mapcurrent_top.latitude
                longitude: mapcurrent_top.longitude
            }

            Behavior on center.latitude { NumberAnimation { duration: 200 } }
            Behavior on center.longitude { NumberAnimation { duration: 200 } }

            zoomLevel: 1
            Behavior on zoomLevel { NumberAnimation { duration: 100 } }

            activeMapType: supportedMapTypes[supportedMapTypes.length > 5 ? 5 : (supportedMapTypes.length-1)]

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

            MapQuickItem {

                id: marker

                anchorPoint.x: container.width*(61/256)
                anchorPoint.y: container.height*(198/201)

                visible: true

                coordinate: QtPositioning.coordinate(mapcurrent_top.latitude, mapcurrent_top.longitude)

                sourceItem:
                    Image {
                        id: container
                        width: 64
                        height: 50
                        mipmap: true
                        smooth: false
                        source: "qrc:/" + PQCLook.iconShade + "/maplocation.png" // qmllint disable unqualified
                    }

            }

            Rectangle {
                id: noloc
                anchors.fill: parent
                color: PQCLook.transColor // qmllint disable unqualified
                opacity: (mapcurrent_top.noLocation&&PQCFileFolderModel.countMainView>0) ? 1 : 0 // qmllint disable unqualified
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                    anchors.centerIn: parent
                    //: The location here is a GPS location
                    text: qsTranslate("mapcurrent", "No location data")
                }
                MouseArea {
                    anchors.fill: parent
                    onWheel: (wheel) => {
                        wheel.accepted = true
                    }
                }
            }

            Rectangle {
                id: nofileloaded
                anchors.fill: parent
                color: PQCLook.transColor // qmllint disable unqualified
                opacity: PQCFileFolderModel.countMainView===0 ? 1 : 0 // qmllint disable unqualified
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                    anchors.centerIn: parent
                    //: The location here is a GPS location
                    text: qsTranslate("mapcurrent", "Current location")
                }
                MouseArea {
                    anchors.fill: parent
                    onWheel: (wheel) => {
                        wheel.accepted = true
                    }
                }
            }

        }

    ]

    additionalAction: [
        Image {

            id: explorerimage

            x: 2
            y: 2
            width: 21
            height: 21

            source: "image://svg/:/" + PQCLook.iconShade + "/mapmarker.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)

            opacity: explorermouse.containsMouse ? 0.8 : 0.1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQMouseArea {
                id: explorermouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:
                    PQCNotify.executeInternalCommand("__showMapExplorer") // qmllint disable unqualified
            }

            Rectangle {
                anchors.fill: explorerimage
                radius: width/2
                z: -1
                visible: mapcurrent_top.darkBackgroundManageIcons
                color: PQCLook.transColor // qmllint disable unqualified
                opacity: explorerimage.opacity
            }

        }

    ]

    Component.onCompleted: {

        var pos = PQCSettings.extensions.MapCurrentPosition
        var sze = PQCSettings.extensions.MapCurrentSize

        x = pos.x
        y = pos.y
        width = sze.width
        height = sze.height

        mapcurrent_top.state = ((popout || forcePopout) ? "popout" : "")

    }

    Connections {

        target: PQCMetaData // qmllint disable unqualified

        function onExifGPSChanged() {
            mapcurrent_top.updateMap()
        }

    }

    Connections {
        target: PQCNotify // qmllint disable unqualified

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === "mapcurrent") {
                if(mapcurrent_top.visible) {
                    mapcurrent_top.hide()
                } else {
                    mapcurrent_top.show()
                    mapcurrent_top.updateMap()
                }
            }

        }

    }

    function updateMap() {

        var pos = PQCScriptsMetaData.convertGPSToPoint(PQCMetaData.exifGPS)

        // this value means: no gps data
        if(pos.x === 9999 || pos.y === 9999) {
            if(PQCFileFolderModel.countMainView > 0) {
                noLocationZoomBefore = map.zoomLevel
                map.zoomLevel = 1
            }
            noLocation = true
            return
        }

        if(noLocationZoomBefore > 0)
            map.zoomLevel = noLocationZoomBefore
        noLocationZoomBefore = 0

        latitude = pos.x
        longitude = pos.y
        noLocation = false

    }

    function show() {
        opacity = 1
        PQCSettings.extensions.MapCurrent = true
        if(popoutWindowUsed)
            mapcurrent_popout.visible = true
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            mapcurrent_popout.visible = false // qmllint disable unqualified
        PQCSettings.extensions.MapCurrent = false
    }

}
