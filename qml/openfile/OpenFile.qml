import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

import "../elements/"

Rectangle {

	id: openfile_top

	visible: false
	opacity: 0

	color: "#88000000"

	anchors.fill: parent

	property string items_path: ""
	property string dir_path: settings.openKeepLastLocation ? getanddostuff.getOpenFileLastLocation() : getanddostuff.getHomeDir()

	property var hovered: []


	property bool type_preview: tweaks.isHoverPreviewEnabled

	property string currentlyLoadedDir: ""

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
	}


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
			onFocusOnFolders:
				folders.forceActiveFocus()
			onFocusOnFilesView:
				edit_rect.focusOnInput()
			onMoveOneLevelUp:
				folders.moveOneLevelUp()
		}


		Folders {
			id: folders
			onFocusOnFilesView:
				edit_rect.focusOnInput()
			onFocusOnUserPlaces:
				userplaces.forceActiveFocus()
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
				onMoveFocusFiveUp:
					filesview.moveFocusFiveUp()
				onMoveFocusFiveDown:
					filesview.moveFocusFiveDown()
				onFocusOnFirstItem:
					filesview.focusOnFirstItem()
				onFocusOnLastItem:
					filesview.focusOnLastItem()
				onMoveOneLevelUp:
					folders.moveOneLevelUp()
				onFocusOnFolderView:
					folders.forceActiveFocus()
				onFocusOnUserPlaces:
					userplaces.forceActiveFocus()
				onGoBackHistory:
					breadcrumbs.goBackInHistory()
				onGoForwardsHistory:
					breadcrumbs.goForwardsInHistory()
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
		target: openfile_top
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted:
			unblurAllBackgroundElements()
		onStopped: {
			visible = false
			blocked = false
			edit_rect.enabled = false
		}
	}

	PropertyAnimation {
		id: showOpenAni
		target: openfile_top
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
			blurAllBackgroundElements()
			if(settings.openDefaultView === "list")
				tweaks.displayList()
			else if(settings.openDefaultView === "icons")
				tweaks.displayIcons()
			if(thumbnailBar.currentFile !== "") {
				edit_rect.setEditText(getanddostuff.removePathFromFilename(thumbnailBar.currentFile))
				var path = getanddostuff.removeFilenameFromPath(thumbnailBar.currentFile)
				if(path !== currentlyLoadedDir)
					loadCurrentDirectory(path)
			}
		}
		onStopped: {
			edit_rect.enabled = true
			filesview.focusOnFile(getanddostuff.removePathFromFilename(thumbnailBar.currentFile))
			openshortcuts.forceActiveFocus()
			openshortcuts.display()
		}
	}


	ShortcutNotifier {
		id: openshortcuts
		area: "openfile"

		onClosed: {
			edit_rect.focusOnInput()
		}

	}


	Component.onCompleted: {

		// We needto do that here, as it seems to be not possible to compose a string in the dict definition
		// (i.e., when defining the property, inside the {})
		//: This is used in the context of the 'Open File' element with its three panes
		openshortcuts.shortcuts[str_keys.get("alt") + " + " + str_keys.get("left") + "/" + str_keys.get("right")] = qsTr("Move focus between Places/Folders/Fileview")
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("up") + "/" + str_keys.get("down")] = qsTr("Go up/down an entry")
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("page up") + "/" +str_keys.get("page down")] = qsTr("Move 5 entries up/down")
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("ctrl") + " + " + str_keys.get("up") + "/" + str_keys.get("down")] = qsTr("Move to the first/last entry")
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("alt") + " + " + str_keys.get("up")] = qsTr("Go one folder level up")
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("ctrl") + " + B/F"] = qsTr("Go backwards/forwards in history");
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("enter") + "/" + str_keys.get("ret")] = qsTr("Load the currently highlighted item")
		//: This is used in the context of the 'Open File' element
		openshortcuts.shortcuts[str_keys.get("escape")] = qsTr("Cancel")

		userplaces.loadUserPlaces()
		loadCurrentDirectory(dir_path)

		edit_rect.focusOnInput()

	}

	function show() { showOpenAni.start(); }

	function hide() {

		if(openshortcuts.visible)
			openshortcuts.reject()
		else
			hideOpenAni.start();

	}

	function loadCurrentDirectory(path) {

		setOverrideCursor()

		currentlyLoadedDir = path

		breadcrumbs.loadDirectory(path)
		folders.loadDirectory(path)
		filesview.loadDirectory(path)

		restoreOverrideCursor()

	}

	function reloadUserPlaces() {
		userplaces.loadUserPlaces()
	}

}
