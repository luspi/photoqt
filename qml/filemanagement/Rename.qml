import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"
import "../loadfile.js" as Load

Item {

    id: rename_top

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: Math.min(container.height, childrenRect.height)

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
                enabled: management_top.opacity==1&&management_top.current=="rn"
                text: ""
                fontsize: 13
                width: rename_top.width/2
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
                // Button for renaming the current file based on the entered text
                text: qsTr("Save")
                fontsize: 18
                enabled: newfilename.getText() !== ""
                onClickedButton: {
                    verboseMessage("Rename","Save")
                    if(newfilename.getText() !== "")
                        simulateEnter()
                }
            }
            CustomButton {
                text: qsTr("Cancel")
                fontsize: 18
                onClickedButton: {
                    verboseMessage("Rename","Cancel")
                    management_top.hide()
                }
            }
        }
    }

    Connections {
        target: container
        onItemShown:
            setupRename()
    }

    Connections {
        target: call
        onShortcut: {
            if(management_top.visible && current == "rn") {
                if(sh == "Enter" || sh == "Return")
                    simulateEnter()
            }
        }
    }

    // This 'simulate' function can be called via shortcut
    function simulateEnter() {
        verboseMessage("Rename::simulateEnter()","")
        if(newfilename.getText() !== "") {
            // a rename is the same as a move into the same directory
            getanddostuff.moveImage(variables.currentDir + "/" + variables.currentFile, variables.currentDir + "/" + newfilename.getText() + suffix.text)
            Load.loadFile(variables.currentDir + "/" + newfilename.getText() + suffix.text, variables.filter, true)
            management_top.hide()
        }
    }

    function setupRename() {
        filename.text = variables.currentFile
        newfilename.text = ""	// This is needed, otherwise the lineedit might keep its old contents
                                // (if opened twice for same image with different keys pressed in between)
        newfilename.text = getanddostuff.getImageBaseName(variables.currentFile)
        suffix.text = "." + getanddostuff.getSuffix(variables.currentFile)
        newfilename.selectAll()
    }

}
