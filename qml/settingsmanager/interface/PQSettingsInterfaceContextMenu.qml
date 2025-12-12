/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import QtCore
import "../../other/PQCommonFunctions.js" as PQF
import PhotoQt

PQSetting {

    id: set_come

    property var defaultentries: ({})
    property list<var> entries: []

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Context menu")

            helptext: qsTranslate("settingsmanager", "The context menu contains actions that can be performed related to the currently viewed image. By default is it shown when doing a right click on the background, although it is possible to change that in the shortcuts category. In addition to pre-defined image functions it is also possible to add custom entries to that menu.")

        },

        Column {

            spacing: set_come.contentSpacing

            PQTextL {
                visible: set_come.entries.length===0
                height: 50
                verticalAlignment: Text.AlignVCenter
                color: palette.disable.text
                font.weight: PQCLook.fontWeightBold
                //: The custom entries here are the custom entries in the context menu
                text: qsTranslate("settingsmanager", "No custom entries exists yet")
            }

            Column {

                spacing: 5

                Repeater {

                    model: set_come.entries.length

                    Item {

                        id: deleg

                        required property int modelData

                        property var curData: (deleg.modelData < set_come.entries.length) ? set_come.entries[deleg.modelData] : ["","","","",""]
                        onCurDataChanged: {
                            set_come.entries[deleg.modelData] = curData
                            set_come.checkForChanges()
                        }

                        width: Math.min(800, set_come.contentWidth-delicn.width-10)
                        height: 50

                        Row {
                            spacing: 5
                            x: 5
                            y: (parent.height-height)/2

                            PQButtonIcon {
                                id: appicon
                                iconScale: 0.5
                                source: (deleg.curData[0]==="" ? ("image://svg/:/" + PQCLook.iconShade + "/application.svg") : ("data:image/png;base64," + set_come.entries[deleg.modelData][0]))
                                onSourceChanged:
                                    set_come.checkForChanges()
                                onClicked: {
                                                                                        //: written on button for selecting a file from the file dialog
                                    var newicn = PQCScriptsFilesPaths.openFileFromDialog(qsTranslate("settingsmanager", "Select"), (PQCScriptsConfig.amIOnWindows() ? PQCScriptsFilesPaths.getHomeDir() : "/usr/share/icons/hicolor/32x32/apps"), PQCImageFormats.getEnabledFormatsQt());
                                    if(newicn !== "")
                                        deleg.curData[0] = PQCScriptsImages.loadImageAndConvertToBase64(newicn)
                                    else
                                        deleg.curData[0] = ""
                                    deleg.curDataChanged()

                                }
                            }
                            PQLineEdit {
                                id: entryname
                                width: (deleg.width-appicon.width-quitcheck.width-30)/3
                                //: The entry here refers to the text that is shown in the context menu for a custom entry
                                placeholderText: qsTranslate("settingsmanager", "entry name")
                                text: deleg.curData[2]
                                onTextChanged: {
                                    if(deleg.curData[2] !== text) {
                                        deleg.curData[2] = text
                                        deleg.curDataChanged()
                                    }
                                }
                            }
                            Row {
                                PQLineEdit {
                                    id: executable
                                    width: entryname.width
                                    placeholderText: qsTranslate("settingsmanager", "executable")
                                    text: deleg.curData[1]
                                    onTextChanged: {
                                        if(deleg.curData[1] !== text) {
                                            deleg.curData[1] = text
                                            deleg.curDataChanged()
                                        }
                                    }
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
                                            deleg.curData[1] = fname
                                        else
                                            deleg.curData[1] = PQCScriptsFilesPaths.cleanPath(newexe)

                                        if(icn !== "" && deleg.curData[0] === "") {
                                            deleg.curData[0] = PQCScriptsImages.loadImageAndConvertToBase64(icn)
                                        }

                                        deleg.curDataChanged()

                                    }
                                }
                            }
                            PQLineEdit {
                                id: addflags
                                width: entryname.width-selectexe.width
                                //: The flags here are additional parameters that can be passed on to an executable
                                placeholderText: qsTranslate("settingsmanager", "additional flags")
                                text: deleg.curData[4]
                                onTextChanged: {
                                    if(deleg.curData[4] !== text) {
                                        deleg.curData[4] = text
                                        deleg.curDataChanged()
                                    }
                                }
                            }
                            PQCheckBox {
                                y: (addflags.height-height)/2
                                id: quitcheck
                                //: Quit PhotoQt after executing custom context menu entry. Please keep as short as possible!!
                                text: qsTranslate("settingsmanager", "quit")
                                checked: (deleg.curData[3]==="1")
                                onCheckedChanged: {
                                    var val = (checked ? "1" : "0")
                                    if(deleg.curData[3] !== val) {
                                        deleg.curData[3] = val
                                        deleg.curDataChanged()
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
                                source: "image://svg/:/" + PQCLook.iconShade + "/x.svg"
                                height: 15
                                width: 15
                                sourceSize: Qt.size(width, height)
                                property bool hovered: false
                                opacity: hovered ? 1 : 0.3
                                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    //: The entry here is a custom entry in the context menu
                                    text: qsTranslate("settingsmanager", "Delete entry")
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: set_come.deleteEntry(deleg.modelData)
                                    onEntered: delicn.hovered = true
                                    onExited: delicn.hovered = false
                                }
                            }
                        }

                    }

                }

            }

            PQButton {
                id: addnewbut
                //: The entry here is a custom entry in the context menu
                text: qsTranslate("settingsmanager", "Add new entry")
                forceWidth: Math.min(parent.width, 500)
                fontWeight: PQCLook.fontWeightNormal
                onClicked: set_come.addNewEntry()
            }

            PQButton {
                id: addsysbut
                forceWidth: Math.min(parent.width, 500)
                visible: !PQCScriptsConfig.amIOnWindows()
                //: The system applications here refers to any image related applications that can be found automatically on your system
                text: qsTranslate("settingsmanager", "Add system applications")
                fontWeight: PQCLook.fontWeightNormal
                onClicked: {
                    var newentries = PQCScriptsContextMenu.detectSystemEntries()
                    for(var i = 0; i < newentries.length; ++i) {

                        var cur = newentries[i]

                        var found = false
                        for(var j = 0; j < set_come.entries.length; ++j) {
                            if(set_come.entries[j][1] === cur[1]) {
                                found = true
                                break
                            }
                        }

                        if(!found)
                            set_come.entries.push(cur)

                    }
                    set_come.entriesChanged()
                }
            }

        },

        /******************************/

        PQSettingSubtitle {

            visible: set_come.modernInterface

            //: The entries here are the custom entries in the context menu
            title: qsTranslate("settingsmanager", "Duplicate entries in main menu")

            helptext: qsTranslate("settingsmanager", "The custom context menu entries can also be duplicated in the main menu. If enabled, the entries set above will be accesible in both places.")

        },

        PQCheckBox {
            id: check_dupl
            visible: set_come.modernInterface
            //: Refers to duplicating the custom context menu entries in the main menu
            text: qsTranslate("settingsmanager", "Duplicate in main menu")
            onCheckedChanged:
                set_come.checkForChanges()
        },

        PQSettingsResetButton {
            visible: set_come.modernInterface
            onResetToDefaults: {

                check_dupl.checked = PQCSettings.getDefaultForMainmenuShowExternal()

                set_come.checkForChanges()

            }
        }

    ]

    function addNewEntry() {
        entries.push(["","","","0",""])
        entriesChanged()
        checkForChanges()
    }

    function deleteEntry(index: int) {
        entries.splice(index,1)
        entriesChanged()
        checkForChanges()
    }

    Timer {
        id: loadtimer
        interval: 100
        onTriggered: {
            // these need to be completely disconnected otherwise the changed check doesn't work
            set_come.entries = PQCScriptsContextMenu.getEntries()
            set_come.defaultentries = PQCScriptsContextMenu.getEntries()
            check_dupl.loadAndSetDefault(PQCSettings.mainmenuShowExternal)
            PQCConstants.settingsManagerSettingChanged = false
            set_come.settingsLoaded = true
        }
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (!PQF.areTwoListsEqual(entries, defaultentries) || check_dupl.hasChanged())

    }

    function load() {

        settingsLoaded = false

        loadtimer.restart()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCScriptsContextMenu.setEntries(entries)
        defaultentries = PQCScriptsContextMenu.getEntries()
        PQCSettings.mainmenuShowExternal = check_dupl.checked
        check_dupl.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
