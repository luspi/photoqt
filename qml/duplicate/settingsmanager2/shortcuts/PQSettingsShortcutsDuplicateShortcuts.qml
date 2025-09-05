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
import QtQuick.Controls
import "../../other/PQCommonFunctions.js" as PQF
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_dush

    disabledAutoIndentation: true
    addBlankSpaceBottom: false

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property var currentData: ({})
    property var defaultData: ({})

    onCurrentDataChanged:
        checkForChanges()

    content: [

        PQTextXL {
            text: qsTranslate("settingsmanager", "Duplicate shortcuts")
            font.capitalization: Font.SmallCaps
            font.weight: PQCLook.fontWeightBold
        },

        PQText {
            width: set_dush.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager", "In PhotoQt, a key or mouse combination can be used for more than one shortcut action. In such a situation, PhotoQt by default loops through the actions one by one each time the shortcut is triggered. Alternatively, all shortcut actions can be executed at the same time each time the shortcut is triggered. That behavior, and the order of the shortcuts (drag-and-drop of the entries) can be configured here. If you want to edit the key or mouse combinations or the associated shortcut actions, you can do so by visiting the other tabs on the left.")
        },

        ListView {

            id: dupview

            width: set_dush.width
            height: set_dush.availableHeight - dupview.y

            spacing: 10
            clip: true

            model: ListModel { id: dupmodel }

            // this ensures all entries are always set up
            cacheBuffer: dupmodel.count*60

            ScrollBar.vertical: PQVerticalScrollBar {}

            PQTextXL {
                x: (parent.width-width)/2
                y: parent.height*0.15
                visible: dupmodel.count===0
                text: qsTranslate("settingsmanager", "no duplicate shortcuts found")
                color: pqtPaletteDisabled.text
                font.weight: PQCLook.fontWeightBold
            }

            delegate:
            Rectangle {

                id: deleg

                required property int index
                required property string combo
                required property string _cmds
                required property int cycle
                required property int cycletimeout

                property list<string> cmds: _cmds.split(":://::")

                onCmdsChanged: {
                    set_dush.currentData[combo][0] = cmds
                    set_dush.currentDataChanged()
                }

                width: dupview.width
                height: contcol.height+20

                border.width: 1
                border.color: PQCLook.baseBorder
                radius: 5

                clip: true
                color: pqtPalette.base

                Column {

                    id: contcol
                    spacing: 5

                    Item {
                        width: deleg.width
                        height: shtxt.height+10
                        Rectangle {
                            anchors.fill: parent
                            color: pqtPalette.text
                            opacity: 0.6
                            radius: 5
                        }
                        PQTextL {
                            id: shtxt
                            x: 10
                            y: 5
                            color: pqtPalette.base
                            text: deleg.combo
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    Flow {
                        x: 5
                        width: deleg.width-10
                        spacing: 10
                        Item {
                            width: cycle_check.width
                            height: timeout_spin.height
                            PQRadioButton {
                                id: cycle_check
                                ButtonGroup { id: grpwhattodo }
                                y: (parent.height-height)/2
                                text: qsTranslate("settingsmanager", "cycle through actions one by one")
                                checked: deleg.cycle==1
                                ButtonGroup.group: grpwhattodo
                                onCheckedChanged: {
                                    set_dush.currentData[deleg.combo][1] = (cycle_check.checked ? 1 : 0)
                                    set_dush.currentDataChanged()
                                }
                            }
                        }
                        Text {
                            height: timeout_spin.height
                            text: "|"
                            verticalAlignment: Text.AlignVCenter
                        }

                        PQSliderSpinBox {
                            id: timeout_spin
                            enabled: cycle_check.checked
                            minval: 0
                            maxval: 10
                            suffix: "s"
                            title: qsTranslate("settingsmanager", "reset after:")
                            value: deleg.cycletimeout
                            overrideMinValText: "no timeout"
                            onValueChanged: {
                                set_dush.currentData[deleg.combo][2] = timeout_spin.value
                                set_dush.currentDataChanged()
                            }
                        }
                    }

                    PQRadioButton {
                        x: 5
                        enforceMaxWidth: deleg.width-10
                        text: qsTranslate("settingsmanager", "run all actions at once")
                        ButtonGroup.group: grpwhattodo
                        checked: deleg.cycle==0
                        // we don't need to listen for onCheckedChanged here as this is covered by cycle_check
                    }

                    ListView {

                        id: entryview

                        x: 5
                        width: deleg.width-10
                        height: Math.min(200, deleg.cmds.length*50 + (deleg.cmds.length-1)*spacing)

                        model: ListModel { id: entrymodel }
                        spacing: 5

                        Component.onCompleted: {
                            setupModel()
                        }

                        function setupModel() {
                            entrymodel.clear()
                            for(var i in deleg.cmds)
                                entrymodel.append({"cmd" : deleg.cmds[i]})
                        }

                        property int dragItemIndex: -1

                        ScrollBar.vertical: PQVerticalScrollBar {}

                        delegate:
                        Item {

                            id: entrydeleg

                            required property int index
                            required property string cmd

                            width: deleg.width-10
                            height: 50

                            Rectangle {

                                id: dragRect

                                width: entrydeleg.width
                                height: entrydeleg.height

                                color: pqtPalette.alternateBase

                                Row {
                                    spacing: 5

                                    Item {
                                        width: 1
                                        height: 1
                                    }

                                    Image {
                                        y: (entrydeleg.height-height)/2
                                        width: 20
                                        height: 20
                                        rotation: 90
                                        opacity: 0.3
                                        sourceSize: Qt.size(width, height)
                                        smooth: true
                                        mipmap: true
                                        source: "image://svg/:/" + PQCLook.iconShade + "/draghandler.svg"
                                    }

                                    PQText {
                                        x: 5
                                        y: (entrydeleg.height-height)/2
                                        font.weight: PQCLook.fontWeightBold
                                        text: (entrydeleg.index+1) + ". " + set_dush.getFullNameForShortcut(entrydeleg.cmd)
                                    }
                                }

                                PQMouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                                    text: qsTranslate("settingsmanager", "click and drag to reorder")
                                    drag.target: parent
                                    drag.axis: Drag.YAxis
                                    drag.onActiveChanged: {
                                        if(mouseArea.drag.active) {
                                            entryview.dragItemIndex = entrydeleg.index;
                                        }
                                        dragRect.Drag.drop();
                                        if(!mouseArea.drag.active) {
                                            // we need to reset this as we use this to ensure a drop event originates from an item from the same view
                                            entryview.dragItemIndex = -1
                                        }
                                    }
                                    cursorShape: Qt.OpenHandCursor
                                    onPressed: (mouse) => {
                                        if(mouse.button === Qt.LeftButton)
                                            cursorShape = Qt.ClosedHandCursor
                                    }
                                    onReleased: (mouse) => {
                                        if(mouse.button === Qt.LeftButton)
                                            cursorShape = Qt.OpenHandCursor
                                    }
                                }

                                states: [
                                    State {
                                        when: dragRect.Drag.active
                                        ParentChange {
                                            target: dragRect
                                            parent: entryview
                                        }

                                        AnchorChanges {
                                            target: dragRect
                                            anchors.horizontalCenter: undefined
                                            anchors.verticalCenter: undefined
                                        }
                                    }
                                ]

                                Drag.active: mouseArea.drag.active
                                Drag.hotSpot.x: 0
                                Drag.hotSpot.y: entrydeleg.height/2

                            }

                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            onPositionChanged: (drag) => {

                                // this ensures the dragged item originated in THIS view and not another one
                                if(entryview.dragItemIndex === -1) return

                                var newindex = entryview.indexAt(drag.x, drag.y)

                                if(newindex !== -1 && newindex !== entryview.dragItemIndex) {

                                    var element = deleg.cmds[entryview.dragItemIndex];
                                    deleg.cmds.splice(entryview.dragItemIndex, 1);
                                    deleg.cmds.splice(newindex, 0, element);

                                    entryview.model.move(entryview.dragItemIndex, newindex, 1)
                                    entryview.dragItemIndex = newindex

                                    deleg.cmdsChanged()

                                }
                            }
                        }

                    }

                }

            }

        }

    ]

    function getFullNameForShortcut(cmd : string) : string {

        // external shortcut
        if(cmd[0] !== "_" || cmd[1] !== "_") {
            var parts = cmd.split(":/:/:")
            return parts[0] + " " + parts[1] + " (" + (parseInt(parts[2])===0 ? "don't" : "") + "quit)"
        }

        // check for internal shortcut name
        for(var i in PQCConstants.settingsManagerCacheShortcutNames) {

            if(PQCConstants.settingsManagerCacheShortcutNames[i][0] === cmd)
                return PQCConstants.settingsManagerCacheShortcutNames[i][1]

        }

        return cmd

    }

    onResetToDefaults: {


        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        for(var combo in currentData) {

            if(!PQF.areTwoListsEqual(currentData[combo][0], defaultData[combo][0]) ||
                    currentData[combo][1] !== defaultData[combo][1] ||
                    currentData[combo][2] !== defaultData[combo][2]) {
                PQCConstants.settingsManagerSettingChanged = true
                return
            }

        }

        PQCConstants.settingsManagerSettingChanged = false

    }

    function load() {

        settingsLoaded = false

        dupmodel.clear()
        currentData = []
        defaultData = []

        var allsh = PQCShortcuts.getAllCurrentShortcuts()
        for(var i in allsh) {

            var dat = allsh[i]
            var combos = dat[0]
            var cmds = dat[1]
            var cycle = parseInt(dat[2])
            var cycletimeout = parseInt(dat[3])

            if(cmds.length > 1) {

                for(var iC in combos) {
                    var combo = combos[iC]
                    currentData[combo] = [cmds, cycle, cycletimeout]
                    defaultData[combo] = [cmds, cycle, cycletimeout]
                    dupmodel.append({"combo" : combo, "_cmds" : cmds.join(":://::"), "cycle" : cycle, "cycletimeout" : cycletimeout})
                }

            }

        }

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var lst = []
        for(var i in currentData) {
            var cur = [i, currentData[i][0], currentData[i][1], currentData[i][2]]
            lst.push(cur)
        }

        PQCShortcuts.saveDuplicateShortcutsCommandOrder(lst)

        PQCConstants.settingsManagerSettingChanged = false

    }

}
