import QtQuick 2.9
import QtQuick.Controls 2.2

ToolTip {
    id: control
    text: ""
    delay: 500

    property alias wrapMode: contentText.wrapMode
    property alias elide: contentText.elide
    property int maxWidth: -1

    contentItem: Text {
        id: contentText
        text: control.text
        font: control.font
        color: "white"
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
    }

    background: Rectangle {
        color: "#ee000000"
        border.color: "#ee666666"
    }

}
