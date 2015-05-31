import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: tab

	color: "#00000000"

	anchors {
		fill: parent
		leftMargin: 20
		rightMargin: 20
		topMargin: 15
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+50
		contentWidth: tab.width

		boundsBehavior: Flickable.StopAtBounds

		Column {

			id: maincol

			spacing: 15

			/**********
			* HEADER *
			**********/

			Rectangle {
				id: header
				width: flickable.width
				height: childrenRect.height
				color: "#00000000"
				Text {
					color: colour.text
					font.pointSize: 18
					font.bold: true
					text: qsTr("Basic Settings")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/***************
			* SORT IMAGES *
			***************/

			SettingsText {

				width: tab.width

				text: "<h2>" + qsTr("Sort Images") + "</h2><br>" + qsTr("Here you can adjust, how the images in a folder are supposed to be sorted. You can sort them by Filename, Natural Name (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), File Size, and Date. Also, you can reverse the sorting order from ascending to descending if wanted.") + "<br><br><b>" + qsTr("Hint: You can also change this setting very quickly from the 'Quick Settings' window, hidden behind the right screen edge.") + "</b>"

			}

			/* SORT IMAGES ELEMENTS */

			// packed in rectangle for centering
			Rectangle {

				id: sortimages_subrect

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

					spacing: 10

					// Label
					Text {
						color: colour.text
						text: qsTr("Sort by:")
						font.pointSize: 10
						y: (sortimages_subrect.height-height)/2
					}
					// Choose Criteria
					CustomComboBox {
						id: sortimages_checkbox
						width: 150
						model: [qsTr("Name"), qsTr("Natural Name"), qsTr("Date"), qsTr("Filesize")]
					}

					// Ascending or Descending
					ExclusiveGroup { id: radiobuttons_sorting }
					CustomRadioButton {
						id: sortimages_ascending
						text: qsTr("Ascending")
						icon: "qrc:/img/settings/sortascending.png"
						y: (sortimages_subrect.height-height)/2
						exclusiveGroup: radiobuttons_sorting
						checked: true
					}
					CustomRadioButton {
						id: sortimages_descending
						text: qsTr("Descending")
						y: (sortimages_subrect.height-height)/2
						icon: "qrc:/img/settings/sortdescending.png"
						exclusiveGroup: radiobuttons_sorting
					}
				}

			}

			/***************
			* WINDOW MODE *
			***************/

			SettingsText {

				width: tab.width

				text: "<h2>" + qsTr("Window Mode") + "</h2><br>" + qsTr("PhotoQt is designed with the space of a fullscreen app in mind. That's why it by default runs as fullscreen. However, some might prefer to have it as a normal window, e.g. so that they can see the panel.")

			}

			/* WINDOW MODE ELEMENTS */

			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

				spacing: 10

					CustomCheckBox {
						id: windowmode
						text: qsTr("Run PhotoQt in Window Mode")
						onButtonCheckedChanged:     // 'Window Decoration' checkbox is only enabled when the 'Window ModeÄ checkbox is checked
						windowmode_deco.enabled = checkedButton
					}

					CustomCheckBox {
						id: windowmode_deco
						enabled: false
						text: qsTr("Show Window Decoration")
					}

				}

			}

			/*************
			* TRAY ICON *
			*************/

			SettingsText {

				width: tab.width

				text: "<h2>" + qsTr("Hide to Tray Icon") + "</h2><br>" + qsTr("When started PhotoQt creates a tray icon in the system tray. If desired, you can set PhotoQt to minimise to the tray instead of quitting. This causes PhotoQt to be almost instantaneously available when an image is opened.<br>It is also possible to start PhotoQt already minimised to the tray (e.g. at system startup) when called with \"--start-in-tray\".")

			}

			CustomComboBox {
				id: trayicon
				width: 250
				x: (parent.width-width)/2
				model: [qsTr("No tray icon"),qsTr("Hide to tray icon"),qsTr("Show tray icon, but don't hide to it")]
			}

			/***************
			* CLOSING 'X' *
			***************/

			SettingsText {

				width: tab.width

				text: "<h2>" + qsTr("Closing 'X' (top right)") + "</h2><br>" + qsTr("There are two looks for the closing 'x' at the top right: a normal 'x', or a slightly more fancy 'x'. Here you can switch back and forth between both of them, and also change their size. If you prefer not to have a closing 'x' at all, see below for an option to hide it.")

			}

			/* LOOK OF CLOSING 'X' */

			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

				spacing: 10

					ExclusiveGroup { id: radiobuttons_closingx }

					CustomRadioButton {
						id: closingx_normal
						text: qsTr("Normal Look")
						checked: true
						exclusiveGroup: radiobuttons_closingx
					}

					CustomRadioButton {
						id: closingx_fancy
						text: qsTr("Fancy Look")
						exclusiveGroup: radiobuttons_closingx
					}

				}

			}

			/* SIZE OF CLOSING 'X' */

			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

					spacing: 5

					Text {
						color: colour.text
						font.pointSize: 10
						text: qsTr("Small Size")
					}

					CustomSlider {
						id: closingx_sizeslider
						width: 300
						minimumValue: 5
						maximumValue: 25
						tickmarksEnabled: true
						stepSize: 1
					}

					Text {
						color: colour.text
						font.pointSize: 10
						text: qsTr("Large Size")
					}

				}

			}


			/************************
			* FIT IMAGES IN WINDOW *
			************************/

			SettingsText {

				width: tab.width

				text: "<h2>" + qsTr("Fit Image in Window") + "</h2><br>" + qsTr("If the image dimensions are smaller than the screen dimensions, PhotoQt can zoom those images to make them fir into the window. However, keep in mind, that such images will look pixelated to a certain degree (depending on each image).")

			}

			CustomCheckBox {
				id: fitinwindow
				x: (tab.width-width)/2
				text: qsTr("Fit Images in Window")
			}



			/******************************
			* HIDE/SHOW QUICKINFO LABELS *
			******************************/

			SettingsText {

				width: tab.width

				text: "<h2>" + qsTr("Hide Quickinfo (Text Labels)") + "</h2><br>" + qsTr("Here you can hide the text labels shown in the main area: The Counter in the top left corner, the file path/name following the counter, and the \"X\" displayed in the top right corner. The labels can also be hidden by simply right-clicking on them and selecting \"Hide\".")

			}

			// Checkboxes

			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Column {

					spacing: 5

					CustomCheckBox {
						id: quickinfo_counter
						text: qsTr("Hide Counter")
					}

					CustomCheckBox {
						id: quickinfo_filepath
						text: qsTr("Hide Filepath (Shows only file name)")
					}

					CustomCheckBox {
						id: quickinfo_filename
						text: qsTr("Hide Filename (Including file path)")
					}

					CustomCheckBox {
						id: quickinfo_closingx
						text: qsTr("Hide \"X\" (Closing)")
					}

				}

			}

		}

	}

	function saveData() {

		if(sortimages_checkbox.currentIndex == 0)
			settings.sortby = "name"
		else if(sortimages_checkbox.currentIndex == 1)
			settings.sortby = "naturalname"
		else if(sortimages_checkbox.currentIndex == 2)
			settings.sortby = "date"
		else if(sortimages_checkbox.currentIndex == 3)
			settings.sortby = "size"

		settings.sortbyAscending = sortimages_ascending.checked

		settings.windowmode = windowmode.checkedButton
		settings.windowDecoration = windowmode_deco.checkedButton

		settings.trayicon = trayicon.currentIndex

		settings.fancyX = closingx_fancy.checked
		settings.closeXsize = closingx_sizeslider.value

		settings.fitInWindow = fitinwindow.checkedButton

		settings.hidecounter = quickinfo_counter.checkedButton
		settings.hidefilepathshowfilename = quickinfo_filepath.checkedButton
		settings.hidefilename = quickinfo_filename.checkedButton
		settings.hidex = quickinfo_closingx.checkedButton

	}

	function setData() {

		if(settings.sortby === "name")
			sortimages_checkbox.currentIndex = 0
		else if(settings.sortby === "naturalname")
			sortimages_checkbox.currentIndex = 1
		else if(settings.sortby === "date")
			sortimages_checkbox.currentIndex = 2
		else if(settings.sortby === "size")
			sortimages_checkbox.currentIndex = 3

		sortimages_ascending.checked = settings.sortbyAscending
		sortimages_descending.checked = !settings.sortbyAscending

		windowmode.checkedButton = settings.windowmode
		windowmode_deco.enabled = windowmode.checkedButton
		windowmode_deco.checkedButton = settings.windowDecoration

		trayicon.currentIndex = settings.trayicon

		closingx_normal.checked = !settings.fancyX
		closingx_fancy.checked = settings.fancyX
		closingx_sizeslider.value = settings.closeXsize

		fitinwindow.checkedButton = settings.fitInWindow

		quickinfo_counter.checkedButton = settings.hidecounter
		quickinfo_filepath.checkedButton = settings.hidefilepathshowfilename
		quickinfo_filename.checkedButton = settings.hidefilename
		quickinfo_closingx.checkedButton = settings.hidex

	}

}
