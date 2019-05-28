import QtQuick 2.9
import QtQuick.Controls 2.2

Item {

    id: top

    property alias tooltip: control.text
    property alias hoverEnabled: tooltip_mousearea.hoverEnabled
    property alias cursorShape: tooltip_mousearea.cursorShape
    property alias propagateComposedEvents: tooltip_mousearea.propagateComposedEvents
    property alias acceptedButtons: tooltip_mousearea.acceptedButtons

    property alias drag: tooltip_mousearea.drag

    property bool tooltipFollowsMouse: true

    signal clicked(var mouse)
    signal doubleClicked(var mouse)
    signal pressAndHold(var mouse)
    signal entered()
    signal exited()
    signal pressed()
    signal released()
    signal dragOnActiveChanged()

    PQToolTip {
        id: control
        parent: top.tooltipFollowsMouse ? curmouse : top
        visible: text!=""&&tooltip_mousearea.containsMouse
    }

    Item {
        id: curmouse
        x: tooltip_mousearea.mouseX + control.width/2
        y: tooltip_mousearea.mouseY
        width: 1
        height: 1
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
        drag.onActiveChanged:
            top.dragOnActiveChanged()

    }

}
