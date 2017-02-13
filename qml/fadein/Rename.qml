import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

FadeInTemplate {

    id: rename_top

    heading: ""
    showSeperators: false

    marginTopBottom: (background.height-400)/2
    clipContent: false

    content: [

        // Heading
        Text {
            text: qsTr("Rename File")
            color: colour.text
            font.bold: true
            font.pointSize: 18*2
            x: (rename_top.contentWidth-width)/2
        },

        // This one (and the following ones) are simply space adders...
        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // The filename is dynamically updated when element is shown
        Text {
            id: filename
            text: ""
            color: colour.text_disabled
            font.pointSize: 10*2
            x: (rename_top.contentWidth-width)/2
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // The new filename (the suffix cannot be changed here)
        Rectangle {
            color: "#00000000"
            width: childrenRect.width
            height:childrenRect.height
            x: (rename_top.contentWidth-width)/2
            Row {
                spacing: 5
                CustomLineEdit {
                    id: newfilename
                    text: ""
                    fontsize: 13
                    width: rename_top.contentWidth/2
                }
                Text {
                    id: suffix
                    color: colour.text
                    text: ".JPG"
                    font.pointSize: 13
                }
            }
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // The two buttons for save/cancel
        Rectangle {
            color: "#00000000"
            width: childrenRect.width
            height:childrenRect.height
            x: (rename_top.contentWidth-width)/2
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

    ]

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
        hide()
    }

}
