import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

FadeInTemplate {

	id: filter_top

	heading: ""
	showSeperators: false

	marginTopBottom: (background.height-400)/2
	clipContent: false

	content: [

		// Heading
		Text {
			text: qsTr("Filter images in current directory")
			color: colour.text
			font.bold: true
			font.pointSize: 18
			x: (filter_top.contentWidth-width)/2
		},

		// This one (and the following ones) are simply space adders...
		Rectangle {
			color: "#00000000"
			width: 1
			height: 1
		},

		Text {
			text: qsTr("Enter here the term you want to search for. Separate multiple terms by a space.")
			x: (filter_top.contentWidth-width)/2
			color: colour.text
			font.pointSize: 10
		},

		Text {
			text: qsTr("If you want to limit a term to file extensions, prepend a dot '.' to the term.")
			x: (filter_top.contentWidth-width)/2
			color: colour.text
			font.pointSize: 10
		},

		Rectangle {
			color: "#00000000"
			width: 1
			height: 1
		},

		CustomLineEdit {

			id: term
			width: 400
			x: (filter_top.contentWidth-width)/2

		},

		Rectangle {
			color: "#00000000"
			width: 1
			height: 1
		},

		// Two main buttons
		Rectangle {

			color: "#00000000"

			x: (filter_top.contentWidth-width)/2
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
					onClickedButton: {
						verboseMessage("Filter","Accept filter")
						simulateEnter()
					}
				}

				CustomButton {
					text: qsTr("Cancel")
					onClickedButton: {
						verboseMessage("Filter","Cancel filter")
						hideFilter()
					}
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
						verboseMessage("Filter","Remove filter")
						currentfilter = ""
						doReload(thumbnailBar.currentFile)
						hideFilter()
					}
				}

			}
		}
	]

	// These two 'simulate' functions can be called via shortcuts
	function simulateEnter() {
		verboseMessage("Filter::simulateEnter()","")
		currentfilter = term.getText()
		doReload(thumbnailBar.currentFile)
		hideFilter()
	}

	function showFilter() {
		verboseMessage("Filter::showFilter()","")
		term.text = currentfilter
		term.forceActiveFocus()
		term.selectAll()
		show()
	}
	function hideFilter() {
		hide()
	}

}
