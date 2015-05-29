import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: filter

	anchors.fill: background
	color: colour.fadein_block_bg

	opacity: 0
	visible: false

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideFilterAni.start()
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
		border.color: colour.fadein_border
		radius: 10
		color: colour.fadein_bg

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
					text: qsTr("Filter images in current directory")
					color: colour.text
					font.bold: true
					font.pointSize: 20
					x: (rect.width-width)/2
				}

				// This one (and the following ones) are simply space adders...
				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				Text {
					text: qsTr("Enter here the term you want to search for. Seperate multiple terms by a space.")
					x: (rect.width-width)/2
					color: colour.text
				}

				Text {
					text: qsTr("If you want to limit a term to file extensions, prepend a dot '.' to the term.")
					x: (rect.width-width)/2
					color: colour.text
				}

				Rectangle {
					color: "#00000000"
					width: 1
					height: 1
				}

				CustomLineEdit {

					id: term
					width: 400
					x: (parent.width-width)/2

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

						Rectangle {
							color: "#00000000"
							width: 10+remove.width
							height: 1
						}

						CustomButton {
							id: enter
							text: qsTr("Filter")
							fontsize: 15
							onClickedButton: {
								simulateEnter()
							}
						}

						CustomButton {
							text: qsTr("Cancel")
							fontsize: 15
							onClickedButton: hideFilter()
						}

						Rectangle {
							color: "#00000000"
							width: 10
							height: 1
						}

						CustomButton {
							id: remove
							text: qsTr("Remove Filter")
							fontsize: 10
							enabled: currentfilter != ""
							y: (parent.height-height)/2
							onClickedButton: {
								currentfilter = ""
								doReload(thumbnailBar.currentFile)
								hideFilter()
							}
						}

					}
				}

			}

		}

	}

	// These two 'simulate' functions can be called via shortcuts
	function simulateEnter() {
		currentfilter = term.getText()
		doReload(thumbnailBar.currentFile)
		hideFilter()
	}

	function showFilter() {
		term.text = currentfilter
		term.forceActiveFocus()
		term.selectAll()
		showFilterAni.start()
	}
	function hideFilter() {
		hideFilterAni.start()
	}

	PropertyAnimation {
		id: hideFilterAni
		target: filter
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
		id: showFilterAni
		target: filter
		property: "opacity"
		to: 1
		duration: settings.myWidgetAnimated ? 250 : 0
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
