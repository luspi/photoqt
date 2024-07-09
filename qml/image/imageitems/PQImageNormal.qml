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

import "../../elements"

import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsOther
import PQCScriptsClipboard
import PQCScriptsMetaData

import QtMultimedia

Image {

    id: image

    source: imageloaderitem.imageSource==="" ? "" : ("image://full/" + PQCScriptsFilesPaths.toPercentEncoding(imageloaderitem.imageSource))

    asynchronous: true

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: interpThreshold
    mipmap: interpThreshold

    cache: false

    property bool fitImage: false

    width: fitImage ? image_top.width : undefined
    height: fitImage ? image_top.height : undefined

    fillMode: fitImage ? Image.PreserveAspectFit : Image.Pad

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Ready) {
            hasAlpha = PQCScriptsImages.supportsTransparency(imageloaderitem.imageSource)
            fitImage = (PQCSettings.imageviewFitInWindow && image.sourceSize.width < image_top.width && image.sourceSize.height < image_top.height)
            if(loader_top.defaultScale < 0.95)
                loadScaledDown.restart()
        } else if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        loader_top.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        loader_top.imageMirrorV = myMirrorV

    property bool hasAlpha: false

    onSourceSizeChanged:
        loader_top.imageResolution = sourceSize

    Connections {
        target: image_top
        function onMirrorH() {
            image.myMirrorH = !image.myMirrorH
        }
        function onMirrorV() {
            image.myMirrorV = !image.myMirrorV
        }
        function onMirrorReset() {
            image.myMirrorH = false
            image.myMirrorV = false
        }
        function onWidthChanged() {
            resetScreenSize.restart()
        }
        function onHeightChanged() {
            resetScreenSize.restart()
        }

    }

    transform: [
        Rotation {
            origin.x: width / 2
            origin.y: height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: width / 2
            origin.y: height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: myMirrorV ? -180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

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
            if(loader_top.isMainImage) {
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
            smooth: image_wrapper.scale < 0.95*loader_top.defaultScale
            mipmap: smooth
            cache: false
            visible: loader_top.defaultScale >= image_wrapper.scale
            sourceSize: Qt.size(screenW, screenH)
        }
    }

    function setMirrorHV(mH, mV) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    /**********************************************************************************/
    // the code below takes care of loading special photo actions

    Connections {
        target: image_top
        function onCurrentlyVisibleIndexChanged() {
            if(!loader_top.isMainImage) {
                videoloader.active = false
            }
        }
    }

    /******************************************************************************************/
    // The next block is for photo spheres and motion photos


    // a big button in middle of screen to enter photo sphere
    Loader {

        active: loader_top.thisIsAPhotoSphere && PQCSettings.filetypesPhotoSphereBigButton && !PQCNotify.slideshowRunning

        sourceComponent:
            Rectangle {
                parent: loader_top
                id: spherebut
                x: (parent.width-width)/2
                y: (parent.height-height)/2
                width: 150
                height: 150
                color: PQCLook.transColor
                radius: width/2
                opacity: (spheremouse.containsMouse ? 0.8 : 0.4)
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    anchors.margins: 20
                    mipmap: true
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/white/photosphere.svg"
                }

                PQMouseArea {
                    id: spheremouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Click here to enter photo sphere")
                    onClicked: {
                        image_top.enterPhotoSphere()
                    }
                }

            }
    }



    // check for photo sphere if enabled
    Timer {

        // this is triggered after the image has animated in
        interval: PQCSettings.imageviewAnimationDuration*100

        // we use this trimmed down version whenever we don't use the motion photo stuff below (the photo sphere checks are part of it)
        running: visible&&(PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos)
        onTriggered: {

            if(PQCNotify.slideshowRunning)
                return

            if(!loader_top.isMainImage)
                return

            if(PQCScriptsConfig.isMotionPhotoSupportEnabled() && (PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos)) {

                var what = PQCScriptsImages.isMotionPhoto(imageloaderitem.imageSource)

                if(what > 0) {

                    var src = ""

                    if(what === 1)
                        src = PQCScriptsFilesPaths.getDir(imageloaderitem.imageSource) + "/" + PQCScriptsFilesPaths.getBasename(imageloaderitem.imageSource) + ".mov"
                    else if(what === 2 || what === 3)
                        src = PQCScriptsImages.extractMotionPhoto(imageloaderitem.imageSource)

                    if(src != "") {

                        PQCNotify.isMotionPhoto = true

                        // HEIF/HEIC images are a little trickier with their orientation handling
                        // We need to ignore this value as the Exif orientation might not be correct
                        // See also: https://github.com/Exiv2/exiv2/issues/2958
                        var suf = PQCScriptsFilesPaths.getSuffix(imageloaderitem.imageSource).toLowerCase()
                        if(PQCSettings.metadataAutoRotation && suf !== "heic" && suf !== "heif") {

                            var orientation = PQCScriptsMetaData.getExifOrientation(imageloaderitem.imageSource)
                            switch(orientation) {

                            case 1:
                                // no rotation, no mirror
                                videoloader.forceRotation = 0
                                videoloader.forceMirror = false
                                break;
                            case 2:
                                // no rotation, horizontal mirror
                                videoloader.forceRotation = 0
                                videoloader.forceMirror = true
                                break;
                            case 3:
                                // 180 degree rotation, no mirror
                                videoloader.forceRotation = 180
                                videoloader.forceMirror = false
                                break;
                            case 4:
                                // 180 degree rotation, horizontal mirror
                                videoloader.forceRotation = 180
                                videoloader.forceMirror = true
                                break;
                            case 5:
                                // 90 degree rotation, horizontal mirror
                                videoloader.forceRotation = 90
                                videoloader.forceMirror = true
                                break;
                            case 6:
                                // 90 degree rotation, no mirror
                                videoloader.forceRotation = 90
                                videoloader.forceMirror = false
                                break;
                            case 7:
                                // 270 degree rotation, horizontal mirror
                                videoloader.forceRotation = 270
                                videoloader.forceMirror = true
                                break;
                            case 8:
                                // 270 degree rotation, no mirror
                                videoloader.forceRotation = 270
                                videoloader.forceMirror = false
                                break;
                            default:
                                console.warn("Unexpected orientation value received:", orientation)
                                break;

                            }

                        }

                        videoloader.active = false
                        // earlier versions of Qt6 seem to struggle if only one slash is used
                        if(PQCScriptsConfig.isQtAtLeast6_5())
                            videoloader.mediaSrc = "file:/" + src
                        else
                            videoloader.mediaSrc = "file://" + src
                        videoloader.active = true
                        return
                    }

                }

            } else
                videoloader.mediaSrc = ""

        }

    }

    // we hide the video element behind a loader so that we don't even have to set it up if no video is found

    Loader {
        id: videoloader

        active: false
        property string mediaSrc: ""

        property int forceRotation: 0
        property bool forceMirror: false

        asynchronous: true
        sourceComponent: motionphoto
    }

    Component {

        id: motionphoto

        Item {

            width: image.width
            height: image.height
            transform:
                Rotation {
                    origin.x: width / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: videoloader.forceMirror ? 180 : 0
                }

            Video {
                id: mediaplayer
                rotation: videoloader.forceRotation
                anchors.fill: parent
                anchors.margins: rotation%180==0 ? 0 : -(image.height-image.width)/2
                source: videoloader.mediaSrc
                Component.onCompleted: {
                    if(PQCSettings.filetypesMotionAutoPlay)
                        play()
                }
                Connections {
                    target: loader_top
                    function onVideoTogglePlay() {
                        if(!image_top.isMainImage)
                            return
                        if(mediaplayer.playbackState == MediaPlayer.PausedState)
                            mediaplayer.play()
                        else if(mediaplayer.playbackState == MediaPlayer.StoppedState) {
                            mediaplayer.source = videoloader.mediaSrc
                            mediaplayer.play()
                        } else
                            mediaplayer.pause()
                    }
                }
            }

            Row {

                parent: image_top

                x: parent.width-width-10
                y: parent.height-height-10
                z: image_top.curZ+1

                visible: PQCSettings.filetypesMotionPhotoPlayPause && mediaplayer.hasVideo

                Rectangle {

                    width: 30
                    height: 30
                    color: "#88000000"
                    radius: 5

                    opacity: autoplaymouse.containsMouse ? (PQCSettings.filetypesMotionAutoPlay ? 1 : 0.6) : 0.2
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        opacity: PQCSettings.filetypesMotionAutoPlay ? 1 : 0.5
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        sourceSize: Qt.size(width, height)
                        source: PQCSettings.filetypesMotionAutoPlay ? "image://svg/:/white/autoplay.svg" : "image://svg/:/white/autoplay_off.svg"
                    }

                    PQMouseArea {
                        id: autoplaymouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("image", "Toggle autoplay")
                        onClicked: {
                            PQCSettings.filetypesMotionAutoPlay = !PQCSettings.filetypesMotionAutoPlay
                        }
                    }

                }

                Rectangle {

                    width: 30
                    height: 30
                    color: "#88000000"
                    radius: 5

                    opacity: playpausemouse.containsMouse ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        sourceSize: Qt.size(width, height)
                        source: mediaplayer.playbackState == MediaPlayer.PlayingState ? "image://svg/:/white/pause.svg" : "image://svg/:/white/play.svg"
                    }

                    MouseArea {
                        id: playpausemouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(mediaplayer.playbackState == MediaPlayer.PlayingState)
                                mediaplayer.pause()
                            else
                                mediaplayer.play()
                        }
                    }

                }

            }

        }

    }

    /******************************************************************************************/

}
