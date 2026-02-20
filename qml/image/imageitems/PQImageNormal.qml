/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import PhotoQt

Item {

    id: imgtop

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

    // this is to explicitely set the sourceSize when the image is ready
    // see below for more details
    signal ensureSourceSizeSet()

    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status
    width: image.width
    height: image.height

    property bool hasAlpha: false

    property bool ignoreSignals: false

    Image {

        id: image

        source: imgtop.imageSource==="" ? "" : "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(imgtop.imageSource)

        asynchronous: true

        // this stores whether we are still in our initial loading phase
        // it will be set to false once the proper sourceSize is available
        property bool initialLoad: true

        property bool interpThresholdMet: sourceSize.width > PQCConstants.availableWidth || sourceSize.height > PQCConstants.availableHeight

        smooth: !PQCSettings.imageviewInterpolationDisableForSmallImages || interpThresholdMet || initialLoad
        mipmap: false


        Component.onCompleted: {
            // this is necessary, otherwise the interpThresholdMet property is not properly updated
            PQCConstants.availableWidthChanged()
        }

        cache: true

        fillMode: Image.Pad

        onStatusChanged: {

            if(imgtop.ignoreSignals)
                return

            if(status == Image.Ready) {
                PQCConstants.availableWidthChanged()
                // this signal is necessary, otherwise it *can* happen that the image source size is not reported correctly
                // this then results in a 0x0 dimension reported, the fit-to-size does not work, and the image might not show up at all
                imgtop.ensureSourceSizeSet()
                imgtop.hasAlpha = PQCScriptsImages.supportsTransparency(image.imageSource)
                // asynchronous = false
            } else if(status == Image.Error)
                source = "image://svg/:/other/errorimage.svg"
        }

        // we use custom mirror properties to be able to animate the mirror process with transforms
        property bool myMirrorH: false
        property bool myMirrorV: false

        onMyMirrorHChanged: {
            if(!imgtop.ignoreSignals)
                imgtop.imageMirrorH = myMirrorH
        }
        onMyMirrorVChanged: {
            if(!imgtop.ignoreSignals)
                imgtop.imageMirrorV = myMirrorV
        }

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
                Behavior on angle { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
            },
            Rotation {
                origin.x: image.width / 2
                origin.y: image.height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: image.myMirrorV ? -180 : 0
                Behavior on angle { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
            }
        ]

        Image {
            anchors.fill: parent
            z: parent.z-1
            fillMode: Image.Tile

            source: PQCSettings.imageviewTransparencyMarker&&image.hasAlpha ? "/other/checkerboard.png" : ""

        }

        // This is a black overlay that is shown when this instance is used as background for the ken burns effect
        Loader {
            active: imgtop.ignoreSignals
            asynchronous: true
            sourceComponent:
                Rectangle {
                width: image.width
                height: image.height
                color: "black"
                opacity: 0.75
            }
        }

    }

    function setMirrorHV(mH : bool, mV : bool) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    onCurrentScaleChanged: {
        if(delayCurrentScale == 0) {
            delaySetCurrentScale.stop()
            delaySetCurrentScale.triggered()
        } else
            delaySetCurrentScale.restart()
    }

    property real delayCurrentScale: 0
    Timer {
        id: delaySetCurrentScale
        interval: 200
        triggeredOnStart: true
        onTriggered: {
            if(delaySetCurrentScale.running) {
                scaledloader.manualHidden = true
            } else {
                scaledloader.manualHidden = false
                imgtop.delayCurrentScale = imgtop.currentScale
            }
        }
    }

    Loader {
        id: scaledloader
        width: image.paintedWidth
        height: image.paintedHeight
        property bool manualHidden: false
        active: (!image.initialLoad || image.status===Image.Ready) && (!PQCSettings.imageviewInterpolationDisableForSmallImages || image.interpThresholdMet)
        asynchronous: true
        sourceComponent:
        Image {
            id: scaledimage
            width: image.paintedWidth
            height: image.paintedHeight
            source: imgtop.source
            visible: image.status == Image.Ready && !scaledloader.manualHidden
            cache: false
            smooth: true
            mipmap: true
            z: parent.z+1
            asynchronous: false
            sourceSize: Qt.size(Math.min(image.sourceSize.width, width*(imgtop.delayCurrentScale/imgtop.defaultScale)),
                                Math.min(image.sourceSize.height, height*(imgtop.delayCurrentScale/imgtop.defaultScale)))
        }
    }


    /**********************************************************************************/
    // the code below takes care of loading special photo actions

    Connections {
        target: PQCConstants
        function onCurrentImageSourceChanged() {
            if(!imgtop.isMainImage && !imgtop.ignoreSignals) {
                videoloader.active = false
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
        running: !imgtop.ignoreSignals && image.visible&&(PQCSettings.filetypesLoadMotionPhotos || PQCSettings.filetypesLoadAppleLivePhotos)
        onTriggered: {

            if(PQCConstants.slideshowRunning)
                return

            if(!imgtop.isMainImage)
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

                        PQCConstants.currentImageIsMotionPhoto = true

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
                onPlaybackStateChanged: {
                    PQCConstants.motionPhotoIsPlaying = (mediaplayer.playbackState == MediaPlayer.PlayingState)
                }

                Connections {

                    target: PQCNotify

                    function onPlayPauseAnimationVideo() {

                        if(!imgtop.isMainImage)
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

        }

    }

    /******************************************************************************************/

}
