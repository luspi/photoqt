import QtQuick 2.4
import QtQuick.Controls 1.3

import "../elements"

Item {

    id: rename_top

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: Math.min(container.height, childrenRect.height)

    Connections {
        target: container
        onItemShown: {
            filename.text = variables.currentFile
            newfilename.text = getanddostuff.removePathFromFilename(variables.currentFile, true)
            newfilename.forceActiveFocus()
            newfilename.selectAll()
        }
    }

    // Heading
    Text {
        id: headingtext
        text: qsTr("Rename File")
        color: colour.text
        font.bold: true
        font.pointSize: 18*2
        x: (parent.width-width)/2
        anchors.top: rename_top.top
        anchors.topMargin: 25
    }

    // The filename is dynamically updated when element is shown
    Text {
        id: filename
        text: "/path/to/some/image/file.jpg"
        color: colour.text_inactive
        font.pointSize: 10*2
        x: (parent.width-width)/2
        anchors.top: headingtext.bottom
        anchors.topMargin: 25
    }

    // The new filename (the suffix cannot be changed here)
    Rectangle {
        id: newfilenamecontainer
        color: "#00000000"
        width: childrenRect.width
        height:childrenRect.height
        x: (parent.width-width)/2
        anchors.top: filename.bottom
        anchors.topMargin: 25
        Row {
            spacing: 5
            CustomLineEdit {
                id: newfilename
                enabled: management_top.opacity==1
                text: ""
                fontsize: 13
                width: rename_top.width/2
                onAccepted: shortcuts.processString("Enter")
                onRejected: shortcuts.processString("Escape")
            }
            Text {
                id: suffix
                color: colour.text
                text: ".JPG"
                font.pointSize: 13
            }
        }
    }

    // The two buttons for save/cancel
    Rectangle {
        color: "#00000000"
        width: childrenRect.width
        height:childrenRect.height
        x: (parent.width-width)/2
        anchors.top: newfilenamecontainer.bottom
        anchors.topMargin: 25
        Row {
            spacing: 5
            CustomButton {
                text: qsTr("Save")
                fontsize: 18
                enabled: newfilename.getText() !== ""
                onClickedButton: {
                    verboseMessage("Rename","Save")
                    if(newfilename.getText() !== "") {
                        getanddostuff.renameImage(thumbnailBar.currentFile,newfilename.getText() + suffix.text)
                        reloadDirectory(getanddostuff.removeFilenameFromPath(thumbnailBar.currentFile) + "/" + newfilename.getText() + suffix.text)
                        hideRename()
                    }
                }
            }
            CustomButton {
                text: qsTr("Cancel")
                fontsize: 18
                onClickedButton: {
                    verboseMessage("Rename","Cancel")
                    hideRename()
                }
            }
        }
    }

    // This 'simulate' function can be called via shortcut
    function simulateEnter() {
        verboseMessage("Rename::simulateEnter()","")
        if(newfilename.getText() !== "") {
            getanddostuff.renameImage(thumbnailBar.currentFile,newfilename.getText() + suffix.text)
            reloadDirectory(getanddostuff.removeFilenameFromPath(thumbnailBar.currentFile) + "/" + newfilename.getText() + suffix.text,currentfilter)
            hideRename()
        }
    }

    function showRename() {
        verboseMessage("Rename::showRename()","")
        if(thumbnailBar.currentFile === "") return
        filename.text = getanddostuff.removePathFromFilename(thumbnailBar.currentFile)
        newfilename.text = ""	// This is needed, otherwise the lineedit might keep its old contents
                                // (if opened twice for same image with different keys pressed in between)
        newfilename.text = getanddostuff.removePathFromFilename(thumbnailBar.currentFile, true)
        suffix.text = "." + getanddostuff.getSuffix(thumbnailBar.currentFile)
        newfilename.forceActiveFocus()
        newfilename.selectAll()
        show()
    }
    function hideRename() {
        management_top.hide()
    }

}
