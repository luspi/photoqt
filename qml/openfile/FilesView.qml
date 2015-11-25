import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

Rectangle {

	id: top

	color: "#44000000"

	property var files: []
	property string dir_path: getanddostuff.getHomeDir()

	clip: true

	property int previous_width: 0
	property string previous_mode: ""

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
			cache: true
			Behavior on opacity { SmoothedAnimation { id: preview_load; velocity: 0.1; } }

			source: ""
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
					preview_load.duration = 200
				}
			}
		}

		Rectangle {
			anchors.fill: parent
			color: "#99000000"
		}
	}

	ListView {

		id: listview

		anchors.fill: parent

		focus: true

		property int prev_highlight: -1
		highlight: Rectangle { color: "#DD5d5d5d"; radius: 5 }
		highlightMoveDuration: 200

		model: listviewmodel
		delegate: listviewDelegate

		spacing: 2
		opacity: settings.openDefaultView==="list" ? 1: 0
		Behavior on opacity { SmoothedAnimation { id: opacitylistani; velocity: 0.1; } }
		onOpacityChanged: {
			if(opacity == 0)
				visible = false
		}

		onCurrentIndexChanged: {

			if(opacity == 1)
				gridview.currentIndex = currentIndex
			else
				return

			if(type_preview == "none" || files[2*currentIndex] === "")
				preview.source = ""
			else {
				if(previous_width != top.width || tweaks.getMode() !== previous_mode)
					updatePreviewSourceSize()
				preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*currentIndex])
			}

		}

	}

	GridView {

		id: gridview

		anchors.fill: parent

		cellWidth: tweaks.zoomlevel*5;
		cellHeight: cellWidth*(4/3);
		highlight: Rectangle { color: "#22ffffff"; radius: 5 }
		focus: true

		opacity: settings.openDefaultView==="icons" ? 1: 0
		Behavior on opacity { SmoothedAnimation { id: opacitygridani; velocity: 0.1; } }
		onOpacityChanged: {
			if(opacity == 0)
				visible = false
		}

		property int prev_highlight: -1

		model: gridviewmodel
		delegate: gridviewDelegate

		onCurrentIndexChanged: {

			if(opacity == 1)
				listview.currentIndex = currentIndex
			else
				return

			if(type_preview == "none" || files[2*currentIndex] === "")
				preview.source = ""
			else {
				if(previous_width != top.width || tweaks.getMode() !== previous_mode)
					updatePreviewSourceSize()
				preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*currentIndex])
			}

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

		id: listviewDelegate

		Rectangle {
			width: listview.width
			height: files_txt.height
			color: index%2==0 ? "#22ffffff" : "#11ffffff"

			Image {
				id: files_img
				source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[2*index])
				width: files_txt.height-4
				x: 7
				verticalAlignment: Image.AlignVCenter
				height: width
			}

			Text {
				id: files_txt
				x: 5 + files_img.width+5
				width: listview.width-15-files_size.width
				text: "<b>" + filename + "</b>"
				color: "white"
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: tweaks.zoomlevel
				elide: Text.ElideRight
			}
			Text {
				id:files_size
				x: (files_txt.x + files_txt.width) + 5
				width: Math.max(tweaks.zoomlevel*4,100)
				text: filesize
				color: "white"
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: tweaks.zoomlevel
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onEntered: {
					listview.currentIndex = index
					edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
					edit_rect.focusOnInput()
				}
				onClicked: {
					hideOpenAni.start()
					reloadDirectory(dir_path + "/" + filename,"")
				}
			}
		}
	}


	Component {

		id: gridviewDelegate

		Rectangle {

			color: "#00000000"
			width: gridview.cellWidth;
			height: gridview.cellHeight

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
					source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[2*index])
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
						font.pixelSize: tweaks.zoomlevel*0.75
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
					gridview.currentIndex = index
				}
				onExited: {
					textrect.opacity = 0.4
					icon.opacity = 0.6
				}
				onClicked: {
					hideOpenAni.start()
					reloadDirectory(dir_path + "/" + files[2*index],"")
				}
			}
		}
	}

	ListModel { id: listviewmodel; }
	ListModel { id: gridviewmodel; }

	function loadDirectory(path) {

		listviewmodel.clear()
		gridviewmodel.clear()
		files = getanddostuff.getFilesWithSizeIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)
		listview.contentY = 0
		for(var j = 0; j < files.length; j+=2) {
			listviewmodel.append({"filename" : files[j], "filesize" : files[j+1]})
			gridviewmodel.append({"filename" : files[j], "filesize" : files[j+1]})
		}

		if(files.length == 0)
			nothingfound.visible = true
		else
			nothingfound.visible = false

		preview.source = ""
		updatePreviewSourceSize()

		if(files.length > 0) {
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[0])
			focusOnFirstItem()
		}

	}

	function focusOnFile(filename) {

		var pattern = new RegExp(escapeRegExp(filename) + ".*","i")
		if(pattern.test(files[2*listview.currentIndex])) return
		var index = -1
		for(var i = 0; i < files.length; i+=2) {
			if(pattern.test(files[i])) {
				index = i/2
				break;
			}
		}
		if(index != -1)
			listview.currentIndex = index

	}

	function escapeRegExp(str) {
		return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
	}

	function loadCurrentlyHighlightedImage() {
		hideOpenAni.start()
		if(listview.opacity == 1)
			reloadDirectory(dir_path + "/" + files[listview.currentIndex*2],"")
		else if(gridview.opacity == 1)
			reloadDirectory(dir_path + "/" + files[gridview.currentIndex*2],"")
	}

	function focusOnNextItem() {
		if(listview.opacity == 1 && listview.currentIndex+1 < listview.count)
			listview.currentIndex += 1
		else if(gridview.opacity == 1 && gridview.currentIndex+1 < gridview.count)
			gridview.currentIndex += 1
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function focusOnPrevItem() {
		if(listview.opacity == 1 && listview.currentIndex > 0)
			listview.currentIndex -= 1
		else if(gridview.opacity == 1 && gridview.currentIndex > 0)
			gridview.currentIndex -= 1
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function moveFocusFiveDown() {
		if(listview.opacity == 1 && listview.currentIndex+10 < listview.count)
			listview.currentIndex += 10
		else if(gridview.opacity == 1 && gridview.currentIndex+10 < gridview.count)
			gridview.currentIndex += 10
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function moveFocusFiveUp() {
		if(listview.opacity == 1 && listview.currentIndex > 9)
			listview.currentIndex -= 10
		else if(gridview.opacity == 1 && gridview.currentIndex > 9)
			gridview.currentIndex -= 10
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function focusOnLastItem() {
		if(listview.opacity == 1 && listview.count > 0)
			listview.currentIndex = listview.count-1
		else if(gridview.opacity == 1 && gridview.count > 0)
			gridview.currentIndex = gridview.count
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function focusOnFirstItem() {
		if(listview.opacity == 1 && listview.count > 0)
			listview.currentIndex = 0
		else if(gridview.opacity == 1 && gridview.count > 0)
			gridview.currentIndex = 0
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function updatePreview() {

		if((listview.opacity == 1 && files[2*listview.currentIndex] === undefined)
				|| (gridview.opacity == 1 && files[2*gridview.currentIndex] === undefined)) {
			preview.source = ""
			return
		}

		if(previous_width != top.width || tweaks.getMode() !== previous_mode)
			updatePreviewSourceSize()

		if(type_preview == "none")
			preview.source = ""
		else if(listview.opacity == 1)
			preview.source = "image://full/" + dir_path + "/" + files[2*listview.currentIndex]
		else if(gridview.opacity == 1)
			preview.source = "image://full/" + dir_path + "/" + files[2*gridview.currentIndex]
	}

	function displayIcons() {

		opacitylistani.duration = 0
		opacitygridani.duration = 1
		listview.opacity = 1
		gridview.opacity = 0
		gridview.visible = true
		opacitygridani.duration = 300
		opacitylistani.duration = 300
		gridview.opacity = 1
		listview.opacity = 0

	}

	function displayList() {

		opacitylistani.duration = 0
		opacitygridani.duration = 1
		listview.opacity = 0
		gridview.opacity = 1
		listview.visible = true
		opacitygridani.duration = 300
		opacitylistani.duration = 300
		gridview.opacity = 0
		listview.opacity = 1

	}

	function updatePreviewSourceSize() {
		var mode = tweaks.getMode()
		preview.sourceSize = Qt.size((mode==="lq" ? 0.5 : 1)*preview.width,(mode==="lq" ? 0.5 : 1)*preview.height)
		previous_width = top.width
		previous_mode = tweaks.getMode()
	}

}

