import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: deleteImage

	anchors.fill: background
	color: colour.fadein_slidein_block_bg

	opacity: 0
	visible: false

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideDeleteAni.start()
	}

	Rectangle {

		id: item

		// Set size
		width: topcol.width+2*radius+2*30
		height: topcol.height+2*topcol.spacing+2*30-20	// The -20 is due to the fact, that the key info is moved all the way down
		x: (parent.width-width)/2
		y: (parent.height-height)/2

		// Some styling
		border.width: 1
		border.color: colour.fadein_slidein_border
		radius: global_element_radius
		color: colour.fadein_slidein_bg

		// Clicks INSIDE element doesn't close it
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
		}

		Rectangle {

			id: rect

			// Set inner area for display
			anchors.fill: parent
			anchors.margins: {
				top: 30
				bottom: 30
				right: 30
				left: 30
			}

			color: "#00000000"

			Column {

				id: topcol

				spacing: 10

				// Heading
				Text {
					text: qsTr("Delete File")
					color: colour.text
					font.bold: true
					font.pointSize: 28
					x: (rect.width-width)/2
				}

				// This one (and the following ones) are simply space adders...
				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				// The filename is dynamically updated when element is shown
				Text {
					id: filename
					text: ""
					color: colour.disabled
					font.pointSize: 20
					x: (rect.width-width)/2
				}

				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				Text {
					text: qsTr("Do you really want to delete this file?")
					x: (rect.width-width)/2
					font.pointSize: 22
					color: colour.text
				}

				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				// Two main buttons
				Rectangle {

					color: "#00000000"

					x: (rect.width-width)/2
					width: childrenRect.width
					height: childrenRect.height

					Row {

						spacing: 5

						// This button triggers "Move to Trash" under Linux, and permanent "Delete" under Windows
						CustomButton {
							id: movetotrash
							text: getanddostuff.amIOnLinux() ? qsTr("Move to Trash") : qsTr("Delete")
							fontsize: 20
							onClickedButton: {
								hideDelete()
								getanddostuff.deleteImage(thumbnailBar.currentFile,getanddostuff.amIOnLinux())
								reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion())
							}
						}

						CustomButton {
							text: qsTr("Cancel")
							fontsize: 20
							onClickedButton: hideDelete()
						}

					}
				}

				// Permanent "Delete" (needed on Linux only)
				CustomButton {
					text: qsTr("Delete permanently")
					fontsize: 15
					visible: getanddostuff.amIOnLinux()
					x: (rect.width-width)/2
					onClickedButton: {
						hideDelete()
						getanddostuff.deleteImage(thumbnailBar.currentFile,false)
						reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion())
					}
				}

				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				// A little explanatory text informing the user about the shortcuts
				Text {
					text: getanddostuff.amIOnLinux() ? qsTr("Enter = Move to Trash, Shift+Enter = Delete permanently, Escape = Cancel") : qsTr("Enter = Delete, Escape = Cancel")
					color: colour.text
					font.pointSize: 10
					x: rect.width-width
				}

			}

		}

	}

	// These two 'simulate' functions can be called via shortcuts
	function simulateEnter() {
		hideDelete()
		getanddostuff.deleteImage(thumbnailBar.currentFile,getanddostuff.amIOnLinux())
		reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion())
	}
	function simulateShiftEnter() {
		hideDelete()
		getanddostuff.deleteImage(thumbnailBar.currentFile,false)
		reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion())
	}

	function showDelete() {
		if(thumbnailBar.currentFile == "") return
		filename.text = getanddostuff.removePathFromFilename(thumbnailBar.currentFile)
		showDeleteAni.start()
	}
	function hideDelete() {
		hideDeleteAni.start()
	}

	PropertyAnimation {
		id: hideDeleteAni
		target: deleteImage
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStopped: {
			visible = false
			blocked = false
			if(thumbnailBar.currentFile === "")
				openFile()
		}
	}

	PropertyAnimation {
		id: showDeleteAni
		target: deleteImage
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
