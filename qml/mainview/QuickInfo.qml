import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "../elements"
import "../loadfile.js" as Load

Item {

    id: item

    x: 5+metadata.nonFloatWidth
    y: 5

    width: childrenRect.width
    height: childrenRect.height

    opacity: 0

    property bool somethingLoaded: false


    // Set data
    function updateQuickInfo() {

        verboseMessage("QuickInfo::updateQuickInfo()",variables.currentFilePos + "/" + variables.totalNumberImagesCurrentFolder + " - " + variables.currentDir + "/" + variables.currentFile)

        somethingLoaded = true

        if(settings.hidecounter || variables.totalNumberImagesCurrentFolder === 0 || variables.deleteNothingLeft || variables.filterNoMatch) {
            counter.text = ""
            counter.visible = false
            spacing.visible = false
        } else {
            counter.text = (variables.currentFilePos+1).toString() + "/" + variables.totalNumberImagesCurrentFolder.toString()
            counter.visible = true
        }

        if(settings.hidefilename || variables.totalNumberImagesCurrentFolder === 0 || variables.deleteNothingLeft || variables.filterNoMatch) {
            filename.text = ""
            filename.visible = false
            spacing.visible = false
        } else if(settings.hidefilepathshowfilename) {
            filename.text = variables.currentFile
            filename.visible = true
        } else {
            filename.text = variables.currentDir + "/" + variables.currentFile
            filename.visible = true
        }

        spacing.visible = (counter.visible && filename.visible && variables.totalNumberImagesCurrentFolder !== 0)
        spacing.width = (spacing.visible ? 10 : 0)

        if(((!counter.visible && !filename.visible) || (variables.slideshowRunning && settings.slideShowHideQuickinfo)) && variables.filter == "") {
            opacity = 0
        } else
            opacity = 1

    }

    // Rectangle holding all the items
    Rectangle {

        id: counterRect

        x: 0
        y: settings.thumbnailposition == "Bottom" ? 0 : background.height-height-6

        // it is always as big as the item it contains
        width: childrenRect.width+6
        height: childrenRect.height+6

        // Some styling
        color: colour.quickinfo_bg
        radius: variables.global_item_radius

        // COUNTER
        Text {

            id: counter

            x:3
            y:3

            text: ""

            color: colour.quickinfo_text
            font.bold: true
            font.pointSize: 10

            // Show context menu on right click
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton && somethingLoaded)
                        contextmenuCounter.popup()
                }
            }

            // The context menu
            ContextMenu {

                id: contextmenuCounter

                MenuItem {
                    //: This is the image counter in the top left corner (part of the quickinfo labels)
                    text: qsTr("Hide Counter")
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
            color: colour.quickinfo_text
            font.bold: true
            font.pointSize: 10

            // Show context menu
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton && somethingLoaded)
                        contextmenuFilename.popup()
                }
            }

            // The actual context menu
            ContextMenu {

                id: contextmenuFilename

                MenuItem {
                    //: This hides part of the quickinfo labels in the top left corner
                    text: qsTr("Hide Filepath, leave Filename")
                    onTriggered: {
                        filename.text = getanddostuff.removePathFromFilename(filename.text)
                        settings.hidefilepathshowfilename = true;
                    }
                }

                MenuItem {
                    text: "<font color=\"" + colour.menu_text + "\">" + qsTr("Hide both, Filename and Filepath") + "</font>"
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

        // Filter label
        Rectangle {
            id: filterLabel
            visible: (variables.filter != "")
            x: ((!filename.visible && !counter.visible) ? 5 : filename.x-filter_delete.width-filterrow.spacing)
            y: ((!filename.visible && !counter.visible) ? (filename.height-height/2)/2 : filename.y+filename.height+2)
            width: childrenRect.width
            height: childrenRect.height
            color: "#00000000"
            Row {
                id: filterrow
                spacing: 5
                Text {
                    id: filter_delete
                    color: colour.quickinfo_text
                    visible: (variables.filter != "")
                    text: "x"
                    font.pointSize: 10
                    y: (parent.height-height)/2
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            variables.filter = ""
                            Load.loadFile(variables.currentDir+"/"+variables.currentFile, "", true)
                        }
                    }
                }
                Text {
                    color: colour.quickinfo_text
                    font.pointSize: 10
                    //: As in: FILTER images
                    text: qsTr("Filter:") + " " + variables.filter
                    visible: (variables.filter != "")
                }
            }
        }

    }

}
