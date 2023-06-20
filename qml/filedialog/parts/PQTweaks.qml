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

import "../../elements"

Rectangle {

    id: tweaks_top

    color: "transparent"

    height: 50

    property string showWhichFileTypeIndex: "all"

    property bool condensed: false

    Rectangle {
        x: 0
        width: parent.width
        y: 0
        height: 1
        color: "#aaaaaa"
    }

    PQTweaksPopup {
        id: condensed_popup
    }

    PQText {

        id: zoomtext

        visible: !condensed

        text: em.pty+qsTranslate("filedialog", "Zoom:")
        anchors.left: parent.left
        anchors.leftMargin: 5
        y: (parent.height-height)/2

        PQMouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            tooltip: em.pty+qsTranslate("filedialog", "Adjust size of files and folders")
            tooltipFollowsMouse: false
        }

    }

    PQSlider {

        id: zoom

        visible: !condensed

        from: 10
        to: 50
        value: PQSettings.openfileZoomLevel

        divideToolTipValue: 10
        tooltip: em.pty+qsTranslate("filedialog", "Adjust size of files and folders")
        toolTipPrefix: em.pty+qsTranslate("filedialog", "Zoom factor:") + " "

        anchors.left: zoomtext.right
        anchors.leftMargin: 5
        y: (parent.height-height)/2

        onValueChanged: {
            PQSettings.openfileZoomLevel = value
            // we set the focus to some random element (one that doesn't aid in catching key events (otherwise we catch them twice))
            // this avoids the case where left/right arrow would cause inadvertently a zoom in/out event
            variables.forceActiveFocus()
        }

    }

    PQButton {

        id: cancelbutton

        x: condensed ? (condensed_popup.x+condensed_popup.width + (remember.x-condensed_popup.width-width)/2) : (zoom.x+zoom.width + (sortby.x-zoom.x-zoom.width - width)/2)
        y: 1

        height: parent.height-1

        text: genericStringCancel
        leftRightTextSpacing: 40

        font.weight: baselook.boldweight
        font.pointSize: baselook.fontsize_l

        onClicked: filedialog_top.hideFileDialog()

        Rectangle {
            x: 0
            width: 2
            height: parent.height
            color: "#888888"
        }

        Rectangle {
            x: parent.width-2
            width: 2
            height: parent.height
            color: "#888888"
        }

    }

    PQComboBox {

        onXChanged:
            condensed = (x < zoomtext.width+zoom.width+cancelbutton.width+30)

        id: sortby

        visible: !condensed

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
            if(visible)
                condensed_popup.setCurrentIndexSortBy(currentIndex)
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

        visible: !condensed

        property var allfiletypes: ["all", "qt", "magick", "libraw", "devil", "freeimage", "poppler", "video", "allfiles"]

        model: [em.pty+qsTranslate("filedialog", "All supported images"),
                "Qt",
                (handlingGeneral.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick"),
                "LibRaw", "DevIL",
                "FreeImage", "PDF (Poppler)",
                em.pty+qsTranslate("filedialog", "Video files"),
                em.pty+qsTranslate("filedialog", "All files")]


        onCurrentIndexChanged: {
            showWhichFileTypeIndex = allfiletypes[allfiles.currentIndex]
            if(visible)
                condensed_popup.setCurrentIndexShowFiles(currentIndex)
        }

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

        anchors.right: divider.left
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        leftRightTextSpacing: 0

        tooltip: em.pty+qsTranslate("filedialog", "Switch between list and icon view")
        tooltipFollowsMouse: false

        imageButtonSource: PQSettings.openfileDefaultView=="icons" ? "/filedialog/iconview.svg" : "/filedialog/listview.svg"

        onClicked:
            PQSettings.openfileDefaultView = (PQSettings.openfileDefaultView=="icons" ? "list" : "icons")

    }

    Rectangle {
        id: divider
        anchors.right: settingsbutton.left
        anchors.rightMargin: 10
        y: (parent.height-height)/2
        height: parent.height-10
        width: 2
        color: "#cccccc"
    }

    PQButton {

        id: settingsbutton

        anchors.right: parent.right
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        leftRightTextSpacing: 0

        tooltip: em.pty+qsTranslate("filedialog", "Fine-tune file dialog")
        tooltipFollowsMouse: false

        imageButtonSource: "/mainmenu/setup.svg"

        onClicked: {
            filedialogsettings.show()
        }

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
