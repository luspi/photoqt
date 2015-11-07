import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

Rectangle {

	width: 200
	Layout.maximumWidth: 600
	Layout.minimumWidth: 200
	color: "#44000000"

	ListView {
		id: userplaces
		width: parent.width
		height: parent.height

		model: ListModel { id: userplacesmodel; }

		delegate: userplacesdelegate
	}

	Component {

		id: userplacesdelegate

		Rectangle {

			width: userplaces.width
			height: userplacestext.height+14 + (type=="heading" ? 20 : 0)
			color: counter%2==1 ? "#88000000" : "#44000000"

			Image {
				id: userplacesimg
				x: 5
				y: 7
				width: userplacestext.height
				height: width
				source: type=="heading" ? "" : "image://icon/" + icon
				sourceSize: Qt.size(width,height)

			}

			Text {

				id: userplacestext
				x: 5 + (type == "heading" ? 0 : height) + 5
				y: 7 + (type=="heading" ? 15 : 0)
				width: userplaces.width-userplacesimg.width-10
				elide: Text.ElideRight
				font.capitalization: (type == "heading" ? Font.AllUppercase : Font.MixedCase)
				text: title
				color: type=="heading" ? "grey" : "white"
				font.pixelSize: tweaks.zoomlevel-2

			}

			MouseArea {

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: type=="heading" ? Qt.ArrowCursor : Qt.PointingHandCursor
				onEntered: {
					if(type != "heading")
						parent.color = "#22ffffff"
				}
				onExited: {
					if(type != "heading")
						parent.color = (counter%2==1 ? "#88000000" : "#44000000")
				}
				onClicked: {
					loadCurrentDirectory(location)
				}

			}
		}
	}

	function loadUserPlaces() {
		var entries = getanddostuff.getUserPlaces()

		userplacesmodel.append({"type" : "heading",
								   "title" : "Places",
								   "location" : "",
								   "icon" : "",
								   "counter" : 0})

		var reached_devcies = false;
		var counter = 1
		for(var i = 0; i < entries.length; i+=4) {
			if(entries[i] === "device" && reached_devcies == false) {
				userplacesmodel.append({"type" : "heading",
										   "title" : "Devices",
										   "location" : "",
										   "icon" : "",
										   "counter" : 0})
				counter = 1
				reached_devcies = true
			}

			userplacesmodel.append({"type" : entries[i],
									   "title" : entries[i+1],
									   "location" : entries[i+2],
									   "icon" : entries[i+3],
									   "counter" : counter})
			++counter
		}
	}

}
