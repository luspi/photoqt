/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.5
import QtQuick.Layouts 1.2

import "../elements"
import "../handlestuff.js" as Handle

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
        text: em.pty+qsTr("Delete File")
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
        text: em.pty+qsTr("Do you really want to delete this file?")
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
                text: getanddostuff.amIOnLinux()
                        //: In the sense of 'move the current image into the trash'
                        ? em.pty+qsTr("Move to Trash")
                        //: As in 'Delete the current image'
                        : em.pty+qsTr("Delete")
                fontsize: 18
                onClickedButton: {
                    verboseMessage("Delete","move to trash")
                    simulateEnter()
                }
            }

            CustomButton {
                text: em.pty+qsTr("Cancel")
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

        //: In the sense of 'Delete the current image permanently'
        text: em.pty+qsTr("Delete permanently")
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

        text: getanddostuff.amIOnLinux()
                ? em.pty+qsTr("Enter = Move to Trash, Shift+Enter = Delete permanently, Escape = Cancel")
                : em.pty+qsTr("Enter = Delete, Escape = Cancel")
        color: colour.text
        font.pointSize: 10*0.8
    }

    Connections {
        target: call
        onShortcut: {
            if(management_top.visible && current == "del") {
                if(sh == "Enter" || sh == "Return")
                    simulateEnter()
                else if(sh == "Shift+Enter" || sh == "Shift+Return")
                    simulateShiftEnter()
            }
        }
    }

    Connections {
        target: container
        onItemShown: filename.text = variables.currentFile
    }

    // These two 'simulate' functions can be called via shortcuts
    function simulateEnter() {
        verboseMessage("Filemanagement/Delete", "simulateEnter()")
        hideDelete()
        getanddostuff.deleteImage(variables.currentDir + "/" + variables.currentFile,getanddostuff.amIOnLinux())
        var newfilename = Handle.getNewFilenameAfterDeletion()
        if(newfilename === "")
            variables.deleteNothingLeft = true
        else
            Handle.loadFile(variables.currentDir + "/" + newfilename, variables.filter, true)
    }
    function simulateShiftEnter() {
        verboseMessage("Filemanagement/Delete", "simulateShiftEnter()")
        hideDelete()
        getanddostuff.deleteImage(variables.currentDir + "/" + variables.currentFile,false)
        var newfilename = Handle.getNewFilenameAfterDeletion()
        if(newfilename === "")
            variables.deleteNothingLeft = true
        else
            Handle.loadFile(variables.currentDir + "/" + newfilename, variables.filter, true)
    }

    function hideDelete() {
        management_top.hide()
    }

}
