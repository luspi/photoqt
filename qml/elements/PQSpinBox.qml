import QtQuick
import QtQuick.Controls

SpinBox {
    id: control

    editable: true

    width: 160
    height: 30

    property alias liveValue: txtinp.text

    Timer {
        interval: 100
        running: true
        onTriggered:
            control.widthChanged()
    }

    contentItem: TextInput {
        id: txtinp
        text: control.value
        font: control.font
        color: enabled ? PQCLook.textColor : PQCLook.textColorHighlight
        Behavior on color { ColorAnimation { duration: 200 } }
        selectionColor: PQCLook.baseColorActive
        selectedTextColor: PQCLook.textColorActive
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        z: 3
        implicitWidth: 40
        implicitHeight: parent.height
        color: control.enabled ? (control.up.pressed ? PQCLook.baseColorActive : PQCLook.baseColorAccent) : PQCLook.baseColorAccent
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: PQCLook.baseColorHighlight
        border.width: 1

        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize * 2
            color: control.enabled ? PQCLook.textColor : PQCLook.textColorHighlight
            Behavior on color { ColorAnimation { duration: 200 } }
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        z: 3
        implicitWidth: 40
        implicitHeight: parent.height
        color: control.enabled ? (control.down.pressed ? PQCLook.baseColorActive : PQCLook.baseColorAccent) : PQCLook.baseColorAccent
        Behavior on color { ColorAnimation { duration: 200 } }
        border.color: PQCLook.baseColorHighlight
        border.width: 1

        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize * 2
            color: control.enabled ? PQCLook.textColor : PQCLook.textColorHighlight
            Behavior on color { ColorAnimation { duration: 200 } }
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 140
        color: PQCLook.baseColorHighlight
    }

}
