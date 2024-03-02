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

import "../../elements"

import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCScriptsClipboard
import PQCScriptsOther
import PQCNotify

AnimatedImage {

    id: image

    source: "file:/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)

    asynchronous: true

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: Math.abs(image_wrapper.scale-1) < 0.1 ? false : interpThreshold
    mipmap: interpThreshold

    property bool fitImage: (PQCSettings.imageviewFitInWindow && image.sourceSize.width < deleg.width && image.sourceSize.height < deleg.height)
    property bool imageLarger: (image.sourceSize.width > deleg.width || image.sourceSize.height > deleg.height)

    width: (fitImage||imageLarger) ? deleg.width : undefined
    height: (fitImage||imageLarger) ? deleg.height : undefined

    fillMode: Image.PreserveAspectFit

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Ready) {
            hasAlpha = PQCScriptsImages.supportsTransparency(deleg.imageSource)
            if(deleg.defaultScale < 0.95)
                loadScaledDown.restart()
        } else if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        deleg.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        deleg.imageMirrorV = myMirrorV

    property bool hasAlpha: false

    onSourceSizeChanged:
        deleg.imageResolution = sourceSize

    Connections {
        target: image_top
        function onMirrorH() {
            image.myMirrorH = !image.myMirrorH
        }
        function onMirrorV() {
            image.myMirrorV = !image.myMirrorV
        }
        function onMirrorReset() {
            image.myMirrorH = false
            image.myMirrorV = false
        }

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

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile

        source: PQCSettings.imageviewTransparencyMarker&&image.hasAlpha ? "/other/checkerboard.png" : ""

    }
    function setMirrorHV(mH, mV) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    Connections {

        target: loader_component
        function onVideoTogglePlay() {
            if(!image.playing) {
                // without explicitely storing/loading the frame it will restart playing at the start
                var fr = image.currentFrame
                image.playing = true
                image.currentFrame = fr
            } else
                image.playing = false
        }

    }

    Connections {

        target: image_top

        function onCurrentlyVisibleIndexChanged() {
            image.playing = (image_top.currentlyVisibleIndex === deleg.itemIndex)
        }

        function onAnimImageJump(leftright) {
            image.currentFrame = (image.currentFrame+leftright+image.frameCount)%image.frameCount
        }

    }

    /**********************************************************/
    // Allow control of what frame to show of animated image

    // we use this workaround to avoid a binding loop below
    property int setFrame: 0
    onCurrentFrameChanged: {
        if(setFrame !== image.currentFrame)
            setFrame = image.currentFrame
    }

    Loader {

        active: PQCSettings.imageviewAnimatedControls

        Rectangle {

            id: controlitem

            parent: deleg

            x: (parent.width-width)/2
            y: 0.9*parent.height
            width: controlrow.width+10
            height: 50
            radius: 5
            color: PQCLook.transColor

            Connections {
                target: image_top
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, image_top.width-controlitem.width-5)
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, image_top.height-controlitem.height-5)
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2) {
                    image_top.animatedControlsLocation.x = x
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height) {
                    image_top.animatedControlsLocation.y = y
                    y = y
                }
            }

            Component.onCompleted: {
                if(image_top.animatedControlsLocation.x !== -1) {
                    controlitem.x = image_top.animatedControlsLocation.x
                    controlitem.y = image_top.animatedControlsLocation.y
                }
            }

            // only show when needed
            opacity: (image.frameCount>1 && image.visible && PQCSettings.imageviewAnimatedControls) ? (hovered ? 1 : 0.3) : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            enabled: visible

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||playpausecontrol.containsMouse||
                                   slidercontrol.backgroundContainsMouse||slidercontrol.handleContainsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||saveframemouse.containsMouse

            // drag and catch wheel events
            MouseArea {
                id: controldrag
                anchors.fill: parent
                drag.target: parent
                drag.minimumX: 5
                drag.minimumY: 5
                drag.maximumX: image_top.width-controlitem.width-5
                drag.maximumY: image_top.height-controlitem.height-5
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                propagateComposedEvents: true
                onWheel: {}
            }

            Row {

                id: controlrow

                x: 5
                y: (parent.height-height)/2

                // play/pause button
                Image {
                    y: (parent.height-height)/2
                    width: 30
                    height: 30
                    opacity: enabled ? 0.75 : 0.25
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    source: "image://svg/:/white/remember.svg"
                    sourceSize: Qt.size(width, height)
                    enabled: !image.playing
                    PQMouseArea {
                        id: saveframemouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: The frame here refers to one of the images making up an animation of a gif or other animated image
                        text: qsTranslate("image", "Save current frame to new file")
                        onClicked: {
                            PQCScriptsImages.extractFrameAndSave(deleg.imageSource, image.currentFrame)
                        }
                    }
                }

                Item {
                    width: 5
                    height: 1
                }

                // play/pause button
                Image {
                    y: (parent.height-height)/2
                    width: 30
                    height: 30
                    source: (image.playing ? "image://svg/:/white/pause.svg" : "image://svg/:/white/play.svg")
                    sourceSize: Qt.size(width, height)
                    MouseArea {
                        id: playpausecontrol
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(!image.playing) {
                                // without explicitely storing/loading the frame it will restart playing at the start
                                var fr = image.currentFrame
                                image.playing = true
                                image.currentFrame = fr
                            } else
                                image.playing = false
                        }
                    }
                }

                PQSlider {
                    id: slidercontrol
                    y: (parent.height-height)/2
                    from: 0
                    to: image.frameCount-1
                    value: setFrame
                    wheelEnabled: false

                    onValueChanged: {
                        if(value !== image.currentFrame)
                            image.currentFrame = value
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
                source: "image://svg/:/white/close.svg"
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: PQCSettings.imageviewAnimatedControls = false
                }
            }

            Connections {

                target: PQCNotify

                enabled: controlitem.enabled

                function onMouseMove(x, y) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y))
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

            }

        }

    }

}
