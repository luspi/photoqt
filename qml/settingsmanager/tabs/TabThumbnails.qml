import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./thumbnails"
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
				text: "Thumbnails"
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 10
				text: qsTr("Move your mouse cursor over the different settings titles to see more information.")
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			ThumbnailSize { id: thumbnailsize }
			Spacing { id: spacing; alternating: true }
			LiftUp { id: liftup }
			KeepVisible { id: keepvisible; alternating: true }
			Dynamic { id: dynamic }
			CenterOn { id: centeron; alternating: true }
			TopOrBottom { id: toporbottom }
			Label { id: label; alternating: true }
			FilenameOnly { id: filenameonly }
			Disable { id: disable; alternating: true }
			Cache { id: cache }


		}

	}

	function setData() {
		thumbnailsize.setData()
		spacing.setData()
		liftup.setData()
		keepvisible.setData()
		dynamic.setData()
		centeron.setData()
		toporbottom.setData()
		label.setData()
		filenameonly.setData()
		disable.setData()
		cache.setData()
	}

	function saveData() {
		thumbnailsize.saveData()
		spacing.saveData()
		liftup.saveData()
		keepvisible.saveData()
		dynamic.saveData()
		centeron.saveData()
		toporbottom.saveData()
		label.saveData()
		filenameonly.saveData()
		disable.saveData()
		cache.saveData()
	}

	function eraseDatabase() {
		thumbnailmanagement.eraseDatabase()
		updateDatabaseInfo()
	}

	function cleanDatabase() {
		thumbnailmanagement.cleanDatabase()
		updateDatabaseInfo()
	}

}
