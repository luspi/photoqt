import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: rename

	anchors.fill: background
	color: colour.fadein_slidein_block_bg

	opacity: 0
	visible: false

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideRenameAni.start()
	}

	Rectangle {

		id: item

		// Set size
		width: topcol.width+2*radius+3*50
		height: topcol.height+2*topcol.spacing+2*50-20	// The -20 is due to the fact, that the key info is moved all the way down
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
				top: 50
				bottom: 50
				right: 50
				left: 50
			}

			color: "#00000000"

			Column {

				id: topcol

				spacing: 10

				// Heading
				Text {
					text: qsTr("Rename File")
					color: colour.text
					font.bold: true
					font.pointSize: 18*2
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
					color: colour.text_disabled
					font.pointSize: 10*2
					x: (rect.width-width)/2
				}

				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				// The new filename (the suffix cannot be changed here)
				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height:childrenRect.height
					x: (rect.width-width)/2
					Row {
						spacing: 5
						CustomLineEdit {
							id: newfilename
							text: ""
							fontsize: 13
							width: 350
						}
						Text {
							id: suffix
							color: colour.text
							text: ".JPG"
							font.pointSize: 13
						}
					}
				}

				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				// The two buttons for save/cancel
				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height:childrenRect.height
					x: (rect.width-width)/2
					Row {
						spacing: 5
						CustomButton {
							text: "Save"
							fontsize: 18
							enabled: newfilename.getText() !== ""
							onClickedButton: {
								verboseMessage("Rename","Save")
								if(newfilename.getText() !== "") {
									getanddostuff.renameImage(thumbnailBar.currentFile,newfilename.getText() + suffix.text)
									reloadDirectory(getanddostuff.removeFilenameFromPath(thumbnailBar.currentFile) + "/" + newfilename.getText() + suffix.text)
									hideRename()
								}
							}
						}
						CustomButton {
							text: qsTr("Cancel")
							fontsize: 18
							onClickedButton: {
								verboseMessage("Rename","Cancel")
								hideRename()
							}
						}
					}
				}


			}

		}

	}

	// This 'simulate' function can be called via shortcut
	function simulateEnter() {
		verboseMessage("Rename::simulateEnter()","")
		if(newfilename.getText() !== "") {
			getanddostuff.renameImage(thumbnailBar.currentFile,newfilename.getText() + suffix.text)
			reloadDirectory(getanddostuff.removeFilenameFromPath(thumbnailBar.currentFile) + "/" + newfilename.getText() + suffix.text)
			hideRename()
		}
	}

	function showRename() {
		verboseMessage("Rename::showRename()","")
		if(thumbnailBar.currentFile === "") return
		filename.text = getanddostuff.removePathFromFilename(thumbnailBar.currentFile)
		newfilename.text = ""	// This is needed, otherwise the lineedit might keep its old contents
								// (if opened twice for same image with different keys pressed in between)
		newfilename.text = getanddostuff.removePathFromFilename(thumbnailBar.currentFile, true)
		suffix.text = "." + getanddostuff.getSuffix(thumbnailBar.currentFile)
		newfilename.forceActiveFocus()
		newfilename.selectAll()
		showRenameAni.start()
	}
	function hideRename() {
		hideRenameAni.start()
	}

	PropertyAnimation {
		id: hideRenameAni
		target: rename
		property: "opacity"
		to: 0
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: unblurAllBackgroundElements()
		onStopped: {
			visible = false
			blocked = false
			if(thumbnailBar.currentFile === "")
				openFile()
		}
	}

	PropertyAnimation {
		id: showRenameAni
		target: rename
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			blurAllBackgroundElements()
			visible = true
			blocked = true
		}
	}

}
