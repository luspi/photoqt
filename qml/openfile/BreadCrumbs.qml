import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {

	anchors.left: parent.left
	anchors.top: parent.top
	anchors.right: parent.right
	height: 50

	color: "#44000000"

	ListView {

		id: crumbsview

		spacing: 0

		x: 10
		width: parent.width-20
		height: parent.height

		orientation: ListView.Horizontal
		interactive: false

		model: ListModel { id: crumbsmodel; }

		property var menuitems: []

		delegate: Button {
			y: 7
			height: parent.height-15
			property bool hovered: false

			style: ButtonStyle {
				background: Rectangle {
					id: bg
					anchors.fill: parent
					color: hovered ? "#44ffffff" : "#00000000"
					radius: 5
				}

				label: Text {
					id: txt
					horizontalAlignment: Text.AlignHCenter
					color: "white"
					font.bold: true
					font.pointSize: 15
					text: type=="folder" ? " " + location : " /"
				}

			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: type=="folder" ? Qt.PointingHandCursor : Qt.ArrowCursor
				onClicked: {
					if(type == "folder")
						loadCurrentDirectory(partialpath)
					else {
//							m.clear()
//							var folders = getanddostuff.getFoldersIn(partialpath)
//							m.dir = partialpath
//							for(var i = 0; i < folders.length; ++i) {
//								m.addItem(folders[i])
//							}
//							m.popup()
					}
				}
				onEntered:
					if(type=="folder")
						parent.hovered = true
				onExited:
					if(type=="folder")
						parent.hovered = false
			}

		}

	}

	//	Menu {
	//		id: m
	//		property string dir: ""
	//		style: MenuStyle {
	//			// an item text
	//			itemDelegate.label: Text {
	//				verticalAlignment: Text.AlignVCenter
	//				horizontalAlignment: Text.AlignHCenter
	//				font.pointSize: 12
	//				color: "white"
	//				text: styleData.text.split("/")[styleData.text.split("/").length-1]
	//			}

	//			// selection of an item
	//			itemDelegate.background: Rectangle {
	//				color: styleData.selected ? "grey" : "#222222"
	//				border.width: 1
	//				border.color: "#222222"
	//			}
	//		}
	//	}


	function loadDirectory(path) {


		var parts = path.split("/")
		var partialpath = ""

		crumbsmodel.clear()

		if(path === "/")
			crumbsmodel.append({"type" : "separator", "location" : "/", "partialpath" : "/"})
		else {
			for(var i = 0; i < parts.length; ++i) {
				if(parts[i] === "") continue;
				if(parts[i] === "..") {
					var l = crumbsmodel.count
					crumbsmodel.remove(l-1)
					crumbsmodel.remove(l-2)
					partialpath += "/" + parts[i]
				} else {
					partialpath += "/"
					crumbsmodel.append({"type" : "separator", "location" : parts[i], "partialpath" : partialpath})
					partialpath += parts[i]
					crumbsmodel.append({"type" : "folder", "location" : parts[i], "partialpath" : partialpath})
				}
			}
		}

		if(crumbsmodel.count == 0)
			crumbsmodel.append({"type" : "separator", "location" : "/", "partialpath" : "/"})

		crumbsview.positionViewAtEnd()

	}

}
