/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
            width: entrycol.width + 20
            height: variables.settingsManagerExpertMode ? (showExternal.height+(handlingGeneral.amIOnWindows() ? 0 : replaceWithAvailable.height)+entrycol.height+60) : ((handlingGeneral.amIOnWindows() ? 0 : replaceWithAvailable.height)+entrycol.height+40)
            color: "#111111"
            radius: 5

            PQButton {
                id: replaceWithAvailable
                visible: !handlingGeneral.amIOnWindows()
                x: 10
                y: 10
                text: em.pty+qsTranslate("settingsmanager_interface", "Detect other image related applications")
                onClicked: {
                    if(handlingGeneral.askForConfirmation(em.pty+qsTranslate("settingsmanager_interface", "This will look for some other image related applications on your computer and add an entry for any that are found."),
                                                          em.pty+qsTranslate("settingsmanager_interface", "Note that this will replace all entries currently set and cannot be undone. Continue?"))) {
                        handlingExternal.replaceContextMenuEntriesWithAvailable()
                        entries = handlingExternal.getContextMenuEntries()
                        addNewEntry()
                    }
                }
            }

            Column {
                id: entrycol
                y: handlingGeneral.amIOnWindows() ? 10 : (replaceWithAvailable.y+replaceWithAvailable.height+20)
                spacing: 10
                Repeater {
                    model: entries.length
                    delegate: Rectangle {
                        x: 10
                        width: childrenRect.width+6
                        height: 70
                        color: "#222222"
                        radius: 5

                        Column {

                            x: 3
                            y: 3

                            spacing: 4

                            Row {

                                id: firstrow

                                spacing: 10

                                Row {

                                    Rectangle {

                                        id: exeicon

                                        height: 30
                                        width: 30

                                        color: "transparent"
                                        border.width: 1
                                        border.color: "#44cccccc"

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 3
                                            fillMode: Image.PreserveAspectFit
                                            verticalAlignment: Image.AlignVCenter
                                            horizontalAlignment: Image.AlignHCenter
                                            opacity: 0.5
                                            source: (entries[index][0] == "" ? "/settingsmanager/interface/application.svg" : ("data:image/png;base64," + entries[index][0]))

                                        }

                                        PQMouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            tooltip: em.pty+qsTranslate("settingsmanager_interface", "Click to change the icon of the entry")
                                            onClicked: {
                                                selectIcon.folder = "file:///" + (handlingGeneral.amIOnWindows() ? handlingFileDir.getHomeDir() : "/usr/share/icons/hicolor/32x32/apps")
                                                selectIcon.currentIndex = index
                                                selectIcon.visible = true
                                            }
                                        }

                                    }

                                    PQLineEdit {
                                        id: entrytext
                                        width: 200
                                        height: 30
                                        borderColor: "#666666"
                                        //: this is the placeholder text inside of a text box telling the user what text they can enter here
                                        placeholderText: em.pty+qsTranslate("settingsmanager_interface", "entry name")
                                        text: entries[index][2]
                                        tooltipText: text=="" ? placeholderText : (placeholderText + ": " + text)
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

                                }

                                PQCheckbox {
                                    id: quit
                                    y: (30-height)/2
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

                                Row {

                                    height: 30

                                    PQButton {
                                        id: up
                                        height: 30
                                        width: 30
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
                                        height: 30
                                        width: 30
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
                                        height: 30
                                        width: 30
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

                                }

                            }

                            Row {

                                id: secondrow

                                spacing: 10

                                Row {

                                    id: exerow

                                    Item {
                                        width: exeicon.width
                                        height: exeicon.width
                                    }

                                    PQLineEdit {
                                        id: exepath
                                        width: 200
                                        height: 30
                                        //: This is used as in "executable binary/program"
                                        placeholderText: em.pty+qsTranslate("settingsmanager_interface", "executable")
                                        text: handlingFileDir.pathWithNativeSeparators(entries[index][1])
                                        tooltipText: text=="" ? placeholderText : (placeholderText + ": " + text)
                                        onTextEdited: {
                                            entries[index][1] = text
                                            if(index == entries.length-1) {
                                                focusIndex = index
                                                focusField = 3
                                                addNewEntry()
                                            }
                                        }
                                        Component.onCompleted: {
                                            if(focusIndex == index && focusField == 3) {
                                                exepath.setFocus()
                                                exepath.deselect()
                                            }
                                        }
                                    }

                                    PQButton {
                                        id: exebutton
                                        forceWidth: 30
                                        height: 30
                                        tooltip: em.pty+qsTranslate("settingsmanager_interface", "Click here to select the executable for this entry.")
                                        text: "..."
                                        onClicked: {
                                            selectExec.currentIndex = index
                                            selectExec.folder = "file:///"+(entries[index][1].slice(0,1) == "/"
                                                                           ? handlingFileDir.getDirectory(entries[index][1])
                                                                           : (handlingGeneral.amIOnWindows()
                                                                              ? handlingFileDir.getHomeDir()
                                                                              : "/usr/bin/"))
                                            selectExec.visible = true
                                        }
                                    }

                                }

                                PQLineEdit {
                                    id: exec
                                    width: firstrow.width - exerow.x - exerow.width - secondrow.spacing
                                    height: 30
                                    borderColor: "#666666"
                                    //: this is the placeholder text inside of a text box telling the user what text they can enter here
                                    placeholderText: em.pty+qsTranslate("settingsmanager_interface", "additional flags")
                                    text: entries[index][4]
                                    tooltipText: text=="" ? placeholderText : (placeholderText + ": " + text)
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
            var icn = handlingExternal.getIconPathFromTheme(fname)

            if(StandardPaths.findExecutable(fname) == selectExec.file)
                entries[currentIndex][1] = fname
            else
                entries[currentIndex][1] = handlingFileDir.cleanPath(selectExec.file)

            if(icn != "") {
                if(handlingGeneral.askForConfirmation("An icon for this executable was found in the system theme.", "Do you want to use it?")) {
                    entries[currentIndex][0] = handlingExternal.loadImageAndConvertToBase64(icn)
                }
            }

            entriesChanged()
        }
    }

    FileDialog {
        id: selectIcon
        modality: Qt.ApplicationModal
        fileMode: FileDialog.OpenFile
        nameFilters: ["Images (*."+PQImageFormats.getEnabledFormatsQt().join(" *.")+")", "All files (*.*)"]
        property int currentIndex: -1
        onAccepted: {

            if(selectIcon.file == "")
                return

            entries[currentIndex][0] = handlingExternal.loadImageAndConvertToBase64(selectIcon.file)
            entriesChanged()

        }
        onRejected: {

            if(handlingGeneral.askForConfirmation("No icon was selected.", "Do you want to remove any icon currently set?")) {
                entries[currentIndex][0] = ""
                entriesChanged()
            }

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
