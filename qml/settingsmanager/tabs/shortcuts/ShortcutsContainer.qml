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

	// these are picked up by the sub-widgets and processed there
	property string currentMouseCombo: ""
	property bool mouseCancelled: false
	// We don't reset this one right away, as this otherwise wouldn't trigger the children listeners
	onMouseCancelledChanged: resetMouseCancelled.running = true

	// These are the ones that this element is responsible for
	property var allAvailableItems: []
	property string category: ""

	// This array is filled in the setData() function containing all commands of allAvailableItems
	property var allAvailableCommands: []

	// An external shortcut shows a TextEdit instead of a title to edit a custom command
	property bool external: false

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
		Set {

			id: set

			// The width is adjusted according to the width of the parent widget (above row)
			width: parent.w/2-5

		}

		// The available shortcuts
		Available {

			id: avail

			// The width is adjusted according to the width of the parent widget (above row)
			width: parent.w/2-5

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

			}

		}

	}

	Component.onCompleted: {

		// Filter out the keys for setData/saveData
		allAvailableCommands = []
		for(var k = 0; k < allAvailableItems.length; ++k)
			allAvailableCommands[allAvailableCommands.length] = allAvailableItems[k][0]

		// load the available shortcuts
		avail.shortcuts = allAvailableItems

	}

	// Set the data
	function setData(shortcuts) {

		// We use a temporary array because we'll sort the shortcuts according to their command first
		var tmp = {}
		var tmp_keys = []

		// Loop over all shortcuts and filter out the ones we're interested in
		for(var ele in shortcuts) {

			var ind = allAvailableCommands.indexOf(shortcuts[ele][1])

			if(ind !== -1) {

				var keyormouse = "key"
				var key = ele;
				if(ele.slice(0,3) === "[M]") {
					keyormouse = "mouse"
					key = ele.slice(4,ele.length)
				}

				var cmd = shortcuts[ele][1]
				// Format: [desc, key, close, command, key/mouse]
				if(!(cmd in tmp)) {
					tmp[cmd] = []
					tmp_keys = tmp_keys.concat(cmd)
				}
				tmp[cmd].push([allAvailableItems[ind][1],key,shortcuts[ele][0], cmd, keyormouse])
			}

		}

		tmp_keys.sort()

		// The ones important for this element
		var setshortcuts = []

		for(var k in tmp_keys) {
			var cur_key = tmp_keys[k];
			for(var l = 0; l <tmp[cur_key].length; ++l)
				setshortcuts = setshortcuts.concat([tmp[cur_key][l]])
		}

		// Update arrays
		set.shortcuts = setshortcuts

	}

	function saveData() {

		var ret = []

		for(var i = 0; i < set.shortcuts.length; ++i)
			// Format of data: [close, mouse, keys, command]
			ret = ret.concat([[set.shortcuts[i][2], (set.shortcuts[i][4] === "key" ? false : true), set.shortcuts[i][1], set.shortcuts[i][3]]])

		return ret;

	}

}
