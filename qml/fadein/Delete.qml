import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

FadeInTemplate {

    id: delete_top

    heading: ""
    showSeperators: false

    marginTopBottom: (background.height-500)/2
    clipContent: false

    content: [

        // Heading
        Text {
            text: qsTr("Delete File")
            color: colour.text
            font.bold: true
            font.pointSize: 18*2
            x: (delete_top.contentWidth-width)/2
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
            x: (delete_top.contentWidth-width)/2
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        Text {
            text: qsTr("Do you really want to delete this file?")
            x: (delete_top.contentWidth-width)/2
            font.pointSize: 10*2
            color: colour.text
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // Two main buttons
        Rectangle {

            color: "#00000000"

            x: (delete_top.contentWidth-width)/2
            width: childrenRect.width
            height: childrenRect.height

            Row {

                spacing: 5

                // This button triggers "Move to Trash" under Linux, and permanent "Delete" under Windows
                CustomButton {
                    id: movetotrash
                    text: getanddostuff.amIOnLinux() ? qsTr("Move to Trash") : qsTr("Delete")
                    fontsize: 18
                    onClickedButton: {
                        verboseMessage("Delete","move to trash")
                        hideDelete()
                        getanddostuff.deleteImage(thumbnailBar.currentFile,getanddostuff.amIOnLinux())
                        reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion(), currentfilter)
                    }
                }

                CustomButton {
                    text: qsTr("Cancel")
                    fontsize: 18
                    onClickedButton: {
                        verboseMessage("Delete","do not delete")
                        hideDelete()
                    }
                }

            }
        },

        // Permanent "Delete" (needed on Linux only)
        CustomButton {
            text: qsTr("Delete permanently")
            fontsize: 13
            visible: getanddostuff.amIOnLinux()
            x: (delete_top.contentWidth-width)/2
            onClickedButton: {
                verboseMessage("Delete","delete permanently")
                hideDelete()
                getanddostuff.deleteImage(thumbnailBar.currentFile,false)
                reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion(), currentfilter)
            }
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // A little explanatory text informing the user about the shortcuts
        Text {
            text: getanddostuff.amIOnLinux() ? qsTr("Enter = Move to Trash, Shift+Enter = Delete permanently, Escape = Cancel") : qsTr("Enter = Delete, Escape = Cancel")
            color: colour.text
            font.pointSize: 10*0.8
            x: (delete_top.contentWidth-width)/2
        }
    ]

    // These two 'simulate' functions can be called via shortcuts
    function simulateEnter() {
        verboseMessage("Delete::simulateEnter()","")
        hideDelete()
        getanddostuff.deleteImage(thumbnailBar.currentFile,getanddostuff.amIOnLinux())
        reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion(), currentfilter)
    }
    function simulateShiftEnter() {
        verboseMessage("Delete::simulateShiftEnter()","")
        hideDelete()
        getanddostuff.deleteImage(thumbnailBar.currentFile,false)
        reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion(), currentfilter)
    }

    function showDelete() {
        if(thumbnailBar.currentFile == "") return
        filename.text = getanddostuff.removePathFromFilename(thumbnailBar.currentFile)
        show()
    }

    function doDirectPermanentDelete() {
        simulateShiftEnter()
    }

    function hideDelete() {
        hide()
    }

}
