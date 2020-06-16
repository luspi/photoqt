import QtQuick 2.9
import QtQuick.Controls 2.2

CheckBox {

    id: control

    text: ""

    property alias interactive: mousearea.enabled
    property alias tooltip: mousearea.tooltip
    property alias tooltipFollowsMouse: mousearea.tooltipFollowsMouse

    indicator: Rectangle {

        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        color: control.checked ? (control.enabled ? "#ffffff" : "#dddddd" ) : "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 50 } }
        border.color: "#333333"
        Rectangle {
            width: 12
            height: 12
            x: 4
            y: 4
            radius: 2
            color: control.enabled ? "#333333" : "#666666"
            opacity: control.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 50 } }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.checked ? "#ffffff" : "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 50 } }
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    PQMouseArea {
        id: mousearea
        anchors.fill: control
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked:
            control.checked = !control.checked
    }

}
