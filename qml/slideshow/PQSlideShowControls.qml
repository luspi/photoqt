import QtQuick 2.9
import QtMultimedia 5.5
import "../elements"

Rectangle {

    id: controls_top

    color: "#aa000000"

    border.width: 1
    border.color: "#88aaaaaa"

    x: variables.metaDataWidthWhenKeptOpen-1
    y: -1
    width: toplevel.width+2-variables.metaDataWidthWhenKeptOpen
    height: 75

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: (opacity != 0)

    MouseArea {
        id: controlsbgmousearea
        anchors.fill: parent
        hoverEnabled: true
    }

    property bool running: false
    onRunningChanged: {
        if(running) {
            switcher.restart()
            hideBarAfterTimeout.restart()
            if(slideshowmusic.source != "")
                slideshowmusic.play()
        } else {
            controls_top.opacity = 1
            slideshowmusic.pause()
        }
    }

    property var shuffledIndices: []
    property int shuffledCurrentIndex: -1

    Image {

        id: prev

        x: 10
        y: 10
        width: parent.height-2*y
        height: parent.height-2*y

        source: "/slideshow/prev.png"

        PQMouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            tooltip: "Click to go to the previous image"
            onClicked: {
                switcher.restart()
                loadPrevImage()
            }
        }

    }

    Image {

        id: playpause

        x: prev.x+prev.width
        y: 10
        width: parent.height-2*y
        height: parent.height-2*y

        source: (controls_top.running ? "/slideshow/pause.png" : "/slideshow/play.png")

        PQMouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            tooltip: (controls_top.running ? "Click to pause slideshow" : "Click to play slideshow")
            onClicked:
                controls_top.running = !controls_top.running
        }

    }

    Image {

        id: next

        x: playpause.x+playpause.width
        y: 10
        width: parent.height-2*y
        height: parent.height-2*y

        source: "/slideshow/next.png"

        PQMouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            tooltip: "Click to go to the next image"
            onClicked: {
                switcher.restart()
                loadNextImage()
            }
        }

    }

    Item {

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        width: childrenRect.width
        height: childrenRect.height

        Row {

            Image {

                id: volumeicon

                width: 40
                height: 40

                source: volumeslider.value==0 ?
                            "/slideshow/speaker_mute.png" :
                            (volumeslider.value <= 40 ?
                                 "/slideshow/speaker_low.png" :
                                 (volumeslider.value <= 80 ?
                                      "/slideshow/speaker_medium.png" :
                                      "/slideshow/speaker_high.png"))

            }

            PQSlider {

                id: volumeslider

                width: 200
                height: 20

                handleToolTipPrefix: "Sound volume: "
                handleToolTipSuffix: "%"

                value: 80

                y: 10

                from: 0
                to: 100

            }

        }

    }


    Image {

        id: quit

        x: parent.width-width-15
        y: 10
        width: parent.height-2*y
        height: parent.height-2*y

        source: "/slideshow/quit.png"

        PQMouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            tooltip: "Click to quit slideshow"
            onClicked:
                quitSlideShow()
        }

    }

    // Audio element
    Audio {
        id: slideshowmusic
        volume: volumeslider.value/100.0
        onError: console.error("AUDIO ERROR:",errorString,"-",source)
        loops: Audio.Infinite
    }

    Connections {
        target: variables
        onMousePosChanged: {
            if(!variables.slideShowActive || !controls_top.running)
                return
            if(variables.mousePos.y < (PQSettings.hotEdgeWidth+5))
                controls_top.opacity = 1
            else
                controls_top.opacity = 0
        }
    }

    Connections {
        target: loader
        onSlideshowControlsPassOn: {

            if(what == "start")
                startSlideShow()

            else if(what == "quit")
                quitSlideShow()

            else if(what == "keyevent") {

                if(param[0] == Qt.Key_Space)
                    controls_top.running = !controls_top.running

                else if(param[0] == Qt.Key_Right)
                    loadNextImage()

                else if(param[0] == Qt.Key_Left)
                    loadPrevImage()

                else if(param[0] == Qt.Key_Minus) {

                    var val = 1
                    if(param[1] & Qt.AltModifier)
                        val = 5

                    volumeslider.value = Math.max(0, volumeslider.value-val)

                }else if(param[0] == Qt.Key_Plus || param[0] == Qt.Key_Equal) {

                    var val = 1
                    if(param[1] & Qt.AltModifier)
                        val = 5

                    volumeslider.value = Math.min(100, volumeslider.value+val)

                } else if(param[0] == Qt.Key_Escape || param[0] == Qt.Key_Q)
                    quitSlideShow()

            }
        }
    }

    Timer {
        id: hideBarAfterTimeout
        interval: 1000
        repeat: false
        onTriggered: {
            if(!controlsbgmousearea.containsMouse && controls_top.running)
                controls_top.opacity = 0

        }
    }

    Timer {
        id: switcher
        interval: Math.max(1000, Math.min(300*1000, PQSettings.slideShowTime*1000))
        repeat: true
        running: variables.slideShowActive&&controls_top.running
        onTriggered: loadNextImage()
    }

    function startSlideShow() {

        variables.visibleItem = "slideshowcontrols"
        variables.slideShowActive = true

        if(PQSettings.slideShowShuffle) {

            controls_top.shuffledIndices = []
            for(var k = 0; k < variables.allImageFilesInOrder.length; ++k)
                if(k !== variables.indexOfCurrentImage) {
                    controls_top.shuffledIndices.push(k)
                }
            shuffle(controls_top.shuffledIndices)
            controls_top.shuffledIndices.push(variables.indexOfCurrentImage)
            controls_top.shuffledCurrentIndex = -1

        }

        controls_top.running = true

        controls_top.opacity = 1
        hideBarAfterTimeout.start()

        if(PQSettings.slideShowMusicFile != "") {
            slideshowmusic.source = "file://" + PQSettings.slideShowMusicFile
            slideshowmusic.play()
        } else
            slideshowmusic.source = ""

    }

    function quitSlideShow() {

        slideshowmusic.stop()

        variables.visibleItem = ""
        variables.slideShowActive = false
        controls_top.opacity = 0

    }

    function loadNextImage() {

        console.log("loadNextImage", PQSettings.slideShowShuffle)

        if(!PQSettings.slideShowShuffle) {
            if(variables.indexOfCurrentImage < variables.allImageFilesInOrder.length-1)
                ++variables.indexOfCurrentImage
            else if(PQSettings.slideShowLoop)
                variables.indexOfCurrentImage = 0
            else
                quitSlideShow()
        } else {
            if(controls_top.shuffledCurrentIndex < controls_top.shuffledIndices.length-1) {
                ++controls_top.shuffledCurrentIndex
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            } else if(PQSettings.slideShowLoop) {
                controls_top.shuffledCurrentIndex = 0
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            } else
                quitSlideShow()

        }

    }

    function loadPrevImage() {

        if(!PQSettings.slideShowShuffle) {
            if(variables.indexOfCurrentImage > 0)
                --variables.indexOfCurrentImage
            else if(PQSettings.slideShowLoop)
                variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
        } else {
            if(controls_top.shuffledCurrentIndex > 0) {
                --controls_top.shuffledCurrentIndex
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            } else if(PQSettings.slideShowLoop) {
                controls_top.shuffledCurrentIndex = controls_top.shuffledIndices.length-1
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            }
        }

    }

    /***************************************/
        // The Fisher–Yates shuffle algorithm
        // Code found at http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript
        // (adapted from http://bost.ocks.org/mike/shuffle/)
        function shuffle(array) {
            var counter = array.length, temp, index;

            // While there are elements in the array
            while (counter > 0) {
                // Pick a random index
                index = Math.floor(Math.random() * counter);

                // Decrease counter by 1
                counter--;

                // And swap the last element with it
                temp = array[counter];
                array[counter] = array[index];
                array[index] = temp;
            }

            return array;
        }

}
