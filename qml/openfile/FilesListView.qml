import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

Rectangle {

	color: "#44000000"

	property var files: []
	property string dir_path: getanddostuff.getHomeDir()
	property string mode: tweaks.getMode()

	clip: true

	Rectangle {

		color: "#00000000"
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
			sourceSize: Qt.size((mode=="lq" ? 0.5 : 1)*width,(mode=="lq" ? 0.5 : 1)*height)
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
		highlight: Rectangle { color: "#DD5d5d5d"; radius: 5 }
		highlightMoveDuration: 200

		model: gridmodel
		delegate: gridDelegate

		onCurrentIndexChanged: {
			if(type_preview == "none")
				preview.source = ""
			else if(files[2*currentIndex] === "")
				return
			else
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
//					parent.color = "#33ffffff"
					grid.currentIndex = index
				}
//				onExited:
//					parent.color = (index%2==0 ? "#22ffffff" : "#11ffffff")
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

		if(grid.currentIndex != -1 && type_preview == "color")
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*grid.currentIndex])

	}

	function focusOnFile(filename) {

		var pattern = new RegExp(escapeRegExp(filename) + ".*","i")
		if(pattern.test(files[2*grid.currentIndex])) return
		var index = -1
		for(var i = 0; i < files.length; i+=2) {
			if(pattern.test(files[i])) {
				index = i/2
				break;
			}
		}
		if(index != -1)
			grid.currentIndex = index

	}

	function escapeRegExp(str) {
		return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
	}

	function loadCurrentlyHighlightedImage() {
		reloadDirectory(dir_path + "/" + files[grid.currentIndex*2],"")
		hideOpenAni.start()
	}

	function focusOnNextItem() {
		if(grid.currentIndex+1 < grid.count)
			grid.currentIndex += 1
	}

	function focusOnPrevItem() {
		if(grid.currentIndex > 0)
			grid.currentIndex -= 1
	}

	function updatePreview() {

		if(files[2*grid.currentIndex] === undefined) {
			preview.source = ""
			return
		}

		if(type_preview == "none")
			preview.source = ""
		else
			preview.source = "image://full/" + dir_path + "/" + files[2*grid.currentIndex]
	}

}
