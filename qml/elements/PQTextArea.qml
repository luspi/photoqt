import QtQuick
import QtQuick.Controls

ScrollView {

    id: control

    clip: true

    property alias text: textarea.text
    property alias placeholderText: textarea.placeholderText
    property alias controlFocus: textarea.focus
    property alias controlActiveFocus: textarea.activeFocus
    property alias cursorPosition: textarea.cursorPosition

    implicitWidth: 200
    implicitHeight: 200

    ScrollBar.vertical:
        PQVerticalScrollBar {
            x: parent.width - width
            height: control.availableHeight
        }

    ScrollBar.horizontal:
        PQHorizontalScrollBar {
            y: parent.height - height
            width: control.availableWidth
        }


    TextArea {

        id: textarea

        color: PQCLook.textColor

        font.pointSize: PQCLook.fontSize
        font.weight: PQCLook.fontWeightNormal

        background: Rectangle {
            implicitWidth: control.implicitWidth
            implicitHeight: control.implicitHeight
            color: PQCLook.baseColor
            border.color: PQCLook.baseColorHighlight
        }
    }

}
