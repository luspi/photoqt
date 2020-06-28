import QtQuick 2.9
import QtQuick.Controls 2.2

Item {

    id: top

    property alias tooltip: control.text
    property alias hoverEnabled: tooltip_mousearea.hoverEnabled
    property alias cursorShape: tooltip_mousearea.cursorShape
    property alias propagateComposedEvents: tooltip_mousearea.propagateComposedEvents
    property alias acceptedButtons: tooltip_mousearea.acceptedButtons
    property alias containsMouse: tooltip_mousearea.containsMouse
    property alias buttonPressed: tooltip_mousearea.pressed

    property alias drag: tooltip_mousearea.drag

    property bool tooltipFollowsMouse: true
    property alias tooltipWrapMode: control.wrapMode
    property alias tooltipWidth: control.width
    property alias tooltipElide: control.elide
    property alias tooltipDelay: control.delay

    signal clicked(var mouse)
    signal doubleClicked(var mouse)
    signal pressAndHold(var mouse)
    signal entered()
    signal exited()
    signal pressed(var mouse)
    signal released(var mouse)
    signal dragOnActiveChanged()
    signal positionChanged(var mouse)
    signal wheel(var wheel)

    function containsMouse() {
        return tooltip_mousearea.containsMouse()
    }

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
        onPositionChanged: {
            top.positionChanged(mouse)
            mouse.accepted = !propagateComposedEvents
        }

        onWheel:
            top.wheel(wheel)

        drag.onActiveChanged:
            top.dragOnActiveChanged()

    }

}
