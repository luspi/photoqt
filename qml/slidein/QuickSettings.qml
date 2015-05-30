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
	x: background.width+safetyDistanceForSlidein
	y: (background.height-height)/3

	// Adjust size
	width: 350
	height: childrenRect.height

	// Corner radius
	radius: global_element_radius

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
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			text: qsTr("Quick Settings")
			font.pointSize: global_fontsize_header
			font.bold: true
		}

		// DESCRIPTION

		Text {
			color: colour.text
			text: qsTr("Change settings with one click. They are saved and applied immediately. If you're unsure what a setting does, check the full settings for descriptions.")
			font.pointSize: global_fontsize_normal
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
					color: colour.text
					text: qsTr("Sort by")
					font.pointSize: global_fontsize_normal
					y: (sortby.height-height)/2
				}
				CustomComboBox {
					id: sortby
					width: 150
					model: [qsTr("Name"), qsTr("Natural Name"), qsTr("Date"), qsTr("File Size")]
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
			color: colour.linecolour
		}

		// SYSTEM TRAY

		CustomComboBox {
			id: trayicon
			width: 250
			x: quicksettings.radius
			model: [qsTr("No tray icon"),qsTr("Hide to tray icon"),qsTr("Show tray icon, but don't hide to it")]
			onCurrentIndexChanged: settings.trayicon = trayicon.currentIndex
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: colour.linecolour
		}

		// LOOP THROUGH FOLDER

		CustomCheckBox {
			id: loop
			text: qsTr("Loop through folder")
			x: quicksettings.radius
			onCheckedButtonChanged: settings.loopthroughfolder = loop.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: colour.linecolour
		}

		// WINDOW MODE

		CustomCheckBox {
			id: windowmode
			text: qsTr("Window mode")
			x: quicksettings.radius
			onCheckedButtonChanged: settings.windowmode = windowmode.checkedButton
		}

		CustomCheckBox {
			id: windowdeco
			text: qsTr("Show window decoration")
			x: quicksettings.radius
			enabled: windowmode.checkedButton
			onCheckedButtonChanged: settings.windowDecoration = windowdeco.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: colour.linecolour
		}

		// CLOSE ON CLICK

		CustomCheckBox {
			id: closeclick
			text: qsTr("Close on click on background")
			x: quicksettings.radius
			onCheckedButtonChanged: settings.closeongrey = closeclick.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: colour.linecolour
		}

		// KEEP THUMBNAILS VISIBLE

		CustomCheckBox {
			id: keepvisible
			text: qsTr("Keep thumbnails visible")
			x: quicksettings.radius
			onCheckedButtonChanged: settings.thumbnailKeepVisible = keepvisible.checkedButton
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: colour.linecolour
		}

		// THUMBNAIL MODE

		CustomComboBox {
			id: thumbmode
			width: quicksettings.width-3*quicksettings.radius
			x: quicksettings.radius
			model: [qsTr("Normal thumbnails"), qsTr("Dynamic thumbnails"), qsTr("Smart thumbnails")]
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
			color: colour.linecolour
		}

		// QUICK SETTINGS

		CustomCheckBox {
			id: quickset
			text: qsTr("Enable 'Quick Settings'")
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
				text: qsTr("Show full settings")
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
