import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: top

	color: colour.fadein_slidein_bg

	width: container.width+16
	height: container.height+16
	radius: global_element_radius
	visible: false
	opacity: 0

	property int contextMenuSetup_modTime: 0

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
						color: colour.contextmenu_infotext
						//: as in: "Move file..."
						text: qsTr("Move:")
						font.pointSize: 10
					}
					ContextMenuEntry {
						textEnabled: false
						icon: "qrc:/img/contextmenu/first.png"
						onClicked: thumbnailBar.gotoFirstImage()
					}
					ContextMenuEntry {
						//: Go to previous file
						text: qsTr("Previous")
						iconEnabled: false
						onClicked: thumbnailBar.previousImage()
					}
					ContextMenuEntry {
						//: Go to next file
						text: qsTr("Next")
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
						color: colour.contextmenu_infotext
						//: As in: Rotate file
						text: qsTr("Rotate:")
						font.pointSize: 10
					}
					ContextMenuEntry {
						//: As in: rotate LEFT
						text: qsTr("Left")
						icon: "qrc:/img/contextmenu/rotateLeft.png"
						onClicked: mainview.rotateLeft()
					}

					ContextMenuEntry {
						//: As in: Rotate RIGHT
						text: qsTr("Right")
						icon: "qrc:/img/contextmenu/rotateRight.png"
						iconPositionLeft: false
						onClicked: mainview.rotateRight()
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
						color: colour.contextmenu_infotext
						//: As in: Flip file
						text: qsTr("Flip:")
						font.pointSize: 10
					}
					ContextMenuEntry {
						//: As in: Flip file HORIZONTALLY
						text: qsTr("Horizontal")
						icon: "qrc:/img/contextmenu/flipH.png"
						onClicked: mainview.mirrorHorizontal()
					}

					ContextMenuEntry {
						//: As in: Flip file VERTICALLY
						text: qsTr("Vertical")
						icon: "qrc:/img/contextmenu/flipV.png"
						onClicked: mainview.mirrorVertical()
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
						color: colour.contextmenu_infotext
						//: Zoom file
						text: qsTr("Zoom:")
						font.pointSize: 10
					}
					ContextMenuEntry {
						//: As in: Zoom IN
						text: "(+) " + qsTr("In")
						iconEnabled: false
						onClicked: mainview.zoomIn(true)
					}
					ContextMenuEntry {
						// As in: Zoom OUT
						text: "(-) " + qsTr("Out")
						iconEnabled: false
						onClicked: mainview.zoomOut()
					}
					ContextMenuEntry {
						//: As in: Zoom to ACTUAL size
						text: "(1:1) " + qsTr("Actual")
						iconEnabled: false
						onClicked: mainview.zoomActual()
					}
					ContextMenuEntry {
						//: As in: Reset zoom
						text: "(0) " + qsTr("Reset")
						iconEnabled: false
						onClicked: mainview.resetZoom()
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
				text: qsTr("Scale Image")
				onClicked: {
					hide()
					scaleImage.showScale()
					softblocked = 0
				}
			}

			ContextMenuEntry {
				icon: "qrc:/img/contextmenu/open.png"
				text: qsTr("Open in default File Manager")
				onClicked: {
					hide()
					softblocked = 0
					if(thumbnailBar.currentFile !== "")
						getanddostuff.openInDefaultFileManager(thumbnailBar.currentFile)
				}
			}

			Rectangle {

				color: "#00000000"
				width: childrenRect.width
				height: childrenRect.height

				Row {

					spacing: 40

					Rectangle {

						color: "#00000000"
						width: childrenRect.width
						height: childrenRect.height

						Column {

							spacing: 10

							ContextMenuEntry {
								id: entry_rename
								icon: "qrc:/img/contextmenu/rename.png"
								text: qsTr("Rename File")
								onClicked: {
									hide()
									rename.showRename()
									softblocked = 0
								}
							}

							ContextMenuEntry {
								icon: "qrc:/img/contextmenu/delete.png"
								text: qsTr("Delete File")
								onClicked: {
									hide()
									deleteImage.showDelete()
									softblocked = 0
								}
							}

						}

					}

					Rectangle {

						color: "#00000000"
						width: childrenRect.width
						height: childrenRect.height

						Column {

							spacing: 10

							ContextMenuEntry {
								id: entry_copy
								icon: "qrc:/img/contextmenu/copy.png"
								text: qsTr("Copy File")
								onClicked: {
									hide()
									softblocked = 0
									if(thumbnailBar.currentFile !== "")
										getanddostuff.copyImage(thumbnailBar.currentFile)
								}
							}

							ContextMenuEntry {
								icon: "qrc:/img/contextmenu/move.png"
								text: qsTr("Move File")
								onClicked: {
									hide()
									softblocked = 0
									if(thumbnailBar.currentFile !== "")
										getanddostuff.moveImage(thumbnailBar.currentFile)
								}
							}

						}

					}

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
					height: contextmodel.count*(entry_rename.height+5)
					model: ListModel { id: contextmodel; }
					delegate: ContextMenuEntry {
						iconEnabled: true
						icon: getanddostuff.getIconPathFromTheme(icn)
						text: txt
						onClicked: {
							executeExternal(bin,close)
							softblocked = 0
							hide()
						}
					}
				}
			}


		}

	}


	function popup(p) {

		verboseMessage("ContextMenu::popup()","(" + p.x + ", " + p.y + ")")

		// Set-up the contextmenu on first open every session
		var mod = getanddostuff.getContextMenuFileModifiedTime()
		if(contextMenuSetup_modTime == 0 || mod !== contextMenuSetup_modTime) {

			contextmodel.clear()

			var c = getanddostuff.getContextMenu()

			for(var i = 0; i < c.length/3; ++i) {
				var bin = getanddostuff.trim(c[3*i].replace("%f","").replace("%u","").replace("%d",""))
				// The icon for Krita is called 'calligrakrita'
				if(bin === "krita")
					contextmodel.append({"txt" : c[3*i+2], "bin" : c[3*i], "close" : c[3*i+1], "icn" : "calligrakrita" });
				else
					contextmodel.append({"txt" : c[3*i+2], "bin" : c[3*i], "close" : c[3*i+1], "icn" : bin });
			}

			contextMenuSetup_modTime = mod

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

	function executeExternal(bin,close) {
		verboseMessage("ContextMenu::executeExternal()",close + " - " + bin)
		if(thumbnailBar.currentFile !== "") {
			getanddostuff.executeApp(bin,thumbnailBar.currentFile,close)
			if(close*1 == 1)
				if(settings.trayicon)
					hideToSystemTray()
				else
					quitPhotoQt()
		}
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
