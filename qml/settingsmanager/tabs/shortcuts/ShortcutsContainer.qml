import QtQuick 2.3

Rectangle {

	color: "transparent"

	x: 5
	width: parent.width-10
	height: childrenRect.height

	// these are picked up by the sub-widgets and processed there
	property string currentKeyCombo: ""
	property bool keysReleased: false
	// We don't reset this one right away, as this otherwise wouldn't trigger the children listeners
	onKeysReleasedChanged: resetKeysReleased.running = true

	property string currentMouseCombo: ""
	property bool mouseCancelled: false
	onMouseCancelledChanged: resetMouseCancelled.running = true

	// These are the ones that this element is responsible for
	property var allAvailableItems: []
	property string category: ""

	// Reset after a tiny timeout -> necessary, otherwise change isn't passed on to children
	Timer {
		id: resetKeysReleased
		interval: 10
		repeat: false
		running: false
		onTriggered: parent.keysReleased = false
	}
	// Reset after a tiny timeout -> necessary, otherwise change isn't passed on to children
	Timer {
		id: resetMouseCancelled
		interval: 10
		repeat: false
		running: false
		onTriggered: parent.mouseCancelled = false
	}

	// A title above the two lists
	Text {
		id: heading
		x: (parent.width-width)/2
		color: colour.text
		font.bold: true
		text: category
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
				set.shortcuts = set.shortcuts.concat([[desc, "", 0, shortcut, keyormouse]])

				if(keyormouse === "mouse")
					detectMouseShortcut.show()

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
			if(ind !== -1) {

				var keyormouse = "key"
				var key = ele;
				if(ele.slice(0,3) === "[M]") {
					keyormouse = "mouse"
					key = ele.slice(3,ele.length)
				}

				// Format: [desc, key, close, command, key/mouse]
				setshortcuts = setshortcuts.concat([[allAvailableItems[ind][1],key,shortcuts[ele][0], shortcuts[ele][1], keyormouse]])
			}

		}

		// Update arrays
		set.shortcuts = setshortcuts
		avail.shortcuts = allAvailableItems

	}

	function saveData() {

		// Filter out the keys
		var keys = []
		for(var k = 0; k < allAvailableItems.length; ++k)
			keys[keys.length] = allAvailableItems[k][0]


		var ret = []

		for(var i = 0; i < set.shortcuts.length; ++i) {
			// Format of data: [close, mouse, keys, command]
			ret = ret.concat([[set.shortcuts[i][2], (set.shortcuts[i][4] === "key" ? false : true), set.shortcuts[i][1], set.shortcuts[i][3]]])
		}

		return ret;

	}

}
