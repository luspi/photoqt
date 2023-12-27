import QtQuick
import PQCNotify
import PQCPhotoSphere
import PQCFileFolderModel

import "../elements"

Item {

    id: sphere_top

    anchors.fill: parent
    anchors.margins: -PQCSettings.imageviewMargin

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    onOpacityChanged: (opacity) => {
        if(opacity === 0) {
            thesphere.visible = false
            thesphere.source = ""
        }
    }

    PQCPhotoSphere {

        id: thesphere
        anchors.fill: parent

        visible: false

        // these need to have a small duration as otherwise touchpad handling is awkward
        // key events are handled with their own animations below
        Behavior on fieldOfView { NumberAnimation { id: behavior_fov; duration: 50 } }
        Behavior on azimuth { NumberAnimation { id: behavior_az; duration: 50 } }
        Behavior on elevation { NumberAnimation { id: behavior_ele; duration: 50 } }

        PinchArea {

            id: pincharea

            anchors.fill: parent

            property real storeFieldOfView

            onPinchStarted:
                storeFieldOfView = thesphere.fieldOfView

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

                onWheel: (wheel) => {
                    if(wheel.modifiers & Qt.ControlModifier) {
                        thesphere.azimuth +=  wheel.angleDelta.x*0.1
                        thesphere.elevation -=  wheel.angleDelta.y*0.05
                    } else
                        thesphere.fieldOfView -=  wheel.angleDelta.y*0.05
                }
            }
        }

    }

    Rectangle {

        parent: fullscreenitem_foreground
        x: 20
        y: 20
        width: 42
        height: 42
        radius: 21

        opacity: hovered ? 0.8 : 0.3
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: PQCNotify.insidePhotoSphere

        color: PQCLook.transColor

        property bool hovered: false

        Image {
            x: 5
            y: 5
            width: 32
            height: 32
            sourceSize: Qt.size(width, height)
            source: "/white/close.svg"
        }

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: qsTranslate("facetagging", "Click to exit photo sphere")
            onClicked: hide()
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
        }

    }

    // these are not handled with the behavior above because key events are handled smoother than mouse events
    NumberAnimation {
        id: animatedAzimuth
        target: thesphere
        property: "azimuth"
        duration: 200
    }
    NumberAnimation {
        id: animatedElevation
        target: thesphere
        property: "elevation"
        duration: 200
    }
    NumberAnimation {
        id: animatedFieldOfView
        target: thesphere
        property: "fieldOfView"
        duration: 200
    }

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(loader.visibleItem !== "photosphere")
                return

            if(what === "keyEvent") {

                if(param[0] === Qt.Key_Escape)
                    hide()

                else if(param[0] === Qt.Key_Left)
                    moveView("left")

                else if(param[0] === Qt.Key_Right)
                    moveView("right")

                else if(param[0] === Qt.Key_Up)
                    moveView("up")

                else if(param[0] === Qt.Key_Down)
                    moveView("down")

                else if(param[0] === Qt.Key_Plus)
                    zoom("in")

                else if(param[0] === Qt.Key_Minus)
                    zoom("out")

                else if(param[0] === Qt.Key_0) {

                    moveView("reset")
                    zoom("reset")

                }

            }

        }

    }

    // these are not handled with the behavior above because key events are handled smoother than mouse events
    function zoom(dir) {

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
            animatedAzimuth.from = thesphere.azimuth
            animatedAzimuth.to = 180
        }

        if(dir === "up" || dir === "down" || dir === "reset")
            animatedElevation.restart()
        if(dir === "left" || dir === "right" || dir === "reset")
            animatedAzimuth.restart()

    }

    Connections {

        target: PQCNotify

        function onEnterPhotoSphere() {
            sphere_top.show()
        }

    }

    function show() {
        loader.visibleItem = "photosphere"
        PQCNotify.insidePhotoSphere = true
        thesphere.source = PQCFileFolderModel.currentFile
        thesphere.azimuth = 180
        thesphere.elevation = 0
        thesphere.fieldOfView = 90
        thesphere.visible = true
        opacity = 1
    }

    function hide() {
        PQCNotify.insidePhotoSphere = false
        opacity = 0
        loader.visibleItem = ""
    }

}
