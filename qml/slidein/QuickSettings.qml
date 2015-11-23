import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: quicksettings

	// Set up model on first load, afetrwards just change data
	property bool dontAnimateComboboxOpened: false

	// Background/Border color
	color: colour.fadein_slidein_bg
	border.width: 1
	border.color: colour.fadein_slidein_border

	// Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
	x: background.width-width+1
	y: -1

	// Adjust size
	width: 350
	height: parent.height+2

	// Corner radius
//	radius: global_element_radius
	visible: false

	property int paddingleft: 10

	Column {

		spacing: 12

		Rectangle {
			color: "#00000000"
			height: 1
			width: 5
		}

		// HEADER

		Text {
			color: colour.text
			horizontalAlignment: Text.AlignHCenter
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			text: qsTr("Quick Settings")
			font.pointSize: 15
			font.bold: true
		}

		// DESCRIPTION

		Text {
			color: colour.text
			text: qsTr("Change settings with one click. They are saved and applied immediately. If you're unsure what a setting does, check the full settings for descriptions.")
			font.pointSize: 10
			wrapMode: Text.WordWrap
			x: paddingleft
			width: quicksettings.width-3*paddingleft
		}

		// SORTING

		Rectangle {

			color: "#00000000"
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: childrenRect.height

			Row {

				spacing: 5

				Text {
					color: colour.text
					text: qsTr("Sort by")
					font.pointSize: 10
					y: (sortby.height-height)/2
				}
				CustomComboBox {
					id: sortby
					width: 150
					model: [qsTr("Name"), qsTr("Natural Name"), qsTr("Date"), qsTr("File Size")]
					onCurrentIndexChanged: {
						verboseMessage("QuickSettings","Sort-by-Combo: " + currentIndex)
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
					onCheckedChanged: {
						verboseMessage("QuickSettings","Sort in ascending order: " + sortby_asc.checked)
						settings.sortbyAscending = true
					}
				}
				CustomRadioButton {
					id: sortby_desc
					icon: "qrc:/img/settings/sortdescending.png"
					y: (sortby.height-height)/2
					exclusiveGroup: radiobuttons_sorting
					onCheckedChanged: {
						verboseMessage("QuickSettings","Sort in ascending order: " + sortby_asc.checked)
						settings.sortbyAscending = false
					}
				}
			}

		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// SYSTEM TRAY

		CustomComboBox {
			id: trayicon
			width: 250
			x: paddingleft
			model: [qsTr("No tray icon"),qsTr("Hide to tray icon"),qsTr("Show tray icon, but don't hide to it")]
			onCurrentIndexChanged: {
				verboseMessage("QuickSettings","Hide to tray Icon: " + trayicon.currentIndex)
				settings.trayicon = trayicon.currentIndex
			}
		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// LOOP THROUGH FOLDER

		CustomCheckBox {
			id: loop
			text: qsTr("Loop through folder")
			x: paddingleft
			onCheckedButtonChanged: {
				verboseMessage("QuickSettings","Loop through folder: " + loop.checkedButton)
				settings.loopthroughfolder = loop.checkedButton
			}
		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// WINDOW MODE

		CustomCheckBox {
			id: windowmode
			text: qsTr("Window mode")
			x: paddingleft
			onCheckedButtonChanged: {
				verboseMessage("QuickSettings","Window Mode: " + windowmode.checkedButton)
				settings.windowmode = windowmode.checkedButton
				windowdeco.enabled = windowmode.checkedButton
			}
		}

		CustomCheckBox {
			id: windowdeco
			text: qsTr("Show window decoration")
			x: paddingleft
			enabled: windowmode.checkedButton
			onCheckedButtonChanged: {
				verboseMessage("QuickSettings","Window Deco: " + windowdeco.checkedButton)
				settings.windowDecoration = windowdeco.checkedButton
			}
		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// CLOSE ON CLICK

		CustomCheckBox {
			id: closeclick
			text: qsTr("Close on click on background")
			x: paddingleft
			onCheckedButtonChanged: {
				verboseMessage("QuickSettings","Close on Click on Background: " + closeclick.checkedButton)
				settings.closeongrey = closeclick.checkedButton
			}
		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// KEEP THUMBNAILS VISIBLE

		CustomCheckBox {
			id: keepvisible
			text: qsTr("Keep thumbnails visible")
			x: paddingleft
			onCheckedButtonChanged: {
				verboseMessage("QuickSettings","Keep thumbnails visible: " + keepvisible.checkedButton)
				settings.thumbnailKeepVisible = keepvisible.checkedButton
			}
		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// THUMBNAIL MODE

		CustomComboBox {
			id: thumbmode
			width: quicksettings.width-3*paddingleft
			x: paddingleft
			model: [qsTr("Normal thumbnails"), qsTr("Dynamic thumbnails"), qsTr("Smart thumbnails")]
			onCurrentIndexChanged: settings.thumbnailDynamic = thumbmode.currentIndex
			onPressedChanged: {
				verboseMessage("QuickSettings","Thumbnail type: " + thumbmode.currentText + " (" + pressed + ")")
				if(pressed) softblocked = 1
				dontAnimateComboboxOpened = pressed
			}
		}

		/**************************************/

		Rectangle {
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: 1
			color: colour.linecolour
		}

		// QUICK SETTINGS

		CustomCheckBox {
			id: quickset
			text: qsTr("Enable 'Quick Settings'")
			x: paddingleft
			onCheckedButtonChanged: {
				verboseMessage("QuickSettings","Enable Quick Settings: " + quickset.checkedButton)
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
			x: paddingleft
			width: quicksettings.width-3*paddingleft
			height: childrenRect.height
			CustomButton {
				text: qsTr("Show full settings")
				anchors.horizontalCenter: parent.horizontalCenter
				onClickedButton: {
					verboseMessage("QuickSettings","Showing full settings")
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
		id: hideMe
		target: quicksettings
		property: "opacity"
		to: 0
		onStopped: {
			if(opacity == 0 && !showMe.running)
				visible = false
		}
	}

	PropertyAnimation {
		id: showMe
		target:  quicksettings
		property: "opacity"
		to: 1
		onStarted: visible=true
	}

	function show() {
		showMe.start()
	}
	function hide() {
		hideMe.start()
	}


	function setData() {

		verboseMessage("QuickSettings","Setting Data")

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
