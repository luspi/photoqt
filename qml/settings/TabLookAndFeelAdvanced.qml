import QtQuick 2.3
import QtQuick.Dialogs 1.1
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
					text: qsTr("Advanced Settings")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/**************
			* BACKGROUND *
			**************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Background of PhotoQt") + "</h2><br>" + qsTr("The background of PhotoQt is the part, that is not covered by an image. It can be made either real (half-)transparent (using a compositor), or faked transparent (instead of the actual desktop a screenshot of it is shown), or a custom background image can be set, or none of the above.<br>Note: Fake transparency currently only really works when PhotoQt is run in fullscreen/maximised!")

			}

			/* BACKGROUND ELEMENTS */

			// packed in rectangle for centering
			Rectangle {

				color: "#00000000"

				// center rectangle
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Column {

					spacing: 10

					// Ascending or Descending
					ExclusiveGroup { id: radiobuttons_background }
					CustomRadioButton {
						id: background_halftrans
						text: qsTr("Use (half-)transparent background")
						exclusiveGroup: radiobuttons_background
						checked: true
					}
					CustomRadioButton {
						id: background_fakedtrans
						text: qsTr("Use faked transparency")
						exclusiveGroup: radiobuttons_background
					}
					CustomRadioButton {
						id: background_image
						text: qsTr("Use custom background image")
						exclusiveGroup: radiobuttons_background
					}
					CustomRadioButton {
						id: background_onecoloured
						text: qsTr("Use one-coloured, non-transparent background")
						exclusiveGroup: radiobuttons_background
					}
				}

			}

			/* SELECT AND ADJUST BACKGROUND IMAGE */

			Rectangle {

				width: childrenRect.width
				height: childrenRect.height+20

				visible: background_image.checked

				x: (parent.width-width)/2
				y: 20

				color: "#00000000"

				Row {

					spacing: 20

					// DIsplay background image preview
					Image {
						id: background_image_select
						width: 200
						height: 150
						fillMode: background_image_scale.checked
							? Image.PreserveAspectFit : (background_image_stretch.checked
								? Image.Stretch : (background_image_scalecrop.checked
									? Image.PreserveAspectCrop : (background_image_tile.checked
										? Image.Tile : Image.Pad)))
						source: ""
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: {
							var f = getanddostuff.getFilenameQtImage()
							if(f !== "")
								parent.source = "file:/" + f
							}
						}

						// This is an 'empty' rectangle on top of image above - only visible when image source is empty
						Rectangle {
							anchors.fill: parent
							color: "#99222222"
							visible: (background_image_select.source == "")
							Text {
								anchors.fill: parent
								horizontalAlignment: Qt.AlignHCenter
								verticalAlignment: Qt.AlignVCenter
								color: "white"
								font.pointSize: 10
								text: qsTr("No image selected")
							}
						}
					}

					Rectangle {

						height: bg_col.height
						width: bg_col.width

						y: (parent.height-height)/2

						color: "#00000000"

						Column {

							id: bg_col

							spacing: 10

							ExclusiveGroup { id: radiobuttons_image }

							CustomRadioButton {
								id: background_image_scale
								text: qsTr("Scale to fit")
								exclusiveGroup: radiobuttons_image
								checked: true
							}
							CustomRadioButton {
								id: background_image_scalecrop
								text: qsTr("Scale and Crop to fit")
								exclusiveGroup: radiobuttons_image
							}
							CustomRadioButton {
								id: background_image_stretch
								text: qsTr("Stretch to fit")
								exclusiveGroup: radiobuttons_image
							}
							CustomRadioButton {
								id: background_image_center
								text: qsTr("Center image")
								exclusiveGroup: radiobuttons_image
							}
							CustomRadioButton {
								id: background_image_tile
								text: qsTr("Tile image")
								exclusiveGroup: radiobuttons_image
							}

						}
					}

				}
			}


			/*********************
			* BACKGROUND COLOUR *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Background/Overlay Color") + "</h2><br>" + qsTr("Here you can adjust the background colour of PhotoQt (of the part not covered by an image). When using compositing or a background image, then you can also specify an alpha value, i.e. the transparency of the coloured overlay layer. When neither compositing is enabled nor a background image is set, then this colour will be the non-transparent background of PhotoQt.")

			}

			Rectangle {

				color: "#00000000"
				width: childrenRect.width
				height: childrenRect.height
				x: (flickable.width-width)/2

				Row {

					spacing: 5

					Column {

						id: slider_column
						spacing: 5

						Rectangle {
							color: "#00000000"
							height: childrenRect.height
							width: childrenRect.width
							Row {
								spacing: 5
								Text {
									width: 60
									horizontalAlignment: Qt.AlignRight
									color: colour.text
									font.pointSize: 10
									text: qsTr("Red:")
								}

								CustomSlider {
									id: red
									minimumValue: 0
									maximumValue: 1
									stepSize: 0.01
								}
							}
						}
						Rectangle {
							color: "#00000000"
							height: childrenRect.height
							width: childrenRect.width
							Row {
								spacing: 5
								Text {
									width: 60
									horizontalAlignment: Qt.AlignRight
									color: colour.text
									font.pointSize: 10
									text: qsTr("Green:")
								}

								CustomSlider {
									id: green
									minimumValue: 0
									maximumValue: 1
									stepSize: 0.01
								}
							}
						}
						Rectangle {
							color: "#00000000"
							height: childrenRect.height
							width: childrenRect.width
							Row {
								spacing: 5
								Text {
									width: 60
									horizontalAlignment: Qt.AlignRight
									color: colour.text
									font.pointSize: 10
									text: qsTr("Blue:")
								}

								CustomSlider {
									id: blue
									minimumValue: 0
									maximumValue: 1
									stepSize: 0.01
								}
							}
						}
						Rectangle {
							color: "#00000000"
							height: childrenRect.height
							width: childrenRect.width
							Row {
								spacing: 5
								Text {
									width: 60
									horizontalAlignment: Qt.AlignRight
									color: colour.text
									font.pointSize: 10
									text: qsTr("Alpha:")
								}

								CustomSlider {
									id: alpha
									minimumValue: 0
									maximumValue: 1
									stepSize: 0.01
								}
							}
						}

					}

					/* Image, Rectangle, and Label to preview background colour */

					Image {

						id: background_colour

						width: 200
						height: slider_column.height

						source: "qrc:/img/transparent.png"
						fillMode: Image.Tile

						Rectangle {

							id: background_colour_label_back

							anchors.fill: parent

							color: Qt.rgba(red.value,green.value,blue.value,alpha.value)

							border.width: 1
							border.color: "#99969696"

							Rectangle {

								color: "#88000000"

								x: (parent.width-width)/2
								y: (parent.height-height)/2

								width: col_txt.width+10
								height: col_txt.height+10

								radius: global_item_radius

								Text {

									id: col_txt

									x: 5
									y: 5

									font.pointSize: 10

									horizontalAlignment: Qt.AlignHCenter
									verticalAlignment: Qt.AlignVCenter

									color: "white"
									text: qsTr("Preview colour")

								}

							}

						}

					}

				}

			}


			/***********************
			* BORDER AROUND IMAGE *
			***********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Border Around Image") + "</h2><br>" + qsTr("Whenever you load an image, the image is per default not shown completely in fullscreen, i.e. it's not stretching from screen edge to screen edge. Instead there is a small margin around the image of a couple pixels (looks better). Here you can adjust the width of this margin (set to 0 to disable it).")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomSlider {

						id: border_sizeslider

						width: 400

						minimumValue: 0
						maximumValue: 50

						value: border_sizespinbox.value
						tickmarksEnabled: true
						stepSize: 1

					}

					CustomSpinBox {

						id: border_sizespinbox

						width: 75

						minimumValue: 0
						maximumValue: 50

						value: border_sizeslider.value
						suffix: " px"

					}

				}

			}


			/********************************
			* CLOSE ON CLICK ON EMPTY AREA *
			********************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Close on Click in empty area") + "</h2><br>" + qsTr("This option makes PhotoQt behave a bit like the JavaScript image viewers you find on many websites. A click outside of the image on the empty background will close the application. It can be a nice feature, PhotoQt will feel even more like a \"floating layer\". However, you might at times close PhotoQt accidentally.") + "<br><br>" + qsTr("Note: If you use a mouse click for a shortcut already, then this option wont have any effect!")

			}

			CustomCheckBox {
				id: closeongrey
				text: qsTr("Close on click in empty area")
				x: (flickable.width-width)/2
			}


			/**************************
			* LOOPING THROUGH FOLDER *
			**************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Looping Through Folder") + "</h2><br>" + qsTr("When you load the last image in a directory and select 'Next', PhotoQt automatically jumps to the first image (and vice versa: if you select 'Previous' while having the first image loaded, PhotoQt jumps to the last image). Disabling this option makes PhotoQt stop at the first/last image (i.e. selecting 'Next'/'Previous' will have no effect in these two special cases).")

			}

			CustomCheckBox {
				id: loopfolder
				text: qsTr("Loop through folder")
				x: (flickable.width-width)/2
			}


			/*********************
			* SMOOTH TRANSITION *
			*********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Smooth Transition") + "</h2><br>" + qsTr("Switching between images can be done smoothly, the new image can be set to fade into the old image. 'No transition' means, that the previous image is simply replaced by the new image.")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					Text {
						color: colour.text
						text: qsTr("No Transition")
						font.pointSize: 10
					}

					CustomSlider {

						id: transition

						width: 400

						minimumValue: 0
						maximumValue: 10

						tickmarksEnabled: true
						stepSize: 1

					}

					Text {
						color: colour.text
						text: qsTr("Long Transition")
						font.pointSize: 10
					}


				}

			}


			/********************
			* MENU SENSITIVITY *
			********************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Menu Sensitivity") + "</h2><br>" + qsTr("Here you can adjust the sensitivity of the drop-down menu. The menu opens when your mouse cursor gets close to the right side of the upper edge. Here you can adjust how close you need to get for it to open.")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					Text {
						color: colour.text
						text: qsTr("Low Sensitivity")
						font.pointSize: 10
					}

					CustomSlider {

						id: menusensitivity

						width: 400

						minimumValue: 1
						maximumValue: 10

						tickmarksEnabled: true
						stepSize: 1

					}

					Text {
						color: colour.text
						text: qsTr("High Sensitivity")
						font.pointSize: 10
					}

				}

			}



			/***************************
			* MOUSE WHEEL SENSITIVITY *
			***************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Mouse Wheel Sensitivity") + "</h2><br>" + qsTr("Here you can adjust the sensitivity of the mouse wheel. For example, if you have set the mouse wheel up/down for switching back and forth between images, then a lower sensitivity means that you will have to scroll further for triggering a shortcut. Per default it is set to the highest sensitivity, i.e. every single wheel movement is evaluated.")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					Text {
						color: colour.text
						text: qsTr("Very sensitive")
						font.pointSize: 10
					}

					CustomSlider {

						id: wheelsensitivity

						width: 400

						minimumValue: 1
						maximumValue: 10

						tickmarksEnabled: true
						stepSize: 1

					}

					Text {
						color: colour.text
						text: qsTr("Not at all sensitive")
						font.pointSize: 10
					}

				}

			}



			/************************
			* REMEMBER PER SESSION *
			************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Remember per session") + "</h2><br>" + qsTr("If you would like PhotoQt to remember the rotation/flipping and/or zoom level per session (not permanent), then you can enable it here. If not set, then every time a new image is displayed, it is displayed neither zoomed nor rotated nor flipped (one could say, it is displayed 'normal').")

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Row {

					spacing: 10

					CustomCheckBox {
						id: remember_rotation
						text: qsTr("Remember Rotation/Flip")
					}

					CustomCheckBox {
						id: remember_zoom
						text: qsTr("Remember Zoom Level")
					}

				}

			}



			/************************
			* REMEMBER PER SESSION *
			************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Animation and Window Geometry") + "</h2><br>" + qsTr("There are two things that can be adjusted here:") + "<ol><li>" + qsTr("Animation of fade-in widgets (like, e.g., Settings or About Widget)") + "</li><li>" + qsTr("Save and restore of Window Geometry: On quitting PhotoQt, it stores the size and position of the window and can restore it the next time started.") + "</li></ol>"

			}

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (flickable.width-width)/2

				Column {

				spacing: 10

					CustomCheckBox {
						id: animate_elements
						text: qsTr("Animate all fade-in elements")
					}

					CustomCheckBox {
						id: save_restore_geometry
						text: qsTr("Save and restore window geometry")
					}


				}

			}

		}

	}

	function saveData() {

		settings.composite = background_halftrans.checked
		settings.backgroundImageScreenshot = background_fakedtrans.checked
		settings.backgroundImageUse = background_image.checked

		settings.backgroundImagePath = background_image_select.source

		settings.backgroundImageScale = background_image_scale.checked
		settings.backgroundImageScaleCrop = background_image_scalecrop.checked
		settings.backgroundImageStretch = background_image_stretch.checked
		settings.backgroundImageCenter = background_image_center.checked
		settings.backgroundImageTile = background_image_tile.checked

		settings.bgColorRed = red.value*255.0
		settings.bgColorGreen = green.value*255.0
		settings.bgColorBlue = blue.value*255.0
		settings.bgColorAlpha = alpha.value*255.0

		settings.borderAroundImg = border_sizeslider.value

		settings.closeongrey = closeongrey.checkedButton

		settings.loopthroughfolder = loopfolder.checkedButton

		settings.transition = transition.value

		settings.menusensitivity = menusensitivity.value

		settings.mouseWheelSensitivity = wheelsensitivity.value

		settings.rememberRotation = remember_rotation.checkedButton
		settings.rememberZoom = remember_zoom.checkedButton

		settings.myWidgetAnimated = animate_elements.checkedButton
		settings.saveWindowGeometry = save_restore_geometry.checkedButton

	}

	function setData() {

		background_halftrans.checked = settings.composite
		background_fakedtrans.checked = settings.backgroundImageScreenshot
		background_image.checked = settings.backgroundImageUse
		background_onecoloured.checked = (!settings.composite && !settings.backgroundImageScreenshot && !settings.backgroundImageUse)

		background_image_select.source = settings.backgroundImagePath

		background_image_scale.checked = settings.backgroundImageScale
		background_image_scalecrop.checked = settings.backgroundImageScaleCrop
		background_image_stretch.checked = settings.backgroundImageStretch
		background_image_center.checked = settings.backgroundImageCenter
		background_image_tile.checked = settings.backgroundImageTile

		red.value = settings.bgColorRed/255.0
		green.value = settings.bgColorGreen/255.0
		blue.value = settings.bgColorBlue/255.0
		alpha.value = settings.bgColorAlpha/255.0

		border_sizeslider.value = settings.borderAroundImg

		closeongrey.checkedButton = settings.closeongrey

		loopfolder.checkedButton = settings.loopthroughfolder

		transition.value = settings.transition

		menusensitivity.value = settings.menusensitivity

		wheelsensitivity.value = settings.mouseWheelSensitivity

		remember_rotation.checkedButton = settings.rememberRotation
		remember_zoom.checkedButton = settings.rememberZoom

		animate_elements.checkedButton = settings.myWidgetAnimated
		save_restore_geometry.checkedButton = settings.saveWindowGeometry

	}

}
