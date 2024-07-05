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
import QtMultimedia

import PQCScriptsFilesPaths
import PQCScriptsConfig
import PQCNotify

import "../components"

Item {

    id: videotop

    width: video.width
    height: video.height

    // avoid warning message as we listen to changes for this item in different places
    property string source: ""

    Video {

        id: video

        // earlier versions of Qt6 seem to struggle if only one slash is used
        source: (PQCScriptsConfig.isQtAtLeast6_5() ? "file:/" : "file://") + loader_top.imageSource

        onSourceChanged:
            console.warn(">>>>>", source)

        volume: PQCNotify.slideshowRunning ? loader_slideshowhandler.item.volume : PQCSettings.filetypesVideoVolume/100

        width: PQCSettings.imageviewFitInWindow ? image_top.width : undefined
        height: PQCSettings.imageviewFitInWindow ? image_top.height : undefined

        fillMode: VideoOutput.PreserveAspectFit

        onPositionChanged: {
            if(position >= duration-100) {
                if(PQCSettings.filetypesVideoLoop && !PQCNotify.slideshowRunning)
                    video.seek(0)
                else
                    video.pause()
            }
        }

        onPlaybackStateChanged: {
            if(playbackState === MediaPlayer.StoppedState) {

                // earlier versions of Qt6 seem to struggle if only one slash is used
                if(PQCScriptsConfig.isQtAtLeast6_5())
                    video.source = "file:/" + loader_top.imageSource
                else
                    video.source = "file://" + loader_top.imageSource

                if(PQCSettings.filetypesVideoLoop && !PQCNotify.slideshowRunning) {
                    video.play()
                } else {
                    video.pause()
                    video.seek(video.duration-100)
                }
            }
        }

    }

    onWidthChanged: {
        image_wrapper.width = width
        loader_top.imageResolution.width = width
    }
    onHeightChanged: {
        loader_top.imageResolution.height = height
        image_wrapper.height = height
    }

    onVisibleChanged: {
        if(!visible) {
            video.pause()
            video.seek(0)
        } else {
            loader_top.videoLoaded = true
            loader_top.videoDuration = Qt.binding(function() { return Math.round(video.duration/1000); })
            loader_top.videoPosition = Qt.binding(function() { return Math.round(video.position/1000); })
            loader_top.videoPlaying = Qt.binding(function() { return (video.playbackState===MediaPlayer.PlayingState) })
            loader_top.videoHasAudio = Qt.binding(function() { return video.hasAudio })
            loader_top.videoHasAudioChanged()
        }
    }

    Component.onCompleted: {
        loader_top.videoDuration = Qt.binding(function() { return Math.round(video.duration/1000); })
        loader_top.videoPosition = Qt.binding(function() { return Math.round(video.position/1000); })
        loader_top.videoPlaying = Qt.binding(function() { return (video.playbackState===MediaPlayer.PlayingState) })
        loader_top.videoHasAudio = Qt.binding(function() { return video.hasAudio })
        image_wrapper.status = Image.Ready
    }

    Connections {
        target: image_top
        function onVideoJump(seconds) {

            if(!loader_top.isMainImage)
                return

            if(video.seekable)
                video.seek(video.position + seconds*1000)
        }
    }

    Connections {

        target: loader_top

        function onVideoTogglePlay() {

            if(!loader_top.isMainImage)
                return

            toggle()
        }
        function onVideoToPos(pos) {

            if(!loader_top.isMainImage)
                return

            video.seek(pos*1000)
        }
        function onImageClicked() {

            if(!loader_top.isMainImage)
                return

            toggle()
        }

        function onStopVideoAndReset() {

            if(!loader_top.isMainImage)
                return

            if(loader_top.videoPlaying) {
                video.pause()
                video.seek(0)
            }
        }
        function onRestartVideoIfAutoplay() {

            if(!loader_top.isMainImage)
                return

            if(loader_top.videoPlaying) {

                if(!PQCSettings.filetypesVideoAutoplay && !PQCNotify.slideshowRunning) {
                    video.pause()
                } else
                    video.seek(0)

            } else {
                video.seek(0)
                video.pause()
                if(PQCSettings.filetypesVideoAutoplay || PQCNotify.slideshowRunning)
                    video.play()
            }

        }
    }

    Connections {

        target: PQCNotify

        function onSlideshowRunningChanged() {

            if(!loader_top.isMainImage)
                return

            if(PQCNotify.slideshowRunning) {
                video.seek(0)
                video.play()
            }
        }

    }

    function toggle() {

        if(!loader_top.isMainImage)
            return

        if(loader_top.videoPlaying)
            video.pause()
        else {
            if(video.position > video.duration-150)
                video.seek(0)
            video.play()
        }
    }

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        loader_top.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        loader_top.imageMirrorV = myMirrorV

    Connections {
        target: image_top
        function onMirrorH() {
            videotop.myMirrorH = !videotop.myMirrorH
        }
        function onMirrorV() {
            videotop.myMirrorV = !videotop.myMirrorV
        }
        function onMirrorReset() {
            videotop.myMirrorH = false
            videotop.myMirrorV = false
        }
    }

    function setMirrorHV(mH, mV) {
        videotop.myMirrorH = mH
        videotop.myMirrorV = mV
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
            angle: myMirrorV ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

    PQVideoControls {
        id: controls
    }

}
