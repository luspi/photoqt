import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements/"


Rectangle {

	id: zoom
	y: 10
	width: zoom_slider.width+zoom_txt.width+zoom_txt.anchors.rightMargin
	height: parent.height-20
	color: "#00000000"

	signal updateZoom(var level)

	Text {
		id: zoom_txt
		color: "white"
		font.bold: true
		y: (parent.height-height)/2
		text: "Zoom:"
		anchors.right: zoom_slider.left
		anchors.rightMargin: 5
	}

	CustomSlider {
		id: zoom_slider
		width: 200
		y: (parent.height-height)/2
		anchors.right: parent.right
		minimumValue: 10
		maximumValue: 40
		tickmarksEnabled: true
		stepSize: 1
		scrollStep: 1
		value: settings.openZoomLevel
		onValueChanged:
			updateZoom(value)
	}

	function getZoomLevel() {
		return zoom_slider.value
	}

}
