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
pragma ComponentBehavior: Bound

import QtQuick
import PQCScriptsImages
import org.photoqt.qml

Item {

    id: anictrl

    // we use this workaround to avoid a binding loop below
    property int setFrame: 0

    Connections {

        target: image // qmllint disable unqualified

        function onCurrentFrameChanged() {
            if(anictrl.setFrame !== image.currentFrame) // qmllint disable unqualified
                anictrl.setFrame = image.currentFrame // qmllint disable unqualified
        }
    }

    Loader {

        active: PQCSettings.filetypesAnimatedControls && !PQCConstants.slideshowRunning // qmllint disable unqualified

        sourceComponent:
        Rectangle {

            id: controlitem

            parent: loader_top // qmllint disable unqualified

            x: (parent.width-width)/2
            y: 0.9*parent.height
            z: image_top.curZ // qmllint disable unqualified
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColor // qmllint disable unqualified

            Connections {
                target: image_top // qmllint disable unqualified
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, image_top.width-controlitem.width-5) // qmllint disable unqualified
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, image_top.height-controlitem.height-5) // qmllint disable unqualified
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2) {
                    image_top.extraControlsLocation.x = x // qmllint disable unqualified
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height) {
                    image_top.extraControlsLocation.y = y // qmllint disable unqualified
                    y = y
                }
            }

            Component.onCompleted: {
                if(image_top.extraControlsLocation.x !== -1) { // qmllint disable unqualified
                    controlitem.x = image_top.extraControlsLocation.x
                    controlitem.y = image_top.extraControlsLocation.y
                }
            }

            // only show when needed
            opacity: (image.frameCount>1 && image.visible && PQCSettings.filetypesAnimatedControls) ? (hovered ? 1 : 0.3) : 0 // qmllint disable unqualified
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            enabled: visible

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||playpausecontrol.containsMouse||
                                   slidercontrol.backgroundContainsMouse||slidercontrol.handleContainsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||saveframemouse.containsMouse||
                                   leftrightmouse.containsMouse

            // drag and catch wheel events
            MouseArea {
                id: controldrag
                anchors.fill: parent
                drag.target: parent
                drag.minimumX: 5
                drag.minimumY: 5
                drag.maximumX: image_top.width-controlitem.width-5 // qmllint disable unqualified
                drag.maximumY: image_top.height-controlitem.height-5 // qmllint disable unqualified
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                propagateComposedEvents: true
                onWheel: {}
            }

            Row {

                id: controlrow

                x: 10
                y: (parent.height-height)/2

                spacing: 5

                // play/pause button
                Rectangle {
                    y: (parent.height-height)/2
                    color: playpausecontrol.containsPress ? PQCLook.transColorActive : (playpausecontrol.containsMouse ? PQCLook.transColorAccent : "transparent") // qmllint disable unqualified
                    Behavior on color { ColorAnimation { duration: 200 } }
                    height: width
                    width: controlitem.height/2.5 + 6
                    radius: 5
                    Image {
                        x: 3
                        y: 3
                        width: parent.width-6
                        height: width
                        source: (image.playing ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")) // qmllint disable unqualified
                        sourceSize: Qt.size(width, height)
                        MouseArea {
                            id: playpausecontrol
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if(!image.playing) { // qmllint disable unqualified
                                    // without explicitely storing/loading the frame it will restart playing at the start
                                    var fr = image.currentFrame
                                    image.playing = true
                                    image.currentFrame = fr
                                } else
                                    image.playing = false
                            }
                        }
                    }
                }

                PQSlider {
                    id: slidercontrol
                    y: (parent.height-height)/2
                    from: 0
                    to: image.frameCount-1 // qmllint disable unqualified
                    value: anictrl.setFrame
                    wheelEnabled: false

                    onValueChanged: {
                        if(value !== image.currentFrame) // qmllint disable unqualified
                            image.currentFrame = value
                    }

                }

                Rectangle {
                    y: (parent.height-height)/2
                    height: controlitem.height*0.75
                    width: 1
                    color: PQCLook.textColor // qmllint disable unqualified
                }

                Item {
                    width: 1
                    height: 1
                }

                // save frame button
                Rectangle {
                    y: (parent.height-height)/2
                    color: saveframemouse.containsPress ? PQCLook.transColorActive : (saveframemouse.containsMouse ? PQCLook.transColorAccent : "transparent") // qmllint disable unqualified
                    Behavior on color { ColorAnimation { duration: 200 } }
                    height: width
                    width: controlitem.height/2.5 + 6
                    radius: 5
                    Image {
                        x: 3
                        y: 3
                        width: height
                        height: parent.height-6
                        opacity: enabled ? 0.75 : 0.25
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        source: "image://svg/:/" + PQCLook.iconShade + "/remember.svg" // qmllint disable unqualified
                        sourceSize: Qt.size(width, height)
                        enabled: !image.playing // qmllint disable unqualified
                        PQMouseArea {
                            id: saveframemouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            //: The frame here refers to one of the images making up an animation of a gif or other animated image
                            text: qsTranslate("image", "Save current frame to new file")
                            onClicked: {
                                PQCScriptsImages.extractFrameAndSave(imageloaderitem.imageSource, image.currentFrame) // qmllint disable unqualified
                            }
                        }
                    }
                }

                Rectangle {

                    id: leftrightlock

                    y: (parent.height-height)/2
                    width: lockrow.width+6
                    height: lockrow.height+6
                    radius: 5

                    color: leftrightmouse.containsPress ? PQCLook.transColorActive : (leftrightmouse.containsMouse ? PQCLook.transColorAccent : "transparent") // qmllint disable unqualified
                    Behavior on color { ColorAnimation { duration: 200 } }

                    opacity: PQCSettings.filetypesAnimatedLeftRight ? 1 : 0.3 // qmllint disable unqualified
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Row {
                        id: lockrow
                        x: 3
                        y: 3

                        Image {
                            height: controlitem.height/2.5
                            width: height
                            source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg" // qmllint disable unqualified
                            sourceSize: Qt.size(width, height)
                        }

                        PQText {
                            text: "←/→"
                        }

                    }

                    PQMouseArea {
                        id: leftrightmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("image", "Lock left/right arrow keys to frame navigation")
                        onClicked:
                            PQCSettings.filetypesAnimatedLeftRight = !PQCSettings.filetypesAnimatedLeftRight // qmllint disable unqualified
                    }

                }

            }

            // the close button is only visible when hovered
            Image {
                x: parent.width-width+10
                y: -10
                width: 20
                height: 20
                opacity: controlclosemouse.containsMouse ? 0.75 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
                source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: PQCSettings.filetypesAnimatedControls = false // qmllint disable unqualified
                }
            }

            Connections {

                target: PQCNotify // qmllint disable unqualified

                enabled: controlitem.enabled

                function onMouseMove(x : int, y : int) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y)) // qmllint disable unqualified
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

            }

        }

    }

}
