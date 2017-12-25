import QtQuick 2.6
import QtQuick.Layouts 1.3

import "../elements"

Item {

    id: delete_top

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: Math.min(container.height, childrenRect.height)

    // Heading
    Text {
        id: headertext
        x: (parent.width-width)/2
        text: qsTr("Delete File")
        color: colour.text
        font.bold: true
        font.pointSize: 18*2
        anchors.top: delete_top.top
        anchors.topMargin: 10
    }

    // The filename is dynamically updated when element is shown
    Text {
        id: filename
        x: (parent.width-width)/2
        text: "/path/to/some/image/file.jpg"
        color: colour.text_inactive
        font.pointSize: 10*2
        anchors.top: headertext.bottom
        anchors.topMargin: 25
    }

    Text {
        id: question
        x: (parent.width-width)/2
        text: qsTr("Do you really want to delete this file?")
        font.pointSize: 10*2
        color: colour.text
        anchors.top: filename.bottom
        anchors.topMargin: 25
    }

    // Two main buttons
    Rectangle {

        id: mainbuttons

        x: (parent.width-width)/2

        anchors.top: question.bottom
        anchors.topMargin: 25

        color: "#00000000"

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
                    simulateEnter()
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
    }

    // Permanent "Delete" (needed on Linux only)
    CustomButton {

        id: permanentdelete

        x: (parent.width-width)/2

        anchors.top: mainbuttons.bottom
        anchors.topMargin: 25

        text: qsTr("Delete permanently")
        fontsize: 13
        visible: getanddostuff.amIOnLinux()
        onClickedButton: {
            verboseMessage("Delete","delete permanently")
            simulateShiftEnter()
        }
    }

    // A little explanatory text informing the user about the shortcuts
    Text {

        x: (parent.width-width)/2

        anchors.top: permanentdelete.bottom
        anchors.topMargin: 25

        text: getanddostuff.amIOnLinux() ? qsTr("Enter = Move to Trash, Shift+Enter = Delete permanently, Escape = Cancel") : qsTr("Enter = Delete, Escape = Cancel")
        color: colour.text
        font.pointSize: 10*0.8
    }


    // These two 'simulate' functions can be called via shortcuts
    function simulateEnter() {
        verboseMessage("Delete::simulateEnter()","")
        hideDelete()
        getanddostuff.deleteImage(variables.currentFile,getanddostuff.amIOnLinux())
        reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion(), currentfilter)
    }
    function simulateShiftEnter() {
        verboseMessage("Delete::simulateShiftEnter()","")
        hideDelete()
        getanddostuff.deleteImage(variables.currentFile,false)
        reloadDirectory(thumbnailBar.getNewFilenameAfterDeletion(), variables.filter)
    }

    function showDelete() {
        if(variables.currentFile == "") return
        filename.text = getanddostuff.removePathFromFilename(variables.currentFile)
        show()
    }

    function doDirectPermanentDelete() {
        simulateShiftEnter()
    }

    function hideDelete() {
        call.hide("filemanagement")
    }

    Connections {
        target: management_top
        onPermanentDeleteFile:
            doDirectPermanentDelete()
    }

    Connections {
        target: call
        onFilemanagementDeleteImage: simulateEnter()
    }

}
