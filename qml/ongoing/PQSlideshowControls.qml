/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import PQCNotify
import PQCScriptsOther

import "../elements"

Item {

    id: slideshowcontrols_top

    x: (toplevel.width-width)/2
    y: toplevel.height-height-50
    width: controlsrow.width
    height: 80

    property int parentWidth: 300
    property int parentHeight: 200

    state: "hidden"

    states: [
        State {
            name: "popout"
            PropertyChanges {
                target: slideshowcontrols_top
                x: 0
                y: 0
                width: slideshowcontrols_top.parentWidth
                height: slideshowcontrols_top.parentHeight
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: slideshowcontrols_top
                opacity: 0
            }
        },
        State {
            name: "foreground"
            PropertyChanges {
                target: slideshowcontrols_top
                opacity: 0.5
            }
        },
        State {
            name: "background"
            PropertyChanges {
                target: slideshowcontrols_top
                opacity: 0.1
            }
        },
        State {
            name: "mouseover"
            PropertyChanges {
                target: slideshowcontrols_top
                opacity: 0.75
            }
        }

    ]

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQCSettings.interfacePopoutSlideshowControls ? 0 : 200 } }
    visible: opacity>0
    enabled: visible

    property string mouseOverId: ""
    onMouseOverIdChanged:
        updateState()

    Timer {
        id: resetMouseOver
        interval: 100
        property string oldId
        onTriggered: {
            if(oldId === mouseOverId)
                mouseOverId = ""
        }
    }

    MouseArea {
        id: controlsbgmousearea
        anchors.fill: parent
        hoverEnabled: true
        drag.target: slideshowcontrols_top
        property string myId: "123"
        onEntered: {
            resetMouseOver.stop()
            mouseOverId = myId
        }
        onExited: {
            resetMouseOver.oldId = myId
            resetMouseOver.restart()
        }
    }

    Row {

        id: controlsrow

        x: (parent.width-width)/2

        spacing: 5

        Image {

            id: prev

            y: PQCSettings.interfacePopoutSlideshowControls ? (slideshowcontrols_top.height-height)/2 : 20
            width: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40
            height: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40

            source: "/white/slideshowprev.svg"

            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: qsTranslate("slideshow", "Click to go to the previous image")
                onClicked:
                    loader_slideshowhandler.item.loadPrevImage()
                drag.target: slideshowcontrols_top
                property string myId: "111"
                onEntered: {
                    resetMouseOver.stop()
                    mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Image {

            id: playpause

            y: PQCSettings.interfacePopoutSlideshowControls ? (slideshowcontrols_top.height-height)/2 : 20
            width: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40
            height: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40

            source: (loader_slideshowhandler.item.running ? "/white/pause.svg" : "/white/play.svg")

            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: (loader_slideshowhandler.item.running ?
                           qsTranslate("slideshow", "Click to pause slideshow") :
                           qsTranslate("slideshow", "Click to play slideshow"))
                onClicked: {
                    loader_slideshowhandler.item.toggle()
                    updateState()
                }
                drag.target: slideshowcontrols_top
                property string myId: "222"
                onEntered: {
                    resetMouseOver.stop()
                    mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Image {

            id: next

            y: PQCSettings.interfacePopoutSlideshowControls ? (slideshowcontrols_top.height-height)/2 : 20
            width: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40
            height: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40

            source: "/white/slideshownext.svg"

            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: qsTranslate("slideshow", "Click to go to the next image")
                onClicked:
                    loader_slideshowhandler.item.loadNextImage()
                drag.target: slideshowcontrols_top
                property string myId: "333"
                onEntered: {
                    resetMouseOver.stop()
                    mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Image {

            id: exit

            y: PQCSettings.interfacePopoutSlideshowControls ? (slideshowcontrols_top.height-height)/2 : 20
            width: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40
            height: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40

            source: "/white/exit.svg"
            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: qsTranslate("slideshow", "Click to exit slideshow")
                onClicked: {
                    loader_slideshowhandler.item.hide()
                }
                drag.target: slideshowcontrols_top
                property string myId: "444"
                onEntered: {
                    resetMouseOver.stop()
                    mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Item {
            width: volumeicon.visible ? 25 : 10
            height: 1
        }

        Image {

            id: volumeicon

            visible: PQCSettings.slideshowMusicFile!==""

            y: PQCSettings.interfacePopoutSlideshowControls ? (slideshowcontrols_top.height-height)/2 : 20
            width: visible ? (PQCSettings.interfacePopoutSlideshowControls ? 80 : 40) : 0
            height: PQCSettings.interfacePopoutSlideshowControls ? 80 : 40

            sourceSize: Qt.size(width, height)

            source: volumeslider.value<1 ?
                        "/white/speaker_mute.svg" :
                        (volumeslider.value <= 40 ?
                             "/white/speaker_low.svg" :
                             (volumeslider.value <= 80 ?
                                  "/white/speaker_medium.svg" :
                                  "/white/speaker_high.svg"))

        }

        PQSlider {

            id: volumeslider

            visible: PQCSettings.slideshowMusicFile!==""

            y: PQCSettings.interfacePopoutSlideshowControls ? (slideshowcontrols_top.height-height)/2 : 30
            width: visible? 200 : 0
            height: 20

            value: 80

            from: 0
            to: 100

            onHoveredChanged:
                mouseOverId = "555"

            onValueChanged: {
                loader_slideshowhandler.item.volume = value/100
            }

        }

        Item {
            width: volumeslider.visible? 20 : 0
            height: 1
        }

    }

    Image {
        x: 4
        y: 4
        width: 15
        height: 15
        source: "/white/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: PQCSettings.interfacePopoutSlideshowControls
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfacePopoutSlideshowControls ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                PQCSettings.interfacePopoutSlideshowControls = !PQCSettings.interfacePopoutSlideshowControls
                slideshowcontrols_top.hide()
                loader.show("slideshowcontrols")
            }
        }
    }

    function updateState() {

        if(PQCSettings.interfacePopoutSlideshowControls) {
            state = "popout"
            return
        }

        if(!PQCNotify.slideshowRunning) {
            state = "hidden"
            return
        }

        if(mouseOverId !== "")
            state = "mouseover"

        else if(!loader_slideshowhandler.item.running)
            state = "foreground"

        else
            state = "background"

    }

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === "slideshowcontrols")
                    show()

            } else if(what === "hide") {

                if(param === "slideshowcontrols")
                    hide()

            }

        }
    }

    Connections {

        target: PQCNotify

        function onSlideshowRunningChanged() {
            updateState()
            if(PQCNotify.slideshowRunning)
                show()
            else
                hide()
        }

    }

    Connections {

        target: loader_slideshowhandler.item

        function onRunningChanged() {
            updateState()
        }

    }

    function show() {
        opacity = 1
    }

    function hide() {
        opacity = 0
        loader.elementClosed("slideshowcontrols")
    }

    Component.onCompleted: {
        if(PQCSettings.interfacePopoutSlideshowControls)
            updateState()
        else
            removeHighlightTimeout.restart()
    }


    Timer {
        id: removeHighlightTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            updateState()
        }
    }

}

