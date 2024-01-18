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

    color: PQCLook.baseColor

    clip: true

    property int countVisible: 0

    Flickable {

        anchors.fill: parent
        anchors.topMargin: 1
        contentHeight: files_grid.height

        ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

        Flow {

            id: files_grid

            width: parent.width

            property int currentIndex: -1
            Timer {
                id: resetCurrentIndex
                interval: 100
                property int oldIndex
                onTriggered: {
                    if(oldIndex === files_grid.currentIndex)
                        files_grid.currentIndex = -1
                }
            }

            Repeater {

                model: imagesWithLocation.length

                delegate: Item {

                    id: maindeleg

                    width: opacity!=0 ? PQCSettings.mapviewExplorerThumbnailsZoomLevel*6 : 0
                    height: PQCSettings.mapviewExplorerThumbnailsZoomLevel*6

                    Behavior on width { NumberAnimation { duration: 200 } }

                    readonly property string fpath: imagesWithLocation[index][0]
                    readonly property real latitude: imagesWithLocation[index][1]
                    readonly property real longitude: imagesWithLocation[index][2]
                    readonly property string fname: PQCScriptsFilesPaths.getFilename(fpath)

                    opacity: (latitude>=(map.visibleLatitudeRight-0.001) &&
                             latitude<=(map.visibleLatitudeLeft+0.001) &&
                             longitude>=(map.visibleLongitudeLeft-0.001) &&
                             longitude<=(map.visibleLongitudeRight+0.001)) ? 1 : 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    visible: opacity>0

                    onVisibleChanged:
                        countVisible += (visible ? 1 : -1)

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
                            width: parent.width-2*PQCSettings.filedialogElementPadding
                            height: parent.height-2*PQCSettings.filedialogElementPadding

                            asynchronous: true

                            fillMode: Image.PreserveAspectFit

                            smooth: true
                            mipmap: false

                            opacity: 1
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            // if we do not cache this image, then we keep the generic icon here
                            source: filethumb.status==Image.Ready ? "" : "image://icon/"+PQCScriptsFilesPaths.getSuffix(maindeleg.fname)

                            Image {

                                id: filethumb
                                anchors.fill: parent

                                cache: false

                                sourceSize: Qt.size(256, 256)

                                fillMode: PQCSettings.mapviewExplorerThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit

                                // mipmap does not look good, use only smooth
                                smooth: true
                                asynchronous: true

                                // if we do not cache this image, then we keep this empty and thus preserve the generic icon in the outside image
                                source: "image://thumb/" + maindeleg.fpath

                            }

                        }

                        Rectangle {

                            id: icn

                            width: parent.width
                            height: files_grid.currentIndex === index ? parent.height/2 : parent.height/3.5
                            y: parent.height-height

                            Behavior on height { NumberAnimation { duration: 100 } }

                            color: fpath===PQCFileFolderModel.currentFile ? PQCLook.transColor : PQCLook.transColorAccent

                            PQTextS {

                                width: parent.width-20
                                height: parent.height
                                x: 10
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: decodeURIComponent(maindeleg.fname)
                                elide: Text.ElideMiddle
                                font.weight: PQCLook.fontWeightBold

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
                            files_grid.currentIndex = index

                            map.showHighlightMarkerAt(maindeleg.latitude, maindeleg.longitude)

                            if(!tooltipSetup) {

                                var fmodi = PQCScriptsFilesPaths.getFileModified(maindeleg.fpath)
                                var ftype = PQCScriptsFilesPaths.getFileType(maindeleg.fpath)
                                var fsize = PQCScriptsFilesPaths.getFileSizeHumanReadable(maindeleg.fpath)

                                var str = ""

                                // if we do not cache this directory, we do not show a thumbnail image
                                if(fileicon.source == "")
                                    str += "<img src=\"image://thumb/" + PQCScriptsFilesPaths.toPercentEncoding(maindeleg.fpath) + "\"><br><br>"

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
                                if(fileicon.source == "")
                                    tooltipSetup = true

                            }

                        }
                        onExited: {
                            map.hideHightlightMarker()
                            resetCurrentIndex.oldIndex = index
                            resetCurrentIndex.restart()
                        }

                        onClicked: {
                            clickOnImage(maindeleg.latitude, maindeleg.longitude)
                        }
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
        opacity: (countVisible==-imagesWithLocation.length&&!nolocation.visible) ? 0.75 : 0
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
        opacity: imagesWithLocation.length==0 ? 0.75 : 0
        visible: opacity>0
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.italic: true
        text: qsTranslate("mapexplorer", "no images with location data in current folder")
    }

}
