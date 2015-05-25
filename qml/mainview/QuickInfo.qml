import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick 2.3

Item {

	id: item

	x:5
	y:5

	function getWidth() { return counterRect.width; }
	function getHeight() { return counterRect.height; }

	opacity: 0

	property bool somethingLoaded: false

	property int _pos: -1

	// Set data
	function updateQuickInfo(pos, totalNumberImages, filepath) {

		_pos = pos

		somethingLoaded = true

		if(settings.hidecounter || totalNumberImages === 0) {
			counter.text = ""
			counter.visible = false
			spacing.visible = false
		} else {
			counter.text = (pos+1).toString() + "/" + totalNumberImages.toString()
			counter.visible = true
		}

		if(settings.hidefilename || totalNumberImages === 0) {
			filename.text = ""
			filename.visible = false
			spacing.visible = false
		} else if(settings.hidefilepathshowfilename) {
			filename.text = getanddostuff.removePathFromFilename(filepath)
			filename.visible = true
		} else {
			filename.text = filepath
			filename.visible = true
		}

		spacing.visible = (counter.visible && filename.visible && totalNumberImages !== 0)
		spacing.width = (spacing.visible ? 10 : 0)

		if(((!counter.visible && !filename.visible) || (slideshowRunning && settings.slideShowHideQuickinfo)) && currentfilter == "") {
			opacity = 0
		} else
			opacity = 1

	}

	// Rectangle holding all the items
	Rectangle {

		id: counterRect

		x: 0
		y: 0

		// it is always as big as the item it contains
		width: childrenRect.width+6
		height: childrenRect.height+6

		// Some styling
		color: "#55000000"
		radius: 5

		// COUNTER
		Text {

			id: counter

			x:3
			y:3

			text: ""

			color: "white"
			font.bold: true

			// Show context menu on right click
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				onClicked: {
					if (mouse.button == Qt.RightButton && somethingLoaded) {
						if(softblocked != 0)
							softblocked = 0
						else {
							softblocked = 1
							contextmenuCounter.popup()
						}
					}
				}
			}

			// The context menu
			Menu {
				id: contextmenuCounter
				style: MenuStyle {
					frame: menuFrame
					itemDelegate.background: menuHighlight
				}

				MenuItem {
					text: "<font color=\"white\">" + qsTr("Hide Counter") + "</font>"
					onTriggered: {
					counter.text = ""
					counter.visible = false
					spacing.visible = false
					spacing.width = 0
					settings.hidecounter = true;
					if(filename.visible == false) item.opacity = 0
					}
				}

			}

		}

		// SPACING - it does nothing but seperate counter from filename
		Text {
			id: spacing

			visible: !settings.hidecounter && !settings.hidefilepathshowfilename && !settings.hidefilename

			y: 3
			width: 10
			anchors.left: counter.right

			text: ""

		}

		// FILENAME
		Text {

			id: filename

			y: 3
			anchors.left: spacing.right

			text: ""
			color: "white"
			font.bold: true

			// Show context menu
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				onClicked: {
					if (mouse.button == Qt.RightButton && somethingLoaded) {
						if(softblocked != 0)
							softblocked = 0
						else {
							softblocked = 1
							contextmenuFilename.popup()
						}
					}
				}
			}

			// The actual context menu
			Menu {
				id: contextmenuFilename
				style: MenuStyle {
					frame: menuFrame
					itemDelegate.background: menuHighlight
				}

				MenuItem {
					text: "<font color=\"white\">" + qsTr("Hide Filepath, leave Filename") + "</font>"
					onTriggered: {
						filename.text = getanddostuff.removePathFromFilename(filename.text)
						settings.hidefilepathshowfilename = true;
					}
				}

				MenuItem {
					text: "<font color=\"white\">" + qsTr("Hide both, Filename and Filepath") + "</font>"
					onTriggered: {
						filename.text = ""
						spacing.visible = false
						spacing.width = 0
						settings.hidefilename = true;
						if(counter.visible == false) item.opacity = 0
					}
				}

			}
		}

		// Filter label
		Rectangle {
			id: filterLabel
			visible: (currentfilter != "")
			x: (_pos == -1 ? 5 : filename.x-filter_delete.width-filterrow.spacing)
			y: (_pos == -1 ? (filename.height-height/2)/2 : filename.y+filename.height+2)
			width: childrenRect.width
			height: childrenRect.height
			color: "#00000000"
			Row {
				id: filterrow
				spacing: 5
				Text {
					id: filter_delete
					color: "#99ffffff"
					visible: (currentfilter != "")
					text: "x"
					font.pointSize: 8
					y: (parent.height-height)/2
					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: {
							currentfilter = ""
							doReload(thumbnailBar.currentFile)
						}
					}
				}
				Text {
					color: "white"
					//: As in: FILTER images
					text: qsTr("Filter:") + " " + currentfilter
					visible: (currentfilter != "")
				}
			}
		}

	}

	// Some menu styling
	Component {
		id: menuFrame
		Rectangle {
			color: "#0F0F0F"
		}
	}
	Component {
		id: menuHighlight
		Rectangle {
			color: (styleData.selected ? "#4f4f4f" :"#0F0F0F")
		}
	}

}
