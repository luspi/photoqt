/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

Item {

    anchors.left: parent.left
    y: (parent.height-height)/2
    height: parent.height-2
    width: height

    visible: tweaks_top.condensed

    PQButton {

        id: condensed_popup

        forceWidth: parent.width
        height: parent.height

        imageButtonSource: menu.shown ? "/filedialog/downwards.svg" : "/filedialog/upwards.svg"

        onClicked: {
            menu.shown = !menu.shown
        }
    }

    Rectangle {

        id: menu

        property bool shown: false

        x: 0
        y: -height
        width: col.width+20
        height: shown ? col.height : 0
        color: "#2f2f2f"

        border {
            width: 1
            color: "#a8a8a8"
        }

        Behavior on height { NumberAnimation { duration: 100 } }

        clip: true

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Column {

            id: col
            x: 10

            spacing: 10

            Item {
                width: 1
                height: 1
            }

            PQComboBox {

                id: allfiles_condensed

                width: zoomrow.width

                property var allfiletypes: ["all", "qt", "magick", "libraw", "devil", "freeimage", "poppler", "video", "allfiles"]

                model: [em.pty+qsTranslate("filedialog", "All supported images"),
                        "Qt",
                        (handlingGeneral.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick"),
                        "LibRaw", "DevIL",
                        "FreeImage", "PDF (Poppler)",
                        em.pty+qsTranslate("filedialog", "Video files"),
                        em.pty+qsTranslate("filedialog", "All files")]


                onCurrentIndexChanged: {
                    showWhichFileTypeIndex = allfiletypes[allfiles_condensed.currentIndex]
                    // this is the id of the non-condensed element
                    if(!allfiles.visible)
                        allfiles.currentIndex = currentIndex
                }

                tooltip: em.pty+qsTranslate("filedialog", "Choose which selection of files to show")
                tooltipFollowsMouse: false

                firstItemEmphasized: true

            }

            PQComboBox {

                id: sortby_condensed

                width: zoomrow.width

                prefix: em.pty+qsTranslate("filedialog", "Sort by:") + " "

                model: [em.pty+qsTranslate("filedialog", "Name"),
                        em.pty+qsTranslate("filedialog", "Natural Name"),
                        em.pty+qsTranslate("filedialog", "Time modified"),
                        em.pty+qsTranslate("filedialog", "File size"),
                        em.pty+qsTranslate("filedialog", "File type"),
                        "[" + em.pty+qsTranslate("filedialog", "reverse order") + "]"]
                lineBelowItem: 4

                tooltip: em.pty+qsTranslate("filedialog", "Choose by what to sort the files")
                tooltipFollowsMouse: false

                property int prevCurIndex: -1
                property bool startUpDelay: false

                currentIndex: PQSettings.imageviewSortImagesBy=="name" ? 0 : (PQSettings.imageviewSortImagesBy=="time" ? 2 : (PQSettings.imageviewSortImagesBy=="size" ? 3 : (PQSettings.imageviewSortImagesBy=="type" ? 4 : 1)))

                onCurrentIndexChanged: {
                    if(currentIndex == 5) {
                        PQSettings.imageviewSortImagesAscending = !PQSettings.imageviewSortImagesAscending
                        currentIndex = prevCurIndex
                    } else {
                        if(startUpDelay)
                            PQSettings.imageviewSortImagesBy = (currentIndex===0 ? "name" : (currentIndex===1 ? "naturalname" : (currentIndex===2 ? "time" : (currentIndex===3 ? "size" : "type"))))
                        prevCurIndex = currentIndex
                    }
                    // this is the id of the non-condensed element
                    if(!sortby.visible)
                        sortby.currentIndex = currentIndex
                }

            }

            Row {

                id: zoomrow

                spacing: 5

                PQText {

                    id: zoomtext

                    text: em.pty+qsTranslate("filedialog", "Zoom:")
                    y: (zoom.height-height)/2

                    PQMouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        tooltip: em.pty+qsTranslate("filedialog", "Adjust font size of files and folders")
                        tooltipFollowsMouse: false
                    }

                }

                PQSlider {

                    id: zoom

                    from: 10
                    to: 50
                    value: PQSettings.openfileZoomLevel

                    width: 150

                    divideToolTipValue: 10
                    tooltip: em.pty+qsTranslate("filedialog", "Adjust font size of files and folders")
                    toolTipPrefix: em.pty+qsTranslate("filedialog", "Zoom factor:") + " "

                    onValueChanged: {
                        PQSettings.openfileZoomLevel = value
                        // we set the focus to some random element (one that doesn't aid in catching key events (otherwise we catch them twice))
                        // this avoids the case where left/right arrow would cause inadvertently a zoom in/out event
                        variables.forceActiveFocus()
                    }

                }

            }

            Item {
                width: 1
                height: 1
            }

        }

    }

    function setCurrentIndexShowFiles(ind) {
        allfiles_condensed.currentIndex = ind
    }
    function setCurrentIndexSortBy(ind) {
        sortby_condensed.currentIndex = ind
    }

}
