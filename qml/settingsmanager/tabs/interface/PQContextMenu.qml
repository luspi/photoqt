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
import Qt.labs.platform 1.0

import "../../../elements"

PQSetting {

    id: set

    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "custom context menu entries")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Add some custom entries to the context menu.")

    expertmodeonly: false

    property var entries: [["","","","0",""]]

    property int focusIndex: -1
    property int focusField: 0

    signal focusOnIndex(var newindex)

    content: [
        Rectangle {
            width: contwidth-20
            height: variables.settingsManagerExpertMode ? (showExternal.height+(handlingGeneral.amIOnWindows() ? 0 : replaceWithAvailable.height)+entrycol.height+60) : ((handlingGeneral.amIOnWindows() ? 0 : replaceWithAvailable.height)+entrycol.height+40)
            color: "#111111"
            radius: 5

            PQButton {
                id: replaceWithAvailable
                visible: !handlingGeneral.amIOnWindows()
                x: 10
                y: 10
                text: em.pty+qsTranslate("settingsmanager_interface", "Set entries for other image related applications")
                onClicked: {
                    if(handlingGeneral.askForConfirmation(em.pty+qsTranslate("settingsmanager_interface", "This will look for some other image related applications on your computer and add an entry for any that are found."),
                                                          em.pty+qsTranslate("settingsmanager_interface", "Note that this will replace all entries currently set and cannot be undone."))) {
                        handlingExternal.replaceContextMenuEntriesWithAvailable()
                        entries = handlingExternal.getContextMenuEntries()
                        addNewEntry()
                    }
                }
            }

            Column {
                id: entrycol
                y: handlingGeneral.amIOnWindows() ? 10 : (replaceWithAvailable.y+replaceWithAvailable.height+20)
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
                            width: (parent.width-quit.width-up.width-down.width-del.width-10)*0.4-20
                            borderColor: "#666666"
                            //: this is the placeholder text inside of a text box telling the user what text they can enter here
                            placeholderText: em.pty+qsTranslate("settingsmanager_interface", "what string to show for this entry")
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
                        PQButton {
                            id: exebutton
                            x: entrytext.width+20
                            y: (parent.height-height)/2
                            forceWidth: (parent.width-quit.width-up.width-down.width-del.width-10)*0.3-10
                            tooltip: em.pty+qsTranslate("settingsmanager_interface", "Click here to select an executable to be used with this shortcut.")
                            //: This is written on a button, used as in 'click this button to select an executable'
                            text: (entries[index][1] == "" ? ("(" + em.pty+qsTranslate("settingsmanager_interface", "executable") + ")") : entries[index][1])
                            elide: Text.ElideLeft
                            onClicked: {
                                selectExec.currentIndex = index
                                selectExec.folder = "file://"+(entries[index][1].slice(0,1) == "/"
                                                               ? handlingFileDir.getDirectory(entries[index][1])
                                                               : (handlingGeneral.amIOnWindows()
                                                                  ? handlingFileDir.getHomeDir()
                                                                  : "/usr/bin/"))
                                selectExec.visible = true
                            }
                        }

                        PQLineEdit {
                            id: exec
                            x: entrytext.width+exebutton.width+30
                            y: (parent.height-height)/2
                            width: (parent.width-quit.width-up.width-down.width-del.width-10)*0.3-10
                            borderColor: "#666666"
                            //: this is the placeholder text inside of a text box telling the user what text they can enter here
                            placeholderText: em.pty+qsTranslate("settingsmanager_interface", "additional command line flags")
                            text: entries[index][4]
                            onTextEdited: {
                                entries[index][4] = text
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
                            checked: entries[index][3]=="1"
                            onCheckedChanged: {
                                entries[index][3] = (checked ? 1 : 0)
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

            PQCheckbox {
                id: showExternal
                visible: variables.settingsManagerExpertMode
                x: 10
                y: entrycol.y+entrycol.height+20
                text: em.pty+qsTranslate("settingsmanager_interface", "Also show entries in main menu")
            }

        }

    ]

    FileDialog {
        id: selectExec
        modality: Qt.ApplicationModal
        fileMode: FileDialog.OpenFile
        property int currentIndex: -1
        onAccepted: {

            if(selectExec.file == "")
                return

            var fname = handlingFileDir.getFileNameFromFullPath(selectExec.file)

            if(StandardPaths.findExecutable(fname) == selectExec.file)
                entries[currentIndex][1] = fname
            else
                entries[currentIndex][1] = handlingFileDir.cleanPath(selectExec.file)

            entriesChanged()
        }
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            showExternal.checked = PQSettings.mainmenuShowExternal
            entries = handlingExternal.getContextMenuEntries()
            addNewEntry()
        }

        onSaveAllSettings: {
            handlingExternal.saveContextMenuEntries(entries)
            PQSettings.mainmenuShowExternal = showExternal.checked
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
        entries.push(["","","","0",""])
        set.entriesChanged()
    }

}
