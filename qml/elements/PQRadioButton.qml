import QtQuick
import QtQuick.Controls.Basic

RadioButton {

    id: control
    text: ""
    property int elide: Text.ElideNone

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        border.color: enabled ? PQCLook.inverseColor : PQCLook.inverseColorHighlight
        Behavior on border.color { ColorAnimation { duration: 200 } }
        color: enabled ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent
        Behavior on color { ColorAnimation { duration: 200 } }
        Rectangle {
            width: 14
            height: 14
            radius: 7
            anchors.centerIn: parent
            visible: control.checked
            color: enabled ? PQCLook.inverseColor : PQCLook.inverseColorHighlight
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    contentItem: PQText {
        text: control.text
        elide: control.elide
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

}
