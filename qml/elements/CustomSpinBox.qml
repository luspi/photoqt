import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

SpinBox {

	font.pixelSize: height/2

	style: SpinBoxStyle{
		background: Rectangle {
			implicitWidth: 50
			implicitHeight: 25
			color: control.enabled ? colour.element_bg_color : colour.element_bg_color_disabled
			Behavior on color { ColorAnimation { duration: 150; } }
			border.color: control.enabled ? colour.element_border_color : colour.element_border_color_disabled
			Behavior on border.color { ColorAnimation { duration: 150; } }
			radius: global_item_radius
		}
		textColor: control.enabled ? colour.text : colour.text_disabled
		Behavior on textColor { ColorAnimation { duration: 150; } }

		selectionColor: control.enabled ? colour.text_selection_color : colour.text_selection_color_disabled
		Behavior on selectionColor { ColorAnimation { duration: 150; } }

		selectedTextColor: colour.text_selected
		decrementControl: Text {
			color: control.enabled ? colour.text : colour.text_disabled
			Behavior on color { ColorAnimation { duration: 150; } }
			y: -height/3
			x: -2
			font.pixelSize: control.height*2/3
			text: "-"
		}
		incrementControl: Text {
			color: control.enabled ? colour.text : colour.text_disabled
			Behavior on color { ColorAnimation { duration: 150; } }
			y: -height/3
			x: width/25
			font.pixelSize: control.height*2/3
			text: "+"
		}

	}

}
