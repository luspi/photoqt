import QtQuick
import QtQuick.Controls.Basic

CheckBox {

    id: control
    text: ""
    property int elide: Text.ElideNone

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal
    property string color: enabled ? PQCLook.textColor : PQCLook.textColorHighlight

    indicator: Rectangle {
        implicitWidth: 22
        implicitHeight: 22
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        opacity: enabled ? 1.0 : 0.3
        Behavior on opacity { NumberAnimation { duration: 200 } }

        border.color: PQCLook.inverseColor
        color: PQCLook.baseColorHighlight
        radius: 2
        Rectangle {
            width: 10
            height: 10
            anchors.centerIn: parent
            visible: control.checked
            color: PQCLook.inverseColor
            radius: 2
        }
    }

    contentItem: PQText {
        text: control.text
        elide: control.elide
        font: control.font
        color: control.color
        opacity: control.checked ? 1.0 : 0.7
        Behavior on opacity { NumberAnimation { duration: 200 } }
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    property bool _defaultChecked
    Component.onCompleted: {
        _defaultChecked = checked
    }

    function saveDefault() {
        _defaultChecked = checked
    }

    function setDefault(chk) {
        _defaultChecked = chk
    }

    function loadAndSetDefault(chk) {
        checked = chk
        _defaultChecked = chk
    }

    function hasChanged() {
        return _defaultChecked!==checked
    }

}
