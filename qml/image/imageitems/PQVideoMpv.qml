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

import PQCNotify
import PQCScriptsFilesPaths
import PQCMPVObject

// The MPV object needs to be wrapped in an item
// and be as empty as shown below
// otherwise a separate mpv window will open up
Item {

   id: videotop

    width: 100
    height: 100

    // avoid warning message as we listen to changes for this item in different places
    property string source: ""

    onWidthChanged: {
        image_wrapper.width = width
        loader_top.imageResolution.width = width
    }
    onHeightChanged: {
        loader_top.imageResolution.height = height
        image_wrapper.height = height
    }

    onVisibleChanged: {
        if(!visible && loader_top.videoPlaying) {
            loader_top.videoPlaying = false
            video.command(["cycle", "pause"])
        }
    }

    PQCMPVObject {

        id: video

        width: parent.width
        height: parent.height

    }

    Timer {
        interval: 100
        running: true
        onTriggered: {
            video.command(["loadfile", loader_top.imageSource])
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
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
            image_wrapper.status = Image.Ready
            getPosition.restart()
        }
    }

    Timer {
        id: getPosition
        interval: loader_top.videoPlaying ? 250 : 500
        repeat: true
        running: false
        property bool restarting: false
        onTriggered: {
            PQCSettings.filetypesVideoVolume = video.getProperty("volume")
            loader_top.videoPlaying = !video.getProperty("core-idle")
            if(video.getProperty("eof-reached")) {
                if(PQCSettings.filetypesVideoLoop && !restarting) {
                    video.command(["loadfile", loader_top.imageSource])
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
        function onVideoJump(seconds) {
            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return
            video.command(["seek", seconds])
        }
    }

    Connections {
        target: loader_top
        function onVideoTogglePlay() {
            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", loader_top.imageSource])
                loader_top.videoPlaying = true
            } else {
                loader_top.videoPlaying = !loader_top.videoPlaying
                video.command(["cycle", "pause"])
            }
        }
        function onVideoToPos(pos) {
            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", loader_top.imageSource])
                video.command(["cycle", "pause"])
                loader_top.videoPlaying = false
                setPosTimeout.pos = pos
                setPosTimeout.restart()
            } else
                video.command(["seek", pos, "absolute"])
        }
        function onImageClicked() {
            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", loader_top.imageSource])
                loader_top.videoPlaying = true
            } else {
                loader_top.videoPlaying = !loader_top.videoPlaying
                video.command(["cycle", "pause"])
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
            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return
            if(loader_top.videoPlaying) {
                loader_top.videoPlaying = false
                video.command(["cycle", "pause"])
                video.command(["seek", 0, "absolute"])
            }
        }
        function onRestartVideoIfAutoplay() {

            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return

            if(loader_top.videoPlaying) {

                if(!PQCSettings.filetypesVideoAutoplay) {
                    loader_top.videoPlaying = false
                    video.command(["cycle", "pause"])
                } else
                    video.command(["seek", 0, "absolute"])

            } else {
                if(PQCSettings.filetypesVideoAutoplay) {
                    video.command(["seek", 0, "absolute"])
                    loader_top.videoPlaying = true
                    video.command(["cycle", "pause"])
                }
            }

        }
    }

    Connections {

        target: PQCNotify

        function onSlideshowRunningChanged() {

            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return

            if(PQCNotify.slideshowRunning) {
                video.command(["seek", 0, "absolute"])
                if(!loader_top.videoPlaying) {
                    loader_top.videoPlaying = true
                    video.command(["cycle", "pause"])
                }
            }
        }

    }

    Connections {
        target: PQCSettings
        function onFiletypesVideoVolumeChanged() {
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
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

}
