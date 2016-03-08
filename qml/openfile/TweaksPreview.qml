import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements"

Rectangle {
	id: hovprev_but
	y: 10
	width: hovprev.width+20
	height: parent.height-20
	color: "#00000000"

	property bool isHoverEnabled: hovprev.checked

	// A button to set high quality preview images
	Button {
		id: hovprev
		checkable: true
		checked: settings.openPreview
		onCheckedChanged:
			settings.openPreview = checked
		iconSource: "qrc:/img/openfile/hoverpreview.png"
		width: height
		height: parent.height
		style: ButtonStyle {
			background: Rectangle {
				implicitHeight: hovprev_but.height
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
			text: "En-/Disable hover preview"
			onClicked: {
				hovprev.checked = !hovprev.checked
			}
		}
	}
	function getHoverPreviewEnabled() {
		return hovprev.checked
	}
	function setHoverPreviewChecked(s) {
		hovprev.checked = s
	}
}
