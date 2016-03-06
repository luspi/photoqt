import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements"

Rectangle {
	id: prev_but
	y: 10
	width: prev_txt.width+prev_txt.anchors.rightMargin
		   +left_edge.width+left_edge.anchors.rightMargin
		   +right_edge.width+right_edge.anchors.leftMargin
		   +prev_high.width+prev_low.width+prev_none.width+20
	height: parent.height-20
	color: "#00000000"

	function getMode() {
		return prev_high.checked ? "hq" : (prev_low.checked ? "lq" : (prev_none.checked ? "none" : undefined))
	}

	// Starting text explaining the following buttons
	Text {
		id: prev_txt
		anchors.right: left_edge.left
		anchors.rightMargin: 3
		color: "white"
		text: "Hover Preview: "
		font.bold: true
		height: parent.height
		verticalAlignment: Text.AlignVCenter
		ToolTip {
			cursorShape: Qt.WhatsThisCursor
			text: "This is the large preview image that is shown behind all files when you hover an image with your mouse cursor."
		}
	}

	// Only one button can be checked at a time -> changing the button check causes preview reload
	ExclusiveGroup {
		id: prev_grp;
		onCurrentChanged: {
			filesview.updatePreview()
			settings.openPreviewMode = getMode()	// save setting
		}
	}

	// The left edge is rounded (we make it appear as is (left half hidden behind button)
	Rectangle {
		id: left_edge
		height: prev_high.height
		width: height
		radius: height
		anchors.right: prev_high.left
		anchors.rightMargin: -width/2
		color: "#313131"
	}

	// The right edge is also rounded (we make it appear as is (right half hidden behind button)
	Rectangle {
		id: right_edge
		height: prev_high.height
		width: height
		radius: height
		anchors.left: prev_none.right
		anchors.leftMargin: -width/2
		color: "#313131"
	}

	// A button to set high quality preview images
	Button {
		id: prev_high
		anchors.right: prev_low.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		checkable: true
		exclusiveGroup: prev_grp
		checked: settings.openPreviewMode === "hq"
		text: "High Quality"
		style: ButtonStyle {
			background: Rectangle {
				implicitHeight: prev_but.height
				anchors.fill: parent
				color: "#313131"
				Rectangle {
					anchors.fill: parent
					radius: 5
					color: control.checked ? "#696969" : "#00000000"
				}

			}
			label: Text {
				color: "white"
				font.bold: true
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: control.text
			}
		}
		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				if(!prev_high.checked)
					prev_high.checked = true
			}
		}
	}

	// A button to set low quality preview images
	Button {
		id: prev_low
		anchors.right: prev_none.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		checkable: true
		exclusiveGroup: prev_grp
		text: "Low Quality"
		checked: settings.openPreviewMode === "lq"
		style: ButtonStyle {
			background: Rectangle {
				implicitHeight: prev_but.height
				anchors.fill: parent
				color: "#313131"
				Rectangle {
					anchors.fill: parent
					radius: 5
					color: control.checked ? "#696969" : "#00000000"
				}

			}
			label: Text {
				color: "white"
				font.bold: true
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: control.text
			}
		}
		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				if(!prev_low.checked)
					prev_low.checked = true
			}
		}
	}

	// A button to disable preview images altogether
	Button {
		id: prev_none
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		checkable: true
		exclusiveGroup: prev_grp
		text: "No Preview"
		checked: settings.openPreviewMode === "none"
		style: ButtonStyle {
			background: Rectangle {
				implicitHeight: prev_but.height
				anchors.fill: parent
				color: "#313131"
				Rectangle {
					anchors.fill: parent
					radius: 5
					color: control.checked ? "#696969" : "#00000000"
				}

			}
			label: Text {
				color: "white"
				font.bold: true
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: control.text
			}
		}
		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				if(!prev_none.checked)
					prev_none.checked = true
			}
		}
	}


}
