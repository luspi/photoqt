import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick 2.3

Item {

    // Set data
	function updateQuickInfo(pos, totalNumberImages, filepath) {
		counter.text = (pos+1).toString() + "/" + totalNumberImages.toString()
		filename.text = filepath
	}

    // Rectangle holding all the items
    Rectangle {

        id: counterRect

        x: 0
        y: 0

        // it is always as big as the item it contains
        width: childrenRect.width+6
        height: childrenRect.height+6

        // Some styling
        color: "#55000000"
        radius: 5

        // COUNTER
        Text {

            id: counter

            x:3
            y:3

            text: " Open a file to begin..."

            color: "white"
            font.bold: true

            // Show context menu on right click
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        contextmenuCounter.popup()
                    }
                }
            }

            // The context menu
            Menu {
                id: contextmenuCounter
                style: MenuStyle {
                    frame: menuFrame
                    itemDelegate.background: menuHighlight
                }

                MenuItem {
                    text: "<font color=\"white\">Hide Counter</font>"
        //			onTriggered: ...
                }

            }

        }

        // SPACING - it does nothing but seperate counter from filename
        Text {
            id: spacing

            y: 3
            width: 10
            anchors.left: counter.right

            text: ""

        }

        // FILENAME
        Text {

            id: filename

            y: 3
            anchors.left: spacing.right

            text: ""
            color: "white"
            font.bold: true

            // Show context menu
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        contextmenuFilename.popup()
                    }
                }
            }

            // The actual context menu
            Menu {
                id: contextmenuFilename
                style: MenuStyle {
                    frame: menuFrame
                    itemDelegate.background: menuHighlight
                }

                MenuItem {
                    text: "<font color=\"white\">Hide Filepath, leave Filename</font>"
        //			onTriggered: ...
                }

                MenuItem {
                    text: "<font color=\"white\">Hide everything</font>"
        //			onTriggered: ...
                }

            }

        }

    }

    // Some menu styling
	Component {
		id: menuFrame
		Rectangle {
			color: "#0F0F0F"
		}
	}
	Component {
		id: menuHighlight
		Rectangle {
			color: (styleData.selected ? "#4f4f4f" :"#0F0F0F")
		}
	}

}
