import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {

	id: iconlist

	color: "#00000000"

	width: 60 + viewmode_txt.width
	y: 10
	height: parent.height-20

	Text {
		id: viewmode_txt
		anchors.right: viewmode_list.left
		color: "white"
		text: "View mode: "
		font.bold: true
		height: parent.height
		verticalAlignment: Text.AlignVCenter
	}

	ExclusiveGroup { id: view_grp }

	Button {
		id: viewmode_list
		anchors.right: viewmode_icon.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: (parent.width-viewmode_txt.width)/2
		checkable: true
		exclusiveGroup: view_grp
		checked: settings.openDefaultView === "list"
		style: ButtonStyle {
			background: Rectangle {
				implicitWidth: iconlist.height
				implicitHeight: implicitWidth
				anchors.fill: parent
				radius: 5
				color: control.checked ? "#696969" : "#313131"
				Image {
					opacity: control.checked ? 1: 0.2
					width: parent.width
					height: parent.height
					source: Qt.resolvedUrl("qrc:/img/openfile/listview.png")
				}
			}
		}
		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				if(!viewmode_list.checked) {
					viewmode_list.checked = true
					displayList()
				}
			}
		}
	}

	Button {
		id: viewmode_icon
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: (parent.width-viewmode_txt.width)/2
		checkable: true
		exclusiveGroup: view_grp
		checked: settings.openDefaultView === "icons"
		style: ButtonStyle {
			background: Rectangle {
				implicitWidth: iconlist.height
				implicitHeight: implicitWidth
				anchors.fill: parent
				radius: 5
				color: control.checked ? "#696969" : "#313131"
				Image {
					opacity: control.checked ? 1: 0.2
					width: parent.width
					height: parent.height
					source: Qt.resolvedUrl("qrc:/img/openfile/iconview.png")
				}
			}
		}
		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				if(!viewmode_icon.checked) {
					viewmode_icon.checked = true
					displayIcons()
				}
			}
		}
	}

	function getView() {
		return viewmode_icon.checked ? "icons" : "list"
	}

}
