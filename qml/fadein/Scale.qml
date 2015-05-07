import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: scale

	anchors.fill: background
	color: colour_fadein_block_bg

	opacity: 0
	visible: false

	// Click on background closes scale element
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideScaleAni.start()
	}

	// Visible area
	Rectangle {

		id: item

		// Set size
		width: 500
		height: topcol.height+2*topcol.spacing
		x: (parent.width-width)/2
		y: (parent.height-height)/2

		// Some styling
		border.width: 1
		border.color: colour_fadein_border
		radius: 10
		color: colour_fadein_bg

		Rectangle {

			id: rect

			// Set inner area for display
			anchors.fill: parent
			anchors.margins: item.radius
			color: "#00000000"

			MouseArea {
				anchors.fill: parent
			}

			Column {

				id: topcol

				spacing: 22

				// Header
				Text {
					text: "Scale Image"
					color: "white"
					font.pointSize: 25
					font.bold: true
					x: (parent.width-width)/2
				}

				// Current dimension
				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					Row {
						spacing: 5
						Text {
							text: "Current Size:"
							color: "white"
						}
						Text {
							id: currentwidth
							text: "4000"
							color: "white"
						}
						Text {
							text: "x"
							color: "white"
						}
						Text {
							id: currentheight
							text: "3000"
							color: "white"
						}
					}
				}

				// New settings
				Rectangle {

					color: "#00000000"
					width: rect.width
					height: scalerow.height
					x: (parent.width-scalerow.width)/2

					Row {

						id: scalerow
						spacing: 5

						// The labels on the left
						Rectangle {
							id: rowlabels
							color: "#00000000"
							width: childrenRect.width
							height: childrenRect.height
							Text {
								color: "white"
								text: "New Width:"
								horizontalAlignment: Text.AlignRight
								y: (newwidth.height-height)/2+5
							}
							Text {
								color: "white"
								text: "New Height:"
								horizontalAlignment: Text.AlignRight
								y: newwidth.height+10+(newheight.height-height)/2
							}
						}

						// The spinboxes for the new dimension
						Rectangle {
							id: rowedits
							color: "#00000000"
							width: childrenRect.width
							height: childrenRect.height
							// new width
							CustomSpinBox {
								id: newwidth
								width: 75
								value: 4000
								maximumValue: 99999
								minimumValue: 1
								y: 5
							}
							// new height
							CustomSpinBox {
								id: newheight
								width: 75
								value: 3000
								maximumValue: 99999
								minimumValue: 1
								y: newwidth.height+10
							}
						}

						// Image keeping the aspect ratio
						Image {
							id: aspect_image
							source: "qrc:/img/ratioKeep.png"
							sourceSize: Qt.size(0.9*aspect_text.height,0.9*aspect_text.height)
							y: (rowedits.height-height)/2+5
							property bool keepaspectratio: true
							opacity: keepaspectratio ? 1 : 0.3
							// Click triggers keeping of aspect ratio
							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									parent.keepaspectratio = !parent.keepaspectratio
									parent.source = parent.keepaspectratio ? "qrc:/img/ratioKeep.png" : "qrc:/img/ratioDontKeep.png"
								}
							}
						}

						// Text explaining the current aspect ratio setting
						Text {
							id: aspect_text
							color: "white"
							opacity: aspect_image.keepaspectratio ? 1 : 0.3
							text: "Aspect Ratio"
							font.strikeout: !aspect_image.keepaspectratio
							y: (rowedits.height-height)/2+5
							// Click triggers keeping of aspect ratio
							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									aspect_image.keepaspectratio = !aspect_image.keepaspectratio
									aspect_image.source = aspect_image.keepaspectratio ? "qrc:/img/ratioKeep.png" : "qrc:/img/ratioDontKeep.png"
								}
							}
						}
					}
				}

				// Quality setting
				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					Row {
						spacing: 5
						Text {
							color: "white"
							text: "Quality"
						}
						CustomSlider {
							id: quality_slider
							minimumValue: 1
							maximumValue: 100
							value: 90
							stepSize: 1

							y: (quality_text.height-height)/2
						}
						// Display quality percentage
						Text {
							id: quality_text
							color: "white"
							text: quality_slider.value.toString()
						}
					}
				}

				// The three buttons
				Rectangle {

					x: (parent.width-width)/2
					width: childrenRect.width
					height: childrenRect.height

					color: "#00000000"

					Row {

						spacing: 5

						CustomButton {
							id: scale_inplace
							text: "Scale in place"
							onClickedButton: hideScale()
						}
						CustomButton {
							id: scale_innewfile
							text: "Scale into new file"
							onClickedButton: hideScale()
						}
						CustomButton {
							id: scale_dont
							text: "Don't scale"
							onClickedButton: hideScale()
						}
					}
				}
			}
		}
	}

	function showScale() {
		showScaleAni.start()
	}
	function hideScale() {
		hideScaleAni.start()
	}

	PropertyAnimation {
		id: hideScaleAni
		target:  scale
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
			blocked = false
		}
	}

	PropertyAnimation {
		id: showScaleAni
		target:  scale
		property: "opacity"
		to: 1
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
