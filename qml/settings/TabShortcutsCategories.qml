import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Rectangle {

	id: top

	// The category above the box
	property string category: "category"

	// The available shortcuts
	property var responsiblefor: []
	property var responsiblefor_text: []

	// All the deleted id's (needed so that we don't have to change all id's when deleting a tile)
	property var deleted: []

	// External category?
	property bool extern: false

	// Sizing
	height: 250
	width: parent.width

	color: "#00000000"

	// Category label
	Text {
		id: cat
		text: "Category: " + category
		anchors.horizontalCenter: parent.horizontalCenter
		color: "white"
		font.bold: true
	}

	// Main box
	Rectangle {

		id: cont

		color: "#00000000"
		radius: 10

		// Anchor it in place
		anchors {
			top: cat.bottom
			topMargin: 5
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		Row {

			spacing: 5

			// Space on the left
			Rectangle { color: "#00000000"; width: 1; height: 1; }

			// The 'set' shortcuts
			Rectangle {

				id: set

				width: (cont.width-3*5-2)/2
				height: cont.height

				radius: 10

				color: "#44ffffff"
				clip: true

				// The view for all the tiles
				GridView {

					x: 2.5
					y: 2.5
					width: parent.width-5
					height: parent.height-5

					cellWidth: 105
					cellHeight: 105

					boundsBehavior: Flickable.StopAtBounds

					model: ListModel { id: modSet }
					delegate: TabShortcutsTilesSet {
						_close: close;
						_keys: keys;
						_mouse: mouse;
						_extern: external;
						_cmd: cmd;
						_desc: desc;
						_id: id;
						onDeleteTile: deleteOneTile(id)
					}
				}


			}

			// the box for the available shortcuts
			Rectangle {

				id: avail

				radius: 10

				width: (cont.width-3*5-2)/2
				height: cont.height

				color: "#44ffffff"

				// The view for all the tiles
				GridView {

					x: 2.5
					y: 2.5
					width: parent.width-5
					height: parent.height-5

					cellWidth: 105
					cellHeight: 105

					boundsBehavior: Flickable.StopAtBounds

					model: ListModel { id: modAvail }
					delegate: TabShortcutsTilesAvail { _desc: desc; _cmd: cmd }
				}

			}

			// Space on the right
			Rectangle { color: "#00000000"; width: 1; height: 1; }

		}

	}

	// Set all the set shortcuts
	function setData(shortcuts) {

		// Clear old ones
		modSet.clear()
		modAvail.clear()

		var counter = 0;

		// Set all shortcuts
		for(var obj in shortcuts) {

			if(responsiblefor.indexOf(shortcuts[obj][1]) != -1) {

				var m = false
				var k = obj
				if(k.substr(0,3) == "[M]") {
					k = k.substr(3,k.length)
					m = true
				}

				modSet.append({ "close" : shortcuts[obj][0],
						     "keys" : k,
						     "mouse" : m,
						     "external": false,
						     "cmd" : shortcuts[obj][1],
						     "desc" : responsiblefor_text[responsiblefor.indexOf(shortcuts[obj][1])],
						     "id" : counter })
				++counter

			} else if(extern && shortcuts[obj][1].slice(0,2) !== "__") {

				var m = false
				var k = obj
				if(k.substr(0,3) == "[M]") {
					k = k.substr(3,k.length)
					m = true
				}

				modSet.append({ "close" : shortcuts[obj][0],
						     "keys" : k,
						     "mouse" : m,
						     "external": true,
						     "cmd" : shortcuts[obj][1],
						     "desc" : shortcuts[obj][1],
						     "id" : counter })
				++counter

			}
		}

		// And set all available shortcuts (needed for startup)
		for(var i = 0; i < responsiblefor.length; ++i) {

			modAvail.append({ "desc" : responsiblefor_text[i], "cmd" : responsiblefor[i] })

		}

	}

	// Add a new shortcut
	function addShortcut(cmd, key) {
		var counter = modSet.count
		modSet.append({ "close" : "0", "keys" : key, "mouse" : false, "cmd" : cmd, "desc" : responsiblefor_text[responsiblefor.indexOf(cmd)], "id" : counter })
	}

	// Update an existing shortcut
	function updateShortcut(cmd, key, id) {
		var takeaway = 0
		for(var i = 0; i < deleted.length; ++i) {
			if(deleted[i] < id)
				takeaway += 1
		}
		modSet.set(id-takeaway, { "close" : "0", "keys" : key, "mouse" : false, "cmd" : cmd, "desc" : responsiblefor_text[responsiblefor.indexOf(cmd)] })
	}

	// Add a new mouse shortcut
	function addMouseShortcut(cmd, key) {
		var counter = modSet.count
		modSet.append({ "close" : "0", "keys" : key, "mouse" : true, "cmd" : cmd, "desc" : responsiblefor_text[responsiblefor.indexOf(cmd)], "id" : counter })
	}

	// Update an existing mouse shortcut
	function updateMouseShortcut(cmd, key, id) {
		var takeaway = 0
		for(var i = 0; i < deleted.length; ++i) {
			if(deleted[i] < id)
				takeaway += 1
		}
		modSet.set(id-takeaway, { "close" : "0", "keys" : key, "mouse" : true, "cmd" : cmd, "desc" : responsiblefor_text[responsiblefor.indexOf(cmd)] })
	}

	// Delete a tile
	function deleteOneTile(id) {
		var takeaway = 0
		for(var i = 0; i < deleted.length; ++i) {
			if(deleted[i] < id)
				takeaway += 1
		}
		modSet.remove(id-takeaway)
		deleted.push(id)	// Need this info so that we don't need to adjust all id's of all other tiles
	}

	// Update the command (external category)
	function updateCommand(id, mouse, key, cmd) {
		var takeaway = 0
		for(var i = 0; i < deleted.length; ++i) {
			if(deleted[i] < id)
				takeaway += 1
		}
		modSet.set(id-takeaway, { "close" : "0", "keys" : key, "mouse" : mouse, "cmd" : cmd, "desc" : cmd })
	}

	function addExternalShortcut(key) {
		var counter = modSet.count
		modSet.append({ "close" : "0", "keys" : key, "mouse" : false, "cmd" : "", "desc" : "", "id" : counter, "external" : true })
		setExternalCommand.command = ""
		setExternalCommand.id = counter
		setExternalCommand.keys = key
		setExternalCommand.isMouse = false
		setExternalCommand.show()
	}

	function addExternalMouseShortcut(key) {
		var counter = modSet.count
		modSet.append({ "close" : "0", "keys" : key, "mouse" : true, "cmd" : "", "desc" : "", "id" : counter, "external" : true })
		setExternalCommand.command = ""
		setExternalCommand.id = counter
		setExternalCommand.keys = key
		setExternalCommand.isMouse = true
		setExternalCommand.show()
	}

}
