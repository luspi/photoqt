import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./metadata"
import "../../elements"


Rectangle {

	id: tab_top

	property int titlewidth: 100

	color: "#00000000"

	anchors {
		fill: parent
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+20
		contentWidth: maincol.width

		Column {

			id: maincol

			Rectangle { color: "transparent"; width: 1; height: 10; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 20
				font.bold: true
				text: "Image Metadata"
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Text {
				color: "white"
				width: flickable.width-20
				x: 10
				wrapMode: Text.WordWrap
				text: qsTr("PhotoQt can display different information of and about each image. The widget for this information is on the left outside the screen and slides in when mouse gets close to it and/or when the set shortcut (default Ctrl+E) is triggered. On demand, the triggering by mouse movement can be disabled by checking the box below.")
			}

			Rectangle { color: "transparent"; width: 1; height: 30; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			MouseTrigger { id: trigger }
			Metadata { id: metadata; alternating: true }
			FontSize { id: fontsize }
			RotateFlip { id: rotateflip; alternating: true }
			OnlineMap { id: onlinemap }


		}

	}

	function setData() {
		trigger.setData()
		metadata.setData()
		fontsize.setData()
		rotateflip.setData()
		onlinemap.setData()
	}

	function saveData() {
		trigger.saveData()
		metadata.saveData()
		fontsize.saveData()
		rotateflip.saveData()
		onlinemap.saveData()
	}

}
