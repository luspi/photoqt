import QtQuick
import QtCharts
import QtLocation
import QtPositioning

import PQCFileFolderModel
import PQCScriptsCrypt
import PQCScriptsMetaData
import PQCMetaData
import PQCNotify

import "../elements"

PQTemplateFloating {

    id: mapcurrent_top

    onXChanged: {
        if(!toplevel.startup && dragActive)
            storeSize.restart()
    }
    onYChanged: {
        if(!toplevel.startup && dragActive)
            storeSize.restart()
    }
    onWidthChanged: {
        if(!toplevel.startup && resizeActive)
            storeSize.restart()
    }
    onHeightChanged: {
        if(!toplevel.startup && resizeActive)
            storeSize.restart()
    }

    Timer {
        id: storeSize
        interval: 200
        onTriggered: {
            PQCSettings.mapviewCurrentPosition.x = mapcurrent_top.x
            PQCSettings.mapviewCurrentPosition.y = mapcurrent_top.y
            PQCSettings.mapviewCurrentSize.width = mapcurrent_top.width
            PQCSettings.mapviewCurrentSize.height = mapcurrent_top.height
        }
    }

    states: [
        State {
            name: "popout"
            PropertyChanges {
                target: mapcurrent_top
                x: 0
                y: 0
                width: mapcurrent_top.parentWidth
                height: mapcurrent_top.parentHeight
            }
        }

    ]

    popout: PQCSettings.interfacePopoutMapCurrent
    shortcut: "__showMapCurrent"
    tooltip: PQCSettings.interfacePopoutMapCurrent ? "" : qsTranslate("mapcurrent", "Click-and-drag to move.")

    blur_thisis: "mapcurrent"

    allowWheel: true
    darkBackgroundManageIcons: !noloc.visible && !nofileloaded.visible

    property real noLocationZoomBefore: 12
    property bool noLocation: true
    property real latitude: 49.00937
    property real longitude: 8.40444

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMapCurrent)
            PQCSettings.interfacePopoutMapCurrent = popout
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

            activeMapType: supportedMapTypes[5]

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

                coordinate: QtPositioning.coordinate(latitude, longitude)

                sourceItem:
                    Image {
                        id: container
                        width: 64
                        height: 50
                        mipmap: true
                        smooth: false
                        source: "/white/maplocation.png"
                    }

            }

            Rectangle {
                id: noloc
                anchors.fill: parent
                color: PQCLook.transColor
                opacity: (noLocation&&PQCFileFolderModel.countMainView>0) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    font.weight: PQCLook.fontWeightBold
                    anchors.centerIn: parent
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
                color: PQCLook.transColor
                opacity: PQCFileFolderModel.countMainView===0 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    font.weight: PQCLook.fontWeightBold
                    anchors.centerIn: parent
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

            source: "image://svg/:/white/mapmarker.svg"
            sourceSize: Qt.size(width, height)

            opacity: explorermouse.containsMouse ? 0.8 : 0.1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQMouseArea {
                id: explorermouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:
                    PQCNotify.executeInternalCommand("__showMapExplorer")
            }

            Rectangle {
                anchors.fill: explorerimage
                radius: width/2
                z: -1
                visible: darkBackgroundManageIcons
                color: PQCLook.transColor
                opacity: explorerimage.opacity
            }

        }

    ]

    Component.onCompleted: {
        if(PQCSettings.interfacePopoutMapCurrent) {
            mapcurrent_top.state = "popout"
        } else {
            mapcurrent_top.state = ""
            x = PQCSettings.mapviewCurrentPosition.x
            y = PQCSettings.mapviewCurrentPosition.y
            width = PQCSettings.mapviewCurrentSize.width
            height = PQCSettings.mapviewCurrentSize.height
        }

        if(PQCSettings.mapviewCurrentVisible)
            show()
    }

    Connections {

        target: PQCMetaData

        function onExifGPSChanged() {
            updateMap()
        }

    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {
                if(param === "mapcurrent") {
                    if(mapcurrent_top.visible) {
                        mapcurrent_top.hide()
                    } else {
                        mapcurrent_top.show()
                        updateMap()
                    }
                }
            }

        }

    }

    Connections {

        target: PQCSettings

        function onMapviewCurrentVisibleChanged() {
            if(PQCSettings.mapviewCurrentVisible)
                show()
            else
                hide()
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
        PQCSettings.mapviewCurrentVisible = true
        if(popout)
            mapcurrent_popout.show()
    }

    function hide() {
        opacity = 0
        PQCSettings.mapviewCurrentVisible = false
    }

}
