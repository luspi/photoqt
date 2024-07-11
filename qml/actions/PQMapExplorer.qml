/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import QtQuick.Controls
import QtQuick.Layouts

import PQCNotify
import PQCLocation
import PQCWindowGeometry
import PQCScriptsFilesPaths
import PQCFileFolderModel

import "../elements"
import "./mapexplorerparts"

Item {

    id: mapexplorer_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0
    enabled: visible

    onOpacityChanged: {
        if(opacity > 0 && !isPopout)
            toplevel.titleOverride = qsTranslate("actions", "Map Explorer")
        else if(opacity == 0)
            toplevel.titleOverride = ""
    }

    property bool finishShow: false

    property var imagesWithLocation: []

    property var folderLoaded: []

    property real mapZoomLevel: 10

    property bool isPopout: PQCSettings.interfacePopoutMapExplorer

    state: isPopout ?
               "popout" :
               ""

    states: [
        State {
            name: "popout"
            PropertyChanges {
                target: mapexplorer_top
                width: parentWidth
                height: parentHeight
                opacity: 0
            }
        }
    ]

    SplitView {

        width: parent.width
        height: parent.height

        // Show larger handle with triple dash
        handle: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            color: SplitHandle.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
            Behavior on color { ColorAnimation { duration: 200 } }

            Image {
                y: (parent.height-height)/2
                width: parent.implicitWidth
                height: parent.implicitHeight
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/white/handle.svg"
            }

        }

        Item {

            id: mapcont

            width: mapexplorer_top.width/2
            height: parent.height
            SplitView.minimumWidth: 400
            SplitView.minimumHeight: 300
            SplitView.preferredWidth: mapexplorer_top.width/2

            PQMapExplorerMap {
                id: map
                width: parent.width
                height: parent.height-maptweaks.height
            }

            PQMapExplorerMapTweaks {
                id: maptweaks
                y: parent.height-height
                width: map.width
                height: 50
            }

            Rectangle {

                x: 0
                y: 0
                width: 25
                height: 25

                visible: !PQCWindowGeometry.mapexplorerForcePopout
                enabled: visible

                color: PQCLook.transColor

                opacity: popinmouse.containsMouse ? 1 : 0.2
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: "image://svg/:/white/popinpopout.svg"
                    sourceSize: Qt.size(width, height)
                }

                PQMouseArea {
                    id: popinmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: PQCSettings.interfacePopoutMapExplorer ?
                                 //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                                 qsTranslate("popinpopout", "Merge into main interface") :
                                 //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                                 qsTranslate("popinpopout", "Move to its own window")
                    onClicked: {
                        hideExplorer()
                        PQCSettings.interfacePopoutMapExplorer = !PQCSettings.interfacePopoutMapExplorer
                        PQCNotify.executeInternalCommand("__showMapExplorer")
                    }
                }

            }

            Item {
                width: closebutton.width/2
                height: 1
            }

        }

        Item {

            id: imagestweaks

            width: mapexplorer_top.width/2
            height: parent.height

            SplitView.minimumWidth: 400
            SplitView.minimumHeight: 300
            SplitView.preferredWidth: mapexplorer_top.width/2

            PQMapExplorerImages {
                id: visibleimages
                width: parent.width
                height: parent.height-explorertweaks.height
            }

            PQMapExplorerImagesTweaks {
                id: explorertweaks
                y: parent.height-height
                width: visibleimages.width
                height: 50
            }

        }

    }

    PQButtonElement {
        id: closebutton
        x: mapcont.width-width/2
        y: parent.height-50 + 1
        height: 49
        text: genericStringClose
        onClicked:
            hideExplorer()
    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === "mapexplorer")
                    showExplorer()

            } else if(what === "hide") {

                if(param === "mapexplorer")
                    hideExplorer()

            } else if(mapexplorer_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(mapexplorer_top.popoutWindowUsed && PQCSettings.interfacePopoutMapExplorerNonModal)
                        return

                    if(param[0] === Qt.Key_Escape)
                        hideExplorer()
                }

            }

        }

    }

    NumberAnimation {
        id: smoothWidth
        target: mapcont
        property: "width"
        duration: 200
    }

    function resetWidth() {
        smoothWidth.from = mapcont.width
        smoothWidth.to = mapexplorer_top.width/2
        smoothWidth.start()
    }

    function clickOnImage(lat, lon) {

        map.setMapCenterSmooth(lat, lon)
        map.setMapZoomLevelSmooth(maptweaks.maxZoomLevel/2)

    }

    function loadImages() {

        var items = PQCLocation.imageList
        var labels = PQCLocation.labelList

        map.clearModel()
        imagesWithLocation = []

        for(var key in items) {

            var item_labels = {}

            for(var det = 0; det < 13; ++det) {
                var labelkey = det + "::" + key;
                if(labelkey in labels)
                    item_labels[det] = labels[labelkey]
            }

            var latitude = ""+key.split("::")[0]
            var longitude = ""+key.split("::")[1]
            var filename = ""+items[key][0]
            var full_lat = ""+items[key][1]
            var full_lon = ""+items[key][2]
            var detaillevels = items[key]
            detaillevels.shift()
            detaillevels.shift()
            detaillevels.shift()
            detaillevels = detaillevels.join("_")

            map.addItem(latitude, longitude, filename, detaillevels, item_labels, full_lat, full_lon)

        }

        imagesWithLocation = PQCLocation.allImages

        map.setMapCenter((PQCLocation.minimumLocation.x+PQCLocation.maximumLocation.x)/2,
                         (PQCLocation.minimumLocation.y+PQCLocation.maximumLocation.y)/2)

    }

    function showExplorer() {

        isPopout = PQCSettings.interfacePopoutMapExplorer||PQCWindowGeometry.mapexplorerForcePopout

        opacity = 1
        if(popoutWindowUsed)
            mapexplorer_window.visible = true

        showExplorerData()

    }

    function showExplorerData(forceReload=false) {

        map.resetCurZ()
        finishShow = true

        var path = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
        var mod = PQCScriptsFilesPaths.getFileModified(path).getTime()

        if(folderLoaded.length == 0 || folderLoaded[0] !== path || folderLoaded[1] !== mod) {

            PQCLocation.scanForLocations(PQCFileFolderModel.entriesMainView)
            PQCLocation.processSummary(PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile))
            loadImages()

        } else if(forceReload)
            loadImages()

        map.resetMap()
        map.computeDetailLevel()

        folderLoaded[0] = path
        folderLoaded[1] = mod
        folderLoadedChanged()

        map.updateVisibleRegionNow()

    }

    function hideExplorer() {

        if(PQCSettings.interfacePopoutMapExplorer && PQCSettings.interfacePopoutMapExplorerNonModal)
            return

        opacity = 0
        if(popoutWindowUsed)
            mapexplorer_window.visible = false

        isPopout = Qt.binding(function() { return PQCSettings.interfacePopoutMapExplorer })

        loader.elementClosed("mapexplorer")

    }

}
