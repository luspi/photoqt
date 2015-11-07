import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

import "../elements/"

Rectangle {

	id: top

	visible: false
	opacity: 0

	color: "#88000000"

	anchors.fill: parent

	property string items_path: ""
	property string dir_path: getanddostuff.getHomeDir()

	property var hovered: []


	property string type_preview: tweaks.getMode()


	// Bread crumb navigation
	BreadCrumbs {
		id: breadcrumbs
	}

	// Seperating Line
	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: breadcrumbs.bottom
		height: 1
		color: "white"
	}


	// Main view
	SplitView {

		id: splitview

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.top: breadcrumbs.bottom
		anchors.bottomMargin: 50
		orientation: Qt.Horizontal

		// The user places at the left
		UserPlaces {
			id: userplaces
		}


		Folders {
			id: folders
		}


		Rectangle {
			Layout.minimumWidth: 200
			Layout.fillWidth: true
			color: "#00000000"

			Rectangle {

				color: "#00000000"

				anchors.fill: parent
				anchors.bottomMargin: edit_rect.height

				FilesView {
					id: filesview
					anchors.fill: parent
				}

			}

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				height: 1
				anchors.top: edit_rect.top
				color: "white"
			}

			EditFiles {

				id: edit_rect
				enabled: false
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom

				onFilenameEdit:
					filesview.focusOnFile(filename)
				onAccepted:
					filesview.loadCurrentlyHighlightedImage()
				onFocusOnNextItem:
					filesview.focusOnNextItem()
				onFocusOnPrevItem:
					filesview.focusOnPrevItem()

			}

		}

	}

	Rectangle {
		width: parent.width
		anchors.top: splitview.bottom
		height: 1
		color: "white"
	}

	Tweaks {
		id: tweaks
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		height: 50
		onDisplayIcons:
			filesview.displayIcons()
		onDisplayList:
			filesview.displayList()
	}

	PropertyAnimation {
		id: hideOpenAni
		target: top
		property: "opacity"
		to: 0
		duration: 400
		onStarted: {
			settings.openZoomLevel = tweaks.zoomlevel
			settings.openPreviewMode = tweaks.getMode()
			settings.openDefaultView = tweaks.getView()
			settings.openFoldersWidth = folders.width
			settings.openUserPlacesWidth = userplaces.width
		}
		onStopped: {
			visible = false
			blocked = false
			edit_rect.enabled = false
		}
	}

	PropertyAnimation {
		id: showOpenAni
		target: top
		property: "opacity"
		to: 1
		duration: 400
		onStarted: {
			visible = true
			blocked = true
			if(settings.openDefaultView === "list")
				tweaks.displayList()
			else if(settings.openDefaultView === "icons")
				tweaks.displayIcons()
			edit_rect.setEditText(getanddostuff.removePathFromFilename(thumbnailBar.currentFile))
			edit_rect.focusOnInput()
		}
		onStopped:
			edit_rect.enabled = true
	}

	function show() { showOpenAni.start(); }
	function hide() { hideOpenAni.start(); }

	Timer {
		interval: 100
		repeat: false
		running: true
		onTriggered: {
			userplaces.loadUserPlaces()
			loadCurrentDirectory(dir_path)
		}
	}

	function loadCurrentDirectory(path) {

		breadcrumbs.loadDirectory(path)
		folders.loadDirectory(path)
		filesview.loadDirectory(path)

	}

}
