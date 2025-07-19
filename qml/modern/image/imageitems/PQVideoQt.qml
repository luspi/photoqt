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
import QtMultimedia
import PhotoQt

Item {

    id: videotop

    property string imageSource: ""

    width: video.width
    height: video.height

    // avoid warning message as we listen to changes for this item in different places
    property string source: ""

    Video {

        id: video

        source: "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.imageSource) // qmllint disable unqualified

        volume: PQCConstants.slideshowRunning ? PQCConstants.slideshowVolume : PQCSettings.filetypesVideoVolume/100 // qmllint disable unqualified

        width: PQCSettings.imageviewFitInWindow ? image_top.width : undefined // qmllint disable unqualified
        height: PQCSettings.imageviewFitInWindow ? image_top.height : undefined // qmllint disable unqualified

        fillMode: VideoOutput.PreserveAspectFit

        onPositionChanged: {
            if(position >= duration-100) {
                if(PQCSettings.filetypesVideoLoop && !PQCConstants.slideshowRunning) // qmllint disable unqualified
                    video.seek(0)
                else
                    video.pause()
            }
        }

        onPlaybackStateChanged: {
            if(playbackState === MediaPlayer.StoppedState) {

                video.source = "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.imageSource)

                if(PQCSettings.filetypesVideoLoop && !PQCConstants.slideshowRunning) { // qmllint disable unqualified
                    video.play()
                } else {
                    video.pause()
                    video.seek(video.duration-100)
                }
            }
        }

    }

    onVisibleChanged: {
        if(!visible) {
            video.pause()
            video.seek(0)
        } else {
            loader_top.videoLoaded = true // qmllint disable unqualified
            loader_top.videoDuration = Qt.binding(function() { return Math.round(video.duration/1000); })
            loader_top.videoPosition = Qt.binding(function() { return Math.round(video.position/1000); })
            loader_top.videoPlaying = Qt.binding(function() { return (video.playbackState===MediaPlayer.PlayingState) })
            loader_top.videoHasAudio = Qt.binding(function() { return video.hasAudio })
            loader_top.videoHasAudioChanged()
        }
    }

    Component.onCompleted: {
        loader_top.videoDuration = Qt.binding(function() { return Math.round(video.duration/1000); }) // qmllint disable unqualified
        loader_top.videoPosition = Qt.binding(function() { return Math.round(video.position/1000); })
        loader_top.videoPlaying = Qt.binding(function() { return (video.playbackState===MediaPlayer.PlayingState) })
        loader_top.videoHasAudio = Qt.binding(function() { return video.hasAudio })
        image_wrapper.status = Image.Ready
    }

    Connections {

        target: PQCNotify

        function onCurrentVideoJump(seconds : int) {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            if(video.seekable)
                video.seek(video.position + seconds*1000)
        }

        function onPlayPauseAnimationVideo() {

            if(!loader_top.isMainImage)
                return

            videotop.toggle()
        }

    }

    Connections {

        target: loader_top // qmllint disable unqualified

        function onVideoToPos(pos : int) {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            video.seek(pos*1000)
        }
        function onImageClicked() {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            toggle()
        }

        function onStopVideoAndReset() {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            if(loader_top.videoPlaying) {
                video.pause()
                video.seek(0)
            }
        }
        function onRestartVideoIfAutoplay() {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            if(loader_top.videoPlaying) {

                if(!PQCSettings.filetypesVideoAutoplay && !PQCConstants.slideshowRunning) {
                    video.pause()
                } else
                    video.seek(0)

            } else {
                video.seek(0)
                video.pause()
                if(PQCSettings.filetypesVideoAutoplay || PQCConstants.slideshowRunning)
                    video.play()
            }

        }
    }

    Connections {

        target: PQCConstants // qmllint disable unqualified

        function onSlideshowRunningChanged() {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            if(PQCConstants.slideshowRunning) {
                video.seek(0)
                video.play()
            }
        }

    }

    function toggle() {

        if(!loader_top.isMainImage) // qmllint disable unqualified
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
        loader_top.imageMirrorH = myMirrorH // qmllint disable unqualified
    onMyMirrorVChanged:
        loader_top.imageMirrorV = myMirrorV // qmllint disable unqualified

    Connections {
        target: PQCScriptsShortcuts
        function onSendShortcutMirrorHorizontal() {
            if(visible) videotop.myMirrorH = !videotop.myMirrorH
        }
        function onSendShortcutMirrorVertical() {
            if(visible) videotop.myMirrorV = !videotop.myMirrorV
        }
        function onSendShortcutMirrorReset() {
            if(!visible) return
            videotop.myMirrorH = false
            videotop.myMirrorV = false
        }
    }

    Connections {
        target: image_wrapper // qmllint disable unqualified
        function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
            videotop.setMirrorHV(mirH, mirV)
        }
    }

    function setMirrorHV(mH : bool, mV : bool) {
        videotop.myMirrorH = mH
        videotop.myMirrorV = mV
    }

    transform: [
        Rotation {
            origin.x: videotop.width / 2
            origin.y: videotop.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: videotop.myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        },
        Rotation {
            origin.x: videotop.width / 2
            origin.y: videotop.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: videotop.myMirrorV ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        }
    ]

    PQVideoControls {
        id: controls
    }

}
