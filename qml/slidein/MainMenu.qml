import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	id: mainmenu

	// Background/Border color
	color: colour.fadein_slidein_bg
	border.width: 1
	border.color: colour.fadein_slidein_border

	// Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
	x: (background.width-width)+1
	y: -1
	visible: false

	// Adjust size
	width: 300
	height: background.height+2

	opacity: 0

	property var allitems: [
		[["heading","",qsTr("General Functions")]],
		[["open", "open", qsTr("Open File")]],
		[["settings", "settings", qsTr("Settings")]],
		[["wallpaper", "settings", qsTr("Set as Wallpaper")]],
		[["slideshow","slideshow",qsTr("Slideshow")],["slideshow","",qsTr("setup")],["slideshowquickstart","",qsTr("quickstart")]],
		[["filter", "filter", qsTr("Filter Images in Folder")]],
		[["metadata", "metadata", qsTr("Show/Hide Metadata")]],
		[["about", "about", qsTr("About PhotoQt")]],
		[["hide", "hide", qsTr("Hide (System Tray)")]],
		[["quit", "quit", qsTr("Quit")]],

		[["heading","",""]],

		[["heading","",qsTr("Image")]],
		[["scale","scale",qsTr("Scale Image")]],
		[["zoom","zoom",qsTr("Zoom")],["zoomin","",qsTr("in")],["zoomout","",qsTr("out")],["zoomreset","",qsTr("reset")],["zoomactual","","1:1"]],
		[["rotate","rotate",qsTr("Rotate")],["rotateleft","",qsTr("left")],["rotateright","",qsTr("right")],["rotatereset","",qsTr("reset")]],
		[["flip","flip",qsTr("Flip")],["flipH","",qsTr("horizontal")],["flipV","",qsTr("vertical")],["flipReset","",qsTr("reset")]],

		[["heading","",""]],

		[["heading","",qsTr("File")]],
		[["rename","rename",qsTr("Rename")]],
		[["copy","copy",qsTr("Copy")]],
		[["move","move",qsTr("Move")]],
		[["delete","delete",qsTr("Delete")]]

	]


	ListView {

		anchors.fill: parent
		anchors.bottomMargin: helptext.height+5
		anchors.margins: 10
		model: allitems.length
		delegate: maindeleg
		clip: true

		orientation: ListView.Vertical

	}

	Component {

		id: maindeleg

		ListView {

			id: subview

			property int mainindex: index
			height: 25
			width: childrenRect.width

			orientation: Qt.Horizontal
			spacing: 5

			model: allitems[mainindex].length
			delegate: Row {

				spacing: 5

				Text {
					id: sep
					lineHeight: 1.5

					color: colour.text_inactive
					visible: allitems[subview.mainindex].length > 1 && index > 1
					font.bold: true
					text: "/"
				}

				Image {
					y: 2.5
					width: ((source!="" || allitems[subview.mainindex][index][0]==="heading") ? val.height*0.5 : 0)
					height: val.height*0.5
					sourceSize.width: width
					sourceSize.height: height
					source: allitems[subview.mainindex][index][1]==="" ? "" : "qrc:/img/mainmenu/" + allitems[subview.mainindex][index][1] + ".png"
					opacity: (settings.trayicon || allitems[subview.mainindex][index][0] !== "hide") ? 1 : 0.5
					visible: (source!="" || allitems[subview.mainindex][index][0]==="heading")
				}

				Text {

					id: val;

					color: (allitems[subview.mainindex][index][0]==="heading") ? "white" : colour.text_inactive
					lineHeight: 1.5

					font.capitalization: (allitems[subview.mainindex][index][0]==="heading") ? Font.SmallCaps : Font.MixedCase

					opacity: enabled ? 1 : 0.5

					font.pointSize: 10
					font.bold: true

					enabled: (settings.trayicon || (allitems[subview.mainindex][index][0] !== "hide" && allitems[subview.mainindex][index][0] !=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)))

					// The spaces guarantee a bit of space betwene icon and text
					text: allitems[subview.mainindex][index][2] + ((allitems[subview.mainindex].length > 1 && index == 0) ? ":" : "")

					MouseArea {

						anchors.fill: parent

						hoverEnabled: true
						cursorShape: (allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)) ? Qt.PointingHandCursor : Qt.ArrowCursor

						onEntered: {
							if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
								val.color = colour.text
						}
						onExited: {
							if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
								val.color = colour.text_inactive
						}
						onClicked: {
							if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
								mainmenuDo(allitems[subview.mainindex][index][0])
						}

					}

				}

			}

		}

	}

	Rectangle {
		anchors {
			bottom: helptext.top
			left: parent.left
			right: parent.right
		}
		height: 1
		color: "#22ffffff"

	}

	Text {

		id: helptext

		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		height: 100

		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter

		color: "grey"
		wrapMode: Text.WordWrap

		text: qsTr("Click here to go to the online manual for help regarding shortcuts, settings, features, ...")

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: getanddostuff.openLink("http://photoqt.org/man")
		}

	}

	// Do stuff on clicking on an entry
	function mainmenuDo(what) {

		verboseMessage("MainMenu::mainmenuDo()",what)

		// Hide menu when an entry was clicked
//		if(what !== "metadata") hideMainmenu.start()

		if(what === "open") {

			hideMainmenu.start()
			openFile()

		} else if(what === "quit") {

			hideMainmenu.start()
			quitPhotoQt()

		} else if(what === "about") {

			hideMainmenu.start()
			about.showAbout()

		} else if(what === "settings") {

			hideMainmenu.start()
			settingsitem.showSettings()

		} else if(what === "wallpaper") {

			hideMainmenu.start()
			wallpaper.showWallpaper()

		} else if(what === "slideshow") {

			hideMainmenu.start()
			slideshow.showSlideshow()

		} else if(what === "slideshowquickstart") {

			hideMainmenu.start()
			slideshow.quickstart()

		} else if(what === "filter") {

			hideMainmenu.start()
			filter.showFilter()

		} else if(what === "metadata") {
			if(metaData.opacity != 0) {
				metaData.uncheckCheckbox()
				background.hideMetadata()
			} else {
				metaData.checkCheckbox()
				background.showMetadata(true)
			}
		} else if(what === "scale") {

			hideMainmenu.start()
			scaleImage.showScale()

		} else if(what === "zoomin")

			mainview.zoomIn(true)

		else if(what === "zoomout")

			mainview.zoomOut(true)

		else if(what === "zoomreset")

			mainview.resetZoom()

		else if(what === "zoomactual")

			mainview.zoomActual()

		else if(what === "rotateleft")

			mainview.rotateLeft()

		else if(what === "rotateright")

			mainview.rotateRight()

		else if(what === "rotatereset")

			mainview.resetRotation()

		else if(what === "flipH")

			mainview.mirrorHorizontal()

		else if(what === "flipV")

			mainview.mirrorVertical()

		else if(what === "flipReset")

			mainview.resetMirror()

		else if(what === "rename") {

			if(thumbnailBar.currentFile !== "") {
				hideMainmenu.start()
				rename.showRename()
			}

		} else if(what === "copy") {

			if(thumbnailBar.currentFile !== "") {
				hideMainmenu.start()
				getanddostuff.copyImage(thumbnailBar.currentFile)
			}

		} else if(what === "move") {

			if(thumbnailBar.currentFile !== "") {
				hideMainmenu.start()
				getanddostuff.moveImage(thumbnailBar.currentFile)
			}

		} else if(what === "delete") {

			if(thumbnailBar.currentFile !== "") {
				hideMainmenu.start()
				deleteImage.showDelete()
			}

		}

	}

	// 'Hide' animation
	PropertyAnimation {
		id: hideMainmenu
		target: mainmenu
		property: "opacity"
		to: 0
		onStopped: {
			if(opacity == 0 && !showMainmenu.running)
				visible = false
		}
	}

	PropertyAnimation {
		id: showMainmenu
		target:  mainmenu
		property: "opacity"
		to: 1
		onStarted: visible=true
	}

	function show() {
		showMainmenu.start()
	}
	function hide() {
		hideMainmenu.start()
	}

}
