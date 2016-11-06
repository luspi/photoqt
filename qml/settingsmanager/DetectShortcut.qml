import QtQuick 2.3

import "../elements"

Rectangle {

	id: top

	anchors.fill: parent
	color: "#ee000000"

	opacity: 0

	// The semi-transparent icons at the top have this opacity
	property real opacityDisabledCategory: 0.2

	// Store selections for later use
	property string category: "key"
	property string key_combo: ""
	property int touch_fingers: 1
	property string touch_action: "tap"
	property var touch_path: []
	property string mouse_mods: ""
	property string mouse_button: ""
	property var mouse_path: []

	property bool successful: false
	signal success(var cat, var args)
	signal cancel()

	property var checkAllShortcuts: ({})
	signal takenShortcutsUpdated()

	property bool leftButtonMouseClickAndMove: true
	onLeftButtonMouseClickAndMoveChanged: takenShortcutsUpdated()
	property bool singleFingerTouchPressAndMove: true
	onSingleFingerTouchPressAndMoveChanged: takenShortcutsUpdated()

	// Animate element by controlling opacity
	Behavior on opacity { NumberAnimation { duration: 100; } }
	onOpacityChanged: {
		visible = (opacity == 0 ? false : true)
		if(opacity == 1)
			countdowntimer.start()
	}

	// main column
	Column {

		spacing: 5

		// top row, containing the category symbols
		Rectangle {

			id: icons
			color: "transparent"
			height: 120
			width: top.width

			// The symbols are contained in a sub-rectangle for centering
			Rectangle {

				color: "transparent"
				height: parent.height-20
				width: childrenRect.width
				x: (top.width-width)/2
				y: 10

				// The three symbols
				Row {

					spacing: 100

					// Touch shortcut
					Image {
						opacity: info_touch.opacity == 1 ? 1 : opacityDisabledCategory
						width: 90
						height: 90
						y: 5
						source: "qrc:/img/settings/shortcuts/categorytouch.png"
					}
					// Mouse shortcut
					Image {
						opacity: info_mouse.opacity == 1 ? 1 : opacityDisabledCategory
						width: 90
						height: 90
						y: 5
						source: "qrc:/img/settings/shortcuts/categorymouse.png"
					}
					// Keyboard shortcut
					Image {
						opacity: info_key.opacity == 1 ? 1 : opacityDisabledCategory
						width: 90
						height: 90
						y: 5
						source: "qrc:/img/settings/shortcuts/categorykeyboard.png"
					}
				}
			}

		}

		// Seperator
		Rectangle {
			width: top.width
			height: 1
			color: "white"
		}

		// The main area displaying the current selection
		Rectangle {

			id: info
			color: "transparent"
			height: top.height-icons.height-bottom.height-20
			width: top.width

			// Display the mouse action: modifier, button, path
			Rectangle {

				id: info_mouse

				opacity: 0

				anchors.fill: parent
				color: "transparent"

				Rectangle {

					color: "transparent"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					y: (parent.height-height)/2

					Grid {

						columns: 2
						spacing: 20

						Text {
							text: "Modifier:"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							id: info_mouse_modifier
							text: "Ctrl"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							text: "Mouse Button:"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							id: info_mouse_button
							text: "Right Button"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							text: "Gesture path:"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							id: info_mouse_path
							text: "S-E"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}

					}

				}

			}

			// Display the touch info: fingers, action, path
			Rectangle {

				id: info_touch

				opacity: 0

				anchors.fill: parent
				color: "transparent"

				Rectangle {

					color: "transparent"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					y: (parent.height-height)/2

					Grid {

						columns: 2
						spacing: 20

						Text {
							text: "Number of Fingers:"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							id: info_touch_fingers
							text: "2"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							text: "Action:"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							id: info_touch_action
							text: "Tap"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							text: "Gesture path:"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}
						Text {
							id: info_touch_path
							text: "S-E"
							color: "white"
							font.pointSize: 25
							font.bold: true
						}

					}

				}

			}

			// Display the touch info: key combo
			Rectangle {

				id: info_key

				opacity: 0

				anchors.fill: parent
				color: "transparent"

				Rectangle {

					color: "transparent"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					y: (parent.height-height)/2

					Text {
						id: info_key_combo
						text: "Ctrl+O"
						color: "white"
						font.pointSize: 25
						font.bold: true
					}

				}

			}

			// At start, a simple "..." is displayed
			Rectangle {

				id: info_empty

				opacity: 1

				anchors.fill: parent
				color: "transparent"

				Rectangle {

					color: "transparent"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2
					y: (parent.height-height)/2

					Text {
						text: "..."
						color: "white"
						font.pointSize: 25
						font.bold: true
					}

				}

			}

		}

		// Seperator
		Rectangle {
			width: top.width
			height: 1
			color: "white"
		}

		// Bottom row with cancel button, instructions, and timeout counter
		Rectangle {
			id: bottom
			color: "#99000000"
			height: 100
			width: top.width

			// Cancel detection
			CustomButton {
				id: cancelbutton
				text: "Cancel"
				x: 30
				y: (parent.height-height)/2
				fontsize: 15
				onClickedButton: {
					countdowntimer.stop()
					countdownlabel.text = "0"
					successful = false
					checkResult()
				}
			}

			// Seperator
			Rectangle {
				color: "#44ffffff"
				width: 1
				height: parent.height
				x: cancelbutton.x+cancelbutton.width+30
				y: 0
			}

			// Instructions
			Rectangle {
				id: instructions
				color: "transparent"
				x: cancelbutton.width+60
				y: 0
				height: parent.height
				width: parent.width-countdown.width-cancelbutton.width-60
				Text {
					anchors.fill: parent
					text: "Perform any touch gesture, mouse action or press any key combination."
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					color: "white"
					font.pointSize: 15
					wrapMode: Text.WordWrap
				}
			}

			// Seperator
			Rectangle {
				color: "#44ffffff"
				width: 1
				height: parent.height
				x: instructions.x+instructions.width
				y: 0
			}

			// Timeout counter
			Rectangle {

				id: countdown
				width: parent.height*2
				height: parent.height
				x: parent.width-width
				color: "transparent"

				Text {
					id: countdownlabel
					anchors.fill: parent
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					color: "white"
					text: "5"
					font.bold: true
					font.pointSize: 20
				}
				Timer {
					id: countdowntimer
					interval: 1000
					running: false
					repeat: true
					onTriggered: {
						countdownlabel.text = countdownlabel.text*1-1
						checkResult()
					}
				}

				function reset() {
					countdownlabel.text = "5"
					countdowntimer.restart()
				}
			}
		}

	}

	function checkResult() {
		if(countdownlabel.text == "0") {
			hide()
			if(successful) {
				if(category == "touch")
					success("touch", [touch_fingers,touch_action,touch_path])
				else if(category == "mouse")
					success("mouse",[mouse_mods,mouse_button,mouse_path])
				else if(category == "key")
					success("key",[key_combo])
				else
					cancel()
			} else
				cancel()

		}
	}

	// Show element
	function show() {
		opacity = 1
		resetInterface()
	}
	// Hide element
	function hide() {
		opacity = 0
		countdowntimer.stop()
	}

	// Reset interface and show empty message
	function resetInterface() {
		switchTo("empty")
		successful = false
		countdown.reset()
	}

	// Switch to a different category
	function switchTo(cat) {
		// Unfinished gesture (if finished, this boolean will be set to true later in the finished*() function
		successful = false
		category = cat
		info_touch.opacity = (cat === "touch" ? 1 : 0)
		info_mouse.opacity = (cat === "mouse" ? 1 : 0)
		info_key.opacity = (cat === "key" ? 1 : 0)
		info_empty.opacity = (cat === "empty" ? 1 : 0)
	}

	// Update to mouse gesture
	function updateMouseGesture(button, gesture, modifiers) {
		if(bottom.x+cancelbutton.x <= localcursorpos.x && bottom.y+cancelbutton.y <= localcursorpos.y
			&& bottom.x+cancelbutton.x+cancelbutton.width >= localcursorpos.x
				&& bottom.y+cancelbutton.y+cancelbutton.height >= localcursorpos.y)
			return
		if(opacity != 1) return
		switchTo("mouse")
		info_mouse_button.text = button
		info_mouse_modifier.text = (modifiers == "" ? "-" : modifiers)
		info_mouse_path.text = (gesture.length == 0 ? "-" : gesture.join(" - "))

		successful = false

		mouse_mods = modifiers
		mouse_button = button
		mouse_path = gesture

		countdown.reset()

	}

	// Completed mouse gesture
	function finishedMouseGesture(button, gesture, modifiers) {
		if(bottom.x+cancelbutton.x <= localcursorpos.x && bottom.y+cancelbutton.y <= localcursorpos.y
			&& bottom.x+cancelbutton.x+cancelbutton.width >= localcursorpos.x
				&& bottom.y+cancelbutton.y+cancelbutton.height >= localcursorpos.y)
			return
		if(opacity != 1) return
		switchTo("mouse")
		info_mouse_button.text = button
		info_mouse_modifier.text = (modifiers == "" ? "-" : modifiers)
		info_mouse_path.text = (gesture.length == 0 ? "-" : gesture.join(" - "))

		mouse_mods = modifiers
		mouse_button = button
		mouse_path = gesture

		successful = true
		countdownlabel.text = "1"

	}

	// Update to touch gesture
	function updateTouchGesture(fingers, type, path) {
		if(opacity != 1) return
		switchTo("touch")
		info_touch_fingers.text = fingers
		info_touch_action.text = (type === "pinchIN" ? "pinch inwards" : (type === "pinchOUT" ? "pinch outwards" : type))
		info_touch_path.text = (path.length == 0 ? "-" : path.join(" - "))

		successful = false

		touch_fingers = fingers
		touch_action = type
		touch_path = path

		countdown.reset()

	}

	// Completed touch gesture
	function finishedTouchGesture(fingers, type, path) {
		if(opacity != 1) return
		switchTo("touch")
		info_touch_fingers.text = fingers
		info_touch_action.text = (type === "pinchIN" ? "pinch inwards" : (type === "pinchOUT" ? "pinch outwards" : type))
		info_touch_path.text = (path.length == 0 ? "-" : path.join(" - "))

		touch_fingers = fingers
		touch_action = type
		touch_path = path

		successful = true

		countdownlabel.text = "1"

	}

	// Update to key shortcut
	function updateKeyShortcut(combo) {
		if(opacity != 1) return
		switchTo("key")
		info_key_combo.text = combo

		key_combo = combo

		if(combo !== "" && combo.slice(-1) !== "+") {
			successful = true
			countdownlabel.text = "1"
		} else {
			successful = false
			countdown.reset()
		}

	}


	function setTakenShortcuts(key_shortcuts, mouse_shortcuts, _touch_shortcuts) {

		checkAllShortcuts = {}

		for(var i in key_shortcuts)
			checkAllShortcuts[i] = 1
		for(var j in mouse_shortcuts)
			checkAllShortcuts[j] = 1
		for(var k in _touch_shortcuts)
			checkAllShortcuts[k] = 1

	}

	function updateTakenShortcut(old_shortcut, new_shortcut) {

		console.log(old_shortcut, checkAllShortcuts[old_shortcut])

		checkAllShortcuts[old_shortcut] -= 1;

		if(new_shortcut !== "") {

			if(new_shortcut in checkAllShortcuts)
				checkAllShortcuts[new_shortcut] += 1;
			else
				checkAllShortcuts[new_shortcut] = 1;

		}

		takenShortcutsUpdated()

	}

	function checkForShortcutErrors() {

		var err = false

		for(var ele in checkAllShortcuts) {
			if(checkAllShortcuts[ele] > 1
					|| (checkAllShortcuts[ele] !== 0 && leftButtonMouseClickAndMove && ele.slice(0,12) === "Left Button+")
					|| (checkAllShortcuts[ele] !== 0 && singleFingerTouchPressAndMove && ele.slice(0,8) === "1::swipe")) {
				err = true
				break;
			}
		}

		return err

	}

	function checkIfShortcutTaken(sh) {

		if(sh === undefined || sh === "")
			return false

		if(leftButtonMouseClickAndMove) {
			if(sh.slice(0,12) === "Left Button+")
				return true
		}
		if(singleFingerTouchPressAndMove) {
			if(sh.slice(0,8) === "1::swipe")
				return true
		}

		return checkAllShortcuts[sh]*1 !== 1
	}

}
