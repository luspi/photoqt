import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {

    id: control

    editable: true

    property string suffix: ""

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale) + suffix

        font: control.font
        color: "black"
        selectionColor: "black"
        selectedTextColor: "white"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhDigitsOnly
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.up.pressed ? "#444444" : "#222222"
        border.color: enabled ? "#000000" : "#333333"

        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize * 2
            color: "#ffffff"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.down.pressed ? "#444444" : "#222222"
        border.color: enabled ? "#000000" : "#333333"

        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize * 2
            color: "#ffffff"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 140
        color: "#cccccc"
        border.color: "#000000"
    }

}
