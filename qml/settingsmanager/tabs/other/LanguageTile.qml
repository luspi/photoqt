import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"

Rectangle {

    id: rect

    property string text: ""
    property string author: ""
    property string code: ""

    property bool checked: false
    property bool hovered: false

    property var exclusiveGroup: ExclusiveGroup

    // Size
    width: 200
    height: 30

    // Look
    color: checked ? colour.tiles_active : (hovered ? colour.tiles_inactive : colour.tiles_disabled)
    radius: variables.global_item_radius

    // And the checkbox indicator
    CustomRadioButton {

        id: check

        exclusiveGroup: parent.exclusiveGroup

        objectName: parent.objectName

        checked: parent.checked

        y: (parent.height-height)/2
        x: y
        width: parent.width-2*x

        indicatorColourEnabled: colour.tiles_indicator_col
        indicatorBackgroundColourEnabled: colour.tiles_indicator_bg

        text: rect.text
        textColour: (hovered || checked) ? colour.tiles_text_active : colour.tiles_text_inactive

        onCheckedChanged: parent.checked = checked

    }

    // The mousearea of the Tooltip governs the hover/checked look
    ToolTip {
        text: rect.text
        cursorShape: Qt.PointingHandCursor
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: checked = !checked
    }

}
