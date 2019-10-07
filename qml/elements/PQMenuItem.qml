import QtQuick 2.9
import QtQuick.Controls 2.2

MenuItem {

    id: control
    text: ""

    height: visible ? 30 : 0

    property bool mouseOver: false
    property alias textAlignment: contentItemText.horizontalAlignment

    property bool lineBelowItem: false

    width: parent.width

    contentItem: Text {
        id: contentItemText
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.mouseOver ? "#111111" : "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 200 } }
        horizontalAlignment: Text.AlignLeft // Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: PQCheckbox {
        text: ""
        y: (parent.height-height)/2
        width: height
        checked: control.checked
        visible: control.checkable
        interactive: false
        onCheckedChanged:
            control.checked = checked
    }

    arrow: Item {}

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30
        opacity: enabled ? 1 : 0.3
        color: control.mouseOver ? "#aaaaaa" : "#88111111"
        Behavior on color { ColorAnimation { duration: 200 } }
        Rectangle {
            height: 1
            width: parent.width
            x: 0
            y: parent.height-1
            color: "#cccccc"
            visible: lineBelowItem
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered:
            control.mouseOver = true
        onExited:
            control.mouseOver = false
        onClicked: {
            if(control.checkable) {
                if(control.checked)
                    control.checked = false
                else
                    control.checked = true
            } else
                control.clicked()
        }
    }

}
