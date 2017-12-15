import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"

Rectangle {

    id: rect

    property string fileEnding: ""
    property string fileType: ""
    property string description: ""

    property bool checked: false
    property bool hovered: false

    property var exclusiveGroup: ExclusiveGroup

    // Size
    width: 100
    height: 30

    // Look
    color: checked ? colour.tiles_active : (hovered ? colour.tiles_inactive : colour.tiles_disabled)
    Behavior on color { ColorAnimation { duration: 150 } }
    radius: variables.global_item_radius

    CustomCheckBox {
        y: (parent.height-height)/2
        x: y
        fixedwidth: parent.width-2*x
        elide: Text.ElideRight
        text: parent.fileType
        textColour: (hovered || checked) ? colour.tiles_text_active : colour.tiles_text_inactive
        indicatorColourEnabled: colour.tiles_indicator_col
        indicatorBackgroundColourEnabled: colour.tiles_indicator_bg
        fsize: 9
        checkedButton: parent.checked
    }

    ToolTip {
        text: description=="" ? "<b>" + rect.fileType + ":</b><br>" + rect.fileEnding
                              : "<b>" + rect.description + "</b><br>" + rect.fileEnding
        cursorShape: Qt.PointingHandCursor
        onEntered:
            hovered = true
        onExited:
            hovered = false
        onClicked:
            checked = !checked
    }

}
