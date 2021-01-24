/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.9
import QtMultimedia 5.5
import "../elements"

Rectangle {

    id: controls_top

    color: "#aa000000"

    border.width: 1
    border.color: "#88aaaaaa"

    x: PQSettings.slideShowControlsPopoutElement ? 0 : (variables.metaDataWidthWhenKeptOpen-1)
    y: PQSettings.slideShowControlsPopoutElement ? 0 : -1
    width: PQSettings.slideShowControlsPopoutElement ? parentWidth : (parentWidth+2-variables.metaDataWidthWhenKeptOpen)
    height: PQSettings.slideShowControlsPopoutElement ? parentHeight : 75

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: PQSettings.slideShowControlsPopoutElement ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: (opacity != 0)
    enabled: visible

    property string backupAnimType: ""
    property var backupAllImagesInFolder: []

    MouseArea {
        id: controlsbgmousearea
        anchors.fill: parent
        hoverEnabled: true
    }

    property bool running: false
    onRunningChanged: {
        if(running) {
            imageitem.playAnim()
            switcher.restart()
            hideBarAfterTimeout.restart()
            if(slideshowmusic.source != "")
                slideshowmusic.play()
        } else {
            imageitem.pauseAnim()
            controls_top.opacity = 1
            slideshowmusic.pause()
        }
    }

    property var shuffledIndices: []
    property int shuffledCurrentIndex: -1

    Item {

        id: playplausenextprev

        x: PQSettings.slideShowControlsPopoutElement ? (parent.width-width)/2 : 10
        y: PQSettings.slideShowControlsPopoutElement ? 20 : 0

        width: childrenRect.width
        height: childrenRect.height

        Row {

            Image {

                id: prev

                y: 20
                width: PQSettings.slideShowControlsPopoutElement ? 80 : controls_top.height-2*y
                height: PQSettings.slideShowControlsPopoutElement ? 80 : controls_top.height-2*y

                source: "/slideshow/prev.png"

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: em.pty+qsTranslate("slideshow", "Click to go to the previous image")
                    onClicked: {
                        switcher.restart()
                        loadPrevImage()
                    }
                }

            }

            Image {

                id: playpause

                y: 10
                width: PQSettings.slideShowControlsPopoutElement ? 120 : controls_top.height-2*y
                height: PQSettings.slideShowControlsPopoutElement ? 120 : controls_top.height-2*y

                source: (controls_top.running ? "/slideshow/pause.png" : "/slideshow/play.png")

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: (controls_top.running ?
                                  em.pty+qsTranslate("slideshow", "Click to pause slideshow") :
                                  em.pty+qsTranslate("slideshow", "Click to play slideshow"))
                    onClicked:
                        controls_top.running = !controls_top.running
                }

            }

            Image {

                id: next

                y: 20
                width: PQSettings.slideShowControlsPopoutElement ? 80 : controls_top.height-2*y
                height: PQSettings.slideShowControlsPopoutElement ? 80 : controls_top.height-2*y

                source: "/slideshow/next.png"

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: em.pty+qsTranslate("slideshow", "Click to go to the next image")
                    onClicked: {
                        switcher.restart()
                        loadNextImage()
                    }
                }

            }

        }

    }

    Item {

        id: volumecont

        visible: slideshowmusic.source!=""

        x: (parent.width-width)/2
        y: PQSettings.slideShowControlsPopoutElement ? (playplausenextprev.y+playplausenextprev.height+50) : ((parent.height-height)/2)

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

                toolTipPrefix: em.pty+qsTranslate("slideshow", "Sound volume:") + " "
                toolTipSuffix: "%"

                value: 80

                y: 10

                from: 0
                to: 100

            }

        }

    }


    Image {

        id: quit

        x: PQSettings.slideShowControlsPopoutElement ? (parent.width-width)/2 : (parent.width-width-15)
        y: PQSettings.slideShowControlsPopoutElement ? (volumecont.visible ? (volumecont.y+volumecont.height+50) : (playplausenextprev.y+playplausenextprev.height+50)) : 10
        width: PQSettings.slideShowControlsPopoutElement ? 75 : (parent.height-2*y)
        height: PQSettings.slideShowControlsPopoutElement ? 75 : (parent.height-2*y)

        source: "/slideshow/quit.png"

        PQMouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            tooltip: em.pty+qsTranslate("slideshow", "Click to quit slideshow")
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
            if(!variables.slideShowActive || !controls_top.running || PQSettings.slideShowControlsPopoutElement)
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

                if(param[0] == Qt.Key_Space || param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    controls_top.running = !controls_top.running

                else if(param[0] == Qt.Key_Right) {

                    loadNextImage()
                    if(controls_top.running)
                        switcher.restart()

                } else if(param[0] == Qt.Key_Left) {

                    loadPrevImage()
                    if(controls_top.running)
                        switcher.restart()

                } else if(param[0] == Qt.Key_Minus) {

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

    // The below shortcuts are needed for the popout version only

    Shortcut {
        sequences: ["Esc", "q"]
        enabled: PQSettings.slideShowControlsPopoutElement
        onActivated: quitSlideShow()
    }

    Shortcut {
        sequences: ["Enter", "Return", "Space"]
        enabled: PQSettings.slideShowControlsPopoutElement
        onActivated: controls_top.running = !controls_top.running
    }

    Shortcut {
        sequence: "Right"
        enabled: PQSettings.slideShowControlsPopoutElement
        onActivated: {
            loadNextImage()
            if(controls_top.running)
                switcher.restart()
        }
    }

    Shortcut {
        sequence: "Left"
        enabled: PQSettings.slideShowControlsPopoutElement
        onActivated: {
            loadPrevImage()
            if(controls_top.running)
                switcher.restart()
        }
    }

    Shortcut {
        sequence: "-"
        enabled: PQSettings.slideShowControlsPopoutElement
        onActivated:
            volumeslider.value = Math.max(0, volumeslider.value-1)
    }

    Shortcut {
        sequences: ["+", "="]
        enabled: PQSettings.slideShowControlsPopoutElement
        onActivated:
            volumeslider.value = Math.min(100, volumeslider.value+1)
    }

    Timer {
        id: hideBarAfterTimeout
        interval: 1000
        repeat: false
        onTriggered: {
            if(!controlsbgmousearea.containsMouse && controls_top.running && !PQSettings.slideShowControlsPopoutElement)
                controls_top.opacity = 0

        }
    }

    Timer {
        id: switcher
        interval: imageitem.getCurrentVideoLength()==-1 ? Math.max(1000, Math.min(300*1000, PQSettings.slideShowTime*1000)) : imageitem.getCurrentVideoLength()
        repeat: true
        running: variables.slideShowActive&&controls_top.running
        onTriggered: loadNextImage()
    }

    Component.onDestruction: {
        if(variables.slideShowActive = true)
            quitSlideShow()
    }

    function startSlideShow() {

        variables.visibleItem = "slideshowcontrols"
        variables.slideShowActive = true

        imageitem.zoomReset()
        imageitem.rotateReset()

        backupAnimType = PQSettings.animationType
        PQSettings.animationType = PQSettings.slideShowTypeAnimation

        var sortby = 1
        if(PQSettings.sortby == "name")
            sortby = 0
        else if(PQSettings.sortby == "time")
            sortby = 2
        else if(PQSettings.sortby == "size")
            sortby = 3
        else if(PQSettings.sortby == "type")
            sortby = 4

        if(PQSettings.slideShowIncludeSubFolders) {
            backupAllImagesInFolder = variables.allImageFilesInOrder
            var sub = filefoldermodel.loadFilesInSubFolders(variables.allImageFilesInOrder[variables.indexOfCurrentImage],
                                                            PQSettings.openShowHiddenFilesFolders,
                                                            [], [],
                                                            sortby, !PQSettings.sortbyAscending)
            variables.allImageFilesInOrder = variables.allImageFilesInOrder.concat(sub)
        }

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
        imageitem.restartAnim()

        controls_top.opacity = 1
        if(PQSettings.slideShowControlsPopoutElement)
            slideshowcontrols_window.visible = true

        hideBarAfterTimeout.start()

        if(PQSettings.slideShowMusicFile != "") {
            slideshowmusic.source = "file://" + PQSettings.slideShowMusicFile
            slideshowmusic.play()
        } else
            slideshowmusic.source = ""

    }

    function quitSlideShow() {

        slideshowmusic.stop()

        PQSettings.animationType = backupAnimType

        if(PQSettings.slideShowIncludeSubFolders) {
            variables.allImageFilesInOrder = backupAllImagesInFolder
            if(variables.indexOfCurrentImage >= variables.allImageFilesInOrder.length) {
                variables.indexOfCurrentImage = 0
                variables.newFileLoaded()
            }
        }

        variables.visibleItem = ""
        variables.slideShowActive = false
        if(PQSettings.slideShowControlsPopoutElement)
            slideshowcontrols_window.visible = false
        else
            controls_top.opacity = 0

    }

    function loadNextImage() {

        if(!PQSettings.slideShowShuffle) {
            if(variables.indexOfCurrentImage < variables.allImageFilesInOrder.length-1) {
                ++variables.indexOfCurrentImage
                variables.newFileLoaded()
            } else if(PQSettings.slideShowLoop) {
                variables.indexOfCurrentImage = 0
                variables.newFileLoaded()
            } else
                quitSlideShow()
        } else {
            if(controls_top.shuffledCurrentIndex < controls_top.shuffledIndices.length-1) {
                ++controls_top.shuffledCurrentIndex
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
                variables.newFileLoaded()
            } else if(PQSettings.slideShowLoop) {
                controls_top.shuffledCurrentIndex = 0
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
                variables.newFileLoaded()
            } else
                quitSlideShow()

        }

    }

    function loadPrevImage() {

        if(!PQSettings.slideShowShuffle) {
            if(variables.indexOfCurrentImage > 0) {
                --variables.indexOfCurrentImage
                variables.newFileLoaded()
            } else if(PQSettings.slideShowLoop) {
                variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
                variables.newFileLoaded()
            }
        } else {
            if(controls_top.shuffledCurrentIndex > 0) {
                --controls_top.shuffledCurrentIndex
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
                variables.newFileLoaded()
            } else if(PQSettings.slideShowLoop) {
                controls_top.shuffledCurrentIndex = controls_top.shuffledIndices.length-1
                variables.indexOfCurrentImage = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
                variables.newFileLoaded()
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
