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
import "../elements"
import "./explorer"

SplitView {

    id: mapexplorer_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    property int currentDetailLevel: -1

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    property bool finishShow: false

    property var imagesWithLocation: []

    property var folderLoaded: []

    orientation: PQSettings.mapviewExplorerLayoutLeftRight ? Qt.Horizontal : Qt.Vertical

    handleDelegate: Rectangle {

        width: PQSettings.mapviewExplorerLayoutLeftRight ? 8 : parent.width
        height: PQSettings.mapviewExplorerLayoutLeftRight ? parent.height : 8
        color: styleData.hovered ? "#888888" : "#666666"
        Behavior on color { ColorAnimation { duration: 100 } }

        Image {
            x: PQSettings.mapviewExplorerLayoutLeftRight ? 0 : (parent.width-width)/2
            y: PQSettings.mapviewExplorerLayoutLeftRight ? (parent.height-height)/2 : 0
            width: PQSettings.mapviewExplorerLayoutLeftRight ? parent.width : parent.height
            height: width
            source: "/filedialog/handle.svg"
        }

    }

    PQMapExplorerMap {
        id: map
        width: PQSettings.mapviewExplorerLayoutLeftRight ? parent.width/2 : parent.width
        height: PQSettings.mapviewExplorerLayoutLeftRight ? parent.height : parent.height/2
    }

    Item {

        id: imagestweaks

        width: PQSettings.mapviewExplorerLayoutLeftRight ? parent.width/2 : parent.width
        height: PQSettings.mapviewExplorerLayoutLeftRight ? parent.height : parent.height/2

        PQMapExplorerImages {
            id: visibleimages
            width: parent.width
            height: parent.height-explorertweaks.height
        }

        PQMapExplorerTweaks {
            id: explorertweaks
            y: parent.height-height
            width: visibleimages.width
            height: 50
        }

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

    function resetWidthHeight() {
        map.width = PQSettings.mapviewExplorerLayoutLeftRight ? mapexplorer_top.width/2 : mapexplorer_top.width
        map.height = PQSettings.mapviewExplorerLayoutLeftRight ? mapexplorer_top.height : mapexplorer_top.height/2
        imagestweaks.width = PQSettings.mapviewExplorerLayoutLeftRight ? mapexplorer_top.width/2 : mapexplorer_top.width
        imagestweaks.height = PQSettings.mapviewExplorerLayoutLeftRight ? mapexplorer_top.height : mapexplorer_top.height/2
    }

    function clickOnImage(index) {
        filefoldermodel.setAsCurrent(imagesWithLocation[index][0])
        hideExplorer()
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
            var detaillevels = items[key]
            detaillevels.shift()
            detaillevels = detaillevels.join("_")

            map.addItem(latitude, longitude, filename, detaillevels, item_labels)

        }

        imagesWithLocation = PQLocation.allImages

        map.setMapCenter((PQLocation.minimumLocation.x+PQLocation.maximumLocation.x)/2,
                         (PQLocation.minimumLocation.y+PQLocation.maximumLocation.y)/2)

    }

    function showExplorer() {

        map.resetCurZ()
        opacity = 1
        variables.visibleItem = "mapexplorer"
        finishShow = true

        var path = handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath)
        var mod = handlingFileDir.getFileModified(path).getTime()

        if(folderLoaded.length == 0 || folderLoaded[0] != path || folderLoaded[1] != mod) {

            PQLocation.scanForLocations(filefoldermodel.entriesMainView)
            PQLocation.processSummary(handlingFileDir.getFilePathFromFullPath(filefoldermodel.currentFilePath))
            loadImages()
            map.computeDetailLevel()

        }

        folderLoaded[0] = path
        folderLoaded[1] = mod

        map.updateVisibleRegionNow()

    }

    function hideExplorer() {

        opacity = 0
        variables.visibleItem = ""

    }

}
