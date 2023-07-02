import QtQuick
import QtQuick.Controls

CheckBox {

    id: control
    text: ""
    property int elide: Text.ElideNone

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        border.color: PQCLook.inverseColor
        color: PQCLook.baseColorHighlight
        radius: 2
        Rectangle {
            width: 14
            height: 14
            anchors.centerIn: parent
            visible: control.checked
            color: PQCLook.inverseColor
            radius: 2
        }
    }

    contentItem: PQTextL {
        text: control.text
        elide: control.elide
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
