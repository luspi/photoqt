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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

// The MPV object needs to be wrapped in an item
// and be as empty as shown below
// otherwise a separate mpv window will open up
Item {

    id: videotop

    /*******************************************/
    // these values are READONLY, they are set in PQImageDisplay as bindings

    property string imageSource: ""
    property bool isMainImage
    property Item loaderTop
    property bool videoLoaded

    /*******************************************/
    // these values are WRITEONLY and are picked up in PQImageDisplay

    property bool imageMirrorH: false
    property bool imageMirrorV: false
    property bool videoHasAudio
    property int status: Image.Loading

    /*******************************************/

    width: 100
    height: 100

    // avoid warning message as we listen to changes for this item in different places
    property string source: ""

    property bool videoPlaying: false

    onVideoPlayingChanged: {
        video.command(["set", "pause", (videotop.videoPlaying ? "no" : "yes")])
        if(isMainImage)
            PQCConstants.currentlyShowingVideoPlaying = videoPlaying
    }

    onVisibleChanged: {
        if(!visible) {
            videotop.videoPlaying = false
            video.command(["seek", 0, "absolute"])
        }
    }

    PQCMPVObject {

        id: video

        width: videotop.width
        height: videotop.height

    }

    Timer {
        id: starttimer
        interval: 100
        running: videotop.isMainImage
        onTriggered: {
            video.command(["loadfile", videotop.imageSource])
            if(!PQCSettings.filetypesVideoAutoplay && !PQCConstants.slideshowRunning) {
                videotop.videoPlaying = false
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
            if(!videotop.isMainImage) return
            // check whether the file has fully loaded yet
            // depending on the Qt version there will be a comma at the end of the error message string
            var tmp = video.getProperty("width")+""
            if(tmp == "QVariant(mpv::qt::ErrorReturn)" || tmp == "QVariant(mpv::qt::ErrorReturn, )") {
                getProps.restart()
                return
            }
            videotop.width = video.getProperty("width")
            videotop.height = video.getProperty("height")
            PQCConstants.currentlyShowingVideoDuration = video.getProperty("duration")
            var tracklist = video.getProperty(["track-list"])
            var countaudio = 0
            for(var i in tracklist) {
                if(tracklist[i].type === "audio")
                    countaudio += 1
            }
            videotop.videoHasAudio = (countaudio>0)
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
            videotop.status = Image.Ready
            getPosition.restart()
        }
    }

    Timer {
        id: getPosition
        interval: videotop.videoPlaying ? 250 : 500
        repeat: true
        running: false
        property bool restarting: false
        onTriggered: {
            if(!videotop.isMainImage) return
            PQCSettings.filetypesVideoVolume = video.getProperty("volume")
            videotop.videoPlaying = !video.getProperty("core-idle")
            if(video.getProperty("eof-reached")) {
                if(PQCSettings.filetypesVideoLoop && !restarting && !PQCConstants.slideshowRunning) {
                    video.command(["loadfile", videotop.imageSource])
                    restarting = true
                }
            } else {
                PQCConstants.currentlyShowingVideoPosition = video.getProperty("time-pos")
                restarting = false
            }

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

        target: PQCNotify

        function onCurrentVideoJump(seconds : int) {
            if(!videotop.isMainImage)
                return
            video.command(["seek", seconds])
        }

        function onCurrentVideoToPos(pos : int) {
            videotop.videoToPos(pos)
        }

        function onPlayPauseAnimationVideo() {

            if(!videotop.isMainImage)
                return

            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", videotop.imageSource])
                videotop.videoPlaying = true
            } else {
                videotop.videoPlaying = !videotop.videoPlaying
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

        target: loader_top

        function onStopVideoAndReset() {
            if(!videotop.isMainImage)
                return
            if(videotop.videoPlaying) {
                videotop.videoPlaying = false
                video.command(["seek", 0, "absolute"])
            }
        }
        function onRestartVideoIfAutoplay() {

            if(!videotop.isMainImage)
                return

            if(videotop.videoPlaying) {

                if(!PQCSettings.filetypesVideoAutoplay && !PQCConstants.slideshowRunning) {
                    videotop.videoPlaying = false
                } else
                    video.command(["seek", 0, "absolute"])

            } else {
                if(PQCSettings.filetypesVideoAutoplay || PQCConstants.slideshowRunning) {
                    video.command(["seek", 0, "absolute"])
                    videotop.videoPlaying = true
                }
            }

        }
    }

    Connections {

        target: PQCConstants

        function onSlideshowRunningChanged() {

            if(!videotop.isMainImage)
                return

            if(PQCConstants.slideshowRunning) {
                video.command(["seek", 0, "absolute"])
                videotop.videoPlaying = true
            }
        }

    }

    Connections {
        target: PQCSettings
        function onFiletypesVideoVolumeChanged() {
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
        }
    }

    function videoToPos(pos : int) {
        console.warn(">>> videoToPos():", pos)
        if(!videotop.isMainImage)
            return
        if(video.getProperty("eof-reached")) {
            video.command(["loadfile", videotop.imageSource])
            videotop.videoPlaying = false
            setPosTimeout.pos = pos
            setPosTimeout.restart()
        } else
            video.command(["seek", pos, "absolute"])
    }

    function videoClicked() {
        if(!videotop.isMainImage)
            return
        if(video.getProperty("eof-reached")) {
            video.command(["loadfile", videotop.imageSource])
            videotop.videoPlaying = true
        } else {
            videotop.videoPlaying = !videotop.videoPlaying
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

}
