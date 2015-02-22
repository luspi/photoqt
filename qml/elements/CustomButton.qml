import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Button {

    id: but

    property bool pressedDown: false
    property bool hovered: false

    signal clickedButton()

    style: ButtonStyle {

        background: Rectangle {
            color: but.pressedDown ? "#BB292929" : (but.hovered ? "#BB181818" : "#BB000000")
            radius: 6
            border.width: 1
            border.color: "#CC333333"
        }

        label: Text {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: "white"
            text: "  " + but.text + "  "
        }

    }

    MouseArea {

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: but.pressedDown = true
        onReleased: but.pressedDown = false
        onEntered: but.hovered = true
        onExited: but.hovered = false
        onClicked: clickedButton()

    }

}
