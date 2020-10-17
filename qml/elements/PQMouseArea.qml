import QtQuick 2.9
import QtQuick.Controls 2.2

MouseArea {

    id: top

    property bool tooltipFollowsMouse: true
    property alias tooltip: control.text
    property alias tooltipWrapMode: control.wrapMode
    property alias tooltipWidth: control.width
    property alias tooltipElide: control.elide
    property alias tooltipDelay: control.delay

    PQToolTip {
        id: control
        parent: top.tooltipFollowsMouse ? curmouse : top
        visible: text!=""&&top.containsMouse
    }

    Item {
        id: curmouse
        x: top.mouseX + control.width/2
        y: top.mouseY
        width: 1
        height: 1
    }

}
