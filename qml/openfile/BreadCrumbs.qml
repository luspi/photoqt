import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import "../elements"

Rectangle {

	anchors.left: parent.left
	anchors.top: parent.top
	anchors.right: parent.right
	height: 50

	property int historypos: -1
	property var history: []
	property bool loadedFromHistory: false

	color: "#44000000"

	// Two buttons to go backwards/forwards in history
	Rectangle {

		id: hist_but

		// Positioning and styling
		color: "transparent"
		anchors.left: parent.left
		anchors.leftMargin: 10
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: toleft.width+toright.width

		// Backwards
		CustomButton {

			id: toleft

			anchors.left: parent.left
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: 40

			text: "<"
			fontsize: 30
			overrideFontColor: "white"
			overrideBackgroundColor: "transparent"

			tooltip: "Go backwards in history"

			onClickedButton: goBackInHistory()

		}

		// Forwards
		CustomButton {

			id: toright

			anchors.right: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: 40

			text: ">"
			fontsize: 30
			overrideFontColor: "white"
			overrideBackgroundColor: "transparent"

			tooltip: "Go forwards in history"

			onClickedButton: goForwardsInHistory()

		}

	}

	// This button closes the OpenFile dialog -> it is displayed to the RIGHT of the ListView below, in the top right corner
	Image {

		id: closeopenfile

		anchors.right: parent.right
		anchors.top: parent.top

		source: "qrc:/img/closingx.png"
		sourceSize: Qt.size(3*settings.closeXsize,3*settings.closeXsize)

		ToolTip {
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: openfile.hide()
			text: qsTr("Close 'OpenFile' dialog")
		}

	}

	ListView {

		id: crumbsview

		spacing: 0

		anchors.left: hist_but.right
		anchors.right: closeopenfile.left
		height: parent.height

		orientation: ListView.Horizontal
		interactive: false
		clip: true

		model: ListModel { id: crumbsmodel; }

		property var menuitems: []

		delegate: Button {
			y: 7
			height: parent.height-15
			property bool hovered: false

			style: ButtonStyle {
				background: Rectangle {
					id: bg
					anchors.fill: parent
					color: hovered ? "#44ffffff" : "#00000000"
					radius: 5
				}

				label: Text {
					id: txt
					horizontalAlignment: Text.AlignHCenter
					color: "white"
					font.bold: true
					font.pointSize: 15
					text: type=="folder" ? " " + location : " /"
				}

			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: type=="folder" ? Qt.PointingHandCursor : Qt.ArrowCursor
				onClicked: {
					if(type == "folder")
						loadCurrentDirectory(partialpath)
					else {
//							m.clear()
//							var folders = getanddostuff.getFoldersIn(partialpath)
//							m.dir = partialpath
//							for(var i = 0; i < folders.length; ++i) {
//								m.addItem(folders[i])
//							}
//							m.popup()
					}
				}
				onEntered:
					if(type=="folder")
						parent.hovered = true
				onExited:
					if(type=="folder")
						parent.hovered = false
			}

		}

	}

	//	Menu {
	//		id: m
	//		property string dir: ""
	//		style: MenuStyle {
	//			// an item text
	//			itemDelegate.label: Text {
	//				verticalAlignment: Text.AlignVCenter
	//				horizontalAlignment: Text.AlignHCenter
	//				font.pointSize: 12
	//				color: "white"
	//				text: styleData.text.split("/")[styleData.text.split("/").length-1]
	//			}

	//			// selection of an item
	//			itemDelegate.background: Rectangle {
	//				color: styleData.selected ? "grey" : "#222222"
	//				border.width: 1
	//				border.color: "#222222"
	//			}
	//		}
	//	}


	function loadDirectory(path) {

		// If current directory is not loaded from history -> adjust history
		if(loadedFromHistory)
			loadedFromHistory = false
		else
			addToHistory(path)

		var parts = path.split("/")
		var partialpath = ""

		crumbsmodel.clear()

		// On Windows, the root directory is the drive letter, not a seperator
		if(path === "/" && !getanddostuff.amIOnWindows())
			crumbsmodel.append({"type" : "separator", "location" : "/", "partialpath" : "/"})
		else {
			for(var i = 0; i < parts.length; ++i) {
				if(parts[i] === "") continue;
				if(parts[i] === "..") {
					var l = crumbsmodel.count
					crumbsmodel.remove(l-1)
					crumbsmodel.remove(l-2)
					partialpath += "/" + parts[i]
				} else {
					// On Windows, the path starts with the drive letter, not a seperator
					if(!getanddostuff.amIOnWindows() || i != 0) {
						partialpath += "/"
						crumbsmodel.append({"type" : "separator", "location" : parts[i], "partialpath" : partialpath})
					}
					partialpath += parts[i]
					crumbsmodel.append({"type" : "folder", "location" : parts[i], "partialpath" : partialpath + "/"})
					// On Windows, if the path consists only of the drive letter, we add a slash behind (looks better)
					if(parts.length === 2 && getanddostuff.amIOnWindows()) {
						partialpath += "/"
						crumbsmodel.append({"type" : "separator", "location" : parts[i], "partialpath" : partialpath})
					}
				}
			}
		}

		if(crumbsmodel.count == 0)
			crumbsmodel.append({"type" : "separator", "location" : "/", "partialpath" : "/"})

		crumbsview.positionViewAtEnd()

	}

	// Add to history
	function addToHistory(path) {

		// If current position is not the end of history -> cut off end part
		if(historypos != history.length-1)
			history = history.slice(0,historypos+1);

		// Add path
		history.push(path)
		++historypos;

	}

	// Go back in history, if we're not already at the beginning
	function goBackInHistory() {
		if(historypos > 0) {
			--historypos
			loadedFromHistory = true
			loadCurrentDirectory(history[historypos])
		}
	}

	// Go forwards in history, if we're not already at the end
	function goForwardsInHistory() {
		if(historypos < history.length-1) {
			++historypos
			loadedFromHistory = true
			loadCurrentDirectory(history[historypos])
		}
	}

}
