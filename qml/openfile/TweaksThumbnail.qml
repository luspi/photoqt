import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements"

Rectangle {
	id: thumb_but
	y: 10
	width: thumbs.width+20
	height: parent.height-20
	color: "#00000000"

	// A button to set high quality preview images
	Button {
		id: thumbs
		checkable: true
		checked: settings.openThumbnails
		onCheckedChanged:
			settings.openThumbnails = checked
		iconSource: "qrc:/img/openfile/thumbnail.png"
		width: height
		height: parent.height
		style: ButtonStyle {
			background: Rectangle {
				implicitHeight: thumb_but.height
				anchors.fill: parent
				anchors.leftMargin: -10
				anchors.rightMargin: -10
				radius: 5
				color: "#313131"
				Rectangle {
					anchors.fill: parent
					radius: 5
					color: control.checked ? "#696969" : "#00000000"
				}

			}
			label: Image {
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				source: control.iconSource
				sourceSize: Qt.size(control.width, control.height)
			}
		}
		ToolTip {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			text: "En-/Disable image thumbnails"
			onClicked: {
				thumbs.checked = !thumbs.checked
			}
		}
	}
	function getThumbnailEnabled() {
		return thumbs.checked
	}
	function setThumbnailChecked(s) {
		thumbs.checked = s
	}
}
