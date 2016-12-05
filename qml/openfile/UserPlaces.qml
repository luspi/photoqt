import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

import "../elements"

Rectangle {

	id: uplaces

	width: settings.openUserPlacesWidth
	onWidthChanged:
		saveUserPlacesWidth.start()

	Timer {
		id: saveUserPlacesWidth
		interval: 250
		repeat: false
		running: false
		onTriggered:
			settings.openUserPlacesWidth = width
	}

	Layout.maximumWidth: 600
	Layout.minimumWidth: 200
	color: activeFocus ? "#44000055" : "#44000000"

	signal focusOnFolders()
	signal focusOnFilesView()

	signal moveOneLevelUp()

	// MouseArea for the background to make it possible to show sections if they're hidden
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: {
			if(mouse.button == Qt.RightButton)
				headingmenu.popup()
		}
	}

	ListView {
		id: userplaces
		width: parent.width
		height: parent.height

		highlight: Rectangle { color: "#DD5d5d5d"; radius: 5 }
		highlightMoveDuration: 50

		model: ListModel { id: userplacesmodel; }

		delegate: userplacesdelegate

		onCurrentIndexChanged:
			if(!activeFocus)
				uplaces.forceActiveFocus()

		// Don't highlight anything of UserPlaces at startup
		// Otherwise, a heading might be highlighted, that shouldn't happen
		Component.onCompleted:
			userplaces.currentIndex = -1
	}

	Component {

		id: userplacesdelegate

		Rectangle {

			width: userplaces.width
			height: opacity==1 ? userplacestext.height+14 + (type=="heading" ? 20 : 0) : 0
			color: counter%2==1 ? "#88000000" : "#44000000"

			Behavior on height { SmoothedAnimation { duration: 200 } }
			Behavior on opacity { NumberAnimation { duration: 200 } }

			// Groups can be hidden via contextmenu
			opacity: ((group == "user" && visibleuser.checked)
					 || (group == "standard" && visiblestandard.checked)
					 || (group == "volumes" && visiblevolumes.checked)) ? 1 : 0

			Image {
				id: userplacesimg
				x: 5
				y: 7
				width: userplacestext.height
				height: width
				source: (type=="heading" || icon=="") ? "" : "image://icon/" + icon
				sourceSize: Qt.size(width,height)

			}

			Text {

				id: userplacestext
				x: 5 + (type == "heading" ? 0 : height) + 5
				y: 7 + (type=="heading" ? 15 : 0)
				width: userplaces.width-userplacesimg.width-10
				elide: Text.ElideRight
				font.capitalization: (type == "heading" ? Font.AllUppercase : Font.MixedCase)
				text: title
				color: type=="heading" ? "grey" : "white"
				font.pointSize: 11
				font.bold: true

			}

			MouseArea {

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: type=="heading" ? Qt.ArrowCursor : Qt.PointingHandCursor
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				onEntered: {
					if(type !="heading")
						userplaces.currentIndex = index
					else
						userplaces.currentIndex = -1
				}
				onClicked: {
					if(type !== "heading" && mouse.button == Qt.LeftButton) {
						userplaces.currentIndex = index
						loadCurrentDirectory(location)
					} else if(type === "heading" && mouse.button == Qt.RightButton)
						headingmenu.popup()
					else if(type !== "heading" && group == "user" && mouse.button == Qt.RightButton)
						usermenu.popup()
				}
			}
		}
	}

	ContextMenu {

		id: headingmenu

		MenuItem {
			id: visiblestandard
			checkable: true
			checked: settings.openUserPlacesStandard
			onCheckedChanged:
				settings.openUserPlacesStandard = checked
			//: OpenFile: This refers to standard folders for pictures, etc.
			text: qsTr("Show standard locations")
		}
		MenuItem {
			id: visibleuser
			checkable: true
			checked: settings.openUserPlacesUser
			onCheckedChanged:
				settings.openUserPlacesUser = checked
			//: OpenFile: This refers to the user-set folders
			text: qsTr("Show user locations")
		}
		MenuItem {
			id: visiblevolumes
			checkable: true
			checked: settings.openUserPlacesVolumes
			onCheckedChanged:
				settings.openUserPlacesVolumes = checked
			//: OpenFile: This refers to connected devices (harddrives, partitions, etc.)
			text: qsTr("Show devices")
		}

	}

	ContextMenu {

		id: usermenu

		MenuItem {
			//: OpenFile: Remove from user-set folders (favourites)
			text: qsTr("Remove from favourites")
			onTriggered: saveUserPlacesExceptCurrentlyHighlighted()
		}
		MenuItem {
			text: qsTr("Load folder")
			onTriggered: loadCurrentlyHighlightedFolder()
		}

	}

	Keys.onPressed: {

		if(event.key === Qt.Key_Left) {

			if(event.modifiers & Qt.AltModifier)
				focusOnFilesView()
			else if(event.modifiers & Qt.MetaModifier)
				breadcrumbs.goBackInHistory()

		} else if(event.key === Qt.Key_Right) {

			if(event.modifiers & Qt.AltModifier)
				focusOnFolders()

		} else if(event.key === Qt.Key_Up) {
			if(event.modifiers & Qt.AltModifier)
				moveOneLevelUp()
			else
				focusOnPrevItem()
		} else if(event.key === Qt.Key_Down)
			focusOnNextItem()
		else if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
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

	function loadUserPlaces() {

		// We store the current index in a variable to re-set it afterwards
		// If the userplaces file got changed during runtime, then this ensures the highlighted index remains the same
		var index = userplaces.currentIndex

		userplacesmodel.clear()

		var entries = getanddostuff.getUserPlaces()

		var useritems = [
					//: OpenFile: This refers to the home folder
					[qsTr("Home"), getanddostuff.getHomeDir(), "user-home"],
					//: OpenFile: This refers to the desktop folder
					[qsTr("Desktop"), getanddostuff.getDesktopDir(), "user-desktop"],
					//: OpenFile: This refers to the pictures folder
					[qsTr("Pictures"), getanddostuff.getPicturesDir(), "folder-pictures"],
					//: OpenFile: This refers to the downloads folder
					[qsTr("Downloads"), getanddostuff.getDownloadsDir(), "folder-download"]
				]

		userplacesmodel.append({"type" : "heading",
								   //: OpenFile: 'Standard' is the title for the standard folders (home, desktop, pictures, downloads)
								   "title" : qsTr("Standard"),
								   "location" : "",
								   "icon" : "",
								   "counter" : 0,
								   "group" : "standard"})

		for(var u = 0; u < useritems.length; ++u) {
			if(useritems[u][1] !== "") {
				userplacesmodel.append({"type" : "place_user",
										"title" : useritems[u][0],
										"location" : useritems[u][1],
										"icon" : useritems[u][2],
										"counter" : u+1,
										"group" : "standard"})
			}
		}

		userplacesmodel.append({"type" : "heading",
								   //: OpenFile: 'Places' is the title for the user-set folders (favourites)
								   "title" : qsTr("Places"),
								   "location" : "",
								   "icon" : "",
								   "counter" : 0,
								   "group" : "user"})

		var reached_devcies = false;
		var counter = 1
		for(var i = 0; i < entries.length; i+=4) {
			if(entries[i] === "volumes" && reached_devcies == false) {
				userplacesmodel.append({"type" : "heading",
										   //: OpenFile: 'Devices' is the title for connected harddrives, partitions, ...
										   "title" : qsTr("Devices"),
										   "location" : "",
										   "icon" : "",
										   "counter" : 0,
										   "group" : "volumes"})
				counter = 1
				reached_devcies = true
			}

			userplacesmodel.append({"type" : entries[i],
									"title" : entries[i+1],
									"location" : entries[i+2],
									"icon" : entries[i+3],
									"counter" : counter,
									"group" : entries[i]})

			++counter
		}

		userplaces.currentIndex = index;

	}

	function saveUserPlacesExceptCurrentlyHighlighted() {

		var ret = [[]]

		for(var i = 0; i < userplaces.count; ++i) {
			if(userplacesmodel.get(i).group === "user" && userplacesmodel.get(i).type !== "heading" && i != userplaces.currentIndex) {
				ret.push(["user",userplacesmodel.get(i).title,userplacesmodel.get(i).location,userplacesmodel.get(i).icon])
			}
		}

		getanddostuff.saveUserPlaces(ret);

	}

	function loadCurrentlyHighlightedFolder() {

		loadCurrentDirectory(userplacesmodel.get(userplaces.currentIndex).location)

	}

	function focusOnNextItem() {

		if(userplaces.currentIndex+1 < userplaces.count)
			userplaces.currentIndex += 1

		while(userplacesmodel.get(userplaces.currentIndex).type === "heading" && userplaces.currentIndex < userplaces.count-1)
			userplaces.currentIndex += 1

	}

	function focusOnPrevItem() {

		if(userplaces.currentIndex > 0)
			userplaces.currentIndex -= 1

		while(userplacesmodel.get(userplaces.currentIndex).type === "heading" && userplaces.currentIndex > 0)
			userplaces.currentIndex -= 1

	}

	function moveFocusFiveDown() {

		if(userplaces.currentIndex+5 < userplaces.count)
			userplaces.currentIndex += 5
		else
			userplaces.currentIndex = userplaces.count-1

		while(userplacesmodel.get(userplaces.currentIndex).type === "heading" && userplaces.currentIndex < userplaces.count-1)
			userplaces.currentIndex += 1

	}

	function moveFocusFiveUp() {

		if(userplaces.currentIndex > 4)
			userplaces.currentIndex -= 5
		else
			userplaces.currentIndex  = 0

		while(userplacesmodel.get(userplaces.currentIndex).type === "heading" && userplaces.currentIndex > 0)
			userplaces.currentIndex -= 1

	}

}
