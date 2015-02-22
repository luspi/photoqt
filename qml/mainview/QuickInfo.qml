import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick 2.3

Item {

    id: item

    x:5
    y:5

    property bool somethingLoaded: false

    // Set data
	function updateQuickInfo(pos, totalNumberImages, filepath) {

        somethingLoaded = true

        if(settings.hidecounter) {
            counter.text = ""
            counter.visible = false
            spacing.visible = false
            spacing.width = 0
        } else {
            counter.text = (pos+1).toString() + "/" + totalNumberImages.toString()
            counter.visible = true
        }

        if(settings.hidefilename) {
            filename.text = ""
            filename.visible = false
            spacing.width = 0
            spacing.visible = false
        } else if(settings.hidefilepathshowfilename) {
            filename.text = getstuff.removePathFromFilename(filepath)
            filename.visible = true
        } else {
            filename.text = filepath
            filename.visible = true
        }

        spacing.visible = (counter.visible && filename.visible)

        if(!counter.visible && !filename.visible)
            opacity = 0
        else
            opacity = 1

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
                    if (mouse.button == Qt.RightButton && somethingLoaded) {
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
                    onTriggered: {
                        counter.text = ""
                        counter.visible = false
                        spacing.visible = false
                        spacing.width = 0
                        settings.hidecounter = true;
                        if(filename.visible == false) item.opacity = 0
                    }
                }

            }

        }

        // SPACING - it does nothing but seperate counter from filename
        Text {
            id: spacing

            visible: !settings.hidecounter && !settings.hidefilepathshowfilename && !settings.hidefilename

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
                    if (mouse.button == Qt.RightButton && somethingLoaded) {
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
                    onTriggered: {
                        filename.text = getstuff.removePathFromFilename(filename.text)
                        settings.hidefilepathshowfilename = true;
                    }
                }

                MenuItem {
                    text: "<font color=\"white\">Hide both, Filename and Filepath</font>"
                    onTriggered: {
                        filename.text = ""
                        spacing.visible = false
                        spacing.width = 0
                        settings.hidefilename = true;
                        if(counter.visible == false) item.opacity = 0
                    }
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
