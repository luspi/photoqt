import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1

Rectangle {

	id: top

	color: "#55000000"

	anchors.fill: parent

	property var items: []
	property string items_path: ""
	property string dir_path: "/home/luspi/Bilder"

	property var hovered: []

	Rectangle {
		id: breadcrumbs
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.right: parent.right
		height: 50
		color: "yellow"
	}

	SplitView {

		id: splitview

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.top: breadcrumbs.bottom
		orientation: Qt.Horizontal

		Rectangle {
			width: 200
			Layout.maximumWidth: 600
			Layout.minimumWidth: 200
			color: "#00000000"
			ListView {
				id: userplaces
				width: parent.width
				height: parent.height

				model: ListModel {
					id: userplacesmodel
				}

				delegate: userplacesdelegate
			}
			Component {
				id: userplacesdelegate
				Rectangle {
					width: userplaces.width
					height: userplacestext.height+14 + (type=="heading" ? 20 : 0)
					color: counter%2==1 ? "#88000000" : "#44000000"

					Image {
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
						width: parent.width-10
						font.capitalization: (type == "heading" ? Font.AllUppercase : Font.MixedCase)
						text: title
						color: type=="heading" ? "grey" : "white"
						font.pointSize: 10
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
					}
				}
			}
		}


		Rectangle {
			id: centerItem
			Layout.minimumWidth: 200
			Layout.fillWidth: true
			color: "#44000000"

			Rectangle {
				anchors.fill: parent
				color: "#00000000"

				Component {
					id: contactDelegate

					Rectangle {
						color: "#00000000"
						width: grid.cellWidth;
						height: grid.cellHeight

						Column {
							id: image_rect
							width: parent.width-20
							height: parent.height-20
							x: 10
							y: 10
							property int _index: index
//							radius: 5
//							color: "#33000000"
							Image {
//								anchors.fill: parent
								id: icon
								height: image_rect.height*0.75
								width: image_rect.width
								source: getanddostuff.isFolder(dir_path + "/" + items[index]) ? "qrc:/img/openfile/folder3.png" : "qrc:/img/openfile/image3.png"
//								source: getanddostuff.isFolder(dir_path + "/" + items[index]) ? "qrc:/img/openfile/folder2.png" : "file://" + dir_path + "/" + filename
								fillMode: Image.PreserveAspectFit

								Rectangle {

									x: icon.width*0.1833333
									y: icon.height*0.3666667
									width: icon.width*0.6333333
									height: icon.height*0.45

									color: "#00000000"

									Text {
										width: parent.width
										height: parent.height
										visible: getanddostuff.isFolder(dir_path + "/" + items[index])
										property int num_imgs: getanddostuff.getNumberFilesInFolder(dir_path + "/" + items[index])
										color: num_imgs > 0 ? "white" : "grey"
										font.bold: true
										font.pointSize: grid.cellWidth/8
										horizontalAlignment: Text.AlignHCenter
										verticalAlignment: Text.AlignVCenter
										text: num_imgs
									}
								}
							}
							Rectangle {
								id: textrect
								opacity: 0.4
								x: 5
								y: image_rect.height*0.75
								width: image_rect.width-10
								height: image_rect.height*0.25
								radius: 5
								color: "#BB000000"
								Behavior on opacity {SmoothedAnimation { id: opacityani; velocity: 0.1; } }
								Text {
									x: 3
									y: 3
									width: parent.width-6
									height: parent.height-10
									text: filename
									elide: Text.ElideRight
									wrapMode: Text.WrapAnywhere
									clip: true
									font.bold: true
									color: "white"
									horizontalAlignment: Text.AlignHCenter
									verticalAlignment: Text.AlignVCenter
								}
							}
						}
						MouseArea {
							width: parent.width-20
							height: parent.height-20
							x: 10
							y: 10
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onEntered: {
								opacityani.duration = 200
								textrect.opacity = 1
								grid.currentIndex = index
							}
							onExited:
								textrect.opacity = 0.4
							onClicked: {
								if(getanddostuff.isFolder(dir_path + "/" + items[index]))
									loadCurrentDirectory(dir_path + "/" + items[index])
								else
									reloadDirectory(dir_path + "/" + items[index],"")
							}
						}
					}
				}

				GridView {
					id: grid
					anchors.fill: parent
					cellWidth: 150;
					cellHeight: cellWidth*(4/3);

					property int prev_highlight: -1

					model: gridmodel

					delegate: contactDelegate
					highlight: Rectangle { color: "#22ffffff"; radius: 5 }
					focus: true
				}
			}

			ListModel {

				id: gridmodel

			}

		}
	}

	Timer {
		interval: 100
		repeat: false
		running: true
		onTriggered: {
			loadUserPlaces()
			loadCurrentDirectory(dir_path)
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


	function loadCurrentDirectory(path) {
		gridmodel.clear()
		items = getanddostuff.getFilesAndFoldersIn(path)
		dir_path = path
		for(var j = 0; j < items.length; ++j)
			gridmodel.append({"filename" : items[j]})
	}

}
