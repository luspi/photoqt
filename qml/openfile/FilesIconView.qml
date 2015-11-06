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

	GridView {

		id: grid

		anchors.fill: parent

		cellWidth: 80;
		cellHeight: cellWidth*(4/3);
		highlight: Rectangle { color: "#22ffffff"; radius: 5 }
		focus: true

		property int prev_highlight: -1

		model: gridmodel
		delegate: gridDelegate

		onCurrentIndexChanged: {
			if(type_preview == "none")
				preview.source = ""
			else if(files[currentIndex] === "")
				return
			else
				preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[currentIndex])
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

			color: "#00000000"
			width: grid.cellWidth;
			height: grid.cellHeight

			Column {

				id: image_rect

				x: 10
				y: 10
				width: parent.width-20
				height: parent.height-20

				Image {
					id: icon
					opacity: 0.6
					Behavior on opacity { SmoothedAnimation { id: opacityimgani; velocity: 0.1; } }
					x: (parent.width-width)/2
					width: image_rect.width
					height: image_rect.height*0.6
					source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[index])
					fillMode: Image.PreserveAspectFit
				}

				Rectangle {

					id: textrect

					x: 5
					y: image_rect.height*0.6
					width: image_rect.width-10
					height: image_rect.height*0.4

					radius: 5
					color: "#BB000000"
					opacity: 0.4
					Behavior on opacity { SmoothedAnimation { id: opacityani; velocity: 0.1; } }

					Text {
						x: 3
						width: parent.width-6
						height: parent.height
						text: filename
						elide: Text.ElideRight
						wrapMode: Text.WrapAnywhere
						maximumLineCount: 2
						lineHeight: 0.8
						font.pointSize: 8
						clip: true
						font.bold: true
						color: "white"
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}
			}

			MouseArea {
				x: 10
				y: 10
				width: parent.width-20
				height: parent.height-20
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onEntered: {
					opacityani.duration = 200
					opacityimgani.duration = 200
					textrect.opacity = 1
					icon.opacity = 1
					grid.currentIndex = index
				}
				onExited: {
					textrect.opacity = 0.4
					icon.opacity = 0.6
				}
				onClicked: {
					hideOpenAni.start()
					reloadDirectory(dir_path + "/" + files[index],"")
				}
			}
		}
	}

	ListModel { id: gridmodel; }

	function loadDirectory(path) {

		gridmodel.clear()
		files = getanddostuff.getFilesIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)
		grid.contentY = 0
		for(var j = 0; j < files.length; ++j) {
			gridmodel.append({"filename" : files[j]})
		}

		if(files.length == 0)
			nothingfound.visible = true
		else
			nothingfound.visible = false

		if(grid.currentIndex != -1 && type_preview == "color")
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[grid.currentIndex])

	}

	function focusOnFile(filename) {

		var pattern = new RegExp(escapeRegExp(filename) + ".*","i")
		if(pattern.test(files[grid.currentIndex])) return
		var index = -1
		for(var i = 0; i < files.length; ++i) {
			if(pattern.test(files[i])) {
				index = i
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
		hideOpenAni.start()
		reloadDirectory(dir_path + "/" + files[grid.currentIndex],"")
	}

	function updatePreview() {

		if(files[grid.currentIndex] === undefined) {
			preview.source = ""
			return
		}

		if(type_preview == "none")
			preview.source = ""
		else
			preview.source = "image://full/" + dir_path + "/" + files[grid.currentIndex]

	}

}
