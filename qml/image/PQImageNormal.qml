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

import "../elements"

import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsOther
import PQCScriptsClipboard

import QtMultimedia

Image {

    id: image

    source: "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)

    asynchronous: true

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: interpThreshold
    mipmap: interpThreshold

    property bool fitImage: (PQCSettings.imageviewFitInWindow && image.sourceSize.width < deleg.width && image.sourceSize.height < deleg.height)

    width: fitImage ? deleg.width : undefined
    height: fitImage ? deleg.height : undefined

    fillMode: fitImage ? Image.PreserveAspectFit : Image.Pad

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Ready) {
            hasAlpha = PQCScriptsImages.supportsTransparency(deleg.imageSource)
            if(deleg.defaultScale < 0.95)
                loadScaledDown.restart()
        } else if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    onMirrorChanged:
        deleg.imageMirrorH = mirror
    onMirrorVerticallyChanged:
        deleg.imageMirrorV = image.mirrorVertically

    property bool hasAlpha: false

    onSourceSizeChanged:
        deleg.imageResolution = sourceSize

    Connections {
        target: image_top
        function onMirrorH() {
            image.mirror = !image.mirror
        }
        function onMirrorV() {
            image.mirrorVertically = !image.mirrorVertically
        }
        function onMirrorReset() {
            image.mirror = false
            image.mirrorVertically = false
        }
        function onWidthChanged() {
            resetScreenSize.restart()
        }
        function onHeightChanged() {
            resetScreenSize.restart()
        }

    }

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile

        source: PQCSettings.imageviewTransparencyMarker&&image.hasAlpha ? "/other/checkerboard.png" : ""

    }

    // with a short delay we load a version of the image scaled to screen dimensions
    Timer {
        id: loadScaledDown
        interval: (PQCSettings.imageviewAnimationDuration+1)*100    // this ensures it happens after the animation has stopped
        onTriggered: {
            if(deleg.shouldBeShown) {
                screenW = image_top.width
                screenH = image_top.height
                ldl.active = true
            }
        }
    }

    property int screenW
    property int screenH
    Timer {
        id: resetScreenSize
        interval: 500
        repeat: false
        onTriggered: {
            screenW = image_top.width
            screenH = image_top.height
        }
    }

    // image scaled to screen dimensions
    Loader {
        id: ldl
        asynchronous: true
        active: false
        sourceComponent:
        Image {
            width: image.width
            height: image.height
            source: image.source
            visible: deleg.defaultScale >= image_wrapper.scale
            sourceSize: Qt.size(screenW, screenH)
            mirror: image.mirror
            mirrorVertically: image.mirrorVertically
        }
    }

    function setMirrorHV(mH, mV) {
        image.mirror = mH
        image.mirrorVertically = mV
    }

    /**********************************************************************************/
    // the code below takes care of loading special photo actions

    Connections {

        target: PQCSettings

        function onFiletypesCheckForPhotoSphereChanged() {
            if(PQCScriptsImages.isPhotoSphere(deleg.imageSource)) {
                PQCNotify.hasPhotoSphere = true
            } else
                PQCNotify.hasPhotoSphere = false
        }

    }

    Connections {
        target: image_top
        function onCurrentlyVisibleIndexChanged(currentlyVisibleIndex) {
            if(currentlyVisibleIndex !== deleg.itemIndex) {
                videoloader.active = false
                barcodes = []
            }
        }
        function onDetectBarCodes() {
            if(image_top.currentlyVisibleIndex === deleg.itemIndex) {
                if(!PQCNotify.barcodeDisplayed) {
                    PQCNotify.barcodeDisplayed = true
                    barcodes = PQCScriptsImages.getZXingData(deleg.imageSource)
                } else {
                    PQCNotify.barcodeDisplayed = false
                    barcodes = []
                }
            }
        }
    }

    /******************************************************************************************/
    // The next block deals with bar codes

    property var barcodes: []
    property int barcode_z: 0

    Loader {

        active: barcodes.length>0

        Item {
            // id: barcodes
            anchors.fill: parent
            property var list_barcodes: []
            Repeater {
                model: barcodes.length/3

                Rectangle {

                    id: bardeleg
                    property var val: barcodes[3*index]
                    property var loc: barcodes[3*index+1]
                    property var sze: barcodes[3*index+2]
                    x: loc.x
                    y: loc.y
                    width: sze.width
                    height: sze.height

                    color: "#88ff0000"
                    radius: 5
                    scale: 1/deleg.imageScale

                    property bool overrideCursorSet: false

                    Rectangle {
                        id: txtcont
                        x: (parent.width-width)/2
                        y: (parent.height-height)/2
                        width: valtxt.width+10
                        height: valtxt.height+10
                        color: "white"
                        radius: 5
                        PQTextL {
                            id: valtxt
                            x: 5
                            y: 5
                            color: "black"
                            text: bardeleg.val
                        }

                    }

                    Row {
                        x: (parent.width-width)/2
                        y: txtcont.y+txtcont.height+3

                        spacing: 1

                        Rectangle {
                            id: copycont
                            width: 32
                            height: 32
                            color: "#88000000"
                            radius: 5
                            property bool hovered: false
                            opacity: hovered ? 1 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            Image {
                                anchors.fill: parent
                                anchors.margins: 5
                                sourceSize: Qt.size(width, height)
                                fillMode: Image.Pad
                                source: "/white/copy.svg"
                            }
                        }

                        Rectangle {
                            id: linkcont
                            width: 32
                            height: 32
                            color: "#88000000"
                            radius: 5
                            property bool hovered: false
                            opacity: hovered ? 1 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            visible: PQCScriptsFilesPaths.isUrl(bardeleg.val)
                            enabled: visible
                            Image {
                                anchors.fill: parent
                                anchors.margins: 5
                                sourceSize: Qt.size(width, height)
                                fillMode: Image.Pad
                                source: "/white/globe.svg"
                            }
                        }

                        Connections {

                            target: image_top

                            function onBarcodeClick() {
                                if(copycont.hovered)
                                    PQCScriptsClipboard.copyTextToClipboard(bardeleg.val)
                                else if(linkcont.hovered)
                                    Qt.openUrlExternally(bardeleg.val)
                            }

                        }

                        Connections {

                            target: PQCNotify
                            enabled: image_top.currentlyVisibleIndex === deleg.itemIndex

                            function onMouseMove(x, y) {

                                var local = copycont.mapFromItem(fullscreenitem, Qt.point(x,y))
                                copycont.hovered = (local.x > 0 && local.y > 0 && local.x < copycont.width && local.y < copycont.height)

                                local = linkcont.mapFromItem(fullscreenitem, Qt.point(x,y))
                                linkcont.hovered = (local.x > 0 && local.y > 0 && local.x < linkcont.width && local.y < linkcont.height)

                                if(copycont.hovered || linkcont.hovered) {
                                    barcode_z += 1
                                    bardeleg.z = barcode_z
                                    bardeleg.overrideCursorSet = true
                                    PQCScriptsOther.setPointingHandCursor()
                                } else if(bardeleg.overrideCursorSet) {
                                    bardeleg.overrideCursorSet = false
                                    PQCScriptsOther.restoreOverrideCursor()
                                }

                            }

                        }

                    }

                }

            }

        }

    }

    /******************************************************************************************/
    // The next block is for photo spheres and motion photos


    // check for photo sphere if enabled
    Timer {

        // this is triggered after the image has animated in
        interval: PQCSettings.imageviewAnimationDuration*100

        // we use this trimmed down version whenever we don't use the motion photo stuff below (the photo sphere checks are part of it)
        running: visible&&(PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos || PQCSettings.filetypesCheckForPhotoSphere)
        onTriggered: {

            if(PQCFileFolderModel.currentIndex !== index)
                return

            if(PQCScriptsConfig.isMotionPhotoSupportEnabled() && (PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos)) {

                var what = PQCScriptsImages.isMotionPhoto(deleg.imageSource)

                if(what > 0) {

                    var src = ""

                    if(what === 1)
                        src = PQCScriptsFilesPaths.getDir(deleg.imageSource) + "/" + PQCScriptsFilesPaths.getBasename(deleg.imageSource) + ".mov"
                    else if(what === 2 || what === 3)
                        src = PQCScriptsImages.extractMotionPhoto(deleg.imageSource)

                    if(src != "") {
                        videoloader.active = false
                        // earlier versions of Qt6 seem to struggle if only one slash is used
                        if(PQCScriptsConfig.isQtAtLeast6_5())
                            videoloader.mediaSrc = "file:/" + src
                        else
                            videoloader.mediaSrc = "file://" + src
                        videoloader.active = true
                        PQCNotify.hasPhotoSphere = false
                        return
                    }

                }

            } else
                videoloader.mediaSrc = ""

            if(PQCSettings.filetypesCheckForPhotoSphere && PQCScriptsConfig.isPhotoSphereSupportEnabled()) {

                if(PQCScriptsImages.isPhotoSphere(deleg.imageSource)) {
                    PQCNotify.hasPhotoSphere = true
                } else
                    PQCNotify.hasPhotoSphere = false

            }

        }

    }

    // we hide the video element behind a loader so that we don't even have to set it up if no video is found

    Loader {
        id: videoloader

        active: false
        property string mediaSrc: ""

        asynchronous: true
        sourceComponent: motionphoto
    }

    Component {

        id: motionphoto

        Item {

            width: image.width
            height: image.height

            Video {
                id: mediaplayer
                anchors.fill: parent
                source: videoloader.mediaSrc
                Component.onCompleted: {
                    play()
                }
            }

        }

    }

    /******************************************************************************************/

}
