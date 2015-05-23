import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: quicksettings

	// Set up model on first load, afetrwards just change data
	property bool dontAnimateComboboxOpened: false

	// Background/Border color
	color: colour_slidein_bg
	border.width: 1
	border.color: colour_slidein_border

	// Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
	x: background.width+safetyDistanceForSlidein
	y: (background.height-height)/3

	// Adjust size
	width: 350
	height: childrenRect.height

	// Corner radius
	radius: 10

	Column {

		spacing: 12

		Rectangle {
			color: "#00000000"
			height: 1
			width: 5
		}

		// HEADER

		Text {
			color: "white"
			horizontalAlignment: Text.AlignHCenter
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			text: "Quick Settings"
			font.pointSize: 15
			font.bold: true
		}

		// DESCRIPTION

		Text {
			color: "white"
			text: "Change settings with one click. They are saved and applied immediately. If you're unsure what a setting does, check the full settings for descriptions."
			wrapMode: Text.WordWrap
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
		}

		// SORTING

		Rectangle {

			color: "#00000000"
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: childrenRect.height

			Row {

				spacing: 5

				Text {
					color: "white"
					text: "Sort by"
					y: (sortby.height-height)/2
				}
				CustomComboBox {
					id: sortby
					width: 150
					model: ["Name", "Natural Name", "Date", "File Size"]
					onCurrentIndexChanged: {
						if(currentIndex == 0)
							settings.sortby = "name"
						else if(currentIndex == 1)
							settings.sortby = "naturalname"
						else if(currentIndex == 2)
							settings.sortby = "date"
						else if(currentIndex == 3)
							settings.sortby = "size"
					}
					onPressedChanged: {
						if(pressed) softblocked = 1
						dontAnimateComboboxOpened = pressed
					}
				}
				ExclusiveGroup { id: radiobuttons_sorting }
				CustomRadioButton {
					id: sortby_asc
					icon: "qrc:/img/settings/sortascending.png"
					y: (sortby.height-height)/2
					exclusiveGroup: radiobuttons_sorting
					onClicked: settings.sortbyAscending = sortby_asc.checked
				}
				CustomRadioButton {
					id: sortby_desc
					icon: "qrc:/img/settings/sortdescending.png"
					y: (sortby.height-height)/2
					exclusiveGroup: radiobuttons_sorting
					onClicked: settings.sortbyAscending = sortby_asc.checked
				}
			}

		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// SYSTEM TRAY

		CustomComboBox {
			id: trayicon
			width: 250
			x: quicksettings.radius
			model: ["No tray icon","Hide to tray icon","Show tray icon, but don't hide to it"]
			onCurrentIndexChanged: settings.trayicon = trayicon.currentIndex
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// LOOP THROUGH FOLDER

		CustomCheckBox {
			id: loop
			text: "Loop through folder"
			x: quicksettings.radius
			onCheckedButtonChanged: settings.loopthroughfolder = loop.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// WINDOW MODE

		CustomCheckBox {
			id: windowmode
			text: "Window mode"
			x: quicksettings.radius
			onCheckedButtonChanged: settings.windowmode = windowmode.checkedButton
		}

		CustomCheckBox {
			id: windowdeco
			text: "Show window decoration"
			x: quicksettings.radius
			enabled: windowmode.checkedButton
			onCheckedButtonChanged: settings.windowDecoration = windowdeco.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// CLOSE ON CLICK

		CustomCheckBox {
			id: closeclick
			text: "Close on click on background"
			x: quicksettings.radius
			onCheckedButtonChanged: settings.closeongrey = closeclick.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// KEEP THUMBNAILS VISIBLE

		CustomCheckBox {
			id: keepvisible
			text: "Keep thumbnails visible"
			x: quicksettings.radius
			onCheckedButtonChanged: settings.thumbnailKeepVisible = keepvisible.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// THUMBNAIL MODE

		CustomComboBox {
			id: thumbmode
			width: quicksettings.width-3*quicksettings.radius
			x: quicksettings.radius
			model: ["Normal thumbnails", "Dynamic thumbnails", "Smart thumbnails"]
			onCurrentIndexChanged: settings.thumbnailDynamic = thumbmode.currentIndex
			onPressedChanged: {
				if(pressed) softblocked = 1
				dontAnimateComboboxOpened = pressed
			}
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// QUICK SETTINGS

		CustomCheckBox {
			id: quickset
			text: "Enable 'Quick Settings'"
			x: quicksettings.radius
			onCheckedButtonChanged: {
				settings.quickSettings = quickset.checkedButton
				if(!checkedButton)
					hideQuick.start()
			}
		}


		Rectangle {
			color: "#00000000"
			height: 1
			width: 5
		}

		// OPEN FULL SETTINGS

		Rectangle {
			color: "#00000000"
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: childrenRect.height
			CustomButton {
				text: "Show full settings"
				anchors.horizontalCenter: parent.horizontalCenter
				onClickedButton: {
					background.hideEverything()
					settingsitem.showSettings()
				}
			}
		}

		Rectangle {
			color: "#00000000"
			height: 1
			width: 5
		}

	}

	// 'Hide' animation
	PropertyAnimation {
		id: hideQuick
		target: quicksettings
		property: (dontAnimateComboboxOpened ? "" : "x")
		to: background.width+safetyDistanceForSlidein
	}


	function setData() {

		if(settings.sortby === "name")
			sortby.currentIndex = 0
		else if(settings.sortby === "naturalname")
			sortby.currentIndex = 1
		else if(settings.sortby === "date")
			sortby.currentIndex = 2
		else if(settings.sortby === "size")
			sortby.currentIndex = 3

		sortby_asc.checked = settings.sortbyAscending
		sortby_desc.checked = !settings.sortbyAscending

		trayicon.currentIndex = settings.trayicon

		loop.checkedButton = settings.loopthroughfolder

		windowmode.checkedButton = settings.windowmode
		windowdeco.enabled = windowmode.checkedButton
		windowdeco.checkedButton = settings.windowDecoration

		closeclick.checkedButton = settings.closeongrey

		keepvisible.checkedButton = settings.thumbnailKeepVisible

		thumbmode.currentIndex = settings.thumbnailDynamic

		quickset.checkedButton = settings.quickSettings

	}

}
