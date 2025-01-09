pragma ComponentBehavior: Bound
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
import QtQuick.Controls

import PQCScriptsFilesPaths
import PQCFileFolderModel

import "../../elements"

Rectangle {

    id: visibleimages

    color: PQCLook.baseColor // qmllint disable unqualified

    clip: true

    property var visibleImagesWithLocation: []

    GridView {

        id: gridview

        anchors.fill: parent
        anchors.topMargin: 1

        model: visibleimages.visibleImagesWithLocation.length // qmllint disable unqualified

        ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

        cellWidth: PQCSettings.mapviewExplorerThumbnailsZoomLevel*6
        cellHeight: PQCSettings.mapviewExplorerThumbnailsZoomLevel*6

        property int currentIndex: -1
        Timer {
            id: resetCurrentIndex
            interval: 100
            property int oldIndex
            onTriggered: {
                if(oldIndex === gridview.currentIndex) {
                    gridview.currentIndex = -1
                    map.hideHightlightMarker() // qmllint disable unqualified
                }
            }
        }

        delegate: Item {

            id: maindeleg

            required property int modelData

            width: PQCSettings.mapviewExplorerThumbnailsZoomLevel*6 // qmllint disable unqualified
            height: PQCSettings.mapviewExplorerThumbnailsZoomLevel*6 // qmllint disable unqualified

            readonly property string fpath: visibleimages.visibleImagesWithLocation[modelData][0] // qmllint disable unqualified
            readonly property real latitude: visibleimages.visibleImagesWithLocation[modelData][1] // qmllint disable unqualified
            readonly property real longitude: visibleimages.visibleImagesWithLocation[modelData][2] // qmllint disable unqualified
            readonly property string fname: PQCScriptsFilesPaths.getFilename(fpath) // qmllint disable unqualified

            Rectangle {

                id: deleg_container

                width: maindeleg.width
                height: maindeleg.height

                opacity: 1

                color: "#44aaaaaa"

                border.width: 1
                border.color: "#282828"

                Image {

                    id: fileicon

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width: parent.width-2*PQCSettings.filedialogElementPadding // qmllint disable unqualified
                    height: parent.height-2*PQCSettings.filedialogElementPadding // qmllint disable unqualified

                    asynchronous: true

                    fillMode: Image.PreserveAspectFit

                    smooth: true
                    mipmap: false

                    opacity: 1
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    // if we do not cache this image, then we keep the generic icon here
                    source: filethumb.status==Image.Ready ? "" : "image://icon/"+PQCScriptsFilesPaths.getSuffix(maindeleg.fname) // qmllint disable unqualified

                    Image {

                        id: filethumb
                        anchors.fill: parent

                        cache: false

                        sourceSize: Qt.size(256, 256)

                        fillMode: PQCSettings.mapviewExplorerThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit // qmllint disable unqualified

                        // mipmap does not look good, use only smooth
                        smooth: true
                        asynchronous: false

                        // if we do not cache this image, then we keep this empty and thus preserve the generic icon in the outside image
                        source: "image://thumb/" + maindeleg.fpath

                    }

                }

                Rectangle {

                    id: icn

                    width: parent.width
                    height: gridview.currentIndex === maindeleg.modelData ? parent.height/2 : parent.height/3.5
                    y: deleg_container.height-height

                    Behavior on height { NumberAnimation { duration: 100 } }

                    color: maindeleg.fpath===PQCFileFolderModel.currentFile ? PQCLook.transColor : PQCLook.transColor // qmllint disable unqualified

                    PQTextS {

                        width: parent.width-20
                        x: 10
                        y: (parent.height-height)/2
                        horizontalAlignment: Text.AlignHCenter
                        text: decodeURIComponent(maindeleg.fname)
                        elide: Text.ElideMiddle
                        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified

                    }

                }

            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                property bool tooltipSetup: false

                onEntered: {

                    resetCurrentIndex.stop()
                    gridview.currentIndex = maindeleg.modelData

                    map.showHighlightMarkerAt(maindeleg.latitude, maindeleg.longitude) // qmllint disable unqualified

                    if(!tooltipSetup) {

                        var fmodi = PQCScriptsFilesPaths.getFileModified(maindeleg.fpath)
                        var ftype = PQCScriptsFilesPaths.getFileType(maindeleg.fpath)
                        var fsize = PQCScriptsFilesPaths.getFileSizeHumanReadable(maindeleg.fpath)

                        var str = ""

                        // if we do not cache this directory, we do not show a thumbnail image
                        if(fileicon.source === "")
                            str += "<img src=\"" + encodeURI("image://thumb/" + maindeleg.fpath) + "\"><br><br>"

                        // add details
                        // we keep the string context here as 'filedialog' since the strings are the exact same there and only need to be translated once
                        str += "<b>" + PQCScriptsFilesPaths.createTooltipFilename(maindeleg.fname) + "</b>" + "<br><br>" +
                                  qsTranslate("filedialog", "File size:")+" <b>" + fsize + "</b><br>" +
                                  qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                                  qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                  qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b><br>" +
                                  qsTranslate("filedialog", "Location:")+" <b>" + (maindeleg.latitude>0 ? "+" : "") + Math.round(maindeleg.latitude*100)/100 + " " + (maindeleg.longitude>0 ? "+" : "") + Math.round(maindeleg.longitude*100)/100 + "</b>"

                        text = str

                        // if the thumbnail is not yet loaded and a temp icon is shown, we want to check again for the thumbnail the next time the tooltip is shown
                        if(fileicon.source === "")
                            tooltipSetup = true

                    }

                }
                onExited: {
                    resetCurrentIndex.oldIndex = maindeleg.modelData
                    resetCurrentIndex.restart()
                }

                onClicked: {
                    mapexplorer_top.clickOnImage(maindeleg.latitude, maindeleg.longitude) // qmllint disable unqualified
                }

                doubleClickThreshold: 200
                onMouseDoubleClicked: {
                    PQCFileFolderModel.fileInFolderMainView = maindeleg.fpath // qmllint disable unqualified
                    if(!PQCSettings.interfacePopoutMapExplorerNonModal) {
                        mapexplorer_top.hideExplorer()
                    }
                }

            }

        }

    }

    PQTextL {
        id: nothingvisible
        y: (parent.height-height)/2
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        opacity: (visibleimages.visibleImagesWithLocation.length===0&&!nolocation.visible) ? 0.75 : 0 // qmllint disable unqualified
        visible: opacity>0
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.italic: true
        //: the currently visible area refers to the latitude/longitude selection in the map explorer
        text: qsTranslate("mapexplorer", "no images in currently visible area")
    }

    PQTextL {
        id: nolocation
        y: (parent.height-height)/2
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        opacity: mapexplorer_top.imagesWithLocation.length===0 ? 0.75 : 0 // qmllint disable unqualified
        visible: opacity>0
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.italic: true
        text: qsTranslate("mapexplorer", "no images with location data in current folder")
    }

    Timer {
        id: timerLoadImages
        interval: 500
        onTriggered: {
            loadImages()
        }
    }

    Component.onCompleted: {
        loadImages()
    }

    function loadImages() {

        var m = []

        for(var i in mapexplorer_top.imagesWithLocation) {

            var im = mapexplorer_top.imagesWithLocation[i]

            if(im[1] >= map.visibleLatitudeRight-0.001 &&
                    im[1] <= map.visibleLatitudeLeft+0.001 &&
                    im[2] >= map.visibleLongitudeLeft-0.001 &&
                    im[2] <= map.visibleLongitudeRight+0.001)
                m.push(im)

        }

        visibleimages.visibleImagesWithLocation = m

    }

    Connections {

        target: map

        function onVisibleLatitudeLeftChanged() {
            timerLoadImages.restart()
        }

        function onVisibleLatitudeRightChanged() {
            timerLoadImages.restart()
        }

        function onVisibleLongitudeLeftChanged() {
            timerLoadImages.restart()
        }

        function onVisibleLongitudeRightChanged() {
            timerLoadImages.restart()
        }
    }

}
