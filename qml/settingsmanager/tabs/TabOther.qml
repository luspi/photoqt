import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./other"
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
				text: "Other Settings"
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 30; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Language { id: language }
			CustomEntries { id: customentries; alternating: true }
			FileTypesQt { id: filetypesqt }
			FileTypesGM { id: filetypesgm; alternating: true }
			FileTypesGMGhostscript { id: filetypesgmghostscript }
			FileTypesExtras { id: filetypesextras; alternating: true }
			FileTypesUntested { id: filetypesuntested }


		}

	}

	function setData() {
		language.setData()
		customentries.setData()
		filetypesqt.setData()
		filetypesgm.setData()
		filetypesgmghostscript.setData()
		filetypesextras.setData()
		filetypesuntested.setData()
	}

	function saveData() {
		language.saveData()
		customentries.saveData()
		filetypesqt.saveData()
		filetypesgm.saveData()
		filetypesgmghostscript.saveData()
		filetypesextras.saveData()
		filetypesuntested.saveData()
	}

}
