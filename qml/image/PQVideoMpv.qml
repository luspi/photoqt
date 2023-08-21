import QtQuick
import QtMultimedia

import PQCScriptsFilesPaths
import PQCMPVObject

// The MPV object needs to be wrapped in an item
// and be as empty as shown below
// otherwise a separate mpv window will open up
Item {

   id: videotop

    width: 100
    height: 100

    onWidthChanged: {
        image_wrapper.width = width
        deleg.imageResolution.width = width
    }
    onHeightChanged: {
        deleg.imageResolution.height = height
        image_wrapper.height = height
    }

    onVisibleChanged: {
        if(!visible && video.playing) {
            loader_component.videoPlaying = false
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
            video.command(["loadfile", deleg.imageSource])
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
            loader_component.videoDuration = video.getProperty("duration")
            video.setProperty("volume", PQCSettings.filetypesVideoVolume)
            image_wrapper.status = Image.Ready
            getPosition.restart()
        }
    }

    Timer {
        id: getPosition
        interval: loader_component.videoPlaying ? 250 : 500
        repeat: true
        running: false
        property bool restarting: false
        onTriggered: {
            PQCSettings.filetypesVideoVolume = video.getProperty("volume")
            loader_component.videoPlaying = !video.getProperty("core-idle")
            if(video.getProperty("eof-reached")) {
                if(PQCSettings.filetypesVideoLoop && !restarting) {
                    video.command(["loadfile", deleg.imageSource])
                    restarting = true
                }
            } else {
                loader_component.videoPosition = video.getProperty("time-pos")
                restarting = false
            }

        }
    }

    Connections {
        target: image_top
        function onMirrorH() {
            video.command(["vf", "toggle", "hflip"])
        }
        function onMirrorV() {
            video.command(["vf", "toggle", "vflip"])
        }
    }

    Connections {
        target: loader_component
        function onVideoTogglePlay() {
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", deleg.imageSource])
                loader_component.videoPlaying = true
            } else {
                loader_component.videoPlaying = !loader_component.videoPlaying
                video.command(["cycle", "pause"])
            }
        }
        function onVideoToPos(pos) {
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", deleg.imageSource])
                video.command(["cycle", "pause"])
                loader_component.videoPlaying = false
                setPosTimeout.pos = pos
                setPosTimeout.restart()
            } else
                video.command(["seek", pos, "absolute"])
        }
        function onImageClicked() {
            if(video.getProperty("eof-reached")) {
                video.command(["loadfile", deleg.imageSource])
                loader_component.videoPlaying = true
            } else {
                loader_component.videoPlaying = !loader_component.videoPlaying
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
        target: deleg
        function onStopVideoAndReset() {
            if(loader_component.videoPlaying) {
                loader_component.videoPlaying = false
                video.command(["cycle", "pause"])
                video.command(["seek", 0, "absolute"])
            }
        }
        function onRestartVideoIfAutoplay() {

            if(loader_component.videoPlaying) {

                if(!PQCSettings.filetypesVideoAutoplay) {
                    loader_component.videoPlaying = false
                    video.command(["cycle", "pause"])
                } else
                    video.command(["seek", 0, "absolute"])

            } else {
                if(PQCSettings.filetypesVideoAutoplay) {
                    video.command(["seek", 0, "absolute"])
                    loader_component.videoPlaying = true
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

}
