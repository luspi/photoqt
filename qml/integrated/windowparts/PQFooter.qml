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
import QtQuick.Layouts
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

ToolBar {

    id: ftr

    onHeightChanged:
        PQCConstants.footerHeight = height

    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    RowLayout {

        anchors.fill: parent
        spacing: 5

        Label {
            visible: PQCFileFolderModel.countMainView===0 && PQCConstants.idOfVisibleItem!=="FileDialog"
            text: qsTranslate("other", "Click anywhere to open a file")
        }

        Label {
            visible: PQCConstants.idOfVisibleItem==="FileDialog"
            text: qsTranslate("other", "Select a file")
        }

        Label {
            id: statusinfo
            visible: PQCFileFolderModel.countMainView>0 && PQCConstants.idOfVisibleItem!=="FileDialog"
            elide: Label.ElideMiddle
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            visible: specialaction.visible
            text:"|"
        }

        ToolButton {
            id: specialaction

            property string whatisit

            visible: false
            text: "Special Action"

            onClicked: {
                if(whatisit == "photosphere") {
                    if(PQCConstants.showingPhotoSphere)
                        PQCNotify.exitPhotoSphere()
                    else
                        PQCNotify.enterPhotoSphere()
                } else if(whatisit == "viewermode") {
                    if(PQCFileFolderModel.isARC || PQCFileFolderModel.isPDF)
                        PQCFileFolderModel.disableViewerMode()
                    else
                        PQCFileFolderModel.enableViewerMode()
                } else if(whatisit == "facetagging") {
                    PQCNotify.stopFaceTagging()
                }
            }
        }

        Connections {

            target: PQCConstants

            function onFaceTaggingModeChanged() {
                ftr.checkFooterSpecialAction()
            }

        }

        Connections {

            target: PQCNotify

            function onNewImageHasBeenDisplayed() {
                ftr.checkFooterSpecialAction()
            }
        }

    }

    Connections {

        target: PQCFileFolderModel

        function onCurrentIndexNoDelayChanged() {
            ftr.craftString()
        }

        function onCountMainViewChanged() {
            ftr.craftString()
        }

        function onCurrentFileNoDelayChanged() {
            ftr.craftString()
        }

    }

    Connections {

        target: PQCConstants

        function onCurrentImageResolutionChanged() {
            ftr.craftString()
        }

        function onShowingPhotoSphereChanged() {
            ftr.craftString()
        }

        function onDevicePixelRatioChanged() {
            ftr.craftString()
        }

        function onCurrentImageScaleChanged() {
            ftr.craftString()
        }

        function onCurrentImageRotationChanged() {
            ftr.craftString()
        }

        function onColorProfileCacheChanged() {
            ftr.craftString()
        }

    }

    function craftString() {

        if(PQCFileFolderModel.countMainView === 0) {
            statusinfo.text = ""
            return
        }

        if(isNaN(PQCConstants.currentImageScale)) {
            retryForAdditionalInfo.restart()
            return
        }

        var str = []

        for(var i in PQCSettings.interfaceStatusInfoList) {

            var cur = PQCSettings.interfaceStatusInfoList[i]

            if(cur === "counter")
                str.push((PQCFileFolderModel.currentIndexNoDelay+1) + " / " + PQCFileFolderModel.countMainView)

            else if(cur === "filename")
                str.push(PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFileNoDelay))

            else if(cur === "filepathname")
                str.push(PQCFileFolderModel.currentFileNoDelay)

            else if(cur === "resolution")
                str.push(PQCConstants.currentImageResolution.width + " x " + PQCConstants.currentImageResolution.height)

            else if(cur === "zoom") {
                if(isNaN(PQCConstants.currentImageScale))
                    str.push("---")
                else
                    str.push(Math.round((PQCConstants.showingPhotoSphere ? 1 : PQCConstants.devicePixelRatio) * PQCConstants.currentImageScale*100)+"%" )
            }

            else if(cur === "rotation")
                str.push((Math.round(PQCConstants.currentImageRotation)%360+360)%360 + "°")

            else if(cur === "filesize")
                str.push(PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFileNoDelay))

            else if(cur === "colorprofile") {

                var val = ""

                if(PQCScriptsImages.isMpvVideo(PQCFileFolderModel.currentFileNoDelay) || PQCScriptsImages.isQtVideo(PQCFileFolderModel.currentFileNoDelay)) {
                    val = PQCScriptsColorProfiles.detectVideoColorProfile(PQCFileFolderModel.currentFileNoDelay)
                    if(val === "")
                        val = qsTranslate("statusinfo", "unknown color profile")
                } else
                    val = PQCConstants.colorProfileCache[PQCFileFolderModel.currentFileNoDelay]

                if(val !== undefined)
                    str.push(val)
                else
                    str.push("<font color='"+pqtPaletteDisabled.text+"'>---</font>")

            }

        }

        statusinfo.text = str.join("&nbsp;&nbsp;<font color='"+pqtPaletteDisabled.text+"'><b>|</b></font>&nbsp;&nbsp;")

    }

    Timer {
        id: retryForAdditionalInfo
        interval: 200
        onTriggered:
            ftr.craftString()
    }

    function checkFooterSpecialAction() {

        specialaction.visible = false

        if(PQCConstants.faceTaggingMode) {

            specialaction.whatisit = "facetagging"
            specialaction.text = qsTranslate("other", "Exit face tagging mode")
            specialaction.visible = true

        } else if(PQCConstants.currentImageIsPhotoSphere && !PQCSettings.filetypesPhotoSphereAutoLoad && !PQCConstants.slideshowRunning) {

            specialaction.whatisit = "photosphere"
            specialaction.text = Qt.binding(function() { return (PQCConstants.showingPhotoSphere ?
                                                                     qsTranslate("other", "Exit photo sphere") :
                                                                     qsTranslate("other", "Enter photo sphere")) })
            specialaction.visible = true

        } else if(PQCConstants.currentImageIsArchive || PQCConstants.currentImageIsDocument) {

            specialaction.whatisit = "viewermode"
            specialaction.text = Qt.binding(function() { return (PQCFileFolderModel.activeViewerMode ?
                                                                     qsTranslate("other", "Exit viewer mode") :
                                                                     qsTranslate("other", "Enter viewer mode")) })
            specialaction.visible = true

        }

    }

}
