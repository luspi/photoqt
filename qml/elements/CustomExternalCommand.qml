import QtQuick 2.3

Rectangle {

	id: detect

	property string command: ""

	property int detectWidth: 400
	property int detectHeight: 200
	property Item fillAnchors: parent

	property int posIfNew: -1

	anchors.fill: fillAnchors

	opacity: 0
	visible: false

	color: colour_fadein_block_bg

	// Click on background is like rejecting it
	// (this MouseArea has to come here at the top so that it can be overwritten below for the actual widget
	// (no click on actual rect should close it))
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: {
			if(!rect.contains(Qt.point(mouse.x,mouse.y)))
			hideDetect.start()
		}
	}

	Rectangle {

		id: rect

		// position it
		x: (parent.width-width)/2
		y: (parent.height-height)/2

		// Set size
		width: detectWidth
		height: detectHeight

		// Adjust colour and look
		color: colour_fadein_bg
		border.width: 1
		border.color: colour_fadein_border
		radius: 5

		// Confirmation text
		Text {

			x: 0
			y: 20
			width: parent.width
			horizontalAlignment: Text.AlignHCenter

			color: "white"
			font.pointSize: 13
			wrapMode: Text.WordWrap

			text: "<h2>External Command</h2>"

		}

		// Mousearea preventing background mousearea from catching clicks
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			onClicked: {}
		}

		CustomLineEdit {
			id: lineedit
			text: command
			x: 10
			width: parent.width-20-(browse.width+10)
			y: (parent.height-height)/2
		}

		CustomButton {
			id: browse
			width: height
			text: "..."
			x: parent.width-10-width
			y: (parent.height-height)/2
			onClickedButton: browseForExec()
		}


		CustomButton {

			width: 200
			x: (parent.width-width)/2
			y: parent.height-height-15
			text: "Cancel"

			onClickedButton: {
				hide()
			}

		}

	}



	function show() {
		showDetect.start()
	}
	function hide() {
		hideDetect.start()
	}

	function browseForExec() {
		var ret = getanddostuff.getFilename("Select Executeable",lineedit.text);
		if(ret !== "") lineedit.text = ret
	}

	PropertyAnimation {
		id: hideDetect
		target: detect
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
		}
	}
	PropertyAnimation {
		id: showDetect
		target: detect
		property: "opacity"
		to: 1
		onStarted: {
			visible = true
		}
	}

}
