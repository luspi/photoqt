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

import "../../elements"

Rectangle {

    color: "transparent"

    height: 50

    property string showWhichFileTypeIndex: "all"

    Rectangle {
        x: 0
        width: parent.width
        y: 0
        height: 1
        color: "#aaaaaa"
    }

    Text {

        id: zoomtext

        color: "white"
        text: em.pty+qsTranslate("filedialog", "Zoom:")
        anchors.left: parent.left
        anchors.leftMargin: 5
        y: (parent.height-height)/2

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

        divideToolTipValue: 10
        tooltip: em.pty+qsTranslate("filedialog", "Adjust font size of files and folders")
        toolTipPrefix: em.pty+qsTranslate("filedialog", "Zoom factor:") + " "

        anchors.left: zoomtext.right
        anchors.leftMargin: 5
        y: (parent.height-height)/2

        onValueChanged:
            PQSettings.openfileZoomLevel = value

    }

    PQComboBox {

        id: sortby

        prefix: em.pty+qsTranslate("filedialog", "Sort by:") + " "

        model: [em.pty+qsTranslate("filedialog", "Name"),
                em.pty+qsTranslate("filedialog", "Natural Name"),
                em.pty+qsTranslate("filedialog", "Time modified"),
                em.pty+qsTranslate("filedialog", "File size"),
                em.pty+qsTranslate("filedialog", "File type"),
                "[" + em.pty+qsTranslate("filedialog", "reverse order") + "]"]
        lineBelowItem: 4

        anchors.right: allfiles.left
        anchors.rightMargin: 5
        y: (parent.height-height)/2

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
        }

        Timer {
            id: startupdelay
            interval: 100
            repeat: false
            running: true
            onTriggered:
                sortby.startUpDelay = true
        }

    }

    PQComboBox {

        id: allfiles

        property var allfiletypes: ["all", "qt", "magick", "libraw", "devil", "freeimage", "poppler", "video", "allfiles"]

        model: [em.pty+qsTranslate("filedialog", "All supported images"),
                "Qt",
                (handlingGeneral.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick"),
                "LibRaw", "DevIL",
                "FreeImage", "PDF (Poppler)",
                em.pty+qsTranslate("filedialog", "Video files"),
                em.pty+qsTranslate("filedialog", "All files")]


        onCurrentIndexChanged:
            showWhichFileTypeIndex = allfiletypes[allfiles.currentIndex]

        anchors.right: remember.left
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        tooltip: em.pty+qsTranslate("filedialog", "Choose which selection of files to show")
        tooltipFollowsMouse: false

        firstItemEmphasized: true

        Component.onCompleted:
            readFileTypeSettings()

    }

    PQButton {

        id: remember

        anchors.right: whichview.left
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        leftRightTextSpacing: 0

        tooltip: em.pty+qsTranslate("filedialog", "Remember loaded folder between sessions.")
        tooltipFollowsMouse: false

        imageButtonSource: PQSettings.openfileKeepLastLocation ? "/filedialog/remember.svg" : "/filedialog/dontremember.svg"

        opacity: PQSettings.openfileKeepLastLocation ? 0.8 : 0.2

        onClicked:
            PQSettings.openfileKeepLastLocation = !PQSettings.openfileKeepLastLocation

    }

    PQButton {

        id: whichview

        anchors.right: parent.right
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        leftRightTextSpacing: 0

        tooltip: em.pty+qsTranslate("filedialog", "Switch between list and icon view")
        tooltipFollowsMouse: false

        imageButtonSource: PQSettings.openfileDefaultView=="icons" ? "/filedialog/iconview.svg" : "/filedialog/listview.svg"

        onClicked:
            PQSettings.openfileDefaultView = (PQSettings.openfileDefaultView=="icons" ? "list" : "icons")

    }

    function readFileTypeSettings() {
        allfiles.hideItems = []
        if(!handlingGeneral.isImageMagickSupportEnabled())
            allfiles.hideItems.push(2)
        if(!handlingGeneral.isGraphicsMagickSupportEnabled())
            allfiles.hideItems.push(3)
        if(!handlingGeneral.isLibRawSupportEnabled())
            allfiles.hideItems.push(4)
        if(!handlingGeneral.isDevILSupportEnabled())
            allfiles.hideItems.push(5)
        if(!handlingGeneral.isFreeImageSupportEnabled())
            allfiles.hideItems.push(6)
        if(!handlingGeneral.isPopplerSupportEnabled())
            allfiles.hideItems.push(7)
        if(!handlingGeneral.isVideoSupportEnabled())
            allfiles.hideItems.push(7)

        allfiles.lineBelowItem = allfiles.model.length-2
    }

    function zoomOut() {
        zoom.value -= 1
    }

    function zoomIn() {
        zoom.value += 1
    }

}
