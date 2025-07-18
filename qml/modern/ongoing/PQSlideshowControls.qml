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
import PhotoQt

Item {

    id: slideshowcontrols_top

    x: (PQCConstants.windowWidth-width)/2  // qmllint disable unqualified
    y: PQCConstants.windowHeight-height-50 // qmllint disable unqualified
    width: controlsrow.width
    height: 80

    property int parentWidth: 300
    property int parentHeight: 200

    property bool isPopout: PQCSettings.interfacePopoutSlideshowControls||PQCWindowGeometry.slideshowcontrolsForcePopout // qmllint disable unqualified

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    state: "hidden"

    states: [
        State {
            name: "popout"
            PropertyChanges {
                slideshowcontrols_top.x: 0
                slideshowcontrols_top.y: 0
                slideshowcontrols_top.width: slideshowcontrols_top.parentWidth
                slideshowcontrols_top.height: slideshowcontrols_top.parentHeight
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                slideshowcontrols_top.opacity: 0
            }
        },
        State {
            name: "foreground"
            PropertyChanges {
                slideshowcontrols_top.opacity: 0.5
            }
        },
        State {
            name: "background"
            PropertyChanges {
                slideshowcontrols_top.opacity: 0.1
            }
        },
        State {
            name: "mouseover"
            PropertyChanges {
                slideshowcontrols_top.opacity: 0.75
            }
        }

    ]

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: slideshowcontrols_top.isPopout ? 0 : 200 } }
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
            if(oldId === slideshowcontrols_top.mouseOverId)
                slideshowcontrols_top.mouseOverId = ""
        }
    }

    MouseArea {
        id: controlsbgmousearea
        anchors.fill: parent
        hoverEnabled: true
        drag.target: slideshowcontrols_top.isPopout ? undefined : slideshowcontrols_top
        property string myId: "123"
        onEntered: {
            resetMouseOver.stop()
            slideshowcontrols_top.mouseOverId = myId
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

            y: slideshowcontrols_top.isPopout ? (slideshowcontrols_top.height-height)/2 : 20
            width: slideshowcontrols_top.isPopout ? 80 : 40
            height: slideshowcontrols_top.isPopout ? 80 : 40

            source: "image://svg/:/" + PQCLook.iconShade + "/slideshowprev.svg" // qmllint disable unqualified

            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: qsTranslate("slideshow", "Click to go to the previous image")
                onClicked:
                    PQCNotifyQML.slideshowPrevImage(true) // qmllint disable unqualified
                drag.target: slideshowcontrols_top.isPopout ? undefined : slideshowcontrols_top
                property string myId: "111"
                onEntered: {
                    resetMouseOver.stop()
                    slideshowcontrols_top.mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Image {

            id: playpause

            y: slideshowcontrols_top.isPopout ? (slideshowcontrols_top.height-height)/2 : 20
            width: slideshowcontrols_top.isPopout ? 80 : 40
            height: slideshowcontrols_top.isPopout ? 80 : 40

            source: (PQCConstants.slideshowRunningAndPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")) // qmllint disable unqualified

            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: (PQCConstants.slideshowRunningAndPlaying ? // qmllint disable unqualified
                           qsTranslate("slideshow", "Click to pause slideshow") :
                           qsTranslate("slideshow", "Click to play slideshow"))
                onClicked: {
                    PQCNotifyQML.slideshowToggle()
                    slideshowcontrols_top.updateState()
                }
                drag.target: slideshowcontrols_top.isPopout ? undefined : slideshowcontrols_top
                property string myId: "222"
                onEntered: {
                    resetMouseOver.stop()
                    slideshowcontrols_top.mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Image {

            id: next

            y: slideshowcontrols_top.isPopout ? (slideshowcontrols_top.height-height)/2 : 20
            width: slideshowcontrols_top.isPopout ? 80 : 40
            height: slideshowcontrols_top.isPopout ? 80 : 40

            source: "image://svg/:/" + PQCLook.iconShade + "/slideshownext.svg" // qmllint disable unqualified

            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: qsTranslate("slideshow", "Click to go to the next image")
                onClicked:
                    PQCNotifyQML.slideshowNextImage(true)
                drag.target: slideshowcontrols_top.isPopout ? undefined : slideshowcontrols_top
                property string myId: "333"
                onEntered: {
                    resetMouseOver.stop()
                    slideshowcontrols_top.mouseOverId = myId
                }
                onExited: {
                    resetMouseOver.oldId = myId
                    resetMouseOver.restart()
                }
            }

        }

        Image {

            id: exit

            y: slideshowcontrols_top.isPopout ? (slideshowcontrols_top.height-height)/2 : 20
            width: slideshowcontrols_top.isPopout ? 80 : 40
            height: slideshowcontrols_top.isPopout ? 80 : 40

            source: "image://svg/:/" + PQCLook.iconShade + "/exit.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                text: qsTranslate("slideshow", "Click to exit slideshow")
                onClicked: {
                    PQCNotifyQML.slideshowHideHandler()
                }
                drag.target: slideshowcontrols_top.isPopout ? undefined : slideshowcontrols_top
                property string myId: "444"
                onEntered: {
                    resetMouseOver.stop()
                    slideshowcontrols_top.mouseOverId = myId
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

            visible: PQCSettings.slideshowMusic || (PQCConstants.currentlyShowingVideo&&PQCConstants.currentlyShowingVideoHasAudio)

            y: slideshowcontrols_top.isPopout ? (slideshowcontrols_top.height-height)/2 : 20
            width: visible ? (slideshowcontrols_top.isPopout ? 80 : 40) : 0
            height: slideshowcontrols_top.isPopout ? 80 : 40

            sourceSize: Qt.size(width, height)

            source: volumeslider.value<1 ?
                        ("image://svg/:/" + PQCLook.iconShade + "/volume_mute.svg") : // qmllint disable unqualified
                        (volumeslider.value <= 40 ?
                             ("image://svg/:/" + PQCLook.iconShade + "/volume_low.svg") :
                             (volumeslider.value <= 80 ?
                                  ("image://svg/:/" + PQCLook.iconShade + "/volume_medium.svg") :
                                  ("image://svg/:/" + PQCLook.iconShade + "/volume_high.svg")))

        }

        PQSlider {

            id: volumeslider

            visible: PQCSettings.slideshowMusic || (PQCConstants.currentlyShowingVideo&&PQCConstants.currentlyShowingVideoHasAudio)

            y: slideshowcontrols_top.isPopout ? (slideshowcontrols_top.height-height)/2 : 30
            width: visible? 200 : 0
            height: 20

            value: 80

            from: 0
            to: 100

            onHoveredChanged:
                slideshowcontrols_top.mouseOverId = "555"

            onValueChanged: {
                PQCConstants.slideshowVolume = value/100 // qmllint disable unqualified
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
        visible: PQCSettings.interfacePopoutSlideshowControls && !PQCWindowGeometry.slideshowcontrolsForcePopout // qmllint disable unqualified
        enabled: visible
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg" // qmllint disable unqualified
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfacePopoutSlideshowControls ? // qmllint disable unqualified
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                PQCSettings.interfacePopoutSlideshowControls = !PQCSettings.interfacePopoutSlideshowControls // qmllint disable unqualified
                slideshowcontrols_top.hide()
                PQCNotifyQML.loaderRegisterClose("slideshowcontrols")
            }
        }
    }

    function updateState() {

        if(isPopout) {
            state = "popout"
            return
        }

        if(!PQCConstants.slideshowRunning) { // qmllint disable unqualified
            state = "hidden"
            return
        }

        if(mouseOverId !== "")
            state = "mouseover"

        else if(!PQCConstants.slideshowRunningAndPlaying)
            state = "foreground"

        else
            state = "background"

    }

    Connections {

        target: PQCNotifyQML

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === "slideshowcontrols")
                    slideshowcontrols_top.show()

            } else if(what === "hide") {

                if(param[0] === "slideshowcontrols")
                    slideshowcontrols_top.hide()

            } else if(what === "keyEvent") {

                if(param[0] === Qt.Key_Left)
                    PQCNotifyQML.slideshowPrevImage(true)

                else if(param[0] === Qt.Key_Right)
                    PQCNotifyQML.slideshowNextImage(true)

            }

        }
    }

    Connections {

        target: PQCConstants // qmllint disable unqualified

        function onSlideshowRunningChanged() {
            slideshowcontrols_top.updateState()
            if(PQCConstants.slideshowRunning) // qmllint disable unqualified
                slideshowcontrols_top.show()
            else
                slideshowcontrols_top.hide()
        }

    }

    Connections {

        target: PQCConstants

        function onSlideshowRunningAndPlayingChanged() {
            slideshowcontrols_top.updateState()
        }

    }

    function show() {
        opacity = 1
        if(popoutWindowUsed)
            slideshowcontrols_popout.visible = true // qmllint disable unqualified
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            slideshowcontrols_popout.visible = false // qmllint disable unqualified
        PQCNotifyQML.loaderRegisterClose("slideshowcontrols")
    }

    Component.onCompleted: {
        if(slideshowcontrols_top.isPopout)
            slideshowcontrols_top.updateState()
        else
            removeHighlightTimeout.restart()
    }


    Timer {
        id: removeHighlightTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            slideshowcontrols_top.updateState()
        }
    }

}

