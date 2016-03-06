import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

Rectangle {

	id: top

	color: (!folders.activeFocus && !userplaces.activeFocus) ? "#44000055" : "#44000000"

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

			sourceSize: Qt.size((settings.openPreviewMode==="lq" ? 0.5 : 0.8)*preview.width,(settings.openPreviewMode==="lq" ? 0.5 : 0.8)*preview.height)

			onWidthChanged:
				setSourceSizeAtStart()
			onHeightChanged:
				setSourceSizeAtStart()

			onStatusChanged: {
				if(status == Image.Ready) {
						preview.opacity = 1
				} else {
					preview_load.duration = 0
					preview.opacity = 0
					preview_load.duration = 200
				}
			}

			function setSourceSizeAtStart() {
				if(sourceSize.height <= 5 || sourceSize.width <= 5)
					sourceSize = Qt.size((settings.openPreviewMode==="lq" ? 0.5 : 0.8)*width,(settings.openPreviewMode==="lq" ? 0.5 : 0.8)*height)
			}

		}

		Rectangle {
			anchors.fill: parent
			color: "#99000000"
		}
	}

	FilesViewList {
		id: listview
	}

	FilesViewGrid {
		id: gridview
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

	function loadDirectory(path) {

		files = getanddostuff.getFilesWithSizeIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)

		listview.loadFiles(files)
		gridview.loadFiles(files)

		if(files.length == 0)
			nothingfound.visible = true
		else
			nothingfound.visible = false

		preview.source = ""
		updatePreviewSourceSize()

		if(files.length > 0)
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[0])

	}

	function focusOnFile(filename) {
		listview.focusOnFile(filename)
		gridview.focusOnFile(filename)
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
		if(listview.opacity == 1 && listview.currentIndex+5 < listview.count)
			listview.currentIndex += 5
		else if(listview.opacity == 1 && listview.count > 0)
			listview.currentIndex = listview.count-1
		else if(gridview.opacity == 1 && gridview.currentIndex+5 < gridview.count)
			gridview.currentIndex += 5
		else if(gridview.opacity == 1 && gridview.count > 0)
			gridview.currentIndex = gridview.count-1
		edit_rect.setEditText(getanddostuff.removePathFromFilename(preview.source, true))
		edit_rect.focusOnInput()
	}

	function moveFocusFiveUp() {
		if(listview.opacity == 1 && listview.currentIndex > 4)
			listview.currentIndex -= 5
		else if(listview.opacity == 1 && listview.count > 0)
			listview.currentIndex = 0
		else if(gridview.opacity == 1 && gridview.currentIndex > 4)
			gridview.currentIndex -= 5
		else if(gridview.opacity == 1 && gridview.count > 0)
			gridview.currentIndex = 0
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

		listview.displayIcons()
		gridview.displayIcons()

	}

	function displayList() {

		listview.displayList()
		gridview.displayList()

	}

	function updatePreviewSourceSize() {
		var mode = tweaks.getMode()
		preview.sourceSize = Qt.size((mode==="lq" ? 0.5 : 0.8)*preview.width,(mode==="lq" ? 0.5 : 0.8)*preview.height)
		previous_width = top.width
		previous_mode = tweaks.getMode()
	}

}

