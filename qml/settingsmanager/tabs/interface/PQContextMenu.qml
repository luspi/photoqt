/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {

    id: set

    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "custom main menu entries")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Add some custom entries in the main menu on the right.")

    expertmodeonly: false

    property var entries: [["","","dontclose"]]

    property int focusIndex: -1
    property int focusField: 0

    signal focusOnIndex(var newindex)

    content: [
        Rectangle {
            width: contwidth-20
            height: childrenRect.height+20
            color: "#111111"
            radius: 5

            Column {
                id: entrycol
                y: 10
                width: parent.width
                spacing: 10
                Repeater {
                    model: entries.length
                    delegate: Rectangle {
                        x: 10
                        width: parent.width-20
                        height: 40
                        color: "#222222"
                        radius: 5

                        PQLineEdit {
                            id: entrytext
                            x: 10
                            y: (parent.height-height)/2
                            width: (parent.width-quit.width-up.width-down.width-del.width-10)*0.5-20
                            borderColor: "#666666"
                            //: this is the placeholder text inside of a text box telling the user what text they can enter here
                            placeholderText: em.pty+qsTranslate("settingsmanager_interface", "what string to show in main menu")
                            text: entries[index][2]
                            onTextEdited: {
                                entries[index][2] = text
                                if(index == entries.length-1) {
                                    focusIndex = index
                                    focusField = 0
                                    addNewEntry()
                                }
                            }
                            Component.onCompleted: {
                                if(focusIndex == index && focusField == 0) {
                                    entrytext.setFocus()
                                    entrytext.deselect()
                                }
                            }
                        }
                        PQLineEdit {
                            id: exec
                            x: entrytext.width+20
                            y: (parent.height-height)/2
                            width: (parent.width-quit.width-up.width-down.width-del.width-10)*0.5-10
                            borderColor: "#666666"
                            //: this is the placeholder text inside of a text box telling the user what text they can enter here
                            placeholderText: em.pty+qsTranslate("settingsmanager_interface", "which command to execute")
                            text: entries[index][1]
                            onTextEdited: {
                                entries[index][1] = text
                                if(index == entries.length-1) {
                                    focusIndex = index
                                    focusField = 1
                                    addNewEntry()
                                }
                            }
                            Component.onCompleted: {
                                if(focusIndex == index && focusField == 1) {
                                    exec.setFocus()
                                    exec.deselect()
                                }
                            }
                        }

                        PQCheckbox {
                            id: quit
                            y: (parent.height-height)/2
                            anchors.right: up.left
                            anchors.rightMargin: 5
                            //: Keep string short! Used on checkbox for contextmenu, refers to option to close PhotoQt after respective command has been executed.
                            text: em.pty+qsTranslate("settingsmanager_interface", "quit")
                            checked: entries[index][3]=="close"
                            onCheckedChanged: {
                                entries[index][3] = (checked ? "close" : "dontclose")
                                if(index == entries.length-1) {
                                    focusIndex = index
                                    focusField = 2
                                    addNewEntry()
                                }
                            }
                        }
                        PQButton {
                            id: up
                            anchors.right: down.left
                            height: parent.height
                            width: height
                            text: ">"
                            rotation: 90
                            enabled: (index < entries.length-1)
                            //: contextmenu settings: used as in 'move this entry down in the list of all entries'
                            tooltip: em.pty+qsTranslate("settingsmanager_interface", "move entry down")
                            onClicked:
                                moveIndexDown(index)
                        }
                        PQButton {
                            id: down
                            anchors.right: del.left
                            height: parent.height
                            width: height
                            text: "<"
                            rotation: 90
                            enabled: (index < entries.length-1)
                            //: contextmenu settings: used as in 'move this entry up in the list of all entries'
                            tooltip: em.pty+qsTranslate("settingsmanager_interface", "move entry up")
                            onClicked:
                                moveIndexUp(index)
                        }
                        PQButton {
                            id: del
                            anchors.right: parent.right
                            height: parent.height
                            width: height
                            text: "x"
                            textColor: "red"
                            textColorActive: "red"
                            textColorHover: "red"
                            backgroundColor: "#190000"
                            backgroundColorHover: "#440000"
                            backgroundColorActive: "#2a0000"
                            enabled: (index < entries.length-1)
                            //: contextmenu settings: used as in 'delete this entry out of the list of all entries'
                            tooltip: em.pty+qsTranslate("settingsmanager_interface", "delete entry")
                            onClicked:
                                deleteIndex(index)
                        }

                        Connections {
                            target: set
                            onFocusOnIndex: {
                                if(focusField == 0 && index == newindex) {
                                    entrytext.setFocus()
                                    entrytext.deselect()
                                } else if(focusField == 1 && index == newindex) {
                                    exec.setFocus()
                                    exec.deselect()
                                }
                            }
                        }

                    }
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            entries = handlingExternal.getContextMenuEntries()
            addNewEntry()
        }

        onSaveAllSettings: {
            handlingExternal.saveContextMenuEntries(entries)
        }

    }

    function moveIndexDown(index) {
        if(index < entries.length-2) {
            focusIndex = index+1
            var one = entries[index]
            var two = entries[index+1]
            entries[index] = two
            entries[index+1] = one
            set.entriesChanged()
            focusOnIndex(index+1)
        }
    }

    function moveIndexUp(index) {
        if(index > 0) {
            focusIndex = index-1
            var one = entries[index]
            var two = entries[index-1]
            entries[index] = two
            entries[index-1] = one
            set.entriesChanged()
            focusOnIndex(index-1)
        }
    }

    function deleteIndex(index) {
        entries.splice(index,1)
        focusIndex = index
        set.entriesChanged()
    }

    function addNewEntry() {
        entries.push(["","","","dontclose"])
        set.entriesChanged()
    }

}
