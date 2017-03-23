import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
//import QtQuick.Layouts 1.0

Menu {
    id: contextmenu

    style: MenuStyle {

        frame: Rectangle { color: colour.menu_frame }
        itemDelegate.background: Rectangle { color: (styleData.selected ? (enabled ? colour.menu_bg_highlight : colour.menu_bg_highlight_disabled) : colour.menu_bg) }
        itemDelegate.label: Text { color: (enabled ? colour.menu_text : colour.menu_text_disabled); text: styleData.text }

        itemDelegate.checkmarkIndicator: Rectangle {
                implicitWidth: 10
                implicitHeight: 10
                radius: global_item_radius/2
                color: control.enabled ? colour.radio_check_indicator_bg_color : colour.radio_check_indicator_bg_color_disabled
                Behavior on color { ColorAnimation { duration: 150; } }
                Rectangle {
                    visible: styleData.checked
                    color: control.enabled ? colour.radio_check_indicator_color : colour.radio_check_indicator_color_disabled
                    Behavior on color { ColorAnimation { duration: 150; } }
                    radius: global_item_radius/2
                    anchors.margins: 2
                    anchors.fill: parent
                }
            }

    }
}
