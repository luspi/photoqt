import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

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

	property var tiles: ["Filename","Filetype","Filesize","Dimensions","Make","Model","Software","Time Photo was taken","Exposure Time","Flash","ISO","Scene Type","Focal Length","F-Number","Light Source","GPS Position"]

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
					color: "white"
					font.pointSize: 18
					font.bold: true
					text: "Image Metadata"
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/********************
			* DESCRIPTIVE TEXT *
			********************/

			SettingsText {

				width: flickable.width

				text: "<br>PhotoQt can display different information of and about each image. The widget for this information is on the left outside the screen and slides in when mouse gets close to it and/or when the set shortcut (default Ctrl+E) is triggered. On demand, the triggering by mouse movement can be disabled by checking the box below.<br>"

			}



			/*********************
			* TRRIGGER ON MOUSE *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>Trigger Widget on Mouse Hovering</h2><br>Per default the info widget can be shown two ways: Moving the mouse cursor to the left screen edge to fade it in temporarily (as long as the mouse is hovering it), or permanently by clicking the checkbox (checkbox only stored per session, can't be saved permanently!). Alternatively the widget can also be triggered by shortcut. On demand the mouse triggering can be disabled, so that the widget would only show on shortcut. This can come in handy, if you get annoyed by accidentally opening the widget occasionally."

			}

			CustomCheckBox {

				id: triggeronmouse

				x: (parent.width-width)/2
				text: "Turn mouse triggering OFF"

			}


			/*****************
			* DETAILS TILES *
			*****************/

			SettingsText {

				width: flickable.width

				text: "<h2>Which items are shown?</h2><br>PhotoQt can display a number of information about the image (often called 'Exif data''). However, you might not be interested in all of them, hence you can choose to disable some of them here."

			}

			Rectangle {

				x: (parent.width-width)/2

				width: childrenRect.width
				height: childrenRect.height

				color: "#00000000"

				Row {

					spacing: 10

					CustomButton {
						text: "Enable ALL"
						width: 150
						onClickedButton: { checkAllTiles(true) }
					}
					CustomButton {
						text: "Disable ALL"
						width: 150
						onClickedButton: { checkAllTiles(false) }
					}

				}

			}

			Rectangle {

				x: (parent.width-width)/2

				width: childrenRect.width
				height: childrenRect.height

				color: "#00000000"

				GridLayout {

					id: grid
					columns: 6

					TabDetailsTile { id: filesize; text: "Filesize"; }
					TabDetailsTile { id: dimensions; text: "Dimensions"; }
					TabDetailsTile { id: make; text: "Make"; }
					TabDetailsTile { id: model; text: "Model"; }
					TabDetailsTile { id: software; text: "Software"; }
					TabDetailsTile { id: timephototaken; text: "Time Photo was Taken"; }
					TabDetailsTile { id: exposuretime; text: "Exposure Time"; }
					TabDetailsTile { id: flash; text: "Flash"; }
					TabDetailsTile { id: iso; text: "ISO"; }
					TabDetailsTile { id: scenetype; text: "Scene Type"; }
					TabDetailsTile { id: focallength; text: "Focal Length"; }
					TabDetailsTile { id: fnumber; text: "F-Number"; }
					TabDetailsTile { id: lightsource; text: "Light Source"; }
					TabDetailsTile { id: keywords; text: "Keywords"; }
					TabDetailsTile { id: location; text: "Location"; }
					TabDetailsTile { id: copyright; text: "Copyright"; }
					TabDetailsTile { id: gps; text: "GPS Position"; }

				}

			}


			/*************
			* FONT SIZE *
			*************/

			SettingsText {

				width: flickable.width

				text: "<h2>Adjusting Font Size</h2><br>Computers can have very different resolutions. On some of them, it might be nice to increase the font size of the labels to have them easier readable. Often, a size of 8 or 9 should be working quite well..."

			}

			Rectangle {

				x: (parent.width-width)/2

				width: childrenRect.width
				height: childrenRect.height

				color: "#00000000"

				Row {

					spacing: 10

					CustomSlider {

						id: fontsize_slider

						width: 400

						minimumValue: 5
						maximumValue: 20

						value: fontsize_spinbox.value
						tickmarksEnabled: true
						stepSize: 1

					}

					CustomSpinBox {

						id: fontsize_spinbox

						width: 75

						minimumValue: 5
						maximumValue: 20

						value: fontsize_slider.value
						suffix: " pt"

					}

				}

			}



			/*********************
			* ROTATING/FLIPPING *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>Rotating/Flipping Image according to Exif Data</h2><br>Some cameras can detect - while taking the photo - whether the camera was turned and might store this information in the image exif data. If PhotoQt finds this information, it can rotate the image accordingly. It can even already perform this check while loading the image. This would lead to proper orientations, even for thumbnails right from the start (requires 'Always rotate/flip images' to be selected)."

			}

			Rectangle {

				x: (parent.width-width)/2

				width: childrenRect.width
				height: childrenRect.height

				color: "#00000000"

				ExclusiveGroup { id: rotateflipgroup; }

				Row {

					spacing: 10

					CustomRadioButton {
						id: neverrotate
						text: "Never rotate/flip images"
						exclusiveGroup: rotateflipgroup
						checked: true
					}
					CustomRadioButton {
						id: alwaysrotate
						text: "Always rotate/flip images"
						exclusiveGroup: rotateflipgroup
					}
					CustomRadioButton {
						id: alwaysask
						text: "Always ask"
						exclusiveGroup: rotateflipgroup
					}

				}

			}

			CustomCheckBox {
				id: rotateonload
				text: "Rotate/Flip images already while loading them (including thumbnails)"
				x: (parent.width-width)/2
				enabled: alwaysrotate.checked
			}

			/**********************
			* ONLINE MAP FOR GPS *
			**********************/

			SettingsText {

				width: flickable.width

				text: "<h2>Online map for GPS</h2><br>If you're image includes a GPS location, then a click on the location text will load this location in an online map using your default external browser. Here you can choose which online service to use (suggestions for other online maps always welcome)."

			}

			Rectangle {

				x: (parent.width-width)/2

				width: childrenRect.width
				height: childrenRect.height

				color: "#00000000"

				ExclusiveGroup { id: mapgroup; }

				Row {

					spacing: 10

					CustomRadioButton {
						id: openstreetmap
						text: "openstreetmap.org"
						exclusiveGroup: mapgroup
						checked: true
					}
					CustomRadioButton {
						id: googlemaps
						text: "maps.google.com"
						exclusiveGroup: mapgroup
					}
					CustomRadioButton {
						id: bingmaps
						text: "bing.com/maps"
						exclusiveGroup: mapgroup
					}

				}

			}

		}

	}

	function checkAllTiles(checked) {

		for(var i = 0; i < grid.children.length; ++i) {
			grid.children[i].checked = checked
		}

	}

	function setData() {

		triggeronmouse.checkedButton = !settings.exifenablemousetriggering

		filesize.checked = settings.exiffilesize
		dimensions.checked = settings.exifdimensions
		make.checked = settings.exifmake
		model.checked = settings.exifmodel
		software.checked = settings.exifsoftware
		timephototaken.checked = settings.exifphototaken
		exposuretime.checked = settings.exifexposuretime
		flash.checked = settings.exifflash
		iso.checked = settings.exifiso
		scenetype.checked = settings.exifscenetype
		focallength.checked = settings.exifflength
		fnumber.checked = settings.exiffnumber
		lightsource.checked = settings.exiflightsource
		keywords.checked = settings.iptckeywords
		location.checked = settings.iptclocation
		copyright.checked = settings.iptccopyright
		gps.checked = settings.exifgps

		fontsize_slider.value = settings.exiffontsize

		neverrotate.checked = (settings.exifrotation === "Never")
		alwaysrotate.checked = (settings.exifrotation === "Always")
		alwaysask.checked = (settings.exifrotation === "Ask")
		rotateonload.checkedButton = settings.exifrotationAlreadyOnImageLoad

		openstreetmap.checked = (settings.exifgpsmapservice === "openstreetmap.org")
		googlemaps.checked = (settings.exifgpsmapservice === "maps.google.com")
		bingmaps.checked = (settings.exifgpsmapservice === "bing.com/maps")

	}

	function saveData() {

		settings.exifenablemousetriggering = !triggeronmouse.checkedButton

		settings.exiffilesize = filesize.checked
		settings.exifdimensions = dimensions.checked
		settings.exifmake = make.checked
		settings.exifmodel = model.checked
		settings.exifsoftware = software.checked
		settings.exifphototaken = timephototaken.checked
		settings.exifexposuretime = exposuretime.checked
		settings.exifflash = flash.checked
		settings.exifiso = iso.checked
		settings.exifscenetype = scenetype.checked
		settings.exifflength = focallength.checked
		settings.exiffnumber = fnumber.checked
		settings.exiflightsource = lightsource.checked
		settings.iptckeywords = keywords.checked
		settings.iptclocation = location.checked
		settings.iptccopyright = copyright.checked
		settings.exifgps = gps.checked

		settings.exiffontsize = fontsize_slider.value

		settings.exifrotation = neverrotate.checked ? "Never" : (alwaysrotate.checked ? "Always" : "Ask")
		settings.exifrotationAlreadyOnImageLoad = rotateonload.checkedButton
		settings.exifgpsmapservice = openstreetmap.checked ? "openstreetmap.org" : (googlemaps.checked ? "maps.google.com" : "bing.com/maps")

	}

}
