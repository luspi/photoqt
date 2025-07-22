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

    /*******************************************/
    // these values are READONLY, they are set in PQImageDisplay as bindings

    property string imageSource: ""
    property bool isMainImage
    property bool videoLoaded
    property Item loaderTop

    /*******************************************/
    // these values are WRITEONLY and are picked up in PQImageDisplay

    property bool imageMirrorH: false
    property bool imageMirrorV: false
    property bool videoHasAudio: video.hasAudio

    /*******************************************/

    width: video.width
    height: video.height

    // avoid warning message as we listen to changes for this item in different places
    property string source: ""

    property int status: Image.Loading

    Video {

        id: video

        source: "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.imageSource)

        volume: PQCConstants.slideshowRunning ? PQCConstants.slideshowVolume : PQCSettings.filetypesVideoVolume/100

        width: PQCSettings.imageviewFitInWindow ? videotop.loaderTop.width : undefined
        height: PQCSettings.imageviewFitInWindow ? videotop.loaderTop.height : undefined

        fillMode: VideoOutput.PreserveAspectFit

        onPositionChanged: {
            if(position >= duration-100) {
                if(PQCSettings.filetypesVideoLoop && !PQCConstants.slideshowRunning)
                    video.seek(0)
                else
                    video.pause()
            }
        }

        onPlaybackStateChanged: {
            if(playbackState === MediaPlayer.StoppedState) {

                video.source = "file:" + PQCScriptsFilesPaths.toPercentEncoding(videotop.imageSource)

                if(PQCSettings.filetypesVideoLoop && !PQCConstants.slideshowRunning) {
                    video.play()
                } else {
                    video.pause()
                    video.seek(video.duration-100)
                }
            }

            if(videotop.isMainImage)
                PQCConstants.currentlyShowingVideoPlaying = (video.playbackState===MediaPlayer.PlayingState)

        }

    }

    onVisibleChanged: {
        if(!visible) {
            video.pause()
            video.seek(0)
        }
    }

    Component.onCompleted: {
        videotop.status = Image.Ready
    }

    Connections {

        target: PQCNotify

        function onCurrentVideoJump(seconds : int) {

            if(!videotop.isMainImage)
                return

            if(video.seekable)
                video.seek(video.position + seconds*1000)
        }

        function onPlayPauseAnimationVideo() {

            if(!videotop.isMainImage)
                return

            videotop.toggle()
        }

    }

    function videoToPos(pos : int) {

        if(!videotop.isMainImage)
            return

        video.seek(pos*1000)
    }
    function videoClicked() {

        if(!videotop.isMainImage)
            return

        videotop.toggle()
    }

    function stopVideoAndReset() {

        if(!videotop.isMainImage)
            return

        if(video.playbackState === MediaPlayer.PlayingState) {
            video.pause()
            video.seek(0)
        }
    }
    function restartVideoIfAutoplay() {

        if(!videotop.isMainImage)
            return

        if(video.playbackState === MediaPlayer.PlayingState) {

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

    Connections {

        target: PQCConstants

        function onSlideshowRunningChanged() {

            if(!videotop.isMainImage)
                return

            if(PQCConstants.slideshowRunning) {
                video.seek(0)
                video.play()
            }
        }

    }

    function toggle() {

        if(!videotop.isMainImage)
            return

        if(video.playbackState === MediaPlayer.PlayingState)
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
        videotop.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        videotop.imageMirrorV = myMirrorV

    Connections {
        target: PQCScriptsShortcuts
        function onSendShortcutMirrorHorizontal() {
            if(videotop.visible) videotop.myMirrorH = !videotop.myMirrorH
        }
        function onSendShortcutMirrorVertical() {
            if(videotop.visible) videotop.myMirrorV = !videotop.myMirrorV
        }
        function onSendShortcutMirrorReset() {
            if(!videotop.visible) return
            videotop.myMirrorH = false
            videotop.myMirrorV = false
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
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: videotop.width / 2
            origin.y: videotop.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: videotop.myMirrorV ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

    PQVideoControls {

        id: controls

        loaderTop: videotop.loaderTop
        videoLoaded: videotop.videoLoaded
        videoPlaying: video.playbackState===MediaPlayer.PlayingState
        videoPosition: video.position/1000
        videoDuration: video.duration/1000
        videoHasAudio: videotop.videoHasAudio

        onVideoToPos: (pos) => {
            videotop.videoToPos(pos)
        }

    }

}
