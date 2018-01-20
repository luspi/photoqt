import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

ComboBox {

    property int fontsize: 10
    property bool transparentBackground: false
    property string backgroundColor: ""
    property bool displayAsError: false
    property bool showBorder: true
    property string tooltip: currentText
    property int radius: 0
    property real disabledOpacity: 0.5

    opacity: enabled ? 1 : disabledOpacity
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    style: ComboBoxStyle {

        background: Rectangle {
            clip: true
            radius: control.radius
            color: transparentBackground ? "transparent" : (backgroundColor=="" ? colour.element_bg_color : backgroundColor)
            border.width: showBorder ? 1 : 0
            border.color: transparentBackground ? colour.element_border_color_disabled : colour.element_border_color
            implicitWidth: 100
        }
        label: Text {
            id: txt
            font.pointSize: fontsize
            text: control.currentText
            font.bold: displayAsError
            elide: Text.ElideRight
            color: displayAsError ? colour.text_warning : colour.text
        }

        // Undocumented and unofficial way to style dropdown menu
        // Found at: http://qt-project.org/forums/viewthread/33188

        // drop-down customization here
        property Component __dropDownStyle: MenuStyle {

            __maxPopupHeight: 600
            __menuItemType: "comboboxitem"

            // background
            frame: Rectangle {
                color: colour.combo_dropdown_frame
                border.width: 1
                border.color: colour.combo_dropdown_frame_border
            }

            // an item text
            itemDelegate.label: Text {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: fontsize
                color: styleData.selected ? colour.combo_dropdown_text_highlight : colour.combo_dropdown_text
                text: styleData.text
            }

            // selection of an item
            itemDelegate.background: Rectangle {
                color: styleData.selected ? colour.combo_dropdown_background_highlight : colour.combo_dropdown_background
            }

            __scrollerStyle: ScrollViewStyle { }

        }

    }

    ToolTip {
        anchors.fill: parent
        text: parent.tooltip
        cursorShape: Qt.PointingHandCursor
        propagateComposedEvents: true
        onClicked: mouse.accepted = false
        onPressed: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }

}
