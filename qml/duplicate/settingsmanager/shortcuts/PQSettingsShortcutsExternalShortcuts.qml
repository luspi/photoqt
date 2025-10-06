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
import QtQuick.Controls
import "../../other/PQCommonFunctions.js" as PQF
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_exsh

    disabledAutoIndentation: true
    addBlankSpaceBottom: false

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property int steadyCounter: 0

    property var defaultData: ({})
    property var currentData: ({})

    onCurrentDataChanged: {
        checkForChanges()
    }

    property list<string> duplicateCombos: []

    content: [

        PQSettingSubtitle {

            showLineAbove: false
            noIndent: true

            title: qsTranslate("settingsmanager", "External shortcuts")

            helptext: qsTranslate("settingsmanager", "In addition to a wide range of built-in shortcut actions, any external application, command, or script can be used as shortcut action. Note that relative file paths are not supported, however, you can use the following placeholders:") + "\n\n" +
                      "%f = " + qsTranslate("settingsmanager", "filename including path") + "\n" +
                                                "%u = " + qsTranslate("settingsmanager", "filename without path") + "\n" +
                                                "%d = " + qsTranslate("settingsmanager", "directory containing file") + "\n\n" +
                      qsTranslate("settingsmanager", "If you type out a path, make sure to escape spaces accordingly by prepending a backslash:") + " '\\ '\n\n" +
                      qsTranslate("settingsmanager", "Please note that any external shortcut action that doesnot have any mouse or key combination associated with it will not be saved.")


        },

        Row {

            spacing: 5
            visible: set_exsh.duplicateCombos.length>0

            Item {
                y: (parent.height-height)/2
                width: 20
                height: 20
                Rectangle {
                    id: greenbg_top
                    anchors.fill: parent
                    color: "green"
                    opacity: 0.1
                    SequentialAnimation {
                        running: true
                        loops: SequentialAnimation.Infinite
                        NumberAnimation {
                            target: greenbg_top
                            property: "opacity"
                            duration: 750
                            from: 0.1
                            to: 0.3
                        }
                        NumberAnimation {
                            target: greenbg_top
                            property: "opacity"
                            duration: 750
                            from: 0.3
                            to: 0.1
                        }
                    }
                }
                Image {
                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width: 12
                    height: 12
                    sourceSize: Qt.size(width, height)
                    source: "image://svgcolor/green:://:::/light/zoomin.svg"
                }
            }

            PQText {
                width: set_exsh.contentWidth
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "This symbol indicates a key or mouse combination that is set for more than one shortcut action (for internal and external actions combined).")
            }

        },

        Item {
            width: 1
            height: 5
        },

        Row {
            PQSettingSpacer {}
            PQButton {
                text: qsTranslate("settingsmanager", "add new external shortcut action")
                onClicked: {
                    var uniqueid = set_exsh.steadyCounter
                    set_exsh.currentData[uniqueid] = [[], "", "", 0]
                    set_exsh.currentDataChanged()
                    extmodel.append({"cmd": "", "flags" : "", "quit": 0, "_combos": "", "uniqueId": uniqueid.toString()})
                    set_exsh.steadyCounter += 1
                }
            }
        },

        Item {
            width: 1
            height: 5
        },

        ListView {

            id: extview

            width: set_exsh.width
            height: set_exsh.availableHeight - extview.y

            spacing: 10
            clip: true

            model: ListModel { id: extmodel }

            // this ensures all entries are always set up
            cacheBuffer: extmodel.count*60

            ScrollBar.vertical: PQVerticalScrollBar {}

            PQTextXL {
                x: (parent.width-width)/2
                y: parent.height*0.15
                visible: extmodel.count===0
                text: qsTranslate("settingsmanager", "no external shortcuts set")
                color: pqtPaletteDisabled.text
                font.weight: PQCLook.fontWeightBold
            }

            delegate:
            Rectangle {

                id: deleg

                required property int index
                required property string cmd
                required property string flags
                required property int quit
                required property string _combos
                required property string uniqueId

                property list<string> combos: _combos==="" ? [] : _combos.split(":://::")

                property list<string> default_combos: []

                // the combos for this command
                onCombosChanged: {
                    if(!PQF.areTwoListsEqual(combos, default_combos)) {
                        set_exsh.currentData[deleg.uniqueId][0] = deleg.combos
                        set_exsh.currentDataChanged()
                        default_combos = combos
                        set_exsh.calculateDuplicates()
                    }
                }

                width: extview.width
                height: contcol.height+20

                border.width: 1
                border.color: PQCLook.baseBorder
                radius: 5

                clip: true
                color: pqtPalette.base

                Column {

                    id: contcol
                    x: 10
                    y: 10
                    spacing: 5

                    Row {
                        spacing: 5
                        PQText {
                            y: (parent.height-height)/2
                            text: qsTranslate("settingsmanager", "executable:")
                        }
                        PQLineEdit {
                            id: ext_exe
                            text: deleg.cmd
                            onTextChanged: {
                                set_exsh.currentData[deleg.uniqueId][1] = text
                                set_exsh.currentDataChanged()
                            }
                        }
                        PQButton {
                            y: (parent.height-height)/2
                            text: "..."
                            onClicked: {

                                var p = "/usr/bin/"
                                if(PQCScriptsConfig.amIOnWindows())
                                    p = PQCScriptsFilesPaths.getHomeDir()
                                else if(ext_exe.text.slice(0,1) === "/")
                                    p = PQCScriptsFilesPaths.getDir(ext_exe.text)

                                //: written on button in file picker to select an existing executable file
                                var file = PQCScriptsFilesPaths.openFileFromDialog(qsTranslate("settingsmanager", "Select"), p, [])

                                if(file === "")
                                    return

                                var fname = PQCScriptsFilesPaths.getFilename(file)

                                if(PQCScriptsFilesPaths.cleanPath(StandardPaths.findExecutable(fname)) === file)
                                    ext_exe.text = fname
                                else
                                    ext_exe.text = PQCScriptsFilesPaths.cleanPath(file)

                            }
                        }
                    }
                    Row {
                        spacing: 5
                        PQText {
                            y: (parent.height-height)/2
                            text: qsTranslate("settingsmanager", "additional flags:")
                        }
                        PQLineEdit {
                            text: deleg.flags
                            onTextChanged: {
                                set_exsh.currentData[deleg.uniqueId][2] = text
                                set_exsh.currentDataChanged()
                            }
                        }
                    }
                    PQCheckBox {
                        text: qsTranslate("settingsmanager", "quit after calling executable")
                        checked: (deleg.quit===1)
                        onCheckedChanged: {
                            set_exsh.currentData[deleg.uniqueId][3] = (checked ? 1 : 0)
                            set_exsh.currentDataChanged()
                        }
                    }

                    Row {

                        spacing: 10

                        PQButton {
                            id: addbutton
                            y: comboview.y + (comboview.height-height)/2
                            text: qsTranslate("settingsmanager", "add shortcut")
                            onClicked: {
                                PQCNotify.settingsmanagerSendCommand("newShortcut", [deleg.index])
                            }
                        }

                        ListView {

                            id: comboview

                            y: 5
                            width: deleg.width - addbutton.width - 10
                            height: 40

                            clip: true
                            orientation: ListView.Horizontal
                            boundsBehavior: ListView.StopAtBounds
                            spacing: 10

                            ScrollBar.horizontal: PQHorizontalScrollBar {}

                            model: deleg.combos.length

                            Connections {

                                target: PQCNotify

                                function onSettingsmanagerSendCommand(what : string, args : list<var>) {
                                    if(what === "newShortcut") {
                                        if(deleg.index === args[0] && args[1] === -1) {
                                            deleg.combos.push(args[2])
                                            deleg.combosChanged()
                                        }
                                    }
                                }

                            }

                            delegate:
                            Rectangle {

                                id: shdeleg

                                required property int modelData

                                // the current combo
                                property string combo: deleg.combos[modelData]
                                onComboChanged: {
                                    if(combo !== deleg.combos[modelData]) {
                                        deleg.combos[modelData] = combo
                                        deleg.combosChanged()
                                    }
                                }

                                width: combotxt.width + del_button.width +14 + (mult_loader.active ? mult_loader.width : 0)
                                height: parent.height

                                border.width: 1
                                border.color: PQCLook.baseBorder
                                radius: 5

                                color: changemouse.containsMouse ? PQCLook.baseBorder : pqtPalette.alternateBase

                                Rectangle {
                                    id: greenbg
                                    anchors.fill: parent
                                    color: "green"
                                    opacity: 0.1
                                    visible: mult_loader.active
                                    SequentialAnimation {
                                        running: greenbg.visible
                                        loops: SequentialAnimation.Infinite
                                        NumberAnimation {
                                            target: greenbg
                                            property: "opacity"
                                            duration: 750
                                            from: 0.1
                                            to: 0.3
                                        }
                                        NumberAnimation {
                                            target: greenbg
                                            property: "opacity"
                                            duration: 750
                                            from: 0.3
                                            to: 0.1
                                        }
                                    }
                                }

                                Loader {
                                    id: mult_loader
                                    active: set_exsh.duplicateCombos.indexOf(shdeleg.combo)>-1
                                    x: 5
                                    y: (shdeleg.height-height)/2
                                    // opacity: 0.2
                                    width: 10
                                    height: 10
                                    sourceComponent:
                                    Image {
                                        width: 10
                                        height: 10
                                        sourceSize: Qt.size(width, height)
                                        source: "image://svgcolor/green:://:::/light/zoomin.svg"
                                    }
                                }

                                // the combo text
                                PQText {
                                    id: combotxt
                                    x: 10 + (mult_loader.active ? mult_loader.width : 0)
                                    y: (shdeleg.height-height)/2
                                    text: PQCScriptsShortcuts.translateShortcut(shdeleg.combo)
                                }

                                PQMouseArea {
                                    id: changemouse
                                    anchors.fill: parent
                                    tooltip: qsTranslate("settingsmanager", "Click to change shortcut")
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PQCNotify.settingsmanagerSendCommand("changeShortcut", [shdeleg.combo, deleg.index, shdeleg.modelData])
                                    }
                                }

                                Image {
                                    id: del_button
                                    x: combotxt.width + (mult_loader.active ? mult_loader.width: 0) + 12
                                    y: 2
                                    width: 15
                                    height: 15
                                    opacity: entrymouse.containsMouse ? 0.3 : 0.1
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    sourceSize: Qt.size(width, height)
                                    source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 10
                                        color: "red"
                                        z: -1
                                        opacity: 1
                                    }
                                    PQMouseArea {
                                        id: entrymouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        tooltip: qsTranslate("settingsmanager", "Delete?")
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            deleg.combos = deleg.combos.filter(item => item !== shdeleg.combo)
                                        }
                                    }
                                }

                                Connections {

                                    target: PQCNotify

                                    function onSettingsmanagerSendCommand(what : string, args : list<var>) {
                                        if(what === "newShortcut") {
                                            if(deleg.index === args[0] && shdeleg.modelData === args[1]) {
                                                shdeleg.combo = args[2]
                                                set_exsh.calculateDuplicates()
                                            }
                                        }
                                    }

                                }

                            }

                            // this is only visible if not combo was set for this action yet
                            PQText {
                                visible: deleg.combos.length===0
                                y: (parent.height-height)/2
                                color: pqtPaletteDisabled.text
                                text: qsTranslate("settingsmanager", "no key combination set")
                                font.weight: PQCLook.fontWeightBold
                                opacity: 0.5
                            }
                        }

                    }

                }

                Image {
                    id: del_ext
                    x: parent.width-width-5
                    y: 5
                    width: 25
                    height: 25
                    opacity: delextmouse.containsMouse ? 0.3 : 0.1
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: "red"
                        z: -1
                        opacity: 1
                    }
                    PQMouseArea {
                        id: delextmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        tooltip: qsTranslate("settingsmanager", "Delete?")
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var newCurrentData = ({})
                            for(var key in set_exsh.currentData) {
                                if(key !== deleg.uniqueId)
                                    newCurrentData[key] = set_exsh.currentData[key]
                            }
                            set_exsh.currentData = newCurrentData
                            extmodel.remove(deleg.index, 1)
                        }
                    }
                }

            }

        }

    ]

    function calculateDuplicates() {

        duplicateCombos = []

        var allsh = []

        for(var cmd in currentData) {
            var combos = currentData[cmd][0]
            for(var i in combos) {
                var c = combos[i]
                // if we also have an internal command set for this combo then we have it at least twice (internal and here, external)
                if(PQCShortcuts.getNumberInternalCommandsForShortcut(c) > 0) {
                    allsh.push(c)
                    if(duplicateCombos.indexOf(c) == -1)
                        duplicateCombos.push(c)
                } else {
                    if(allsh.indexOf(c) > -1) {
                        if(duplicateCombos.indexOf(c) == -1)
                            duplicateCombos.push(c)
                    } else
                        allsh.push(c)
                }
            }
        }

        duplicateCombosChanged()

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = !PQF.areTwoDictofListsEqual(currentData, defaultData)

    }

    function load() {

        settingsLoaded = false

        extmodel.clear()

        var allsh = PQCShortcuts.getAllCurrentShortcuts()

        var handledCmd = []

        for(var i in allsh) {

            var dat = allsh[i]
            var allcmd = dat[1]

            for(var j in allcmd) {
                if((allcmd[j][0] !== "_" || allcmd[j][1] !== "_") && !handledCmd.includes(allcmd[j])) {
                    var parts = allcmd[j].split(":/:/:")
                    var combos = PQCShortcuts.getShortcutsForCommand(allcmd[j])
                    var uniqueid = allcmd[j]+"_"+steadyCounter
                    defaultData[uniqueid] = [combos, parts[0], parts[1], parseInt(parts[2])]
                    currentData[uniqueid] = [combos, parts[0], parts[1], parseInt(parts[2])]
                    extmodel.append({"cmd": parts[0], "flags" : parts[1], "quit": parseInt(parts[2]), "_combos": combos.join(":://::"), "uniqueId": uniqueid})
                    handledCmd.push(allcmd[j])
                    steadyCounter += 1
                }
            }
        }

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var lst = []
        for(var i in currentData) {
            lst.push(currentData[i])
        }
        PQCShortcuts.saveExternalShortcutCombos(lst)

        PQCConstants.settingsManagerSettingChanged = false

    }

}
