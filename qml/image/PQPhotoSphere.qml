import QtQuick
import PQCNotify
import PQCPhotoSphere
import PQCFileFolderModel

import "../elements"

Item {

    id: sphere_top

    anchors.fill: parent

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    onOpacityChanged: (opacity) => {
        if(opacity === 0)
            thesphere.visible = false
    }

    PQCPhotoSphere {

        id: thesphere
        anchors.fill: parent

        visible: false

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

                onWheel: (wheel) => {
                    if(wheel.modifiers & Qt.ControlModifier)
                        thesphere.fieldOfView -=  wheel.angleDelta.y*0.05;
                    else if(wheel.modifiers & Qt.ShiftModifier)
                        thesphere.azimuth -=  wheel.angleDelta.y*0.05;
                    else {
                        thesphere.azimuth +=  wheel.angleDelta.x*0.1
                        thesphere.elevation -=  wheel.angleDelta.y*0.05
                    }
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

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(loader.visibleItem !== "photosphere")
                return

            if(what === "keyEvent") {

                if(param[0] === Qt.Key_Escape)
                    hide()

            }

        }

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
        thesphere.visible = true
        opacity = 1
    }

    function hide() {
        PQCNotify.insidePhotoSphere = false
        opacity = 0
        loader.visibleItem = ""
    }

}
