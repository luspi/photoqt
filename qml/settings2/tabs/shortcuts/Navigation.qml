import QtQuick 2.3

Rectangle {

	color: "transparent"

	x: 5
	width: parent.width-10
	height: 200

	// these are picked up by the sub-widgets and processed there
	property string currentKeyCombo: ""
	property bool keysReleased: false
	// We don't reset this one right away, as this otherwise wouldn't trigger the children listeners
	onKeysReleasedChanged: resetKeysReleased.running = true

	// These are the ones that this element is responsible for
	property var allAvailableItems: [["__open",qsTr("Open New File")],
									["__filterImages",qsTr("Filter Images in Folder")],
									["__next",qsTr("Next Image")],
									["__prev",qsTr("Previous Image")],
									["__gotoFirstThb",qsTr("Go to first Image")],
									["__gotoLastThb",qsTr("Go to last Image")],
									["__hide",qsTr("Hide to System Tray")],
									["__close",qsTr("Quit PhotoQt")]]

	// Reset after a tiny timeout -> necessary, otherwise change isn't passed on to children
	Timer {
		id: resetKeysReleased
		interval: 10
		repeat: false
		running: false
		onTriggered: parent.keysReleased = false
	}

	// A title above the two lists
	Text {
		id: heading
		x: (parent.width-width)/2
		color: colour.text
		font.bold: true
		text: "Navigation"
	}

	// the two lists
	Row {

		id: rowabove

		y: heading.height+4
		spacing: 10

		// This is picked up by the children
		property int w: parent.width

		// The set shortcuts
		Set { id: set }

		// The available shortcuts
		Available {

			id: avail

			// This is set to the list by the setData() function
			shortcuts: []

			// Adding a new shortcut
			onAddShortcut: {

				var desc = ""
				for(var k = 0; k < allAvailableItems.length; ++k)
					if(allAvailableItems[k][0] === shortcut)
						desc = allAvailableItems[k][1]

				set.lastaction = "add"
				set.shortcuts = set.shortcuts.concat([[desc, "", shortcut, keyormouse]])

			}

		}

	}

	// Set the data
	function setData() {

		// Filter out the keys
		var keys = []
		for(var k = 0; k < allAvailableItems.length; ++k)
			keys[keys.length] = allAvailableItems[k][0]

		// Get all set shortcuts
		var shortcuts = getanddostuff.getShortcuts()

		// The ones important for this element
		var setshortcuts = []

		// Loop over all shortcuts and filter out the ones we're interested in
		for(var ele in shortcuts) {

			var ind = keys.indexOf(shortcuts[ele][1])
			if(ind !== -1)
				setshortcuts = setshortcuts.concat([[allAvailableItems[ind][1],ele,shortcuts[ele], (ele.slice(0,3)==="[M]" ? "mouse" : "key")]])

		}

		// Update arrays
		set.shortcuts = setshortcuts
		avail.shortcuts = allAvailableItems

	}

}
