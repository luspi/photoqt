import QtQuick 2.5

import "../../../elements"

Rectangle {

    id: rect

    property string text: ""
    property string tooltip: text

    property bool checked: false
    property bool hovered: false

    // Size
    width: 200
    height: 30

    // Look
    color: enabled ? (checked ? colour.tiles_active : (hovered ? colour.tiles_inactive : colour.tiles_disabled)) : colour.tiles_disabled
    Behavior on color { ColorAnimation { duration: 150; } }
    radius: variables.global_item_radius

    // And the checkbox indicator
    CustomCheckBox {

        id: check

        checkedButton: checked

        y: (parent.height-height)/2
        x: y
        width: parent.width-2*x

        indicatorColourEnabled: colour.tiles_indicator_col
        indicatorBackgroundColourEnabled: colour.tiles_indicator_bg

        text: rect.text
        textColour: (hovered || checked) ? colour.tiles_text_active : colour.tiles_text_inactive

    }

    // A mouseares governing the hover/checked look
    ToolTip {

        text: parent.tooltip
        anchors.fill: rect
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: checked = !checked

    }


}
