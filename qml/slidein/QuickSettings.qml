import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: quicksettings

	// Set up model on first load, afetrwards just change data
	property bool imageLoaded: false

	// Background/Border color
	color: colour_slidein_bg
	border.width: 1
	border.color: colour_slidein_border

	// Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
	x: parent.width
	y: (parent.height-quicksettings.height)/3

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
				}
				ExclusiveGroup { id: radiobuttons_sorting }
				CustomRadioButton {
					icon: "qrc:/img/settings/sortascending.png"
					y: (sortby.height-height)/2
					exclusiveGroup: radiobuttons_sorting
				}
				CustomRadioButton {
					icon: "qrc:/img/settings/sortdescending.png"
					y: (sortby.height-height)/2
					exclusiveGroup: radiobuttons_sorting
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

		// BACKGROUND

		CustomComboBox {
			width: quicksettings.width-3*quicksettings.radius
			x: quicksettings.radius
			model: ["Real transparency", "Faked transparency", "Background image", "Coloured background"]
		}

		/**************************************/

		Rectangle {
			x: quicksettings.radius
			width: quicksettings.width-3*quicksettings.radius
			height: 1
			color: "white"
		}

		// SYSTEM TRAY

		CustomCheckBox {
			text: "Hide to system tray"
			x: quicksettings.radius
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
			text: "Loop through folder"
			x: quicksettings.radius
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
		}

		CustomCheckBox {
			id: windowdeco
			text: "Show window decoration"
			x: quicksettings.radius
			enabled: windowmode.checkedButton
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
			text: "Close on click on background"
			x: quicksettings.radius
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
			text: "Keep thumbnails visible"
			x: quicksettings.radius
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
			width: quicksettings.width-3*quicksettings.radius
			x: quicksettings.radius
			model: ["Normal thumbnails", "Dynamic thumbnails", "Smart thumbnails"]
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
			text: "Enable 'Quick Settings'"
			x: quicksettings.radius
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
			}
		}

		Rectangle {
			color: "#00000000"
			height: 1
			width: 5
		}

	}


	function setData(d) {

	}

}
