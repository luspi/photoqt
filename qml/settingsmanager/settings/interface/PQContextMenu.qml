/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls
import QtCore

import PQCNotify
import PQCScriptsConfig
import PQCScriptsContextMenu
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCImageFormats

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - context menu entries
// - mainmenuShowExternal

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property bool settingsLoaded: false

    property var defaultentries: ({})
    property var entries: []

    ScrollBar.vertical: PQVerticalScrollBar {}

    MouseArea {
        width: parent.width
        height: parent.parent.height
        onClicked: {
            setting_top.forceActiveFocus()
        }
    }

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQSetting {

            id: set_con

            //: Settings title
            title: qsTranslate("settingsmanager", "Context menu")

            helptext: qsTranslate("settingsmanager",  "The context menu contains actions that can be performed related to the currently viewed image. By default is it shown when doing a right click on the background, although it is possible to change that in the shortcuts category. In addition to pre-defined image functions it is also possible to add custom entries to that menu.")

            content: [

                PQTextL {
                    visible: entries.length==0
                    height: 50
                    verticalAlignment: Text.AlignVCenter
                    color: PQCLook.textColorDisabled
                    font.weight: PQCLook.fontWeightBold
                    //: The custom entries here are the custom entries in the context menu
                    text: qsTranslate("settingsmanager", "No custom entries exists yet")
                },

                Repeater {

                    model: entries.length

                    Rectangle {

                        id: deleg

                        width: Math.min(800, set_con.rightcol-delicn.width-10)
                        height: 50
                        radius: 5

                        color: PQCLook.baseColorHighlight

                        Row {
                            spacing: 5
                            x: 5
                            y: (parent.height-height)/2

                            PQButtonIcon {
                                id: appicon
                                source: (entries[index][0]==="" ? "image://svg/:/white/application.svg" : ("data:image/png;base64," + entries[index][0]))
                                onSourceChanged:
                                    checkDefault()
                                onClicked: {
                                                                                        //: written on button for selecting a file from the file dialog
                                    var newicn = PQCScriptsFilesPaths.openFileFromDialog(qsTranslate("settingsmanager", "Select"), (PQCScriptsConfig.amIOnWindows() ? PQCScriptsFilesPaths.getHomeDir() : "/usr/share/icons/hicolor/32x32/apps"), PQCImageFormats.getEnabledFormatsQt());
                                    if(newicn !== "")
                                        entries[index][0] = PQCScriptsImages.loadImageAndConvertToBase64(newicn)
                                    else
                                        entries[index][0] = ""
                                    entriesChanged()

                                }
                            }
                            PQLineEdit {
                                id: entryname
                                width: (deleg.width-appicon.width-quitcheck.width-30)/3
                                //: The entry here refers to the text that is shown in the context menu for a custom entry
                                placeholderText: qsTranslate("settingsmanager", "entry name")
                                text: entries[index][2]
                                onTextChanged: {
                                    if(entries[index][2] !== text) {
                                        entries[index][2] = text
                                        entriesChanged()
                                        checkDefault()
                                    }
                                }
                                onControlActiveFocusChanged: {
                                    PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
                                }
                            }
                            Row {
                                PQLineEdit {
                                    id: executable
                                    width: entryname.width
                                    placeholderText: qsTranslate("settingsmanager", "executable")
                                    text: entries[index][1]
                                    onTextChanged: {
                                        if(entries[index][1] !== text) {
                                            entries[index][1] = text
                                            entriesChanged()
                                            checkDefault()
                                        }
                                    }
                                    onControlActiveFocusChanged:
                                        PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
                                }
                                PQButton {
                                    id: selectexe
                                    text: "..."
                                    tooltip: qsTranslate("settingsmanager", "Select executable")
                                    width: height
                                    onClicked: {
                                        //: written on button for selecting a file from the file dialog
                                        var newexe = PQCScriptsFilesPaths.openFileFromDialog(qsTranslate("settingsmanager", "Select"), (PQCScriptsConfig.amIOnWindows() ? PQCScriptsFilesPaths.getHomeDir() : "/usr/bin"), []);

                                        if(newexe === "")
                                            return

                                        var fname = PQCScriptsFilesPaths.getFilename(newexe)
                                        var icn = PQCScriptsImages.getIconPathFromTheme(fname)

                                        if(PQCScriptsFilesPaths.cleanPath(StandardPaths.findExecutable(fname)) === newexe)
                                            entries[index][1] = fname
                                        else
                                            entries[index][1] = PQCScriptsFilesPaths.cleanPath(newexe)

                                        if(icn !== "" && entries[index][0] === "") {
                                            entries[index][0] = PQCScriptsImages.loadImageAndConvertToBase64(icn)
                                        }

                                        entriesChanged()

                                    }
                                }
                            }
                            PQLineEdit {
                                id: addflags
                                width: entryname.width-selectexe.width
                                //: The flags here are additional parameters that can be passed on to an executable
                                placeholderText: qsTranslate("settingsmanager", "additional flags")
                                text: entries[index][4]
                                onTextChanged: {
                                    if(entries[index][4] !== text) {
                                        entries[index][4] = text
                                        entriesChanged()
                                        checkDefault()
                                    }
                                }
                                onControlActiveFocusChanged:
                                    PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
                            }
                            PQCheckBox {
                                y: (addflags.height-height)/2
                                id: quitcheck
                                //: Quit PhotoQt after executing custom context menu entry. Please keep as short as possible!!
                                text: qsTranslate("settingsmanager", "quit")
                                checked: (entries[index][3]==="1")
                                onCheckedChanged: {
                                    var val = (checked ? "1" : "0")
                                    if(entries[index][3] !== val) {
                                        entries[index][3] = val
                                        entriesChanged()
                                        checkDefault()
                                    }
                                }
                            }

                            Item {
                                width: 1
                                height: 1
                            }

                            Image {
                                id: delicn
                                y: (addflags.height-height)/2
                                source: "image://svg/:/white/x.svg"
                                height: 15
                                width: 15
                                sourceSize: Qt.size(width, height)
                                property bool hovered: false
                                opacity: hovered ? 1 : 0.3
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    //: The entry here is a custom entry in the context menu
                                    text: qsTranslate("settingsmanager", "Delete entry")
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: deleteEntry(index)
                                    onEntered: parent.hovered = true
                                    onExited: parent.hovered = false
                                }
                            }
                        }

                    }

                },

                PQButton {
                    //: The entry here is a custom entry in the context menu
                    text: qsTranslate("settingsmanager", "Add new entry")
                    forceWidth: Math.min(parent.width, 500)
                    font.weight: PQCLook.fontWeightNormal
                    onClicked: addNewEntry()
                },
                PQButton {
                    forceWidth: Math.min(parent.width, 500)
                    visible: !PQCScriptsConfig.amIOnWindows()
                    //: The system applications here refers to any image related applications that can be found automatically on your system
                    text: qsTranslate("settingsmanager", "Add system applications")
                    font.weight: PQCLook.fontWeightNormal
                    onClicked: {
                        var newentries = PQCScriptsContextMenu.detectSystemEntries()
                        for(var i = 0; i < newentries.length; ++i) {

                            var cur = newentries[i]

                            var found = false
                            for(var j = 0; j < entries.length; ++j) {
                                if(entries[j][1] === cur[1]) {
                                    found = true
                                    break
                                }
                            }

                            if(!found)
                                entries.push(cur)

                        }
                        entriesChanged()
                    }
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: The entries here are the custom entries in the context menu
            title: qsTranslate("settingsmanager", "Duplicate entries in main menu")

            helptext: qsTranslate("settingsmanager", "The custom context menu entries can also be duplicated in the main menu. If enabled, the entries set above will be accesible in both places.")

            content: [

                PQCheckBox {
                    id: check_dupl
                    //: Refers to duplicating the custom context menu entries in the main menu
                    text: qsTranslate("settingsmanager", "Duplicate in main menu")
                    onCheckedChanged:
                        checkDefault()
                }

            ]

        }

        Item {
            width: 1
            height: 1
        }

    }

    function areTwoListsEqual(l1, l2) {

        if(l1.length !== l2.length)
            return false

        for(var i = 0; i < l1.length; ++i) {

            if(l1[i].length !== l2[i].length)
                return false

            for(var j = 0; j < l1[i].length; ++j) {
                if(l1[i][j] !== l2[i][j])
                    return false
            }
        }

        return true
    }


    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (!areTwoListsEqual(entries, defaultentries) || check_dupl.hasChanged())
    }

    function addNewEntry() {
        entries.push(["","","","0",""])
        entriesChanged()
        checkDefault()
    }

    function deleteEntry(index) {
        entries.splice(index,1)
        entriesChanged()
        checkDefault()
        setting_top.forceActiveFocus()
    }

    Timer {
        id: loadtimer
        interval: 100
        onTriggered: {
            // these need to be completely disconnected otherwise the changed check doesn't work
            entries = PQCScriptsContextMenu.getEntries()
            defaultentries = PQCScriptsContextMenu.getEntries()
            check_dupl.loadAndSetDefault(PQCSettings.mainmenuShowExternal)
            settingChanged = false
            settingsLoaded = true
        }
    }

    Component.onCompleted:
        load()

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEnterEsc = false

    function load() {
        loadtimer.restart()
    }

    function applyChanges() {
        PQCScriptsContextMenu.setEntries(entries)
        defaultentries = PQCScriptsContextMenu.getEntries()
        PQCSettings.mainmenuShowExternal = check_dupl.checked
        check_dupl.saveDefault()
        settingChanged = false
    }

    function revertChanges() {
        load()
    }

}
