import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

Rectangle {

	id: folderlist

	Layout.minimumWidth: 200
	width: 400
	color: "#44000000"
	clip: true

	property string dir_path: getanddostuff.getHomeDir()
	property var folders: []

	ListView {

		id: folderlistview
		anchors.fill: parent

		model: ListModel { id: folderlistmodel; }

		delegate: Rectangle {
			width: folderlist.width
			height: folder_txt.height+10
			color: index%2==0 ? "#88000000" : "#44000000"

			Image {
				id: folder_img
				source: "image://icon/folder"
				width: folder_txt.height-4
				y: 7
				x: 7
				height: width
			}

			Text {
				y: 5
				x: 5 + folder_img.width+5
				id: folder_txt
				width: folderlist.width-(x+5)
				text: "<b>" + folder + "</b>" + ((counter==0||folder=="..") ? "" : " <i>(" + counter + ")</i>")
				color: "white"
				font.pointSize: 12
				elide: Text.ElideRight
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onEntered: {
					parent.color = "#DD5d5d5d"
				}
				onExited: {
					parent.color = (index%2==0 ? "#88000000" : "#44000000")
				}
				onClicked: {
					loadCurrentDirectory(dir_path + "/" + folder)
				}
			}
		}

	}

	function loadDirectory(path) {

		folderlistmodel.clear()
		folders = getanddostuff.getFoldersIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)

		for(var j = 0; j < folders.length; ++j)
			folderlistmodel.append({"folder" : folders[j], "counter" : getanddostuff.getNumberFilesInFolder(dir_path + "/" + folders[j])})

	}

}
