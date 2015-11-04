import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

Rectangle {

	id: top

	visible: false
	opacity: 0

	color: "#44000000"

	anchors.fill: parent

	property string items_path: ""
	property string dir_path: getanddostuff.getHomeDir()

	property var hovered: []

	property string cur_pre: "one"

	Rectangle {

		color: "#00000000"

		anchors.fill: parent
		anchors.margins: 5

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
		color: "grey"
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

			color: "#00000000"
			Layout.minimumWidth: 200
			Layout.fillWidth: true

			FilesListView {
				id: files_list
				anchors.fill: parent
				opacity: 1
				Behavior on opacity { SmoothedAnimation { id: opacitylistani; velocity: 0.1; } }
			}

			FilesIconView {
				id: files_icon
				anchors.fill: parent
				opacity: 0
				Behavior on opacity { SmoothedAnimation { id: opacityiconani; velocity: 0.1; } }
				visible: false
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
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		height: 50
		onDisplayIcons: {
			opacityiconani.duration = 0
			files_icon.opacity = 0
			files_icon.visible = true
			opacityiconani.duration = 300
			files_icon.opacity = 1
			files_list.opacity = 0
		}
		onDisplayList: {
			opacitylistani.duration = 0
			files_list.opacity = 0
			files_list.visible = true
			opacitylistani.duration = 300
			files_list.opacity = 1
			files_icon.opacity = 0
		}
	}

	PropertyAnimation {
		id: hideOpenAni
		target: top
		property: "opacity"
		to: 0
		duration: 400
		onStopped: {
			visible = false
			blocked = false
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
		}
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
		files_list.loadDirectory(path)
		files_icon.loadDirectory(path)

	}

}
