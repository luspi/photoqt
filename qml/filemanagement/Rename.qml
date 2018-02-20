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
import QtQuick.Controls 1.4

import "../elements"
import "../handlestuff.js" as Handle

Item {

    id: rename_top

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: Math.min(container.height, childrenRect.height)

    // Heading
    Text {
        id: headingtext
        text: em.pty+qsTr("Rename File")
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
                enabled: management_top.opacity===1&&management_top.current==="rn"
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
                text: em.pty+qsTr("Save")
                fontsize: 18
                enabled: newfilename.getText() !== ""
                onClickedButton: {
                    verboseMessage("Rename","Save")
                    if(newfilename.getText() !== "")
                        simulateEnter()
                }
            }
            CustomButton {
                text: em.pty+qsTr("Cancel")
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
        verboseMessage("FileManagement/Rename", "simulateEnter()")
        if(newfilename.getText() !== "") {
            // a rename is the same as a move into the same directory
            getanddostuff.moveImage(variables.currentDir + "/" + variables.currentFile, variables.currentDir + "/" + newfilename.getText() + suffix.text)
            Handle.loadFile(variables.currentDir + "/" + newfilename.getText() + suffix.text, variables.filter, true)
            management_top.hide()
        }
    }

    function setupRename() {
        verboseMessage("FileManagement/Rename", "setupRename()")
        filename.text = variables.currentFile
        newfilename.text = ""	// This is needed, otherwise the lineedit might keep its old contents
                                // (if opened twice for same image with different keys pressed in between)
        newfilename.text = getanddostuff.getImageBaseName(variables.currentFile)
        suffix.text = "." + getanddostuff.getSuffix(variables.currentFile)
        newfilename.selectAll()
    }

}
