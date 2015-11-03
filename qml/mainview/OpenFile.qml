import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls.Styles 1.2

Rectangle {

	id: top

	visible: false
	opacity: 0

	color: "#44000000"

	anchors.fill: parent

	property var files: []
	property var folders: []
	property string items_path: ""
	property string dir_path: "/home/luspi/Bilder"

	property var hovered: []

	property string cur_pre: "one"

	Rectangle {

		color: "#00000000"

		anchors.fill: parent
		anchors.margins: 5

	}

	Rectangle {
		id: breadcrumbs
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
				id: but
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


	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: breadcrumbs.bottom
		height: 1
		color: "grey"
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
			color: "#44000000"
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
						onClicked: {
							loadCurrentDirectory(location)
						}
					}
				}
			}
		}

		Rectangle {

			id: folderlist

			Layout.minimumWidth: 200
			width: 400
			color: "#44000000"
			clip: true

			ListView {

				id: folderlistview
				anchors.fill: parent

				model: ListModel { id: folderlistmodel; }

				delegate: Rectangle {
					width: folderlist.width
					height: folder_txt.height+10
					color: index%2==0 ? "#88000000" : "#44000000"

					Image {
						id: folder_img
						source: "image://icon/folder"
						width: folder_txt.height-4
						y: 7
						x: 7
						height: width
					}

					Text {
						y: 5
						x: 5 + folder_img.width+5
						id: folder_txt
						width: folderlist.width-(x+5)
						text: "<b>" + folder + "</b>" + ((counter==0||folder=="..") ? "" : " <i>(" + counter + ")</i>")
						color: "white"
						font.pointSize: 12
						elide: Text.ElideRight
					}

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onEntered: {
							parent.color = "#22ffffff"
						}
						onExited: {
							parent.color = (index%2==0 ? "#88000000" : "#44000000")
						}
						onClicked: {
							loadCurrentDirectory(dir_path + "/" + folder)
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

				color: "#AA000000"

				anchors.fill: parent

				Image {
					id: preview
					anchors.fill: parent
					anchors.margins: 10

					fillMode: Image.PreserveAspectFit
					asynchronous: true

					opacity: 0
					Behavior on opacity { SmoothedAnimation { id: preview_load; velocity: 0.1; } }

					source: ""
					sourceSize: Qt.size(width,height)
					onSourceChanged: {
						var s = getanddostuff.getImageSize(source)
						if(s.width < width && s.height < height)
							fillMode = Image.Pad
						else
							fillMode = Image.PreserveAspectFit
					}

					onStatusChanged: {
						if(status == Image.Ready) {
								preview.opacity = 1
						} else {
							preview_load.duration = 0
							preview.opacity = 0
							preview_load.duration = 400
						}
					}
				}

				Rectangle {
					anchors.fill: parent
					color: "#99000000"
				}
			}






			Rectangle {
				anchors.fill: parent
				color: "#00000000"
			}
			GridView {
				id: grid
				anchors.fill: parent
				cellWidth: 80;
				cellHeight: cellWidth*(4/3);

				property int prev_highlight: -1

				model: gridmodel

				delegate: gridDelegate
				highlight: Rectangle { color: "#22ffffff"; radius: 5 }
				focus: true

				onCurrentIndexChanged: {
					preview.source = Qt.resolvedUrl("file://" + dir_path + "/" + files[currentIndex])
				}

			}
			Text {
				id: nothingfound
				visible: false
				anchors.fill: parent
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
				font.pointSize: 30
				wrapMode: Text.WordWrap
				color: "grey"
				text: "No images found in this folder"
			}

			Component {
				id: gridDelegate

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
						Image {
							id: icon
							height: image_rect.height*0.75
							width: image_rect.width
							sourceSize: Qt.size(width,height)
							source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[index])
							fillMode: Image.PreserveAspectFit
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
							Behavior on opacity { SmoothedAnimation { id: opacityani; velocity: 0.1; } }
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
							reloadDirectory(dir_path + "/" + files[index],"")
							hideOpenAni.start()
						}
					}
				}
			}

			ListModel { id: gridmodel; }

		}
	}

	PropertyAnimation {
		id: hideOpenAni
		target: top
		property: "opacity"
		to: 0
		duration: 400
		onStopped: {
			visible = false
			blocked = false
		}
	}

	PropertyAnimation {
		id: showOpenAni
		target: top
		property: "opacity"
		to: 1
		duration: 400
		onStarted: {
			visible = true
			blocked = true
		}
	}

	function show() { showOpenAni.start(); }
	function hide() { hideOpenAni.start(); }

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
		folderlistmodel.clear()
		files = getanddostuff.getFilesIn(path)
		folders = getanddostuff.getFoldersIn(path)
		dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)
		grid.contentY = 0
		for(var j = 0; j < files.length; ++j) {
			gridmodel.append({"filename" : files[j]})
		}
		if(files.length == 0)
			nothingfound.visible = true
		else
			nothingfound.visible = false

		for(var j = 0; j < folders.length; ++j) {
			folderlistmodel.append({"folder" : folders[j], "counter" : getanddostuff.getNumberFilesInFolder(dir_path + "/" + folders[j])})
		}

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

		crumbsview.positionViewAtEnd()

	}

}
