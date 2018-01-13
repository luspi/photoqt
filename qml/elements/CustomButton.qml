import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {

    id: but

    property bool pressedDown: false
    property bool hovered: false
    property int fontsize: 13
    property string overrideFontColor: ""
    property string overrideBackgroundColor: ""
    property int wrapMode: Text.NoWrap
    property string tooltip: text
    property bool fontBold: false

    height: 2.5*fontsize

    signal clickedButton()
    signal rightClickedButton()

    style: ButtonStyle {

        background: Rectangle {
            anchors.fill: parent
            color: overrideBackgroundColor!="" ? overrideBackgroundColor : control.enabled ? (control.pressedDown ? colour.button_bg_pressed : (control.hovered ? colour.button_bg_hovered : colour.button_bg)) : colour.button_bg_disabled
            Behavior on color { ColorAnimation { duration: 150; } }
            radius: variables.global_item_radius
        }

        label: Text {
            id: txt
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: fontsize
            wrapMode: but.wrapMode
            color: overrideFontColor!="" ? overrideFontColor : control.enabled ? ((control.hovered || control.pressedDown) ? colour.button_text_active : colour.button_text) : colour.button_text_disabled
            Behavior on color { ColorAnimation { duration: 150; } }
            text: "  " + control.text + "  "
            font.bold: fontBold
        }

    }

    ToolTip {

        text: parent.tooltip
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: but.pressedDown = true
        onReleased: but.pressedDown = false
        onEntered: but.hovered = true
        onExited: but.hovered = false
        onClicked: {
            if(mouse.button == Qt.LeftButton)
                clickedButton()
            else
                rightClickedButton()
        }

    }

}
