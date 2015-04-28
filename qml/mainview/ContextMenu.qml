import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: top

	color: colour_fadein_bg

	width: container.width+16
	height: container.height+16
	radius: 10
	visible: false
	opacity: 0

	property bool contextMenuSetup: false

	Rectangle {

		id: container
		x: 8
		y: 8
		width: col.width
		height: col.height
		color: "#00000000"

		Column {

			id: col
			spacing: 10

			Rectangle {

				color: "#00000000"
				width: row1.width
				height: row1.height

				/********/
				// MOVE //
				/********/

				Row {

					id: row1
					spacing: 15

					Text {
						color: "#bbbbbb"
						text: "Move:"
					}
					ContextMenuEntry {
						textEnabled: false
						icon: "qrc:/img/contextmenu/first.png"
						onClicked: thumbnailBar.gotoFirstImage()
					}
					ContextMenuEntry {
						text: "Previous"
						iconEnabled: false
						onClicked: thumbnailBar.previousImage()
					}
					ContextMenuEntry {
						text: "Next"
						iconEnabled: false
						onClicked: thumbnailBar.nextImage()
					}
					ContextMenuEntry {
						textEnabled: false
						icon: "qrc:/img/contextmenu/last.png"
						onClicked: thumbnailBar.gotoLastImage()
					}
				}
			}

			/**********/
			// ROTATE //
			/**********/

			Rectangle {

				color: "#00000000"

				width: row2.width
				height: row2.height

				Row {

					id: row2
					spacing: 15

					Text {
						color: "#bbbbbb"
						text: "Rotate:"
					}
					ContextMenuEntry {
						text: "Left"
						icon: "qrc:/img/contextmenu/rotateLeft.png"
						onClicked: image.rotateLeft()
					}

					ContextMenuEntry {
						text: "Right"
						icon: "qrc:/img/contextmenu/rotateRight.png"
						iconPositionLeft: false
						onClicked: image.rotateRight()
					}

				}

			}

			/********/
			// FLIP //
			/********/

			Rectangle {

				color: "#00000000"

				width: row3.width
				height: row3.height

				Row {

					id: row3
					spacing: 15

					Text {
						color: "#bbbbbb"
						text: "Flip:"
					}
					ContextMenuEntry {
						text: "Horizontal"
						icon: "qrc:/img/contextmenu/flipH.png"
						onClicked: image.flipHorizontal()
					}

					ContextMenuEntry {
						text: "Vertical"
						icon: "qrc:/img/contextmenu/flipV.png"
						onClicked: image.flipVertical()
					}

				}

			}

			/********/
			// ZOOM //
			/********/

			Rectangle {

				color: "#00000000"

				width: row4.width
				height: row4.height

				Row {

					id: row4
					spacing: 15

					Text {
						color: "#bbbbbb"
						text: "Zoom:"
					}
					ContextMenuEntry {
						text: "(+) In"
						iconEnabled: false
						onClicked: image.zoomIn(true)
					}
					ContextMenuEntry {
						text: "(-) Out"
						iconEnabled: false
						onClicked: image.zoomOut(true)
					}
					ContextMenuEntry {
						text: "(1:1) Actual"
						iconEnabled: false
//						onClicked: image.zoom
					}
					ContextMenuEntry {
						text: "(0) Reset"
						iconEnabled: false
						onClicked: image.resetZoom()
					}

				}

			}

			/************************/
			// MORE GENERAL OPTIONS //
			/************************/

			Rectangle {
				color: "#00000000"
				width: 1
				height: 1
			}

			ContextMenuEntry {
				icon: "qrc:/img/contextmenu/scale.png"
				text: "Scale Image"
				onClicked: {
					hide()
					softblocked = 0
				}
			}

			ContextMenuEntry {
				icon: "qrc:/img/contextmenu/open.png"
				text: "Open in default File Manager"
				onClicked: {
					hide()
					softblocked = 0
				}
			}

			ContextMenuEntry {
				icon: "qrc:/img/contextmenu/delete.png"
				text: "Delete File"
				onClicked: {
					hide()
					softblocked = 0
				}
			}

			ContextMenuEntry {
				id: rename
				icon: "qrc:/img/contextmenu/rename.png"
				text: "Rename File"
				onClicked: {
					hide()
					softblocked = 0
				}
			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: -4
			}

			/*********************/
			// EXTERNAL PROGRAMS //
			/*********************/

			Rectangle {
				color: "#00000000"
				width: contextview.width
				height: contextview.height
				ListView {
					id: contextview
					orientation: Qt.Vertical
					spacing: 5
					width: container.width
					height: contextmodel.count*(rename.height+5)
					model: ListModel { id: contextmodel; }
					delegate: ContextMenuEntry {
						iconEnabled: true
						icon: getanddostuff.getIconPathFromTheme(icn)
						text: txt
						onClicked: {
							executeExternal(bin)
							softblocked = 0
							hide()
						}
					}
				}
			}


		}

	}


	function popup(p) {

		// Set-up the contextmenu on first open every session
		if(!contextMenuSetup) {

			contextmodel.clear()

			// These are the possible entries
			var m = ["Edit with Gimp","gimp %f","gimp",
					 "Edit with Krita","krita %f","calligrakrita",
					 "Edit with KolourPaint","kolourpaint %f","kolourpaint",
					 "Open in GwenView","gwenview %f","gwenview",
					 "Open in showFoto","showfoto %f","showfoto",
					 "Open in Shotwell","shotwell %f","shotwell",
					 "Open in GThumb","gthumb %f","gthumb",
					 "Open in Eye of Gnome","eog %f","eog"]

			// Check for all entries
			for(var i = 0; i < m.length/3; ++i) {
				if(getanddostuff.checkIfBinaryExists(m[3*i+1]))
					contextmodel.append({"txt" : m[3*i], "bin" : m[3*i+1], "icn" : m[3*i+2] })
			}

			contextMenuSetup = true

		}

		if(p.x+width > background.width) x = background.width-width
		else x = p.x

		if(p.y+height > background.height) y = background.height-height
		else y = p.y

		showAni.start()
		softblocked = 1

	}

	function hide() {
		hideAni.start()
	}

	function executeExternal(bin) {
		getanddostuff.executeApp(bin,thumbnailBar.currentFile)
	}

	PropertyAnimation {
		id: hideAni
		target: top
		duration: 100
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
		}
	}

	PropertyAnimation {
		id: showAni
		target:  top
		duration: 100
		property: "opacity"
		to: 1
		onStarted: {
			visible = true
		}
	}

}
