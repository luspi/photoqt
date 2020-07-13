import QtQuick 2.9
import QtQuick.Controls 2.2

TextField {

    id: control

    placeholderText: "Enter"
    color: "white"
    selectedTextColor: "black"
    selectionColor: "white"

    focus: true

    enabled: opacity>0 && visible

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: control.enabled ? "transparent" : "#cccccc"
        border.color: control.enabled ? "#cccccc" : "transparent"
    }

    function setFocus() {
        forceActiveFocus()
        selectAll()
    }

}
