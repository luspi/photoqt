import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Slider {

    style: SliderStyle {
        groove: Rectangle {
            implicitWidth: 200
            implicitHeight: 3
            color: "white"
            radius: 8
        }
        handle: Rectangle {
            anchors.centerIn: parent
            color: control.pressed ? "#333333" : "#000000"
            border.color: "white"
            border.width: 1
            implicitWidth: 18
            implicitHeight: 12
            radius: 5
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: (parent.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
        propagateComposedEvents: true
        onPressed: mouse.accepted = false
        onReleased: mouse.accepted = false
    }

}
