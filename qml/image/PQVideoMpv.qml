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

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onVisibleChanged: {
        if(!visible && video.playing) {
            video.playing = false
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
            if(!PQCSettings.filetypesVideoAutoplay) {
                video.playing = false
                video.command(["cycle", "pause"])
            }
            videotop.width = video.getProperty("width")
            videotop.height = video.getProperty("height")
            image_wrapper.status = Image.Ready

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

}
