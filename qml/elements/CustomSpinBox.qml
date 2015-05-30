import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

SpinBox {

	style: SpinBoxStyle{
		background: Rectangle {
			implicitWidth: 50
			implicitHeight: 25
			color: control.enabled ? colour.element_bg_color : colour.element_bg_color_disabled
			border.color: control.enabled ? colour.element_border_color : colour.element_border_color_disabled
			radius: global_item_radius
		}
		textColor: control.enabled ? colour.text : colour.disabled
		selectionColor: control.enabled ? colour.text_selection_color : colour.text_selection_color_disabled
		selectedTextColor: colour.text_selected
		decrementControl: Text {
			color: control.enabled ? colour.text : colour.disabled
			y: -height/3
			x: -2
			font.pixelSize: control.height*2/3
			text: "-"
		}
		incrementControl: Text {
			color: control.enabled ? colour.text : colour.disabled
			y: -height/3
			x: -2
			font.pixelSize: control.height*2/3
			text: "+"
		}
	}

}
