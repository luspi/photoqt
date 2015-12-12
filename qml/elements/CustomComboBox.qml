import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

ComboBox {

	property int fontsize: 10
	property bool transparentBackground: false

	style: ComboBoxStyle {

		background: Rectangle {
			color: transparentBackground ? "transparent" : colour.element_bg_color
			border.width: 1
			border.color: transparentBackground ? colour.element_border_color_disabled : colour.element_border_color
			implicitWidth: 100
		}
		label: Text {
			id: txt
			font.pointSize: fontsize
			text: control.currentText
			color: colour.text
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

}
