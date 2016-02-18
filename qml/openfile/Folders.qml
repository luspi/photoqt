import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

Rectangle {

	id: folderlist

	Layout.minimumWidth: 200
	width: settings.openFoldersWidth
	color: activeFocus ? "#44000055" : "#44000000"
	clip: true

	property string dir_path: getanddostuff.getHomeDir()
	property var folders: []

	signal focusOnFilesView()
	signal focusOnUserPlaces()

	ListView {

		id: folderlistview
		anchors.fill: parent

		highlight: Rectangle { color: "#DD5d5d5d"; radius: 5 }
		highlightMoveDuration: 50

		property string highlightedFolder: ""

		model: ListModel { id: folderlistmodel; }

		onCurrentIndexChanged:{
			if(!activeFocus)
				folderlist.forceActiveFocus()
		}

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
				font.pixelSize: tweaks.zoomlevel
				elide: Text.ElideRight
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onEntered:
					folderlistview.currentIndex = index
				onClicked:
					loadCurrentDirectory(dir_path + "/" + folder)
			}
		}

	}

	Keys.onPressed: {

		if(event.key === Qt.Key_Left) {

			if(event.modifiers & Qt.AltModifier)
				focusOnUserPlaces()

		} else if(event.key === Qt.Key_Right) {

			if(event.modifiers & Qt.AltModifier)
				focusOnFilesView()

		} else if(event.key === Qt.Key_Up) {
			if(event.modifiers & Qt.ControlModifier)
				focusOnFirstItem()
			else if(event.modifiers & Qt.AltModifier)
				moveOneLevelUp()
			else
				focusOnPrevItem()
		} else if(event.key === Qt.Key_Down) {
			if(event.modifiers & Qt.ControlModifier)
				focusOnLastItem()
			else
				focusOnNextItem()
		} else if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
			loadCurrentlyHighlightedFolder()
		else if(event.key === Qt.Key_PageDown)
			moveFocusFiveDown()
		else if(event.key === Qt.Key_PageUp)
			moveFocusFiveUp()
		else if(event.key === Qt.Key_F) {
			if(event.modifiers & Qt.ControlModifier)
				breadcrumbs.goForwardsInHistory()
		} else if(event.key === Qt.Key_B) {
			if(event.modifiers & Qt.ControlModifier)
				breadcrumbs.goBackInHistory()
		}

	}

	function loadDirectory(path) {

		folderlistmodel.clear()
		folders = getanddostuff.getFoldersIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)

		for(var j = 0; j < folders.length; ++j)
			folderlistmodel.append({"folder" : folders[j], "counter" : getanddostuff.getNumberFilesInFolder(dir_path + "/" + folders[j])})

	}

	function loadCurrentlyHighlightedFolder() {
		loadCurrentDirectory(dir_path + "/" + folders[folderlistview.currentIndex])
	}

	function focusOnNextItem() {
		if(folderlistview.currentIndex+1 < folderlistview.count)
			folderlistview.currentIndex += 1
	}

	function focusOnPrevItem() {
		if(folderlistview.currentIndex > 0)
			folderlistview.currentIndex -= 1
	}

	function moveFocusFiveDown() {
		if(folderlistview.currentIndex+5 < folderlistview.count)
			folderlistview.currentIndex += 5
		else
			folderlistview.currentIndex = folderlistview.count-1
	}

	function moveFocusFiveUp() {
		if(folderlistview.currentIndex > 4)
			folderlistview.currentIndex -= 5
		else
			folderlistview.currentIndex  = 0
	}

	function focusOnLastItem() {
		if(folderlistview.count > 0)
			folderlistview.currentIndex = folderlistview.count-1
	}

	function focusOnFirstItem() {
		if(folderlistview.count > 0)
			folderlistview.currentIndex = 0
	}

	function moveOneLevelUp() {

		var parts = dir_path.split("/")

		var moveup = 0
		for(var i = 0; i < parts.length; ++i) {
			if(parts[i] === "..")
				--moveup
			else
				++moveup
		}

		if(moveup > 1)
			loadCurrentDirectory(dir_path + "/..")
	}

}
