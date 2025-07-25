/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsConfig
import PhotoQt

Item {

    id: tweaks_top

    width: parent.width
    height: 50

    property int zoomMoveUpHeight: leftcolrect.state==="moveup" ? leftcolrect.height : 0

    property list<PQButtonElement> allbuttons: [cancelbutton]
    property list<PQMenu> allmenus: [filetypes]

    Rectangle {

        id: leftcolrect

        y: 0
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutElastic } }

        width: leftcol.width+15
        height: parent.height

        color: PQCLook.baseColor // qmllint disable unqualified
        border.color: PQCLook.baseColorActive // qmllint disable unqualified
        border.width: state==="moveup" ? 1 : 0

        Row {

            id: leftcol
            x: 5
            y: (parent.height-height)/2

            spacing: 5

            PQText {
                y: (parent.height-height)/2
                text: qsTranslate("filedialog", "Zoom:")
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                PQMouseArea {
                    anchors.fill: parent
                    text: qsTranslate("filedialog", "Adjust size of files and folders")
                }
            }

            PQSlider {

                id: zoomslider

                y: (parent.height-height)/2

                from: 1
                to: 100

                stepSize: 1
                wheelStepSize: 1

                value: PQCSettings.filedialogZoom // qmllint disable unqualified
                onValueChanged: {
                    var newval = Math.round(value)
                    if(newval !== PQCSettings.filedialogZoom) // qmllint disable unqualified
                        PQCSettings.filedialogZoom = newval
                }

                Connections {

                    target: PQCSettings // qmllint disable unqualified

                    function onFiledialogZoomChanged() {
                        if(zoomslider.value !== PQCSettings.filedialogZoom) // qmllint disable unqualified
                            zoomslider.value = PQCSettings.filedialogZoom
                    }
                }

                Component.onCompleted: {
                    value = 1*value
                }

            }

            PQText {
                y: (parent.height-height)/2
                text: zoomslider.value + "%"
            }

        }

        Connections {
            target: tweaks_top
            function onWidthChanged() {
                if(tweaks_top.width < (rightcol.width+leftcol.width+cancelbutton.width+50))
                    leftcolrect.state   = "moveup"
                else
                    leftcolrect.state = "movedown"
            }
        }

        states: [
            State {
                name: "moveup"
                PropertyChanges {
                    leftcolrect.y: -leftcolrect.height+1
                }
            },
            State {
                name: "movedown"
                PropertyChanges {
                    leftcolrect.y: 0
                }
            }
        ]

    }

    Item {
        anchors.left: parent.left
        anchors.right: rightcol.parent.left
        anchors.leftMargin: leftcolrect.state==="moveup" ? 0 : (leftcol.width+leftcol.x)
        Behavior on anchors.leftMargin { NumberAnimation { duration: 200; easing.type: Easing.OutBounce } }
        height: parent.height

        PQButtonElement {
            id: cancelbutton
            height: parent.height
            anchors.centerIn: parent
            text: genericStringCancel
            tooltip: qsTranslate("filedialog", "Cancel and close")
            onClicked:
                filedialog_top.hideFileDialog() // qmllint disable unqualified
        }
    }

    Item {

        x: parent.width-width-5
        width: rightcol.width
        height: parent.height

        Row {

            id: rightcol
            y: (parent.height-height)/2
            spacing: 5
            PQText {
                y: (parent.height-height)/2
                text: qsTranslate("filedialog", "Sort by:")
            }

            PQComboBox {

                id: rightcombo

                y: (parent.height-height)/2
                property list<int> linedat: [4]
                lineBelowItem: linedat

                property list<string> modeldata: [qsTranslate("filedialog", "Name"),
                                                  qsTranslate("filedialog", "Natural Name"),
                                                  qsTranslate("filedialog", "Time modified"),
                                                  qsTranslate("filedialog", "File size"),
                                                  qsTranslate("filedialog", "File type"),
                                                  "[" + qsTranslate("filedialog", "reverse order") + "]"]
                model: modeldata

                hideEntries: PQCScriptsConfig.isICUSupportEnabled() ? [] : [1]

                Component.onCompleted: {
                    setCurrentIndex()
                }

                // this hack is needed as at startup the currentIndex gets set to 0 and its changed signal gets triggered
                property bool delayAfterSetup: false
                Timer {
                    running: true
                    interval: 200
                    onTriggered:
                        rightcombo.delayAfterSetup = true
                }

                onCurrentIndexChanged: {
                    if(!delayAfterSetup) return
                    if(currentIndex === 0)
                        PQCSettings.imageviewSortImagesBy = "name" // qmllint disable unqualified
                    else if(currentIndex === 1)
                        PQCSettings.imageviewSortImagesBy = "naturalname"
                    else if(currentIndex === 2)
                        PQCSettings.imageviewSortImagesBy = "time"
                    else if(currentIndex === 3)
                        PQCSettings.imageviewSortImagesBy = "size"
                    else if(currentIndex === 4)
                        PQCSettings.imageviewSortImagesBy = "type"
                    else if(currentIndex === 5) {
                        PQCSettings.imageviewSortImagesAscending = !PQCSettings.imageviewSortImagesAscending
                        setCurrentIndex()
                    }
                }

                function setCurrentIndex() {
                    var sortby = PQCSettings.imageviewSortImagesBy // qmllint disable unqualified
                    if(sortby === "name" || (sortby === "naturalname" && !PQCScriptsConfig.isICUSupportEnabled()))
                        currentIndex = 0
                    else if(sortby === "naturalname")
                        currentIndex = 1
                    else if(sortby === "time")
                        currentIndex = 2
                    else if(sortby === "size")
                        currentIndex = 3
                    else if(sortby === "type")
                        currentIndex = 4
                }

            }

            PQButton {

                id: filetypes_button

                y: (parent.height-height)/2
                font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified
                font.pointSize: PQCLook.fontSize  // qmllint disable unqualified
                horizontalAlignment: Text.AlignLeft
                width: 300
                forceWidth: width

                enableContextMenu: false

                property bool menuOpen: false
                forceHovered: menuOpen

                Timer {
                    id: resetMenuOpen
                    interval: 100
                    onTriggered:
                        filetypes_button.menuOpen = false
                }

                text: qsTranslate("filedialog", "All supported images")

                onClicked: {
                    if(menuOpen)
                        filetypes.dismiss()
                    else
                        showMenu()
                }

                function showMenu() {
                    filetypes.popup(x, y-filetypes.height)
                }


            }

            PQMenu {

                id: filetypes
                width: filetypes_button.width

                onAboutToShow: {
                    resetMenuOpen.stop()
                    filetypes_button.menuOpen = true
                }

                onAboutToHide:
                    resetMenuOpen.restart()

                PQMenuItem {
                    id: chk_all
                    checkable: true
                    checked: true
                    text: qsTranslate("filedialog", "All supported images")
                    onCheckedChanged: {
                        if(checked)
                            filetypes.checkAll()
                    }
                }

                PQMenuSeparator {}

                PQMenuItem {
                    id: chk_qt
                    checkable: true
                    checked: true
                    text: "Qt"
                    onCheckedChanged:
                        filetypes.checkChecked("qt")
                }

                PQMenuItem {
                    id: chk_magick
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isImageMagickSupportEnabled()||PQCScriptsConfig.isGraphicsMagickSupportEnabled() // qmllint disable unqualified
                    text: (PQCScriptsConfig.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick") // qmllint disable unqualified
                    onCheckedChanged:
                        filetypes.checkChecked("magick")
                }

                PQMenuItem {
                    id: chk_libraw
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isLibRawSupportEnabled() // qmllint disable unqualified
                    text: "LibRaw"
                    onCheckedChanged:
                        filetypes.checkChecked("libraw")
                }

                PQMenuItem {
                    id: chk_devil
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isDevILSupportEnabled() // qmllint disable unqualified
                    text: "DevIL"
                    onCheckedChanged:
                        filetypes.checkChecked("devil")
                }

                PQMenuItem {
                    id: chk_freeimage
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isFreeImageSupportEnabled() // qmllint disable unqualified
                    text: "FreeImage"
                    onCheckedChanged:
                        filetypes.checkChecked("freeimage")
                }

                PQMenuItem {
                    id: chk_libvips
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isLibVipsSupportEnabled() // qmllint disable unqualified
                    text: "LibVips"
                    onCheckedChanged:
                        filetypes.checkChecked("libvips")
                }

                PQMenuItem {
                    id: chk_libarchive
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isLibArchiveSupportEnabled() // qmllint disable unqualified
                    text: "LibArchive"
                    onCheckedChanged:
                        filetypes.checkChecked("libarchive")
                }

                PQMenuItem {
                    id: chk_pdf
                    checkable: true
                    checked: true
                    visible: PQCScriptsConfig.isPDFSupportEnabled() // qmllint disable unqualified
                    text: "PDF/PS"
                    onCheckedChanged:
                        filetypes.checkChecked("pdf")
                }

                PQMenuItem {
                    id: chk_video
                    checkable: true
                    checked: true
                    implicitHeight: visible ? 40 : 0
                    visible: PQCScriptsConfig.isMPVSupportEnabled()||PQCScriptsConfig.isVideoQtSupportEnabled() // qmllint disable unqualified
                    text: qsTranslate("filedialog", "Video files")
                    onCheckedChanged:
                        filetypes.checkChecked("video")

                }

                function countChecked() {
                    var ret = 0
                    var maxchk = 0
                    if(chk_qt.visible) {
                        maxchk += 1
                        if(chk_qt.checked)
                            ret += 1
                    }
                    if(chk_magick.visible) {
                        maxchk += 1
                        if(chk_magick.checked)
                            ret += 1
                    }
                    if(chk_libraw.visible) {
                        maxchk += 1
                        if(chk_libraw.checked)
                            ret += 1
                    }
                    if(chk_devil.visible) {
                        maxchk += 1
                        if(chk_devil.checked)
                            ret += 1
                    }
                    if(chk_freeimage.visible) {
                        maxchk += 1
                        if(chk_freeimage.checked)
                            ret += 1
                    }
                    if(chk_libvips.visible) {
                        maxchk += 1
                        if(chk_libvips.checked)
                            ret += 1
                    }
                    if(chk_libarchive.visible) {
                        maxchk += 1
                        if(chk_libarchive.checked)
                            ret += 1
                    }
                    if(chk_pdf.visible) {
                        maxchk += 1
                        if(chk_pdf.checked)
                            ret += 1
                    }
                    if(chk_video.visible) {
                        maxchk += 1
                        if(chk_video.checked)
                            ret += 1
                    }
                    return [ret, maxchk]
                }

                function checkChecked(src : string) {

                    var situation = countChecked()
                    var numChecked = situation[0]
                    var maxChecked = situation[1]

                    if(numChecked === maxChecked)
                        chk_all.checked = true
                    else
                        chk_all.checked = false

                    if(numChecked === 0) {
                        if(src === "qt")
                            chk_qt.checked = true
                        else if(src === "magick")
                            chk_magick.checked = true
                        else if(src === "libraw")
                            chk_libraw.checked = true
                        else if(src === "devil")
                            chk_devil.checked = true
                        else if(src === "freeimage")
                            chk_freeimage.checked = true
                        else if(src === "libvips")
                            chk_libvips.checked = true
                        else if(src === "libarchive")
                            chk_libarchive.checked = true
                        else if(src === "pdf")
                            chk_pdf.checked = true
                        else if(src === "video")
                            chk_video.checked = true
                    }

                    applyChanges.restart()

                }

                function checkAll() {
                    chk_qt.checked = true
                    if(chk_magick.visible)
                        chk_magick.checked = true
                    if(chk_libraw.visible)
                        chk_libraw.checked = true
                    if(chk_devil.visible)
                        chk_devil.checked = true
                    if(chk_freeimage.visible)
                        chk_freeimage.checked = true
                    if(chk_libvips.visible)
                        chk_libvips.checked = true
                    if(chk_libarchive.visible)
                        chk_libarchive.checked = true
                    if(chk_pdf.visible)
                        chk_pdf.checked = true
                    if(chk_video.visible)
                        chk_video.checked = true
                    applyChanges.restart()
                }

                Component.onCompleted:
                    applyChanges.triggered()

                Timer {
                    id: applyChanges
                    interval: 50
                    onTriggered: {

                        if(chk_all.checked) {

                            filetypes_button.text = qsTranslate("filedialog", "All supported images")

                            PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormats() // qmllint disable unqualified
                            PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypes()

                        } else {

                            var txts = []

                            var suffixes = []
                            var mimetypes = []

                            if(chk_qt.checked) {
                                txts.push("Qt")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsQt())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesQt())
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsResvg())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesResvg())
                            }
                            if(chk_magick.checked) {
                                if(PQCScriptsConfig.isImageMagickSupportEnabled())
                                    txts.push("ImageMagick")
                                else
                                    txts.push("GraphicsMagick")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsMagick())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesMagick())
                            }
                            if(chk_libraw.checked) {
                                txts.push("LibRaw")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibRaw())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibRaw())
                            }
                            if(chk_devil.checked) {
                                txts.push("DevIL")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsDevIL())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesDevIL())
                            }
                            if(chk_freeimage.checked) {
                                txts.push("FreeImage")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsFreeImage())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesFreeImage())
                            }
                            if(chk_libvips.checked) {
                                txts.push("LibVips")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibVips())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibVips())
                            }
                            if(chk_libarchive.checked) {
                                txts.push("LibArchive")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibArchive())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibArchive())
                            }
                            if(chk_pdf.checked) {
                                txts.push("PDF/PS")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsPoppler())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesPoppler())
                            }
                            if(chk_video.checked) {
                                txts.push("Video")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsVideo())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesVideo())
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibmpv())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibmpv())
                            }

                            var situation = filetypes.countChecked()
                            if(situation[0] === situation[1])
                                filetypes_button.text = qsTranslate("filedialog", "All supported images")
                            else
                                filetypes_button.text = txts.join(", ")

                            PQCFileFolderModel.restrictToSuffixes = suffixes
                            PQCFileFolderModel.restrictToMimeTypes = mimetypes

                        }

                    }
                }


            }


        }

    }

    Rectangle {
        y: 0
        width: parent.width
        height: 1
        color: PQCLook.baseColorActive // qmllint disable unqualified
    }

}
