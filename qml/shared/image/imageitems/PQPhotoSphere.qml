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
import PhotoQt.Shared

PQCPhotoSphere {

    id: thesphere

    /*******************************************/
    // these values are READONLY

    property string imageSource: ""
    property Item loaderTop

    /*******************************************/

    // these need to have a small duration as otherwise touchpad handling is awkward
    // key events are handled with their own animations below
    Behavior on fieldOfView { NumberAnimation { id: behavior_fov; duration: thesphere.aniDuration } }
    Behavior on azimuth { NumberAnimation { id: behavior_az; duration: thesphere.aniDuration } }
    Behavior on elevation { NumberAnimation { id: behavior_ele; duration: thesphere.aniDuration } }

    property int aniDuration: 0

    Component.onCompleted: {
        thesphere.aniDuration = 50

        if(!panOnCompleted.running && !PQCConstants.slideshowRunning && PQCSettings.filetypesPhotoSpherePanOnLoad)
            panOnCompleted.start()
    }

    source: thesphere.imageSource
    azimuth: 180
    elevation: 0
    fieldOfView: 90

    onVisibleChanged: {

        if(!thesphere.visible) {
            zoom("reset")
            moveView("reset")
        }

        if(!loader_top.isMainImage)
            return

        if(!panOnCompleted.running && !PQCConstants.slideshowRunning && PQCSettings.filetypesPhotoSpherePanOnLoad)
            panOnCompleted.start()

    }

    PinchArea {

        id: pincharea

        anchors.fill: parent

        z: PQCConstants.currentZValue+1

        property real storeFieldOfView

        onPinchStarted: {
            leftrightani.stop()
            storeFieldOfView = thesphere.fieldOfView
        }

        onPinchUpdated: (pinch) => {
            // compute the rate of change initiated by this pinch
            var startLength = Math.sqrt(Math.pow(pinch.startPoint1.x-pinch.startPoint2.x, 2) + Math.pow(pinch.startPoint1.y-pinch.startPoint2.y, 2))
            var curLength = Math.sqrt(Math.pow(pinch.point1.x-pinch.point2.x, 2) + Math.pow(pinch.point1.y-pinch.point2.y, 2))
            // avoid division by zero. Can sometimes happen at the end of a pinch.
            if(Math.abs(curLength) > 1e-12)
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
                thesphere.aniDuration = 0
                clickedPos = Qt.point(mouse.x, mouse.y)
                clickedAzimuth = thesphere.azimuth
                clickedElevation = thesphere.elevation
            }
            onPositionChanged: (mouse) => {
                var posDiff = Qt.point(mouse.x-mousearea.clickedPos.x , mouse.y-mousearea.clickedPos.y)
                var curTan = Math.tan(thesphere.fieldOfView * ((0.5*Math.PI)/180));
                thesphere.azimuth = clickedAzimuth - (((3*256)/PQCConstants.imageDisplaySize.height) * posDiff.x/6) * curTan
                thesphere.elevation = clickedElevation + (((3*256)/PQCConstants.imageDisplaySize.height) * posDiff.y/6) * curTan
            }
            onReleased: {
                thesphere.aniDuration = 50
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

        target: PQCScriptsShortcuts

        function onSendShortcutZoomIn(mousePos: point, wheelDelta : point) {
            if(loader_top.isMainImage)
                thesphere.zoom("in")
        }
        function onSendShortcutZoomOut(wheelDelta : point) {
            if(loader_top.isMainImage)
                thesphere.zoom("out")
        }
        function onSendShortcutZoomReset() {
            if(loader_top.isMainImage) {
                thesphere.zoom("reset")
                thesphere.moveView("reset")
            }
        }

    }

    Connections {

        target: PQCNotify

        function onCurrentViewMove(direction : string) {

            if(!loader_top.isMainImage)
                return

            if(direction === "left")
                thesphere.moveView("left")
            else if(direction === "right")
                thesphere.moveView("right")
            else if(direction === "up")
                thesphere.moveView("up")
            else if(direction === "down")
                thesphere.moveView("down")

        }

    }

    // these are not handled with the behavior above because key events are handled smoother than mouse events
    function zoom(dir : string) {

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
    function moveView(dir : string) {

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

    // PQPhotoSphereControls {
    //     id: controls
    //     loaderTop: thesphere.loaderTop
    // }

    property int aniSpeed: Math.max(15-PQCSettings.slideshowImageTransition,1)*30
    property bool animationRunning: false
    property int aniDirection: -1

    Connections {
        target: image_top

        function onAnimatePhotoSpheres(direction : int) {

            if(!loader_top.isMainImage)
                return

            thesphere.aniDirection = direction

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

    // slideshow paused/resumed
    Connections {

        target: PQCConstants

        function onCurrentImageSourceChanged() {

            if(!loader_top.isMainImage) {
                if(kb_left.running)
                    kb_left.pause()
                if(kb_right.running)
                    kb_right.pause()
            }

        }

        function onSlideshowRunningAndPlayingChanged() {
            if(PQCConstants.slideshowRunningAndPlaying) {
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
        running: thesphere.animationRunning

        // animate from middle to the left
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 180
            to: 0
            duration: Math.abs(from-to)*thesphere.aniSpeed
        }

        // animate to the right
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 0
            to: 360
            duration: Math.abs(from-to)*thesphere.aniSpeed
        }

        // animate to the middle
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 360
            to: 180
            duration: Math.abs(from-to)*thesphere.aniSpeed
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
            duration: Math.abs(from-to)*thesphere.aniSpeed
        }

        // animate to the left
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 360
            to: 0
            duration: Math.abs(from-to)*thesphere.aniSpeed
        }

        // animate to the middle
        NumberAnimation {
            target: thesphere
            property: "azimuth"
            from: 0
            to: 180
            duration: Math.abs(from-to)*thesphere.aniSpeed
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
