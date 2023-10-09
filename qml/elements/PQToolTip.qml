import QtQuick
import QtQuick.Controls

ToolTip {

    id: control
    text: ""
    delay: 500

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    contentItem: PQText {
        id: contentText
        text: control.text
        font: control.font
        textFormat: Text.RichText
    }

    background: Rectangle {
        color: PQCLook.transColor
        border.color: PQCLook.inverseColorHighlight
    }

}
