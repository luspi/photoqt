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
import PhotoQt.Modern

Item {

    id: anictrl

    /*******************************************/
    // these values are READONLY

    property Item loaderTop
    property int imageCurrentFrame
    property int imageFrameCount
    property bool imageVisible
    property bool imagePlaying
    property string imageSource

    /*******************************************/

    signal setImagePlaying(var playing)
    signal setImageCurrentFrame(var frame)

    /*******************************************/

    // we use this workaround to avoid a binding loop below
    property int setFrame: 0

    imageCurrentFrame: {
        if(anictrl.setFrame !== anictrl.imageCurrentFrame)
            anictrl.setFrame = anictrl.imageCurrentFrame
    }

    Loader {

        active: PQCSettings.filetypesAnimatedControls && !PQCConstants.slideshowRunning

        sourceComponent:
        Rectangle {

            id: controlitem

            parent: anictrl.loaderTop

            x: (parent.width-width)/2
            y: 0.9*parent.height
            z: PQCConstants.currentZValue
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColor

            Connections {
                target: anictrl.loaderTop
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, anictrl.loaderTop.width-controlitem.width-5)
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, anictrl.loaderTop.height-controlitem.height-5)
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2) {
                    PQCConstants.extraControlsLocation.x = x
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height) {
                    PQCConstants.extraControlsLocation.y = y
                    y = y
                }
            }

            Component.onCompleted: {
                if(PQCConstants.extraControlsLocation.x !== -1) {
                    controlitem.x = PQCConstants.extraControlsLocation.x
                    controlitem.y = PQCConstants.extraControlsLocation.y
                }
            }

            // only show when needed
            opacity: (anictrl.imageFrameCount>1 && anictrl.imageVisible && PQCSettings.filetypesAnimatedControls) ? (hovered ? 1 : 0.3) : 0
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
                drag.maximumX: anictrl.loaderTop.width-controlitem.width-5
                drag.maximumY: anictrl.loaderTop.height-controlitem.height-5
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                propagateComposedEvents: true
                onWheel: {}
                onClicked: {}
            }

            Row {

                id: controlrow

                x: 10
                y: (parent.height-height)/2

                spacing: 5

                // play/pause button
                Rectangle {
                    y: (parent.height-height)/2
                    color: playpausecontrol.containsPress ? PQCLook.transColorActive : (playpausecontrol.containsMouse ? PQCLook.transColorAccent : "transparent")
                    Behavior on color { ColorAnimation { duration: 200 } }
                    height: width
                    width: controlitem.height/2.5 + 6
                    radius: 5
                    Image {
                        x: 3
                        y: 3
                        width: parent.width-6
                        height: width
                        source: (anictrl.imagePlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg"))
                        sourceSize: Qt.size(width, height)
                        MouseArea {
                            id: playpausecontrol
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if(!anictrl.imagePlaying) {
                                    // without explicitely storing/loading the frame it will restart playing at the start
                                    var fr = anictrl.imageCurrentFrame
                                    anictrl.setImagePlaying(true)
                                    anictrl.setImageCurrentFrame(fr)
                                } else
                                    anictrl.setImagePlaying(false)
                            }
                        }
                    }
                }

                PQSlider {
                    id: slidercontrol
                    y: (parent.height-height)/2
                    from: 0
                    to: anictrl.imageFrameCount-1
                    value: anictrl.setFrame
                    wheelEnabled: false

                    onValueChanged: {
                        if(value !== anictrl.imageCurrentFrame)
                            anictrl.setImageCurrentFrame(value)
                    }

                }

                Rectangle {
                    y: (parent.height-height)/2
                    height: controlitem.height*0.75
                    width: 1
                    color: PQCLook.textColor
                }

                Item {
                    width: 1
                    height: 1
                }

                // save frame button
                Rectangle {
                    y: (parent.height-height)/2
                    color: saveframemouse.containsPress ? PQCLook.transColorActive : (saveframemouse.containsMouse ? PQCLook.transColorAccent : "transparent")
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
                        source: "image://svg/:/" + PQCLook.iconShade + "/remember.svg"
                        sourceSize: Qt.size(width, height)
                        enabled: !anictrl.imagePlaying
                        PQMouseArea {
                            id: saveframemouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            //: The frame here refers to one of the images making up an animation of a gif or other animated image
                            text: qsTranslate("image", "Save current frame to new file")
                            onClicked: {
                                PQCScriptsImages.extractFrameAndSave(anictrl.imageSource, anictrl.imageCurrentFrame)
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

                    color: leftrightmouse.containsPress ? PQCLook.transColorActive : (leftrightmouse.containsMouse ? PQCLook.transColorAccent : "transparent")
                    Behavior on color { ColorAnimation { duration: 200 } }

                    opacity: PQCSettings.filetypesAnimatedLeftRight ? 1 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Row {
                        id: lockrow
                        x: 3
                        y: 3

                        Image {
                            height: controlitem.height/2.5
                            width: height
                            source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
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
                            PQCSettings.filetypesAnimatedLeftRight = !PQCSettings.filetypesAnimatedLeftRight
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
                source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: PQCSettings.filetypesAnimatedControls = false
                }
            }

            Connections {

                target: PQCNotify

                enabled: controlitem.enabled

                function onMouseMove(x : int, y : int) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y))
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

            }

        }

    }

}
