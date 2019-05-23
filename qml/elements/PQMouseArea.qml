import QtQuick 2.9
import QtQuick.Controls 2.2

Item {

    id: top

    property alias tooltip: control.text
    property alias hoverEnabled: tooltip_mousearea.hoverEnabled
    property alias cursorShape: tooltip_mousearea.cursorShape
    property alias propagateComposedEvents: tooltip_mousearea.propagateComposedEvents
    signal clicked(var mouse)
    signal doubleClicked(var mouse)
    signal pressAndHold(var mouse)
    signal entered()
    signal exited()
    signal pressed()
    signal released()

    ToolTip {
        id: control
        text: ""
        delay: 500
        visible: tooltip_mousearea.containsMouse

        contentItem: Text {
            text: control.text
            font: control.font
            color: "white"
        }

        background: Rectangle {
            color: "black"
            border.color: "#666666"
        }

    }

    MouseArea {
        id: tooltip_mousearea
        anchors.fill: parent
        onClicked: {
            top.clicked(mouse)
            mouse.accepted = !propagateComposedEvents
        }
        onDoubleClicked: {
            top.doubleClicked(mouse)
            mouse.accepted = !propagateComposedEvents
        }
        onPressAndHold: {
            top.pressAndHold(mouse)
            mouse.accepted = !propagateComposedEvents
        }
        onEntered: {
            top.entered()
        }
        onExited: {
            top.exited()
        }
        onPressed: {
            top.pressed(mouse)
            mouse.accepted = !propagateComposedEvents
        }
        onReleased: {
            top.released(mouse)
            mouse.accepted = !propagateComposedEvents
        }

    }

}
