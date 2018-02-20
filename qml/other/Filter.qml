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

FadeInTemplate {

    id: filter_top

    heading: ""
    showSeperators: false

    marginTopBottom: (background.height-400)/2
    clipContent: false

    content: [

        // Heading
        Text {
            text: em.pty+qsTr("Filter images in current directory")
            color: colour.text
            font.bold: true
            font.pointSize: 30
            x: (filter_top.contentWidth-width)/2
        },

        // This one (and the following ones) are simply space adders...
        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        Text {
            text: em.pty+qsTr("Enter here the term you want to filter the images by. Separate multiple terms by a space.")
            x: (filter_top.contentWidth-width)/2
            color: colour.text
            font.pointSize: 12
        },

        Text {
            text: em.pty+qsTr("If you want to limit a term to file extensions, prepend a dot '.' to the term.")
            x: (filter_top.contentWidth-width)/2
            color: colour.text
            font.pointSize: 12
        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        CustomLineEdit {

            id: term
            width: Math.min(filter_top.contentWidth/2,500)
            height: 35
            x: (filter_top.contentWidth-width)/2

        },

        Rectangle {
            color: "#00000000"
            width: 1
            height: 1
        },

        // Two main buttons
        Rectangle {

            color: "#00000000"

            x: (filter_top.contentWidth-width)/2
            width: childrenRect.width
            height: childrenRect.height

            Row {

                spacing: 5

                Rectangle {
                    color: "#00000000"
                    width: 10+remove.width
                    height: 1
                }

                CustomButton {
                    id: enter
                    //: As in 'Go ahead and filter images'
                    text: em.pty+qsTr("Filter")
                    fontsize: 15
                    onClickedButton:
                        simulateEnter()
                }

                CustomButton {
                    text: em.pty+qsTr("Cancel")
                    fontsize: 15
                    onClickedButton:
                        hide()
                }

                Rectangle {
                    color: "#00000000"
                    width: 10
                    height: 1
                }

                CustomButton {
                    id: remove
                    text: em.pty+qsTr("Remove Filter")
                    fontsize: 13
                    enabled: variables.filter !== ""
                    y: (parent.height-height)/2
                    onClickedButton: {
                        verboseMessage("Other/Filter","Remove filter")
                        variables.filter = ""
                        Handle.loadFile(variables.currentDir+"/"+variables.currentFile, "", true)
                        hide()
                    }
                }

            }
        }
    ]

    Connections {
        target: call
        onFilterShow: {
            if(variables.currentFile === "") return
            showFilter()
        }
        onShortcut: {
            if(!filter_top.visible) return
            if(sh == "Escape")
                hide()
            else if(sh == "Enter" || sh == "Return")
                simulateEnter()
        }
        onCloseAnyElement:
            if(filter_top.visible)
                hide()
    }

    // These two 'simulate' functions can be called via shortcuts
    function simulateEnter() {
        verboseMessage("Other/Filter", "simulateEnter()")
        variables.filter = term.getText()
        var newfilename = Handle.getFilenameMatchingFilter(term.getText())
        if(newfilename === "")
            variables.filterNoMatch = true
        else
            Handle.loadFile(variables.currentDir+"/"+newfilename, term.getText(), true)
        hide()
    }

    function showFilter() {
        verboseMessage("Other/Filter", "showFilter()")
        term.text = variables.filter
        term.forceActiveFocus()
        term.selectAll()
        show()
    }
}
