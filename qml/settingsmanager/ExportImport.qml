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
import "../elements"

Rectangle {

    color: colour.fadein_slidein_block_bg

    // Visibility handlers
    visible: (opacity!=0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    // Catch mouse events (background)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: hide()
    }

    // Outer content rectangle
    Rectangle {

        // Geometry
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 600
        height: 500

        // Some styling
        color: colour.fadein_slidein_bg
        border.width: 1
        border.color: colour.fadein_slidein_border
        radius: variables.global_element_radius

        // Click on content does nothing (overrides big MouseArea above)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        // Inner content rectangle
        Rectangle {

            id: contrect

            // same as outer rectangle with margin
            anchors.fill: parent
            anchors.margins: 10
            color: "transparent"

            // Column content
            Column {

                spacing: 20

                // some spacing at the top
                Rectangle {
                    color: "transparent"
                    width: contrect.width
                    height: 5
                }

                // Header
                Text {
                    text: em.pty+qsTr("Export/Import settings and shortcuts")
                    color: "white"
                    font.pointSize: 18
                    width: contrect.width
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                // A short explanation text
                Text {
                    text: em.pty+qsTr("Here you can export all settings and shortcuts into a single packed file and, e.g.,\
 import it in another installation of PhotoQt.")
                    color: "white"
                    width: contrect.width
                    font.pointSize: 12
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // Separator line
                Rectangle {
                    color: "#55ffffff"
                    width: contrect.width
                    height: 1
                }

                // Button to export config to file
                CustomButton {
                    //: Everything refers to all settings and shortcuts
                    text: em.pty+qsTr("Export everything to file")
                    x: (contrect.width-width)/2
                    fontsize: 18
                    onClickedButton: {
                        // execute export, return value is error message
                        var ret = getanddostuff.exportConfig()
                        // if there's an error message, display it
                        if(ret === "-") {
                            // do nothing, QFileDialog cancelled by user
                        } else if(ret !== "") {
                            errormsg.error = ret
                            errormsg.exp = true
                            errormsg.show()
                        // else hide element
                        } else
                            hide()
                    }
                }

                // Separator line
                Rectangle {
                    color: "#55ffffff"
                    width: contrect.width
                    height: 1
                }

                // Selector for a file
                CustomFileSelect {
                    id: importfilename
                    x: (contrect.width-width)/2
                    width: 400
                }

                // Import selected config file
                CustomButton {
                    x: (contrect.width-width)/2
                    text: em.pty+qsTr("Import settings and shortcuts")
                    enabled: importfilename.file!=""
                    fontsize: 18
                    onClickedButton: {
                        // Import files, return value is error message
                        var ret = getanddostuff.importConfig(importfilename.file)
                        // If error message, display error
                        if(ret !== "") {
                            errormsg.exp = false
                            errormsg.error = ret
                            errormsg.show()
                        // else restart PhotoQt
                        } else
                            getanddostuff.restartPhotoQt(variables.currentDir + "/" + variables.currentFile)
                    }
                }

                // Info text below import button
                Text {
                    color: enabled ? colour.text : colour.text_disabled
                    width: parent.width
                    enabled: importfilename.file!=""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: em.pty+qsTr("PhotoQt will attempt to automatically restart after a successful import!")
                }

                // Separator line
                Rectangle {
                    height: 1
                    width: parent.width
                    color: "white"
                }

                // Cancel and close
                CustomButton {
                    x: (parent.width-width)/2
                    fontsize: 15
                    text: em.pty+qsTr("Cancel")
                    onClickedButton: hide()
                }

            }

        }

    }

    // Error message box
    CustomConfirm {
        id: errormsg
        header: em.pty+qsTr("Error")
        property string error: ""
        property bool exp: false
        description: (exp
                      ? em.pty+qsTr("Exporting the configuration file failed with the following error message:")
                      : em.pty+qsTr("Importing the configuration file failed with the following error message:")) + "<br><br>" + error
        rejectbuttontext: em.pty+qsTr("Close")
        actAsErrorMessage: true
    }

    // Show element
    function show() {
        importfilename.clearText()
        opacity = 1
    }

    // Hide element
    function hide() {
        opacity = 0;
    }

}
