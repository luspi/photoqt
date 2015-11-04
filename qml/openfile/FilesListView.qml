import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

Rectangle {

	Layout.minimumWidth: 200
	Layout.fillWidth: true
	color: "#44000000"

	property var files: []
	property string dir_path: getanddostuff.getHomeDir()

	Rectangle {

		color: "#AA000000"
		anchors.fill: parent

		Image {

			id: preview

			anchors.fill: parent
			anchors.margins: 10
			fillMode: Image.PreserveAspectFit
			asynchronous: true
			opacity: 0
			Behavior on opacity { SmoothedAnimation { id: preview_load; velocity: 0.1; } }

			source: ""
			sourceSize: Qt.size(width,height)
			onSourceChanged: {
				var s = getanddostuff.getImageSize(source)
				if(s.width < width && s.height < height)
					fillMode = Image.Pad
				else
					fillMode = Image.PreserveAspectFit
			}

			onStatusChanged: {
				if(status == Image.Ready) {
						preview.opacity = 1
				} else {
					preview_load.duration = 0
					preview.opacity = 0
					preview_load.duration = 400
				}
			}
		}

		Rectangle {
			anchors.fill: parent
			color: "#99000000"
		}
	}

	ListView {

		id: grid

		anchors.fill: parent

		focus: true

		property int prev_highlight: -1

		model: gridmodel
		delegate: gridDelegate

		onCurrentIndexChanged: {
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*currentIndex])
		}

	}

	Text {
		id: nothingfound
		visible: false
		anchors.fill: parent
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		font.pointSize: 30
		wrapMode: Text.WordWrap
		color: "grey"
		text: "No images found in this folder"
	}

	Component {

		id: gridDelegate

		Rectangle {
			width: grid.width
			height: files_txt.height+10
			color: index%2==0 ? "#22ffffff" : "#11ffffff"

			Image {
				id: files_img
				source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[2*index])
				width: files_txt.height-4
				y: 7
				x: 7
				height: width
			}

			Text {
				id: files_txt
				y: 5
				x: 5 + files_img.width+5
				width: grid.width-(x+5)-files_size.width
				text: "<b>" + filename + "</b>"
				color: "white"
				font.pointSize: 12
				elide: Text.ElideRight
			}
			Text {
				id:files_size
				x: (files_txt.x + files_txt.width) + 5
				width: 100
				text: filesize
				color: "white"
				font.pointSize: 12
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onEntered: {
					parent.color = "#33ffffff"
					grid.currentIndex = index
				}
				onExited:
					parent.color = (index%2==0 ? "#22ffffff" : "#11ffffff")
				onClicked: {
					reloadDirectory(dir_path + "/" + filename,"")
					hideOpenAni.start()
				}
			}
		}
	}

	ListModel { id: gridmodel; }

	function loadDirectory(path) {

		gridmodel.clear()
		files = getanddostuff.getFilesWithSizeIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)
		grid.contentY = 0
		for(var j = 0; j < files.length; j+=2) {
			gridmodel.append({"filename" : files[j], "filesize" : files[j+1]})
		}

		if(files.length == 0)
			nothingfound.visible = true
		else
			nothingfound.visible = false

		if(grid.currentIndex != -1)
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*grid.currentIndex])

	}

}
