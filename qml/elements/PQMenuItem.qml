import QtQuick 2.9
import QtQuick.Controls 2.2

MenuItem {

    id: control
    text: ""

    height: 30

    property bool mouseOver: false

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.mouseOver ? "#222222" : "#bbbbbb"
        Behavior on color { ColorAnimation { duration: 200 } }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: PQCheckbox {
        text: ""
        y: (parent.height-height)/2
        checked: control.checked
        visible: control.checkable
        interactive: false
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30
        opacity: enabled ? 1 : 0.3
        color: control.mouseOver ? "#bbbbbb" : "#222222"
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: "#444444"
        border.width: 1
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
