import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

GridView {

	id: gridview

	anchors.fill: parent

	property var visibleItems: []
	contentItem.onVisibleChildrenChanged: {
		visibleItems = []
		for(var i = 0; i < contentItem.visibleChildren.length; ++i)
			if(contentItem.visibleChildren[i].getSource)
				visibleItems.push(contentItem.visibleChildren[i].getSource())
	}

	cellWidth: tweaks.zoomlevel*5;
	cellHeight: cellWidth*(4/3);
	highlight: Rectangle { color: "#22ffffff"; radius: 5 }
	focus: true

	opacity: settings.openDefaultView==="icons" ? 1: 0
	Behavior on opacity { SmoothedAnimation { velocity: 10; } }
	onOpacityChanged: {
		if(opacity == 0)
			visible = false
	}

	property int prev_highlight: -1

	model: ListModel { id: gridviewmodel; }
	delegate: gridviewDelegate

	onCurrentIndexChanged: {

		if(opacity == 1)
			listview.currentIndex = currentIndex
		else
			return

		if(currentIndex == -1 || !type_preview || files[2*currentIndex] === "")
			preview.source = ""
		else {
			if(previous_width != top.width || tweaks.getMode() !== previous_mode)
				updatePreviewSourceSize()
			preview.source = Qt.resolvedUrl("image://full/" + dir_path + "/" + files[2*currentIndex])
		}

	}

	Component {

		id: gridviewDelegate

		Rectangle {

			id: ele

			color: "#00000000"
			width: gridview.cellWidth;
			height: gridview.cellHeight

			Column {

				id: image_rect

				x: 10
				y: 10
				width: parent.width-20
				height: parent.height-20

				Item {
					x: (parent.width-width)/2
					width: image_rect.width
					height: image_rect.height*0.6

					Image {
						id: icon_tmp
						opacity: icon.thumbnailLoaded&&tweaks.getThumbnailEnabled() ? 0 : 0.6
						anchors.fill: parent
						asynchronous: true
						source: "image://icon/image-" + getanddostuff.getSuffix(dir_path + "/" + files[2*index])
						fillMode: Image.PreserveAspectFit
					}

					Image {
						id: icon
						property bool hovered: false
						anchors.fill: parent
						opacity: hovered ? 1 : 0.8
						Behavior on opacity { NumberAnimation { duration: 100 } }
						scale: hovered ? 1 : 0.95
						Behavior on scale { NumberAnimation { duration: 100 } }
						asynchronous: true
						cache: false
						source: files[2*index]===undefined||gridview.opacity==0 || (!tweaks.getThumbnailEnabled()) || gridview.opacity == 0
								? ""
								: "image://thumb/" + dir_path + "/" + files[2*index]
						mipmap: true
						fillMode: Image.PreserveAspectFit
						property bool thumbnailLoaded: false
						onStatusChanged: {
							if(status == Image.Ready && source != "") {
								thumbnailLoaded = true
							}
						}
					}

				}

				Rectangle {

					id: textrect

					x: 5
					y: image_rect.height*0.6
					width: image_rect.width-10
					height: image_rect.height*0.4

					radius: 5
					color: "#BB000000"
					opacity: icon.hovered ? 0.8 : 0.4
					Behavior on opacity { NumberAnimation { id: opacityani; duration: 100; } }

					Text {
						x: 3
						width: parent.width-6
						height: parent.height
						text: filename
						elide: Text.ElideRight
						wrapMode: Text.WrapAnywhere
						maximumLineCount: 2
						lineHeight: 0.8
						font.pixelSize: tweaks.zoomlevel*0.75
						clip: true
						font.bold: true
						color: "white"
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}
			}

			MouseArea {
				x: 10
				y: 10
				width: parent.width-20
				height: parent.height-20
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onEntered: {
					icon.hovered = true
					gridview.currentIndex = index
				}
				onExited:
					icon.hovered = false
				onClicked: {
					hideOpenAni.start()
					reloadDirectory(dir_path + "/" + files[2*index],"")
				}
			}

			function getSource() {
				return files[2*index]
			}
		}
	}

	function loadFiles(files) {
		gridviewmodel.clear()
		contentY = 0
		for(var j = 0; j < files.length; j+=2)
			gridviewmodel.append({"filename" : files[j], "filesize" : files[j+1]})

	}

	function focusOnFile(filename) {

		var pattern = new RegExp(escapeRegExp(filename) + ".*","i")
		if(pattern.test(files[2*currentIndex])) return
		var index = -1
		for(var i = 0; i < files.length; i+=2) {
			if(pattern.test(files[i])) {
				index = i/2
				break;
			}
		}
		if(index != -1)
			currentIndex = index

	}

	function displayIcons() {
		opacity = 0
		visible = true
		opacity = 1
	}

	function displayList() {
		opacity = 1
		opacity = 0
	}

}
