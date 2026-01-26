/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import QtQuick.Controls
import PhotoQt

PQTemplate {

    id: mapexplorer_top

    elementId: "MapExplorer"

    property list<var> folderLoaded: []

    property real mapZoomLevel: 10

    property int closebuttonWidth: closebutton.width

    content: [

        SplitView {

            width: mapexplorer_top.width
            height: mapexplorer_top.height

            // Show larger handle with triple dash
            handle: Rectangle {
                id: hndl
                implicitWidth: 8
                implicitHeight: 8
                color: SplitHandle.hovered ? palette.alternateBase : palette.button
                Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }

                Image {
                    y: (hndl.height-height)/2
                    width: 8
                    height: 8
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/handle.svg"
                }

            }

            Item {

                id: mapcont

                width: mapexplorer_top.width/2
                height: mapexplorer_top.height
                SplitView.minimumWidth: 400
                SplitView.minimumHeight: 300
                SplitView.preferredWidth: mapexplorer_top.width/2

                PQMapExplorerMap {
                    id: map
                    width: parent.width
                    height: parent.height-maptweaks.height

                    onVisibleLatitudeLeftChanged:
                        visibleimages.mapVisibleLatitudeLeft = map.visibleLatitudeLeft
                    onVisibleLatitudeRightChanged:
                        visibleimages.mapVisibleLatitudeRight = map.visibleLatitudeRight
                    onVisibleLongitudeLeftChanged:
                        visibleimages.mapVisibleLongitudeLeft = map.visibleLongitudeLeft
                    onVisibleLongitudeRightChanged:
                        visibleimages.mapVisibleLongitudeRight = map.visibleLongitudeRight

                    Connections {
                        target: visibleimages
                        function onMapHideHighlightMarker() {
                            map.hideHightlightMarker()
                        }
                    }

                }

                PQMapExplorerMapTweaks {
                    id: maptweaks
                    y: parent.height-height
                    width: map.width
                    height: 50
                }

                Item {
                    width: closebutton.width/2
                    height: 1
                }

            }

            Item {

                id: imagestweaks

                width: mapexplorer_top.width/2
                height: mapexplorer_top.height

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

    ]

    PQButtonElement {
        id: closebutton
        x: mapcont.width-width/2
        y: parent.height-50 + 1
        height: 49
        text: genericStringClose
        onClicked:
            mapexplorer_top.hide()
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(mapexplorer_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape) {

                        mapexplorer_top.hide()

                    }

                }

            }

        }

    }

    Connections {

        target: visibleimages

        function onClickOnImage(lat : real, lon : real) {
            mapexplorer_top.clickOnImage(lat, lon)
        }

        function onHideExplorer() {
            mapexplorer_top.hide()
        }

    }

    function closeAnyMenu() {
        if(map.gpsContextMenuIsOpen) {
            map.closeMenus()
            return true
        } else if(visibleimages.imageContextMenu.visible) {
            visibleimages.imageContextMenu.close()
            return true
        }
        return false
    }

    function resetMap() {
        map.resetMap();
    }

    function resetWidth() {
        smoothWidth.from = mapcont.width
        smoothWidth.to = mapexplorer_top.width/2
        smoothWidth.start()
    }

    function clickOnImage(lat : real, lon : real) {

        map.hideHightlightMarker()
        map.setMapCenterSmooth(lat, lon)
        map.setMapZoomLevelSmooth(maptweaks.maxZoomLevel/2)

    }

    function loadImages() {

        var items = PQCLocation.imageList
        var labels = PQCLocation.labelList

        map.clearModel()
        visibleimages.allImagesWithLocation = []

        for(var key in items) {

            var item_labels = {}

            for(var det = 0; det < 13; ++det) {
                var labelkey = det + "::" + key;
                if(labelkey in labels)
                    item_labels[det] = labels[labelkey]
            }

            var latitude = key.split("::")[0].toString()
            var longitude = key.split("::")[1].toString()
            var filename = items[key][0].toString()
            var full_lat = items[key][1].toString()
            var full_lon = items[key][2].toString()
            var detaillevels = items[key]
            detaillevels.shift()
            detaillevels.shift()
            detaillevels.shift()
            detaillevels = detaillevels.join("_")

            map.addItem(latitude, longitude, filename, detaillevels, item_labels, full_lat, full_lon)

        }

        visibleimages.allImagesWithLocation = PQCLocation.allImages

        map.setMapCenter((PQCLocation.minimumLocation.x+PQCLocation.maximumLocation.x)/2,
                         (PQCLocation.minimumLocation.y+PQCLocation.maximumLocation.y)/2)

    }

    function showing() {
        loadExplorerData()
        PQCConstants.modalMapExplorerOpen = true
        return true
    }

    function hiding() {
        PQCConstants.modalMapExplorerOpen = false
        return true
    }

    function loadExplorerData() {

        map.resetCurZ()

        var path = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
        var mod = PQCScriptsFilesPaths.getFileModified(path).getTime()

        if(folderLoaded.length == 0 || folderLoaded[0] !== path || folderLoaded[1] !== mod) {

            PQCLocation.scanForLocations(PQCFileFolderModel.entriesMainView)
            PQCLocation.processSummary(PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile))
            loadImages()

        }

        map.resetMap()
        map.computeDetailLevel()

        folderLoaded[0] = path
        folderLoaded[1] = mod
        folderLoadedChanged()

        map.updateVisibleRegionNow()

    }

}
