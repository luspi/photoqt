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
import QtQuick.Controls
import PhotoQt

Item {

    id: tweaks_top

    width: parent.width
    height: 50

    property int zoomMoveUpHeight: leftcolrect.state==="moveup" ? leftcolrect.height : 0

    Rectangle {

        id: leftcolrect

        y: 0
        Behavior on y { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200; easing.type: Easing.OutElastic } }

        width: leftcol.width+15
        height: parent.height

        color: palette.base
        border.color: PQCLook.baseBorder
        border.width: state==="moveup" ? 1 : 0

        Row {

            id: leftcol
            x: 5
            y: (parent.height-height)/2

            spacing: 5

            Label {
                y: (parent.height-height)/2
                text: qsTranslate("filedialog", "Zoom:")
                font.weight: PQCLook.fontWeightBold
                font.pointSize: PQCLook.fontSize
                color: palette.text
                PQMouseArea {
                    anchors.fill: parent
                    tooltip: qsTranslate("filedialog", "Adjust size of files and folders")
                }
            }

            PQFileDialogSlider {

                id: zoomslider

                y: (parent.height-height)/2

                from: 1
                to: 100

                stepSize: 1

                value: PQCSettings.filedialogZoom
                onValueChanged: {
                    var newval = Math.round(value)
                    if(newval !== PQCSettings.filedialogZoom)
                        PQCSettings.filedialogZoom = newval
                    tweaks_top.forceActiveFocus()
                }

                Connections {

                    target: PQCSettings

                    function onFiledialogZoomChanged() {
                        if(zoomslider.value !== PQCSettings.filedialogZoom)
                            zoomslider.value = PQCSettings.filedialogZoom
                    }
                }

                Component.onCompleted: {
                    value = 1*value
                }

            }

            Text {
                y: (parent.height-height)/2
                text: zoomslider.value + "%"
                font.pointSize: PQCLook.fontSize
                color: palette.text
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
        Behavior on anchors.leftMargin { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200; easing.type: Easing.OutBounce } }
        height: parent.height

        PQButtonElement {
            id: cancelbutton
            anchors.centerIn: parent
            text: genericStringCancel
            tooltip: qsTranslate("filedialog", "Cancel and close")
            onClicked:
                filedialog_top.handleHiding(true)
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

            PQComboBox {

                id: rightcombo

                y: (parent.height-height)/2

                selectedPrefix: qsTranslate("filedialog", "Sort by: ")

                property list<string> modeldata_wicu: [qsTranslate("filedialog", "Name"),
                                                       qsTranslate("filedialog", "Natural Name"),
                                                       qsTranslate("filedialog", "Time modified"),
                                                       qsTranslate("filedialog", "File size"),
                                                       qsTranslate("filedialog", "File type"),
                                                       "[" + qsTranslate("filedialog", "reverse order") + "]"]

                property list<string> modeldata_woicu: [qsTranslate("filedialog", "Name"),
                                                        qsTranslate("filedialog", "Time modified"),
                                                        qsTranslate("filedialog", "File size"),
                                                        qsTranslate("filedialog", "File type"),
                                                        "[" + qsTranslate("filedialog", "reverse order") + "]"]

                property list<string> modeldata: PQCScriptsConfig.isICUSupportEnabled() ? modeldata_wicu : modeldata_woicu

                model: modeldata

                width: 250

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
                        PQCSettings.imageviewSortImagesBy = "name"
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
                    var sortby = PQCSettings.imageviewSortImagesBy
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

                popup.onClosed: {
                    tweaks_top.forceActiveFocus()
                }

            }

            PQCheckableComboBox {

                id: ft_combo

                model: ListModel { id: mdl }

                // This will be shown as 'selected' entry
                mainEntryText: ""

                width: 250

                Connections {
                    target: PQCNotify
                    function onFiledialogTweaksSetFiletypesButtonText(txt) {
                        ft_combo.mainEntryText = txt
                    }
                }

                property int countEnabled: mdl.count

                Component.onCompleted: {
                    mdl.append({"txt" : "Qt", "checked" : 1})
                    if(PQCScriptsConfig.isImageMagickSupportEnabled())
                        mdl.append({"txt" : "ImageMagick", "checked" : 1})
                    if(PQCScriptsConfig.isGraphicsMagickSupportEnabled())
                        mdl.append({"txt" : "GraphicsMagick", "checked" : 1})
                    if(PQCScriptsConfig.isLibRawSupportEnabled())
                        mdl.append({"txt" : "LibRaw", "checked" : 1})
                    if(PQCScriptsConfig.isDevILSupportEnabled())
                        mdl.append({"txt" : "DevIL", "checked" : 1})
                    if(PQCScriptsConfig.isFreeImageSupportEnabled())
                        mdl.append({"txt" : "FreeImage", "checked" : 1})
                    if(PQCScriptsConfig.isLibVipsSupportEnabled())
                        mdl.append({"txt" : "LibVips", "checked" : 1})
                    if(PQCScriptsConfig.isLibArchiveSupportEnabled())
                        mdl.append({"txt" : "LibArchive", "checked" : 1})
                    if(PQCScriptsConfig.isPDFSupportEnabled())
                        mdl.append({"txt" : "PDF/PS", "checked" : 1})
                    if(PQCScriptsConfig.isMPVSupportEnabled()||PQCScriptsConfig.isVideoQtSupportEnabled())
                        mdl.append({"txt" : "Video", "checked" : 1})

                    saveFiletypes.triggered()
                }

                onEntryUpdated: (index) => {
                    var c = 0
                    for(var i = 0; i < mdl.count; ++i) {
                        if(mdl.get(i).checked)
                            c += 1
                    }
                    countEnabled = c
                    saveFiletypes.restart()
                }

                Timer {
                    id: saveFiletypes
                    interval: 50
                    onTriggered: {

                        if(ft_combo.countEnabled === mdl.count) {

                            PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormats()
                            PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypes()

                            PQCNotify.filedialogTweaksSetFiletypesButtonText(qsTranslate("filedialog", "All supported images"))

                        } else {

                            var runningIndex = 0

                            var txts = []

                            var suffixes = []
                            var mimetypes = []

                            // Qt
                            if(mdl.get(runningIndex).checked) {
                                txts.push("Qt")
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsQt())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesQt())
                                suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsResvg())
                                mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesResvg())
                            }
                            runningIndex += 1

                            // ImageMagick
                            if(PQCScriptsConfig.isImageMagickSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("ImageMagick")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsMagick())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesMagick())
                                }
                                runningIndex += 1
                            }

                            // GraphicsMagick
                            if(PQCScriptsConfig.isGraphicsMagickSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("GraphicsMagick")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsMagick())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesMagick())
                                }
                                runningIndex += 1
                            }

                            // LibRaw
                            if(PQCScriptsConfig.isLibRawSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("LibRaw")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibRaw())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibRaw())
                                }
                                runningIndex += 1
                            }

                            // DevIL
                            if(PQCScriptsConfig.isDevILSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("DevIL")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsDevIL())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesDevIL())
                                }
                                runningIndex += 1
                            }

                            // FreeImage
                            if(PQCScriptsConfig.isFreeImageSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("FreeImage")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsFreeImage())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesFreeImage())
                                }
                                runningIndex += 1
                            }

                            // LibVips
                            if(PQCScriptsConfig.isLibVipsSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("LibVips")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibVips())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibVips())
                                }
                                runningIndex += 1
                            }

                            // LibArchive
                            if(PQCScriptsConfig.isLibArchiveSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("LibArchive")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibArchive())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibArchive())
                                }
                                runningIndex += 1
                            }

                            // Poppler
                            if(PQCScriptsConfig.isPDFSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("PDF/PS")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsPoppler())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesPoppler())
                                }
                                runningIndex += 1
                            }

                            // Video
                            if(PQCScriptsConfig.isMPVSupportEnabled() || PQCScriptsConfig.isVideoQtSupportEnabled()) {
                                if(mdl.get(runningIndex).checked) {
                                    txts.push("Video")
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsVideo())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesVideo())
                                    suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibmpv())
                                    mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibmpv())
                                }
                                runningIndex += 1
                            }

                            PQCNotify.filedialogTweaksSetFiletypesButtonText(txts.join(", "))

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
        color: PQCLook.baseBorder
    }

}
