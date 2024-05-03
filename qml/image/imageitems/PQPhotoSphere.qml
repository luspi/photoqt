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
import PQCNotify
import PQCPhotoSphere
import PQCFileFolderModel

import "../../elements"
import "../components"

PQCPhotoSphere {

    id: thesphere

    width: deleg.width
    height: deleg.height

    // these need to have a small duration as otherwise touchpad handling is awkward
    // key events are handled with their own animations below
    Behavior on fieldOfView { NumberAnimation { id: behavior_fov; duration: 0 } }
    Behavior on azimuth { NumberAnimation { id: behavior_az; duration: 0 } }
    Behavior on elevation { NumberAnimation { id: behavior_ele; duration: 0 } }

    Component.onCompleted: {
        image_wrapper.status = Image.Ready
        image_wrapper.width = width
        image_wrapper.height = height
        behavior_fov.duration = 50
        behavior_az.duration = 50
        behavior_ele.duration = 50

        if(!PQCNotify.slideshowRunning && PQCSettings.filetypesPhotoSpherePanOnLoad)
            panOnCompleted.start()
    }

    source: loader_top.imageSource
    azimuth: 180
    elevation: 0
    fieldOfView: 90

    PinchArea {

        id: pincharea

        anchors.fill: parent

        z: image_top.curZ+1

        property real storeFieldOfView

        onPinchStarted: {
            leftrightani.stop()
            storeFieldOfView = thesphere.fieldOfView
        }

        onPinchUpdated: (pinch) => {
            // compute the rate of change initiated by this pinch
            var startLength = Math.sqrt(Math.pow(pinch.startPoint1.x-pinch.startPoint2.x, 2) + Math.pow(pinch.startPoint1.y-pinch.startPoint2.y, 2))
            var curLength = Math.sqrt(Math.pow(pinch.point1.x-pinch.point2.x, 2) + Math.pow(pinch.point1.y-pinch.point2.y, 2))
            thesphere.fieldOfView = storeFieldOfView * (startLength / curLength)
        }

        MouseArea {

            id: mousearea

            anchors.fill: parent

            property var clickedPos
            property var clickedAzimuth
            property var clickedElevation

            onPressed: (mouse) => {
                leftrightani.stop()
                behavior_fov.duration = 0
                behavior_az.duration = 0
                behavior_ele.duration = 0
                clickedPos = Qt.point(mouse.x, mouse.y)
                clickedAzimuth = thesphere.azimuth
                clickedElevation = thesphere.elevation
            }
            onPositionChanged: (mouse) => {
                var posDiff = Qt.point(mouse.x-mousearea.clickedPos.x , mouse.y-mousearea.clickedPos.y)
                var curTan = Math.tan(thesphere.fieldOfView * ((0.5*Math.PI)/180));
                thesphere.azimuth = clickedAzimuth - (((3*256)/image.height) * posDiff.x/6) * curTan
                thesphere.elevation = clickedElevation + (((3*256)/image.height) * posDiff.y/6) * curTan
            }
            onReleased: {
                behavior_fov.duration = 50
                behavior_az.duration = 50
                behavior_ele.duration = 50
            }
        }
    }

    // these are not handled with the behavior above because key events are handled smoother than mouse events
    NumberAnimation {
        id: animatedAzimuth
        target: thesphere
        property: "azimuth"
        duration: 200
        onRunningChanged: {
            if(!running) {
                animatedAzimuth.easing.type = Easing.Linear
                animatedAzimuth.duration = 200
            }
        }
    }
    NumberAnimation {
        id: animatedElevation
        target: thesphere
        property: "elevation"
        duration: 200
        onRunningChanged: {
            if(!running) {
                animatedElevation.easing.type = Easing.Linear
                animatedElevation.duration = 200
            }
        }
    }
    NumberAnimation {
        id: animatedFieldOfView
        target: thesphere
        property: "fieldOfView"
        duration: 200
    }

    Connections {

        target: image_top

        function onZoomIn(wheelDelta) {
            if(image_top.currentlyVisibleIndex === deleg.itemIndex)
                zoom("in")
        }
        function onZoomOut(wheelDelta) {
            if(image_top.currentlyVisibleIndex === deleg.itemIndex)
                zoom("out")
        }
        function onZoomReset() {
            if(image_top.currentlyVisibleIndex === deleg.itemIndex) {
                zoom("reset")
                moveView("reset")
            }
        }

        function onMoveView(direction) {

            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return

            if(direction === "left")
                moveView("left")
            else if(direction === "right")
                moveView("right")
            else if(direction === "up")
                moveView("up")
            else if(direction === "down")
                moveView("down")

        }

    }

    // these are not handled with the behavior above because key events are handled smoother than mouse events
    function zoom(dir) {

        leftrightani.stop()

        animatedFieldOfView.stop()

        if(dir === "in") {
            animatedFieldOfView.from = thesphere.fieldOfView
            animatedFieldOfView.to = thesphere.fieldOfView-10
        } else if(dir === "out") {
            animatedFieldOfView.from = thesphere.fieldOfView
            animatedFieldOfView.to = thesphere.fieldOfView+10
        } else if(dir === "reset") {
            animatedFieldOfView.from = thesphere.fieldOfView
            animatedFieldOfView.to = 90
        }

        animatedFieldOfView.restart()

    }

    // these are not handled with the behavior above because key events are handled smoother than mouse events
    function moveView(dir) {

        leftrightani.stop()

        if(dir === "up" || dir === "down" || dir === "reset")
            animatedElevation.stop()
        if(dir === "left" || dir === "right" || dir === "reset")
            animatedAzimuth.stop()

        if(dir === "up") {
            animatedElevation.from = thesphere.elevation
            animatedElevation.to = thesphere.elevation + thesphere.fieldOfView/5
        } else if(dir === "down") {
            animatedElevation.from = thesphere.elevation
            animatedElevation.to = thesphere.elevation - thesphere.fieldOfView/5
        } else if(dir === "left") {
            animatedAzimuth.from = thesphere.azimuth
            animatedAzimuth.to = thesphere.azimuth - thesphere.fieldOfView/3
        } else if(dir === "right") {
            animatedAzimuth.from = thesphere.azimuth
            animatedAzimuth.to = thesphere.azimuth + thesphere.fieldOfView/3
        } else if(dir === "reset") {
            animatedElevation.from = thesphere.elevation
            animatedElevation.to = 0
            animatedElevation.easing.type = Easing.OutBack
            animatedElevation.duration = 500
            animatedAzimuth.from = thesphere.azimuth
            animatedAzimuth.to = 180
            animatedAzimuth.easing.type = Easing.OutBack
            animatedAzimuth.duration = 500
        }

        if(dir === "up" || dir === "down" || dir === "reset")
            animatedElevation.restart()
        if(dir === "left" || dir === "right" || dir === "reset")
            animatedAzimuth.restart()

    }

    PQPhotoSphereControls {
        id: controls
    }

    property int aniSpeed: Math.max(15-PQCSettings.slideshowImageTransition,1)*30
    property bool animationRunning: false
    property int aniDirection: -1

    Connections {
        target: image_top

        function onAnimatePhotoSpheres(direction) {

            if(image_top.currentlyVisibleIndex !== deleg.itemIndex)
                return

            aniDirection = direction

            if(direction === 0) {
                kb_right.stop()
                if(kb_left.paused)
                    kb_left.resume()
                else
                    kb_left.start()
            } else if(direction === 1) {
                kb_left.stop()
                if(kb_right.paused)
                    kb_right.resume()
                else
                    kb_right.start()
            } else {
                if(kb_left.running)
                    kb_left.pause()
                if(kb_right.running)
                    kb_right.pause()
            }

        }
    }

    Connections {

        target: image_top

        function onCurrentlyVisibleIndexChanged() {

            if(image_top.currentlyVisibleIndex !== deleg.itemIndex) {
                if(kb_left.running)
                    kb_left.pause()
                if(kb_right.running)
                    kb_right.pause()
            }

        }

    }

    // slideshow paused/resumed
    Connections {

        target: loader_slideshowhandler.item

        function onRunningChanged() {
            if(loader_slideshowhandler.item.running) {
                if(aniDirection === 0) {
                    kb_right.stop()
                    if(kb_left.paused)
                        kb_left.resume()
                    else
                        kb_left.start()
                } else if(aniDirection === 1) {
                    kb_left.stop()
                    if(kb_right.paused)
                        kb_right.resume()
                    else
                        kb_right.start()
                } else {
                    if(kb_left.running)
                        kb_left.pause()
                    if(kb_right.running)
                        kb_right.pause()
                }
            } else {
                if(kb_left.running)
                    kb_left.pause()
                if(kb_right.running)
                    kb_right.pause()
            }
        }

    }

    // Animation: to left
    SequentialAnimation {

        id: kb_left

        loops: Animation.Infinite
        running: animationRunning

        // animate from middle to the left
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 180
            to: 0
            duration: Math.abs(from-to)*aniSpeed
        }

        // animate to the right
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 0
            to: 360
            duration: Math.abs(from-to)*aniSpeed
        }

        // animate to the middle
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 360
            to: 180
            duration: Math.abs(from-to)*aniSpeed
        }

    }

    // Animation: to right
    SequentialAnimation {

        id: kb_right

        loops: Animation.Infinite
        running: false

        // animate from middle to the right
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 180
            to: 360
            duration: Math.abs(from-to)*aniSpeed
        }

        // animate to the left
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 360
            to: 0
            duration: Math.abs(from-to)*aniSpeed
        }

        // animate to the middle
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 0
            to: 180
            duration: Math.abs(from-to)*aniSpeed
        }

    }

    Loader {

        active: !PQCSettings.filetypesPhotoSphereAutoLoad

        sourceComponent:
            Rectangle {

                    parent: fullscreenitem_foreground
                    x: statusinfo.item.visible ? statusinfo.item.x : 20
                    y: statusinfo.item.visible ? statusinfo.item.y+statusinfo.item.height+20 : 20
                    width: 42
                    height: 42
                    radius: 21

                    opacity: hovered ? 0.8 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    color: PQCLook.transColor

                    property bool hovered: false

                    Image {
                        x: 5
                        y: 5
                        width: 32
                        height: 32
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/close.svg"
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("facetagging", "Click to exit photo sphere")
                        onClicked: image_top.exitPhotoSphere()
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                    }

                }

    }


    // This is a short animation to the right and back
    // This is used when a photo sphere has been entered to inform the user that there is more to the image than what they can see
    // The timer below is called from Component.onCompleted above

    SequentialAnimation {

        id: leftrightani

        loops: 1

        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 180
            to: 190
            duration: 500
            easing.type: Easing.OutCirc
        }

        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 190
            to: 180
            duration: 500
            easing.type: Easing.OutBack
        }

    }

    Timer {
        id: panOnCompleted
        interval: PQCSettings.imageviewAnimationDuration*100
        onTriggered: {
            if(!mousearea.pressed)
                leftrightani.start()
        }
    }

}
