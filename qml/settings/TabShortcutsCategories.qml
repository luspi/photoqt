import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Rectangle {

	id: top

	property string category: "category"
	property var responsiblefor: []
	property var responsiblefor_text: []

	color: "#00000000"
	height: 250
	width: parent.width

	Text {
		id: cat
		text: "Category: " + category
		anchors.horizontalCenter: parent.horizontalCenter
		color: "white"
		font.bold: true
	}

	Rectangle {

		id: cont

		color: "#00000000"
		radius: 10

		anchors {
			top: cat.bottom
			topMargin: 5
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		Row {

			spacing: 5

			Rectangle { color: "#00000000"; width: 1; height: 1; }

			Rectangle {

				radius: 10

				id: set

				width: (cont.width-3*5-2)/2
				height: cont.height

				color: "#44ffffff"

				clip: true

				GridView {
					width: parent.width-5
					x: 2.5
					height: parent.height-5
					y: 2.5
					cellWidth: 105
					cellHeight: 105

					boundsBehavior: Flickable.StopAtBounds

					model: ListModel { id: modSet }
					delegate: TabShortcutsTilesSet { _close: close; _keys: keys; _mouse: mouse; _cmd: cmd; _desc: desc }
				}


			}

			Rectangle {

				radius: 10

				id: avail

				width: (cont.width-3*5-2)/2
				height: cont.height

				color: "#44ffffff"

				GridView {
					width: parent.width-5
					x: 2.5
					height: parent.height-5
					y: 2.5
					cellWidth: 105
					cellHeight: 105

					boundsBehavior: Flickable.StopAtBounds

					model: ListModel { id: modAvail }
					delegate: TabShortcutsTilesAvail { _desc: desc; _cmd: cmd }
				}

			}

			Rectangle { color: "#00000000"; width: 1; height: 1; }

		}

	}

	function setData(shortcuts) {

		modSet.clear()
		modAvail.clear()

		for(var i = 0; i < shortcuts.length/3; ++i) {
			var index = responsiblefor.indexOf(shortcuts[i*3+2])
			if(index != -1) {

				var m = false
				var k = shortcuts[i*3+1]
				if(k.substr(0,3) == "[M]") {
					k = k.substr(3,k.length)
					m = true
				}

				modSet.append({ "close" : shortcuts[i*3],
						     "keys" : k,
						     "mouse" : m,
						     "cmd" : shortcuts[i*3+2],
						     "desc" : responsiblefor_text[index]})
			}
		}

		for(var i = 0; i < responsiblefor.length; ++i) {

			modAvail.append({ "desc" : responsiblefor_text[i], "cmd" : responsiblefor[i] })

		}

	}

	function addShortcut(cmd, key) {
		modSet.append({ "close" : "0", "keys" : key, "mouse" : false, "cmd" : cmd, "desc" : responsiblefor_text[responsiblefor.indexOf(cmd)] })
	}

}
