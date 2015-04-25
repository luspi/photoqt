import QtQuick 2.3
import "../../javascript/keydetect.js" as KeyDetect

Rectangle {

	id: detect

	property string command: ""

	property int detectWidth: 400
	property int detectHeight: 200
	property Item fillAnchors: parent

	signal gotKeyCombo(var txt, var cmd)
	signal gotNewKeyCombo(var txt, var cmd, var id)
	signal updateCombo(var txt, var cmd)
	signal updateNewCombo(var txt, var cmd, var id)

	property string combo: ""
	property int posIfNew: -1
	property bool normalkey: false

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

			text: "<h2>Detect key combination</h2>"

		}

		Text {

			id: combo

			x: 0
			width: parent.width
			y: (parent.height-height)/2

			horizontalAlignment: Text.AlignHCenter

			color: "white"
			font.pointSize: 11
			font.italic: true

			text: "[Press keys]"

		}

		// Mousearea preventing background mousearea from catching clicks
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			onClicked: {}
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

	function updateComboString(sh) {
		combo.text = sh
	}
	function gotCombo(sh) {
		combo.text = sh
		hide()
	}

	function show() {
		showDetect.start()
		updateComboString("[Press keys]")
	}
	function hide() {
		hideDetect.start()
	}

	PropertyAnimation {
		id: hideDetect
		target: detect
		property: "opacity"
		to: 0
		onStopped: visible = false
	}
	PropertyAnimation {
		id: showDetect
		target: detect
		property: "opacity"
		to: 1
		onStarted: visible = true
	}

	function detectedCombo(txt) {
		if(posIfNew == -1)
			updateCombo(txt, command)
		else
			updateNewCombo(txt, command, posIfNew)

		detect.combo = txt
	}

	function keysReleased() {
		if(posIfNew == -1)
			gotKeyCombo(detect.combo, command)
		else
			gotNewKeyCombo(detect.combo, command, posIfNew)

		detect.combo = ""
	}

}
