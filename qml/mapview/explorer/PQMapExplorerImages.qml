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
import QtQuick.Controls 2.2
import "../../elements"

Rectangle {

    id: visibleimages

    color: "#333333"

    clip: true

    Flickable {

        anchors.fill: parent
        contentHeight: files_grid.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Flow {

            id: files_grid

            width: parent.width

            property int currentIndex: -1

            Repeater {

                model: imagesWithLocation.length

                delegate: Item {

                    id: maindeleg

                    width: opacity!=0 ? PQSettings.mapviewExplorerThumbnailsZoomLevel*6 : 0
                    height: PQSettings.mapviewExplorerThumbnailsZoomLevel*6

                    Behavior on width { NumberAnimation { duration: 200 } }

                    readonly property string fpath: imagesWithLocation[index][0]
                    readonly property real latitude: imagesWithLocation[index][1]
                    readonly property real longitude: imagesWithLocation[index][2]
                    readonly property string fname: handlingFileDir.getFileNameFromFullPath(fpath)

                    opacity: (latitude>(map.visibleLatitudeRight-0.1) &&
                             latitude<(map.visibleLatitudeLeft+0.1) &&
                             longitude>(map.visibleLongitudeLeft-0.1) &&
                             longitude<(map.visibleLongitudeRight+0.1)) ? 1 : 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }

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
                            width: parent.width-2*PQSettings.openfileElementPadding
                            height: parent.height-2*PQSettings.openfileElementPadding

                            asynchronous: true

                            fillMode: Image.PreserveAspectFit

                            smooth: true
                            mipmap: false

                            opacity: 1
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            // if we do not cache this image, then we keep the generic icon here
                            source: filethumb.status==Image.Ready ? "" : "image://icon/::squared::"+handlingFileDir.getSuffix(maindeleg.fname)

                            Image {

                                id: filethumb
                                anchors.fill: parent

                                cache: false

                                sourceSize: Qt.size(256, 256)

                                fillMode: PQSettings.mapviewExplorerThumbnailsScaleCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit

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
                            height: files_grid.currentIndex == index ? parent.height/2 : parent.height/3.5
                            y: parent.height-height

                            Behavior on height { NumberAnimation { duration: 100 } }

                            color: "#aa2f2f2f"

                            PQTextS {

                                width: parent.width-20
                                height: parent.height
                                x: 10
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: decodeURIComponent(maindeleg.fname)
                                elide: Text.ElideMiddle
                                font.weight: baselook.boldweight

                            }

                        }

                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        tooltipWidth: 282
                        tooltipSomeTransparency: false
                        property bool tooltipSetup: false

                        onEntered: {

                            files_grid.currentIndex = index

                            map.showHighlightMarkerAt(maindeleg.latitude, maindeleg.longitude)

                            if(!tooltipSetup) {

                                var fmodi = handlingFileDir.getFileModified(maindeleg.fpath)
                                var ftype = handlingFileDir.getFileType(maindeleg.fpath)
                                var fsize = handlingGeneral.convertBytesToHumanReadable(handlingFileDir.getFileSize(maindeleg.fpath))

                                var str = ""

                                // if we do not cache this directory, we do not show a thumbnail image
                                if(fileicon.source == "")
                                    str += "<img src=\"image://thumb/::fixedsize::" + handlingGeneral.toPercentEncoding(filefoldermodel.entriesFileDialog[index]) + "\"><br><br>"

                                // add details
                                str += "<b>" + handlingFileDialog.createTooltipFilename(maindeleg.fname) + "</b>" + "<br><br>" +
                                          em.pty+qsTranslate("filedialog", "File size:")+" <b>" + fsize + "</b><br>" +
                                          em.pty+qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                                          em.pty+qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                                          em.pty+qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b><br>" +
                                          em.pty+qsTranslate("filedialog", "Location:")+" <b>" + (maindeleg.latitude>0 ? "+" : "") + Math.round(maindeleg.latitude*100)/100 + " " + (maindeleg.longitude>0 ? "+" : "") + Math.round(maindeleg.longitude*100)/100 + "</b>"

                                tooltip = str

                                // if the thumbnail is not yet loaded and a temp icon is shown, we want to check again for the thumbnail the next time the tooltip is shown
                                if(fileicon.source == "")
                                    tooltipSetup = true

                            }

                        }
                        onExited: {
                            map.hideHightlightMarker()
                            files_grid.currentIndex = -1
                        }

                        onClicked: {
                            clickOnImage(index)
                        }
                    }

                }

            }

        }

    }

}
