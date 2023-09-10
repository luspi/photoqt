import QtQuick

import PQCScriptsFileManagement

Rectangle {

    id: exportRunning

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    anchors.fill: parent
    color: PQCLook.transColor

    signal successHidden()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: (mouse) => { mouse.accepted = true }
        onWheel: (wheel) => { wheel.accepted = true }
    }

    Item {

        id: exportbusy
        anchors.fill: parent

        opacity: 1
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Repeater {

            model: 3

            delegate: Canvas {
                id: load
                x: (parent.width-width)/2
                y: (parent.height-height)/2
                width: 206 - index*25
                height: 206 - index*25
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = "#ffffff";
                    ctx.lineWidth = 3
                    ctx.beginPath();
                    ctx.arc(width/2, height/2, width/2-3, 0, 3.14, false);
                    ctx.stroke();
                }
                RotationAnimator {
                    target: load
                    from: index%2 ? 360 : 0
                    to: index%2 ? 0 : 360
                    duration: 2000 - index*200
                    running: exportRunning.visible
                    loops: Animation.Infinite
                }
            }

        }

    }

    Image {
        id: exportsuccess
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 200
        height: 200
        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        source: "/white/checkmark.svg"
        sourceSize: Qt.size(width, height)
        Timer {
            running: parent.visible
            interval: 1000
            onTriggered: {
                exportsuccess.opacity = 0
                exportRunning.opacity = 0
                hide()
                exportRunning.successHidden()
            }
        }
    }

    function showBusy() {
        exportbusy.opacity = 1
        exportsuccess.opacity = 0
        opacity = 1
    }

    function showSuccess() {
        exportbusy.opacity = 0
        exportsuccess.opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
