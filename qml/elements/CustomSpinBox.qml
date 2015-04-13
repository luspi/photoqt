import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

SpinBox {

	style: SpinBoxStyle{
		background: Rectangle {
			implicitWidth: 50
			implicitHeight: 25
			color: control.enabled ? "#88000000" : "#55000000"
			border.color: control.enabled ? "#99969696" : "#44969696"
			radius: 2
		}
		textColor: control.enabled ? "white" : "grey"
		selectionColor: control.enabled ? "white" : "grey"
		selectedTextColor: "black"
		decrementControl: Text {
			color: control.enabled ? "white" : "grey"
			y: -height/3
			x: -2
			font.pixelSize: control.height*2/3
			text: "-"
		}
		incrementControl: Text {
			color: control.enabled ? "white" : "grey"
			y: -height/3
			x: -2
			font.pixelSize: control.height*2/3
			text: "+"
		}
	}

}
