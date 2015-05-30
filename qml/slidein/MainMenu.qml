import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	id: mainmenu

	// Background/Border color
	color: colour.fadein_slidein_bg
	border.width: 1
	border.color: colour.fadein_slidein_border

	// Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
	x: background.width-width-100
	y: settings.thumbnailposition == "Bottom" ? -height-safetyDistanceForSlidein : background.height+safetyDistanceForSlidein

	// Adjust size
	width: 350
	height: view.contentHeight+3*radius

	// Corner radius
	radius: 10

	// [id, icon, text]
	property var allitems: [["open", "open", qsTr("Open File")],
				["settings", "settings", qsTr("Settings")],
				["wallpaper", "settings", qsTr("Set as Wallpaper")],
				["slideshow", "slideshow", qsTr("Start Slideshow")],
				["filter", "filter", qsTr("Filter Images in Folder")],
				["metadata", "metadata", qsTr("Show/Hide Metadata")],
				["about", "about", qsTr("About PhotoQt")],
				["hide", "quit", qsTr("Hide (System Tray)")],
				["quit", "quit", qsTr("Quit")]]

	// All entries in the menu
	ListView {

		id: view

		// No scrolling/flicking!
		boundsBehavior: ListView.StopAtBounds

		// Same size as parent
		anchors {
			fill: parent
			margins: mainmenu.radius
			topMargin: 2*mainmenu.radius
		}

		// Simple model and delegate
		model: allitems.length
		delegate: deleg

	}

	Component {

		id: deleg

		// Icon and entry text in a row
		Row {

			// Icon
			Image {
				y: 2.5
				width: val.height*0.5
				height: val.height*0.5
				sourceSize.width: width
				sourceSize.height: height
				source: "qrc:/img/mainmenu/" + allitems[index][1] + ".png"
				opacity: (settings.trayicon || allitems[index][0] !== "hide") ? 1 : 0.5
			}

			// Entry text
			Text {

				id: val;

				color: colour.text_inactive
				lineHeight: 1.5

				opacity: enabled ? 1 : 0.5

				font.pointSize: 10
				font.bold: true

				enabled: (settings.trayicon || allitems[index][0] !== "hide")

				// The spaces guarantee a bit of space betwene icon and text
				text: "  " + allitems[index][2];

				MouseArea {

					anchors.fill: parent

					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor

					onEntered: val.color = colour.text
					onExited: val.color = colour.text_inactive
					onClicked: mainmenuDo(allitems[index][0])

				}

			}

			// This is a second text entry - currently only used for Slideshow Quickstart entry (two in a row)
			Text {

				id: val2

				visible: allitems[index][0] === "slideshow"

				color: colour.text_inactive
				lineHeight: 1.5

				font.pointSize: 10
				font.bold: true

				text: " (" + qsTr("Quickstart") + ")"

				MouseArea {

					anchors.fill: parent
					hoverEnabled: true

					cursorShape: Qt.PointingHandCursor
					onEntered: val2.color = colour.text
					onExited: val2.color = colour.text_inactive
					onClicked: mainmenuDo("slideshowquickstart")

				}
			}

		}

	}

	// Do stuff on clicking on an entry
	function mainmenuDo(what) {

		// Hide menu when an entry was clicked
		if(what !== "metadata") hideMainmenu.start()

		if(what === "open") openFile()

		else if(what === "quit") quitPhotoQt()

		else if(what === "about") about.showAbout()

		else if(what === "settings") settingsitem.showSettings()

		else if(what === "wallpaper") wallpaper.showWallpaper()

		else if(what === "slideshow") slideshow.showSlideshow()

		else if(what === "slideshowquickstart") slideshow.quickstart()

		else if(what === "filter") filter.showFilter()

		else if(what === "metadata") {
			if(metaData.x > -2*metaData.radius) {
				metaData.uncheckCheckbox()
				background.hideMetadata()
			} else {
				metaData.checkCheckbox()
				background.showMetadata(true)
			}
		}
	}

	// 'Hide' animation
	PropertyAnimation {
		id: hideMainmenu
		target: mainmenu
		property: "y"
		to: settings.thumbnailposition == "Bottom" ? -mainmenu.height-safetyDistanceForSlidein : background.height+safetyDistanceForSlidein
	}

}
