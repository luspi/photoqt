import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

Rectangle {

	id: uplaces

	width: settings.openUserPlacesWidth
	Layout.maximumWidth: 600
	Layout.minimumWidth: 200
	color: activeFocus ? "#44000055" : "#44000000"

	signal focusOnFolders()
	signal focusOnFilesView()

	signal moveOneLevelUp()

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
			height: userplacestext.height+14 + (type=="heading" ? 20 : 0)
			color: counter%2==1 ? "#88000000" : "#44000000"

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
				font.pixelSize: tweaks.zoomlevel-2

			}

			MouseArea {

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: type=="heading" ? Qt.ArrowCursor : Qt.PointingHandCursor
				onEntered: {
					if(type !="heading")
						userplaces.currentIndex = index
				}
				onClicked: {
					if(type !== "heading") {
						userplaces.currentIndex = index
						loadCurrentDirectory(location)
					}
				}
			}
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
		console.log(event.key)

	}

	function loadUserPlaces() {

		userplacesmodel.clear()

		var entries = getanddostuff.getUserPlaces()

		userplacesmodel.append({"type" : "heading",
								   "title" : "Places",
								   "location" : "",
								   "icon" : "",
								   "counter" : 0})

		var reached_devcies = false;
		var counter = 1
		for(var i = 0; i < entries.length; i+=4) {
			if(entries[i] === "device" && reached_devcies == false) {
				userplacesmodel.append({"type" : "heading",
										   "title" : "Devices",
										   "location" : "",
										   "icon" : "",
										   "counter" : 0})
				counter = 1
				reached_devcies = true
			}

			userplacesmodel.append({"type" : entries[i],
									   "title" : entries[i+1],
									   "location" : entries[i+2],
									   "icon" : entries[i+3],
									   "counter" : counter})
			++counter
		}
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
