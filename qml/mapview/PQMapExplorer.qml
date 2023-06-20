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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.12
import "../elements"
import "./explorer"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: mapexplorer_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: (windowsizepopup.mapExplorer || PQSettings.interfacePopoutMapExplorer) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    property bool finishShow: false

    property var imagesWithLocation: []

    property var folderLoaded: []

    property real mapZoomLevel: 10

    SplitView {

        width: parent.width
        height: parent.height

        handleDelegate: Rectangle {

            width: 8
            height: parent.height
            color: styleData.hovered ? "#888888" : "#666666"
            Behavior on color { ColorAnimation { duration: 100 } }

            Image {
                x: 0
                y: (parent.height-height)/2
                width: parent.width
                height: width
                source: "/filedialog/handle.svg"
            }

        }

        Item {

            id: mapcont

            width: parent.width/2
            height: parent.height
            Layout.minimumWidth: 400
            Layout.minimumHeight: 300
            Layout.fillWidth: true

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

                color: "#88000000"

                opacity: popinmouse.containsMouse ? 1 : 0.2
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: "/popin.svg"
                    sourceSize: Qt.size(width, height)
                }

                PQMouseArea {
                    id: popinmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: PQSettings.interfacePopoutMapExplorer ?
                                 //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                                 em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                                 //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                                 em.pty+qsTranslate("popinpopout", "Move to its own window")
                    onClicked: {
                        if(PQSettings.interfacePopoutMapExplorer)
                            mapexplorer_window.storeGeometry()
                        hideExplorer()
                        PQSettings.interfacePopoutMapExplorer = !PQSettings.interfacePopoutMapExplorer
                        HandleShortcuts.executeInternalFunction("__showMapExplorer")
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

            width: parent.width/2
            height: parent.height

            Layout.minimumWidth: 400
            Layout.minimumHeight: 300
            Layout.fillWidth: true

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

    PQButton {
        id: closebutton
        text: genericStringClose
        font.weight: baselook.boldweight
        x: mapcont.width-width/2
        y: parent.height-50 + 1
        height: 49
        leftRightTextSpacing: 20
        showLeftRightBorder: true
        onClicked:
            hideExplorer()
    }

    Connections {
        target: loader
        onMapExplorerPassOn: {
            if(what == "show") {
                showExplorer()
            } else if(what == "hide") {
                hideExplorer()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    hideExplorer()
            }
        }
    }

    Connections {
        target: PQSettings
        onMapviewProviderChanged: {
            map.currentPlugin = map.getCurrentPlugin()
            map.reloadLoader()
            changeMapDelay.restart()
        }
    }

    Timer {
        id: changeMapDelay
        interval: 500   // this has to be greater than the interval of reloadExplorerMapAfterTimeout in PQMapExplorerMap
        onTriggered: {
            showExplorerData(true)
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

        var items = PQLocation.imageList
        var labels = PQLocation.labelList

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

        imagesWithLocation = PQLocation.allImages

        map.setMapCenter((PQLocation.minimumLocation.x+PQLocation.maximumLocation.x)/2,
                         (PQLocation.minimumLocation.y+PQLocation.maximumLocation.y)/2)

    }

    function showExplorer() {

        if(PQSettings.interfacePopoutMapExplorer || windowsizepopup.mapExplorer)
            mapexplorer_window.visible = true
        else
            opacity = 1


        if((!PQSettings.interfacePopoutMapExplorer && !windowsizepopup.mapExplorer) || !PQSettings.interfacePopoutMapExplorerKeepOpen)
            variables.visibleItem = "mapexplorer"

        showExplorerData()

    }

    function showExplorerData(forceReload=false) {

        map.resetCurZ()
        finishShow = true

        var path = handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath)
        var mod = handlingFileDir.getFileModified(path).getTime()

        if(folderLoaded.length == 0 || folderLoaded[0] != path || folderLoaded[1] != mod) {

            PQLocation.scanForLocations(filefoldermodel.entriesMainView)
            PQLocation.processSummary(handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath))
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

        if(PQSettings.interfacePopoutMapExplorer && PQSettings.interfacePopoutMapExplorerKeepOpen)
            return

        if(PQSettings.interfacePopoutMapExplorer || windowsizepopup.mapExplorer)
            mapexplorer_window.close()
        else
            opacity = 0
        variables.visibleItem = ""

    }

}
