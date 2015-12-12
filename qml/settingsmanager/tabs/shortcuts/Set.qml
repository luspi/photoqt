import QtQuick 2.3
import ToolTip 1.0

import "../../../elements"

Rectangle {

	id: top

	// The width is adjusted according to the width of the parent widget (above row)
	width: rowabove.w/2-5

	// The height adjusts dynamically depending on how many elements there are
	height: childrenRect.height
	Behavior on height { NumberAnimation { duration: 150; } }

	// The current key combo is taken from the parent widget
	property string currentKeyCombo: parent.parent.currentKeyCombo
	onCurrentKeyComboChanged: newComboRightHere(currentKeyCombo)

	// the current mouse combo is taken from the parent widget
	property string currentMouseCombo: parent.parent.currentMouseCombo
	onCurrentMouseComboChanged: newMouseComboRightHere(currentMouseCombo)

	// Keys released signals an end to shortcut detection
	property bool keysReleased: parent.parent.keysReleased

	// Mouse combo change cancelled
	property bool mouseCancelled: parent.parent.mouseCancelled

	// These govern the behaviour of the children elements:
	// A new combo was detected and each child checks if they're looking for a new
	// shortcut, and if they do, then they take it
	signal newComboRightHere(var combo)
	// And this is the pendant to a mouse combo
	signal newMouseComboRightHere(var combo)
	// Only one child at a time can detect a shortcut -> starting a new one cancels all others
	signal cancelAllOtherDetection()

	color: "transparent"
	radius: 4
	clip: true

	// The currently set shortcuts
	property var shortcuts: []

	property string lastaction: ""

	GridView {

		id: grid

		x: 3
		y: 3
		width: parent.width-6
		height: shortcuts.length*cellHeight

		cellWidth: parent.width
		cellHeight: 30

		model: shortcuts.length

		delegate: Rectangle {

			id: ele

			x: 3
			y: 3
			width: grid.cellWidth-6
			height: grid.cellHeight-6

			radius: 3
			clip: true

			// Change color when hovered
			property bool hovered: false
			color: hovered ? colour.tiles_inactive : colour.tiles_disabled
			Behavior on color { ColorAnimation { duration: 150; } }

			// Click on title triggers shortcut detection
			ToolTip {
				cursorShape: Qt.PointingHandCursor
				text: "Click to change shortcut"
				onClicked: triggerDetection()
				onEntered: ele.hovered = true
				onExited: ele.hovered = false
			}

			Row {

				x: 2
				y: 2

				// What shortcut this is
				Text {
					height: ele.height-4
					width: ele.width/2-4
					color: colour.text
					elide: Text.ElideRight
					text: shortcuts[index][0]
				}

				// The currently set key (split into two parts)
				Rectangle {

					width: (ele.width/2-sh_delete.width)-4
					height: ele.height-4

					color: "transparent"

					// The prefix
					Text {
						id: sh_key_desc
						color: colour.text
						text: shortcuts[index][3] === "key" ? "Key: " : "Mouse: "
					}
					// The current shortcut
					Text {

						id: key_combo

						// We store the current shortcut in seperate variable. A '...' signals that no shortcut is set (yet)
						property string store: shortcuts[index][1] === "" ? "..." : shortcuts[index][1]

						// This boolean is changed when a new shortcut is requested
						property bool ignoreAllCombos: true

						anchors.left: sh_key_desc.right
						color: colour.text
						text: store

						// We update the array with the new data
						onTextChanged: shortcuts[index][1] = text

					}

					// A click triggers shortcut detection
					ToolTip {

						cursorShape: Qt.PointingHandCursor
						text: "Click to change shortcut"

						onClicked: triggerDetection()
						onEntered: ele.hovered = true
						onExited: ele.hovered = false

					}

				}

				Text {
					id: sh_delete
					height: ele.height-4
					color: colour.text
					elide: Text.ElideRight
					text: "x"
					horizontalAlignment: Text.AlignHCenter
					width: 20
					ToolTip {
						cursorShape: Qt.PointingHandCursor
						text: "Delete shortcut"
						onClicked: {
							deleteElement.start()
						}
					}
				}

			}

			// When requesting a new shortcut, if nothing happens after 2 seconds, then it is cancelled
			Timer {

				id: abortDetection
				interval: 2000
				running: false
				repeat: false
				onTriggered: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						key_combo.text = key_combo.store
						key_combo.font.italic = false

					}

				}

			}

			Connections {

				target: grid.parent

				// New key combo
				onNewComboRightHere: {

					if(!key_combo.ignoreAllCombos) {

						abortDetection.stop()
						key_combo.font.italic = true
						key_combo.text = grid.parent.currentKeyCombo

					}

				}

				onNewMouseComboRightHere: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.store = grid.parent.currentMouseCombo
						key_combo.text = key_combo.store

					}

				}

				// Keys released -> key combo possibly finished
				onKeysReleasedChanged: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						abortDetection.stop()
						key_combo.font.italic = false
						if(key_combo.text.charAt(key_combo.text.length-1) == "+")
							key_combo.text = key_combo.store
						else
							key_combo.store = key_combo.text

					}

				}

				onMouseCancelledChanged: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						key_combo.text = key_combo.store

					}

				}

				// Another element requested a new shortcut
				onCancelAllOtherDetection: {

					if(!key_combo.ignoreAllCombos) {

						key_combo.ignoreAllCombos = true
						key_combo.text = key_combo.store
						key_combo.font.italic = false

					}

				}

			}

			PropertyAnimation {
				id: deleteElement
				target: ele
				property: "x"
				to: -ele.width
				duration: 200
				onStopped: {
					var tmp = shortcuts
					tmp.splice(index,1)
					lastaction = "del"
					shortcuts = tmp
				}
			}

			function triggerDetection() {
				if(shortcuts[index][3] === "key") {
					grid.parent.cancelAllOtherDetection()
					key_combo.text = "... Press keys ..."
					key_combo.font.italic = true
					key_combo.ignoreAllCombos = false
					abortDetection.restart()
				} else {
					grid.parent.cancelAllOtherDetection()
					key_combo.ignoreAllCombos = false
					detectMouseShortcut.show()
				}
			}

			Component.onCompleted: {
				if(index == shortcuts.length-1 && key_combo.text == "..." && lastaction == "add") {
					grid.parent.cancelAllOtherDetection()
					triggerDetection()
				}
			}

		}

	}

}
