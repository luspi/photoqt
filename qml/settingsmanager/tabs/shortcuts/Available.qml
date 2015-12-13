import QtQuick 2.3
import "../../../elements"

Rectangle {

	id: top

	// The height depends on how many elements there are
	height: Math.max(childrenRect.height,5)
	Behavior on height { NumberAnimation { duration: 150; } }

	// The available shortcuts
	property var shortcuts: []

	color: "transparent"
	clip: true

	// A new shortcut is to be added
	signal addShortcut(var shortcut, var keyormouse)

	GridView {

		id: grid

		x: 3
		y: 3
		width: parent.width-6
		height: childrenRect.height

		cellWidth: parent.width
		cellHeight: 30

		model: shortcuts.length

		delegate: Rectangle {

			x: 3
			y: 3
			width: grid.cellWidth-6
			height: grid.cellHeight-6

			color: "transparent"
			radius: 3


			Rectangle {

				id: sh_title

				width: parent.width/2
				height: parent.height

				// Color changes when hovered
				property bool hovered: false
				color: hovered ? colour.tiles_inactive : colour.tiles_disabled
				Behavior on color { ColorAnimation { duration: 150; } }

				radius: 4

				// Which shortcut this is
				Text {

					anchors.fill: parent
					anchors.margins: 2
					anchors.leftMargin: 4
					color: colour.text
					text: shortcuts[index][1]

				}

				// When hovered, change color of this element AND of 'key' button
				// A click adds a new shortcut
				MouseArea {

					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor

					onEntered: {
						sh_title.hovered = true
						keybutton.hovered = true
					}
					onExited: {
						sh_title.hovered = false
						keybutton.hovered = false
					}
					onClicked:
						addShortcut(shortcuts[index][0], "key")

				}

			}

			// The buttons
			Rectangle {

				x: parent.width/2+2
				y: 2
				width: parent.width/2-4
				height: parent.height-4

				color: "transparent"

				Row {

					spacing: 4

					CustomButton {

						id: keybutton

						width: parent.parent.width/2-2
						height: parent.parent.height

						text: "Key"

						onHoveredChanged:
							sh_title.hovered = hovered
						onClickedButton:
							addShortcut(shortcuts[index][0], "key")

					}
					CustomButton {

						width: parent.parent.width/2-2
						height: parent.parent.height

						text: "Mouse"

						onClickedButton:
							addShortcut(shortcuts[index][0], "mouse")

					}

				}

			}

		}

	}

}
