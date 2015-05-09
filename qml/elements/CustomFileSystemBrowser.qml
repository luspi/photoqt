import QtQuick 2.3
import Qt.labs.folderlistmodel 2.1

ListView {
	id: view
	width: parent.width
	height: 250

	FolderListModel {
		id: folderModel
		showDirs: true
		showFiles: false
		showDotAndDotDot: true

		folder: "file:///home/luspi/"


	}

	Component {
		id: fileDelegate
		Rectangle {
			width: rect.width
			height: childrenRect.height
			color: "#00000000"
			Text {
				id: fol
				text: fileName
				color: "white"
			}
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: parent.color = "#606060"
				onExited: parent.color = "#00000000"
				onClicked: folderModel.folder = folderModel.folder + "/" + fol.text
			}
		}
	}

	model: folderModel
	delegate: fileDelegate

}
