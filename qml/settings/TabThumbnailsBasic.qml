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
					font.pointSize: global_fontsize_title
					font.bold: true
					text: qsTr("Basic Settings")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/******************
			* THUMBNAIL SIZE *
			******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Thumbnail Size") + "</h2><br>" + qsTr("Here you can adjust the thumbnail size. You can set it to any size between 20 and 256 pixel. Per default it is set to 80 pixel, but with different screen resolutions it might be nice to have them larger/smaller.")

			}

			/* THUMBNAIL SIZE ELEMENTS */

			// packed in rectangle for centering
			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomSlider {

						id: size_slider

						width: 400

						minimumValue: 20
						maximumValue: 256

						value: size_spinbox.value
						stepSize: 1

					}

					CustomSpinBox {

						id: size_spinbox

						width: 75

						minimumValue: 20
						maximumValue: 256

						value: size_slider.value

					}


				}

			}


			/*********************
			* THUMBNAIL SPACING *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Spacing Between Thumbnail Images") + "</h2><br>" + qsTr("The thumbnails are shown in a row at the lower or upper edge (depending on your setup). They are lined up side by side. Per default, there's no empty space between them, however exactly that can be changed here.")

			}

			/* THUMBNAIL SPACING ELEMENTS */

			// packed in rectangle for centering
			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

				spacing: 10

					CustomSlider {

						id: spacing_slider

						width: 400

						minimumValue: 0
						maximumValue: 30

						tickmarksEnabled: true

						value: spacing_spinbox.value
						stepSize: 1

					}

					CustomSpinBox {

						id: spacing_spinbox

						width: 75

						minimumValue: 0
						maximumValue: 30

						value: spacing_slider.value

					}


				}

			}


			/*********************
			* THUMBNAIL LIFT-UP *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Lift-up of Thumbnail Images on Hovering") + "</h2><br>" + qsTr("When a thumbnail is hovered, it is lifted up some pixels (default 10). Here you can increase/decrease this value according to your personal preference.")

			}

			/* THUMBNAIL LIFT-UP ELEMENTS */

			// packed in rectangle for centering
			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomSlider {

						id: liftup_slider

						width: 400

						minimumValue: 0
						maximumValue: 40

						tickmarksEnabled: true

						value: liftup_spinbox.value
						stepSize: 1

					}

					CustomSpinBox {

						id: liftup_spinbox

						width: 75

						minimumValue: 0
						maximumValue: 40

						value: liftup_slider.value

					}

				}

			}


			/**************************
			* THUMBNAIL KEEP VISIBLE *
			**************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Keep Thumbnails Visible") + "</h2><br>" + qsTr("Per default the Thumbnails slide out over the edge of the screen. Here you can force them to stay visible. The big image is shrunk to fit into the empty space. Note, that the thumbnails will be hidden (and only shown on mouse hovering) once you zoomed the image in/out. Resetting the zoom restores the original visibility of the thumbnails.")

			}

			CustomCheckBox {

				id: keepvisible

				text: qsTr("Keep Thumnails Visible")

				x: (flickable.width-width)/2

			}


			/*********************
			* THUMBNAIL DYNAMIC *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Dynamic Thumbnail Creation") + "</h2><br>" + qsTr("Dynamic thumbnail creation means, that PhotoQt only sets up those thumbnail images that are actually needed, i.e. it stops once it reaches the end of the visible area and sits idle until you scroll left/right.") + "<br>" +qsTr("Smart thumbnails are similar in nature. However, they make use of the fast, that once a thumbnail has been created, it can be loaded very quickly and efficiently. It also first loads all of the currently visible thumbnails, but it doesn't stop there: Any thumbnails (even if invisible at the moment) that once have been created are loaded. This is a nice compromise between efficiency and usability.") + "<br><br>" + qsTr("Enabling either the smart or dynamic option is recommended, as it increases the performance of PhotoQt significantly, while preserving the usability.")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Column {

					spacing: 10

					ExclusiveGroup { id: dynamicgroup; }

					CustomRadioButton {
						id: normal
						text: qsTr("Normal Thumbnails")
						exclusiveGroup: dynamicgroup
					}

					CustomRadioButton {
						id: dynamic
						text: qsTr("Dynamic Thumbnails")
						exclusiveGroup: dynamicgroup
					}

					CustomRadioButton {
						id: smart
						text: qsTr("Smart Thumbnail")
						exclusiveGroup: dynamicgroup
						checked: true
					}

				}

			}


			/***********************
			* THUMBNAIL CENTER ON *
			***********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Always center on Active Thumbnail") + "</h2><br>" + qsTr("If this option is set, then the active thumbnail (i.e., the thumbnail of the currently displayed image) will always be kept in the center of the thumbnail bar (if possible). If this option is not set, then the active thumbnail will simply be kept visible, but not necessarily in the center.")

			}

			CustomCheckBox {

				id: centeron

				text: qsTr("Center on Active Thumbnails")

				x: (flickable.width-width)/2

			}

		}
	}

	function setData() {

		size_slider.value = settings.thumbnailsize

		spacing_slider.value = settings.thumbnailSpacingBetween

		liftup_slider.value = settings.thumbnailLiftUp

		keepvisible.checkedButton = settings.thumbnailKeepVisible

		normal.checked = (settings.thumbnailDynamic === 0)
		dynamic.checked = (settings.thumbnailDynamic === 1)
		smart.checked = (settings.thumbnailDynamic === 2)

		centeron.checkedButton = settings.thumbnailCenterActive

	}

	function saveData() {

		settings.thumbnailsize = size_slider.value

		settings.thumbnailSpacingBetween = spacing_slider.value

		settings.thumbnailLiftUp = liftup_slider.value

		settings.thumbnailKeepVisible = keepvisible.checkedButton

		settings.thumbnailDynamic = (normal.checked ? 0 : (dynamic.checked ? 1 : 2))

		settings.thumbnailCenterActive = centeron.checkedButton

	}

}
