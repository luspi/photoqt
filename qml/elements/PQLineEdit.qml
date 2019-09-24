import QtQuick 2.9
import QtQuick.Controls 2.2

TextField {

    id: control

    placeholderText: qsTr("Enter new filename")
    placeholderTextColor: "#999999"
    color: "white"
    selectedTextColor: "black"
    selectionColor: "white"

    focus: true

    enabled: visible
    onEnabledChanged:
        variables.textEditFocused = enabled

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: control.enabled ? "transparent" : "#cccccc"
        border.color: control.enabled ? "#cccccc" : "transparent"
    }

    function setFocus() {
        control.forceActiveFocus()
        control.focus = true
    }

}
