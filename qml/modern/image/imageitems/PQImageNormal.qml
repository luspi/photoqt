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
pragma ComponentBehavior: Bound

import QtQuick
import QtMultimedia
import PhotoQt.Shared

Image {

    id: image

    /*******************************************/
    // these values are READONLY, they are set in PQImageDisplay as bindings

    property string imageSource: ""
    property real defaultScale
    property real currentScale
    property bool isMainImage
    property Item loaderTop
    property bool thisIsAPhotoSphere

    /*******************************************/
    // these values are WRITEONLY and are picked up in PQImageDisplay

    property bool imageMirrorH: false
    property bool imageMirrorV: false

    /*******************************************/

    source: image.imageSource==="" ? "" : "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(imageSource)

    asynchronous: true

    // IMPORTANT NOTE REGARDING MIPMAP !!!
    //
    // Whenever the mipmap property changes, then the image is fully reloaded.
    // Making the mipmap property solely depend on the sourceSize makes it switch from false to true most of the time as the
    // sourceSize is reported as QSize(-1,-1) initially. This results, e.g., in the image to flicker when PhotoQt is started with one being passed on.
    // Making the mipmap property by default evaluate to true and ONLY if the image actually is below the threshold in size and the respective setting
    // is switched on, then it is set to false causing the reloading of a very small images (very fast).
    //
    // Another note about using a seperate property to store the sourceSize evaluation for both smooth and mipmap:
    // Such a property is NOT guaranteed to be evaluated before mipmap and might result in it still returning the value of QSize(-1,-1) for
    // the sourceSize even though initialLoad already caused a retrigger of mipmap.
    //
    // This property, initialLoad, ensures the 'true by default' value of mipmap and is set to false once we know the actual sourceSize.
    property bool initialLoad: true

    smooth: !PQCSettings.imageviewInterpolationDisableForSmallImages || (sourceSize.width > PQCSettings.imageviewInterpolationThreshold && sourceSize.height > PQCSettings.imageviewInterpolationThreshold)
    mipmap: initialLoad || !PQCSettings.imageviewInterpolationDisableForSmallImages || (sourceSize.width > PQCSettings.imageviewInterpolationThreshold && sourceSize.height > PQCSettings.imageviewInterpolationThreshold)

    property bool ignoreSignals: false

    cache: true

    fillMode: Image.Pad

    onStatusChanged: {

        if(ignoreSignals)
            return

        if(status == Image.Ready) {
            hasAlpha = PQCScriptsImages.supportsTransparency(image.imageSource)
        } else if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    onDefaultScaleChanged: {
        if(defaultScale < 0.95)
            loadScaledDown.restart()
    }

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged: {
        if(!ignoreSignals)
            image.imageMirrorH = myMirrorH
    }
    onMyMirrorVChanged: {
        if(!ignoreSignals)
            image.imageMirrorV = myMirrorV
    }

    property bool hasAlpha: false

    onSourceSizeChanged: {
        image.initialLoad = false
    }

    Connections {
        target: PQCScriptsShortcuts
        function onSendShortcutMirrorHorizontal() {
            if(image.visible) image.myMirrorH = !image.myMirrorH
        }
        function onSendShortcutMirrorVertical() {
            if(image.visible) image.myMirrorV = !image.myMirrorV
        }
        function onSendShortcutMirrorReset() {
            if(!image.visible) return
            image.myMirrorH = false
            image.myMirrorV = false
        }
    }

    transform: [
        Rotation {
            origin.x: image.width / 2
            origin.y: image.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: image.myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: image.width / 2
            origin.y: image.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: image.myMirrorV ? -180 : 0
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
        // this ensures it happens after the animation has stopped
        interval: (PQCSettings.imageviewAnimationDuration+1)*100
        onTriggered: {
            if(image.isMainImage) {
                image.screenW = image.loaderTop.width
                image.screenH = image.loaderTop.height
                ldl.active = true
            }
        }
    }

    function restartResetScreenSize() {
        resetScreenSize.restart()
    }
    property int screenW
    property int screenH
    Timer {
        id: resetScreenSize
        interval: 500
        repeat: false
        onTriggered: {
            image.screenW = image.loaderTop.width
            image.screenH = image.loaderTop.height
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
            source: visible ? image.source : ""
            smooth: image.currentScale < 0.95*image.defaultScale
            mipmap: smooth
            cache: false
            visible: image.defaultScale >= (1/0.95)*image.currentScale
            sourceSize: Qt.size(image.screenW, image.screenH)
        }
    }

    // This is a black overlay that is shown when this instance is used as background for the ken burns effect
    Loader {
        active: image.ignoreSignals
        asynchronous: true
        sourceComponent:
            Rectangle {
            width: image.width
            height: image.height
            color: "black"
            opacity: 0.75
        }
    }

    function setMirrorHV(mH : bool, mV : bool) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    /**********************************************************************************/
    // the code below takes care of loading special photo actions

    Connections {
        target: PQCConstants
        function onCurrentImageSourceChanged() {
            if(!image.isMainImage && !image.ignoreSignals) {
                videoloader.active = false
            }
        }
    }

    /******************************************************************************************/
    // The next block is for photo spheres and motion photos


    // a big button in middle of screen to enter photo sphere
    Loader {

        active: !image.ignoreSignals && image.thisIsAPhotoSphere && PQCSettings.filetypesPhotoSphereBigButton && !PQCConstants.slideshowRunning

        sourceComponent:
            Rectangle {
                parent: image.loaderTop
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
                    source: "image://svg/:/" + PQCLook.iconShade + "/photosphere.svg"
                }

                MouseArea {
                    id: spheremouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    // text: qsTranslate("image", "Click here to enter photo sphere")
                    onClicked: {
                        PQCNotify.enterPhotoSphere()
                    }
                }

            }
    }



    // check for photo sphere if enabled
    Timer {

        // this is triggered after the image has animated in
        interval: PQCSettings.imageviewAnimationDuration*100

        // we use this trimmed down version whenever we don't use the motion photo stuff below (the photo sphere checks are part of it)
        running: !image.ignoreSignals && image.visible&&(PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos)
        onTriggered: {

            if(PQCConstants.slideshowRunning)
                return

            if(!image.isMainImage)
                return

            if(PQCScriptsConfig.isMotionPhotoSupportEnabled() && (PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos)) {

                var what = PQCScriptsImages.isMotionPhoto(image.imageSource)

                if(what > 0) {

                    var src = ""

                    if(what === 1)
                        src = PQCScriptsFilesPaths.getDir(image.imageSource) + "/" + PQCScriptsFilesPaths.getBasename(image.imageSource) + ".mov"
                    else if(what === 2 || what === 3)
                        src = PQCScriptsImages.extractMotionPhoto(image.imageSource)

                    if(src != "") {

                        PQCConstants.isMotionPhoto = true

                        // HEIF/HEIC images are a little trickier with their orientation handling
                        // We need to ignore this value as the Exif orientation might not be correct
                        // See also: https://github.com/Exiv2/exiv2/issues/2958
                        var suf = PQCScriptsFilesPaths.getSuffixLowerCase(image.imageSource)
                        if(PQCSettings.metadataAutoRotation && suf !== "heic" && suf !== "heif") {

                            var orientation = PQCScriptsMetaData.getExifOrientation(image.imageSource)
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
                        videoloader.mediaSrc = "file:" + PQCScriptsFilesPaths.toPercentEncoding(src)
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

            id: motionphoto_img

            width: image.width
            height: image.height
            transform:
                Rotation {
                    origin.x: motionphoto_img.width / 2
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

                    target: PQCNotify

                    function onPlayPauseAnimationVideo() {

                        if(!image.isMainImage)
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

                parent: image.loaderTop

                x: parent.width-width-10
                y: parent.height-height-10
                z: PQCConstants.currentZValue+1

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
                        source: PQCSettings.filetypesMotionAutoPlay ? ("image://svg/:/" + PQCLook.iconShade + "/autoplay.svg") : ("image://svg/:/" + PQCLook.iconShade + "/autoplay_off.svg")
                    }

                    MouseArea {
                        id: autoplaymouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        // text: qsTranslate("image", "Toggle autoplay")
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
                        source: mediaplayer.playbackState == MediaPlayer.PlayingState ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
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
