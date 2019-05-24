import QtQuick 2.9
import QtQuick.Controls 2.2

ToolTip {
    id: control
    text: ""
    delay: 500

    contentItem: Text {
        text: control.text
        font: control.font
        color: "white"
    }

    background: Rectangle {
        color: "#ee000000"
        border.color: "#ee666666"
    }

}
