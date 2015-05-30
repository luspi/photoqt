import QtQuick 2.3

Rectangle {

	id: confirm

	property Item fillAnchors: parent

	property int maxwidth: 500

	property string header: qsTr("Confirm me?")
	property string description: qsTr("Do you really want to do this?")
	property string confirmbuttontext: qsTr("Yes, do it")
	property string rejectbuttontext: qsTr("No, don't")

	property bool alwaysDoThis: false
	property bool showDontAskAgain: false

	signal accepted()
	signal rejected()

	anchors.fill: fillAnchors

	opacity: 0
	visible: false

	color: colour.fadein_slidein_block_bg

	// Click on background is like rejecting it
	// (this MouseArea has to come here at the top so that it can be overwritten below for the actual widget
	// (no click on actual rect should close it))
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: {
			if(!rect.contains(Qt.point(mouse.x,mouse.y)))
			hideConfirm.start()
		}
	}

	Rectangle {

		id: rect

		// position it
		x: (parent.width-width)/2
		y: (parent.height-height)/2

		// Set size
		width: maxwidth
		height: col.height+5

		// Adjust colour and look
		color: colour.fadein_slidein_bg
		border.width: 1
		border.color: colour.fadein_slidein_border
		radius: 5

		// Mousearea preventing background mousearea from catching clicks
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			onClicked: {}
		}

		Column {

			id: col
			spacing: 5

			Text {
				id: head
				x: 5
				width: rect.width-10
				color: colour.text
				font.pointSize: 13
				wrapMode: Text.WordWrap
				text: "<h1>" + header + "</h1>"
				horizontalAlignment: Text.AlignHCenter
			}

			// Confirmation text
			Text {

				id: txt

				x: 5
				width: rect.width-10

				color: colour.text
				font.pointSize: 13
				wrapMode: Text.WordWrap

				text: description

				horizontalAlignment: Qt.AlignHCenter

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 10
			}

			CustomCheckBox {
				id: ask
				x: (parent.width-width)/2
				text: qsTr("Don't ask again")
				visible: showDontAskAgain
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 10
			}

			// Buttons for accepting/rejecting
			Rectangle {

				id: butrect

				x: 5
				width: rect.width-10
				height: childrenRect.height

				color: "#00000000"

				Row {

					id: butrow
					spacing: 5

					CustomButton {

						width: (butrect.width-butrow.spacing)/2
						text: confirmbuttontext

						onClickedButton: {
							alwaysDoThis = ask.checkedButton
							accepted()
							hide()
						}

					}

					CustomButton {

						width: (butrect.width-butrow.spacing)/2
						text: rejectbuttontext

						onClickedButton: {
							alwaysDoThis = ask.checkedButton
							rejected()
							hide()
						}

					}
				}
			}

		} // END Column

	}

	function show() {
		ask.checkedButton = false
		showConfirm.start()
	}
	function hide() {
		hideConfirm.start()
	}

	PropertyAnimation {
		id: hideConfirm
		target: confirm
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
		}
	}
	PropertyAnimation {
		id: showConfirm
		target: confirm
		property: "opacity"
		to: 1
		onStarted: {
			visible = true
		}
	}

}
