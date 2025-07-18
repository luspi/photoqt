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
import PQCMPVObject
import PhotoQt

// The MPV object needs to be wrapped in an item
// and be as empty as shown below
// otherwise a separate mpv window will open up
Item {

    id: videotop

    property string imageSource: ""

    width: 100
    height: 100

    // avoid warning message as we listen to changes for this item in different places
    property string source: ""

    onVisibleChanged: {
        if(!visible) {
            loader_top.videoPlaying = false // qmllint disable unqualified
            video.command(["seek", 0, "absolute"])
        } else {
            loader_top.videoLoaded = true
            loader_top.videoHasAudio = true
            loader_top.videoHasAudioChanged()
        }
    }

    PQCMPVObject { // qmllint disable

        id: video

        width: videotop.width // qmllint disable missing-property
        height: videotop.height // qmllint disable missing-property

    }

    Timer {
        id: starttimer
        interval: 100
        running: true
        onTriggered: {
            video.command(["loadfile", videotop.imageSource])
            if(!PQCSettings.filetypesVideoAutoplay && !PQCConstants.slideshowRunning) {
                loader_top.videoPlaying = false
                video.command(["set", "pause", "yes"])
            }
            getProps.restart()
        }
    }

    Timer {
        id: getProps
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            // check whether the file has fully loaded yet
            // depending on the Qt version there will be a comma at the end of the error message string
            var tmp = video.getProperty("width")+""
            if(tmp == "QVariant(mpv::qt::ErrorReturn)" || tmp == "QVariant(mpv::qt::ErrorReturn, )") {
                getProps.restart()
                return
            }
            videotop.width = video.getProperty("width")
            videotop.height = video.getProperty("height")
            loader_top.videoDuration = video.getProperty("duration")
            var tracklist = video.getProperty(["track-list"])
            var countaudio = 0
            for(var i in tracklist) {
                if(tracklist[i].type === "audio")
                    countaudio += 1
            }
            loader_top.videoHasAudio = (countaudio>0)
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
            image_wrapper.status = Image.Ready
            getPosition.restart()
        }
    }

    Timer {
        id: getPosition
        interval: loader_top.videoPlaying ? 250 : 500 // qmllint disable unqualified
        repeat: true
        running: false
        property bool restarting: false
        onTriggered: {
            PQCSettings.filetypesVideoVolume = video.getProperty("volume") // qmllint disable unqualified
            loader_top.videoPlaying = !video.getProperty("core-idle")
            if(video.getProperty("eof-reached")) {
                if(PQCSettings.filetypesVideoLoop && !restarting && !PQCConstants.slideshowRunning) {
                    video.command(["loadfile", videotop.imageSource])
                    restarting = true
                }
            } else {
                loader_top.videoPosition = video.getProperty("time-pos")
                restarting = false
            }

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

        target: PQCNotifyQML

        function onCurrentVideoJump(seconds : int) {
            if(!loader_top.isMainImage) // qmllint disable unqualified
                return
            video.command(["seek", seconds])
        }

        function onPlayPauseAnimationVideo() {

            if(!loader_top.isMainImage)
                return

            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", videotop.imageSource])
                loader_top.videoPlaying = true
            } else {
                loader_top.videoPlaying = !loader_top.videoPlaying
            }

        }

    }

    Connections {
        target: loader_top // qmllint disable unqualified

        function onVideoPlayingChanged() {
            video.command(["set", "pause", (loader_top.videoPlaying ? "no" : "yes")])
        }

        function onVideoToPos(pos : int) {
            if(!loader_top.isMainImage) // qmllint disable unqualified
                return
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", videotop.imageSource])
                loader_top.videoPlaying = false
                setPosTimeout.pos = pos
                setPosTimeout.restart()
            } else
                video.command(["seek", pos, "absolute"])
        }
        function onImageClicked() {
            if(!loader_top.isMainImage) // qmllint disable unqualified
                return
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", videotop.imageSource])
                loader_top.videoPlaying = true
            } else {
                loader_top.videoPlaying = !loader_top.videoPlaying
            }
        }
    }

    Timer {
        id: setPosTimeout
        interval: 500
        property int pos
        onTriggered:
            video.command(["seek", pos, "absolute"])
    }

    Connections {

        target: loader_top // qmllint disable unqualified

        function onStopVideoAndReset() {
            if(!loader_top.isMainImage) // qmllint disable unqualified
                return
            if(loader_top.videoPlaying) {
                loader_top.videoPlaying = false
                video.command(["seek", 0, "absolute"])
            }
        }
        function onRestartVideoIfAutoplay() {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            if(loader_top.videoPlaying) {

                if(!PQCSettings.filetypesVideoAutoplay && !PQCConstants.slideshowRunning) {
                    loader_top.videoPlaying = false
                } else
                    video.command(["seek", 0, "absolute"])

            } else {
                if(PQCSettings.filetypesVideoAutoplay || PQCConstants.slideshowRunning) {
                    video.command(["seek", 0, "absolute"])
                    loader_top.videoPlaying = true
                }
            }

        }
    }

    Connections {

        target: PQCConstants // qmllint disable unqualified

        function onSlideshowRunningChanged() {

            if(!loader_top.isMainImage) // qmllint disable unqualified
                return

            if(PQCConstants.slideshowRunning) {
                video.command(["seek", 0, "absolute"])
                loader_top.videoPlaying = true
            }
        }

    }

    Connections {
        target: PQCSettings // qmllint disable unqualified
        function onFiletypesVideoVolumeChanged() {
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
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
