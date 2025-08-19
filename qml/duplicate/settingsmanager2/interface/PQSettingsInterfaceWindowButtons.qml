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

    id: set_windowbuttons

    SystemPalette { id: pqtPalette }

    property list<string> curEntries: []
    property list<string> defaultEntries: []

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Window buttons")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show various integrated window buttons in the top right corner of the window. In addition to all standard window buttons several custom buttons are available, for instance navigation buttons for the current folder. Here the buttons can be arranged in any order. A context menu for each entry offers options to only show a button in fullscreen or when windowed, or to keep it above any other window.")

        },

        PQCheckBox {
            id: integbut_show
            enforceMaxWidth: set_windowbuttons.contentWidth
            text: qsTranslate("settingsmanager", "enable integrated window buttons")
            onCheckedChanged: set_windowbuttons.checkForChanges()
        },

        Rectangle {
            enabled: integbut_show.checked
            width: set_windowbuttons.contentWidth-5
            radius: 5
            clip: true

            height: 60+(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)
            opacity: enabled ? 1 : 0.8
            Behavior on opacity { NumberAnimation { duration: 150 } }

            color: pqtPalette.alternateBase
            ListView {

                id: avail

                x: 5
                y: 5

                width: set_windowbuttons.contentWidth-10
                height: parent.height-10

                opacity: enabled ? 1 : 0.1

                clip: true
                orientation: ListView.Horizontal
                spacing: 5

                ScrollBar.horizontal: PQHorizontalScrollBar { id: scrollbar }

                property int dragItemIndex: -1

                property list<int> widths: []

                property var disp: {
                    "left" : "leftarrow",
                    "right" : "rightarrow",
                    "menu" : "menu",
                    "ontop" : "keepforeground",
                    "fullscreen" : "fullscreen_on",
                    "minimize" : (PQCScriptsConfig.amIOnWindows() ? "windows-minimize" : "minimize"),
                    "maximize" : (PQCScriptsConfig.amIOnWindows() ? "windows-maximize" : "maximize"),
                    "close" : "close"
                }

                model: ListModel {
                    id: model
                }

                delegate: Item {

                    id: deleg

                    width: Math.max.apply(Math, avail.widths)
                    height: avail.height-(scrollbar.size<1.0 ? (scrollbar.height+5) : 0)

                    required property int index
                    required property string component
                    required property bool fullscreenonly
                    required property bool windowedonly
                    required property bool alwaysontop

                    property bool hasBeenSetup: false
                    Timer {
                        interval: 500
                        running: true
                        onTriggered:
                            deleg.hasBeenSetup = true
                    }

                    onFullscreenonlyChanged: {
                        if(!hasBeenSetup) return
                        var entry = set_windowbuttons.curEntries[index]
                        var parts = entry.split("_")[1].split("|")
                        var newfs = (fullscreenonly ? "1" : "0")
                        if(newfs === parts[0]) return
                        set_windowbuttons.curEntries[index] = entry.split("_")[0] + "_" + newfs + "|" + parts[1] + "|" + parts[2]
                        set_windowbuttons.populateModel()
                        set_windowbuttons.checkForChanges()
                    }
                    onWindowedonlyChanged: {
                        if(!hasBeenSetup) return
                        var entry = set_windowbuttons.curEntries[index]
                        var parts = entry.split("_")[1].split("|")
                        var newwm = (windowedonly ? "1" : "0")
                        if(newwm === parts[1]) return
                        set_windowbuttons.curEntries[index] = entry.split("_")[0] + "_" + parts[0] + "|" + newwm + "|" + parts[2]
                        set_windowbuttons.populateModel()
                        set_windowbuttons.checkForChanges()
                    }
                    onAlwaysontopChanged: {
                        if(!hasBeenSetup) return
                        var entry = set_windowbuttons.curEntries[index]
                        var parts = entry.split("_")[1].split("|")
                        var newot = (alwaysontop ? "1" : "0")
                        if(newot === parts[2]) return
                        set_windowbuttons.curEntries[index] = entry.split("_")[0] + "_" + parts[0] + "|" + parts[1] + "|" + newot
                        set_windowbuttons.populateModel()
                        set_windowbuttons.checkForChanges()
                    }

                    Rectangle {
                        id: dragRect
                        width: deleg.width
                        height: deleg.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: pqtPalette.base
                        radius: 5
                        Image {
                            id: txt
                            x: (deleg.width-width)/2
                            y: deleg.height*0.1
                            width: deleg.height*0.75
                            height: deleg.height*0.75
                            source: "image://svg/:/" + PQCLook.iconShade + "/" + avail.disp[deleg.component] + ".svg"
                            sourceSize: Qt.size(width, height)
                            onWidthChanged: {
                                avail.widths.push(width+20)
                                avail.widthsChanged()
                            }
                        }
                        Image {
                            x: parent.width-width-3
                            y: parent.height-height-3
                            visible: deleg.fullscreenonly||deleg.windowedonly
                            width: deleg.height*0.2
                            height: deleg.height*0.2
                            source: "image://svg/:/" + PQCLook.iconShade + (deleg.fullscreenonly ? "/fullscreen_on.svg" : "/computer.svg")
                            sourceSize: Qt.size(width, height)
                        }
                        Image {
                            x: 3
                            y: parent.height-height-3
                            width: deleg.height*0.2
                            height: deleg.height*0.2
                            visible: deleg.alwaysontop
                            source: "image://svg/:/" + PQCLook.iconShade + "/thumbnail.svg"
                            sourceSize: Qt.size(width, height)
                        }
                        PQMenu {
                            id: itemmenu
                            PQMenuItem {
                                id: chk_fs
                                checkable: true
                                //: context menu entry, please keep short!
                                text: qsTranslate("settingsmanager", "only in fullscreen")
                                onCheckedChanged: {
                                    if(checked)
                                        chk_wm.checked = false
                                    if(deleg.fullscreenonly !== checked)
                                        deleg.fullscreenonly = checked
                                    set_windowbuttons.checkForChanges()
                                }
                            }
                            PQMenuItem {
                                id: chk_wm
                                checkable: true
                                //: context menu entry, please keep short! Windowed here is used as the opposite to fullscreen.
                                text: qsTranslate("settingsmanager", "only when windowed")
                                onCheckedChanged: {
                                    if(checked)
                                        chk_fs.checked = false
                                    if(deleg.windowedonly !== checked)
                                        deleg.windowedonly = checked
                                    set_windowbuttons.checkForChanges()
                                }
                            }

                            PQMenuSeparator {}

                            PQMenuItem {
                                id: chk_ot
                                checkable: true
                                //: context menu entry, please keep short!
                                text: qsTranslate("settingsmanager", "above everything else")
                                onCheckedChanged: {
                                    if(deleg.alwaysontop !== checked)
                                        deleg.alwaysontop = checked
                                    set_windowbuttons.checkForChanges()
                                }
                            }

                            onAboutToShow: {
                                chk_fs.checked = deleg.fullscreenonly
                                chk_wm.checked = deleg.windowedonly
                                chk_ot.checked = deleg.alwaysontop
                            }

                        }

                        PQMouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton|Qt.LeftButton
                            text: combo_add.statusdata_vals[combo_add.statusdata_keys.indexOf(deleg.component)]
                            drag.target: parent
                            drag.axis: Drag.XAxis
                            drag.onActiveChanged: {
                                if (mouseArea.drag.active) {
                                    avail.dragItemIndex = deleg.index;
                                }
                                dragRect.Drag.drop();
                                if(!mouseArea.drag.active) {
                                    set_windowbuttons.populateModel()
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
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.RightButton) {
                                    itemmenu.popup(0, deleg.height)
                                }
                            }
                        }
                        states: [
                            State {
                                when: dragRect.Drag.active
                                ParentChange {
                                    target: dragRect
                                    parent: set_windowbuttons.parent
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
                        Drag.hotSpot.y: 0

                        Image {

                            x: parent.width-width
                            y: 0
                            width: 20
                            height: 20

                            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                            sourceSize: Qt.size(width, height)

                            opacity: closemouse.containsMouse ? 0.8 : 0.2
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            PQMouseArea {
                                id: closemouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    set_windowbuttons.curEntries.splice(deleg.index, 1)
                                    set_windowbuttons.populateModel()
                                    set_windowbuttons.checkForChanges()
                                }
                            }

                        }

                    }

                }
            }

            DropArea {
                id: dropArea
                anchors.fill: parent
                onPositionChanged: (drag) => {
                    var newindex = avail.indexAt(drag.x, drag.y)
                    if(newindex !== -1 && newindex !== avail.dragItemIndex) {

                        // we move the entry around in the list for the populate call later
                        var element = set_windowbuttons.curEntries[avail.dragItemIndex];
                        set_windowbuttons.curEntries.splice(avail.dragItemIndex, 1);
                        set_windowbuttons.curEntries.splice(newindex, 0, element);

                        avail.model.move(avail.dragItemIndex, newindex, 1)
                        avail.dragItemIndex = newindex
                        set_windowbuttons.checkForChanges()
                    }
                }
            }
        },

        PQText {
            id: helpmsg
            enabled: integbut_show.checked
            opacity: enabled ? 1 : 0.8
            Behavior on opacity { NumberAnimation { duration: 150 } }
            text: qsTranslate("settingsmanager", "(a right click on an entry shows more options)")
        },

        Row {
            enabled: integbut_show.checked
            spacing: 10

            height: combo_add.height
            opacity: enabled ? 1 : 0.8
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQComboBox {
                id: combo_add
                y: (but_add.height-height)/2
                property list<string> statusdata_keys: [
                    "left",
                    "right",
                    "menu",
                    "ontop",
                    "fullscreen",
                    "minimize",
                    "maximize",
                    "close"
                ]
                property list<string> statusdata_vals: [
                    //: Please keep short!
                    qsTranslate("settingsmanager", "previous image"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "next image"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "main menu"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "keep window on top"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "toggle fullscreen"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "minimize window"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "maximize window"),
                    //: Please keep short!
                    qsTranslate("settingsmanager", "close window")
                ]
                model: statusdata_vals
            }
            PQButton {
                id: but_add
                //: This is written on a button that is used to add a selected block to the status info section.
                text: qsTranslate("settingsmanager", "add")
                smallerVersion: true
                onClicked: {
                    set_windowbuttons.curEntries.push(combo_add.statusdata_keys[combo_add.currentIndex]+"_0|0|1")
                    set_windowbuttons.populateModel()
                    set_windowbuttons.checkForChanges()
                }
            }
        },

        Column {

            id: winbutcol

            width: set_windowbuttons.contentWidth
            spacing: 10

            enabled: integbut_show.checked
            opacity: enabled ? 1 : 0.8
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQSliderSpinBox {
                id: butsize
                width: set_windowbuttons.contentWidth
                minval: 5
                maxval: 50
                title: qsTranslate("settingsmanager", "Size:")
                suffix: " px"
                onValueChanged:
                    set_windowbuttons.checkForChanges()
            }

            Item {
                width: 1
                height: 1
            }

            PQCheckBox {
                id: wb_followaccent
                //: These buttons are the WINDOW BUTTONS specifically!
                text: qsTranslate("settingsmanager", "Color scheme of buttons follows accent color")
                onCheckedChanged:
                    set_windowbuttons.checkForChanges()
            }

            PQSettingSubtitle {
                x: -set_windowbuttons.indentWidth
                title: qsTranslate("settingsmanager", "Visibility")
            }

            PQRadioButton {
                id: autohide_always
                enforceMaxWidth: set_windowbuttons.contentWidth
                //: visibility status of the window buttons
                text: qsTranslate("settingsmanager", "keep always visible")
                onCheckedChanged: set_windowbuttons.checkForChanges()
            }

            PQRadioButton {
                id: autohide_anymove
                enforceMaxWidth: set_windowbuttons.contentWidth
                //: visibility status of the window buttons
                text: qsTranslate("settingsmanager", "only show with any cursor move")
                onCheckedChanged: set_windowbuttons.checkForChanges()
            }

            PQRadioButton {
                id: autohide_topedge
                enforceMaxWidth: set_windowbuttons.contentWidth
                //: visibility status of the window buttons
                text: qsTranslate("settingsmanager", "only show when cursor near top edge")
                onCheckedChanged: set_windowbuttons.checkForChanges()
            }

            PQSliderSpinBox {
                id: autohide_timeout
                width: set_windowbuttons.contentWidth
                minval: 0
                maxval: 10
                title: qsTranslate("settingsmanager", "hide again after timeout:")
                suffix: " s"
                enabled: !autohide_always.checked
                animateHeight: true
                onValueChanged:
                    set_windowbuttons.checkForChanges()
            }

        }

    ]

    onResetToDefaults: {

        integbut_show.checked = PQCSettings.getDefaultForInterfaceWindowButtonsShow()
        butsize.setValue(PQCSettings.getDefaultForInterfaceWindowButtonsSize())
        set_windowbuttons.curEntries = PQCSettings.getDefaultForInterfaceWindowButtonsItems()
        populateModel()

        wb_followaccent.checked = PQCSettings.getDefaultForInterfaceWindowButtonsFollowAccentColor()

        var valAutoHide = PQCSettings.getDefaultForInterfaceWindowButtonsAutoHide()
        var valAutoHideTop = PQCSettings.getDefaultForInterfaceWindowButtonsAutoHideTopEdge()
        var valAutoHideTimeout = PQCSettings.getDefaultForInterfaceWindowButtonsAutoHideTimeout()
        autohide_always.checked = (valAutoHide===0 && valAutoHideTop===0)
        autohide_anymove.checked = (valAutoHide===1 && valAutoHideTop===0)
        autohide_topedge.checked = (valAutoHideTop===1)
        autohide_timeout.setValue(valAutoHideTimeout/1000)

    }

    function handleEscape() {
        butsize.acceptValue()
        autohide_timeout.acceptValue()
    }

    function checkForChanges() {
        if(!settingsLoaded) return
        PQCConstants.settingsManagerSettingChanged = (integbut_show.hasChanged() || butsize.hasChanged() ||
                                                      !PQF.areTwoListsEqual(set_windowbuttons.curEntries, PQCSettings.interfaceWindowButtonsItems) ||
                                                      autohide_topedge.hasChanged() || autohide_anymove.hasChanged() || autohide_always.hasChanged() ||
                                                      autohide_timeout.hasChanged() || wb_followaccent.hasChanged())
    }

    function load() {

        settingsLoaded = false

        integbut_show.loadAndSetDefault(PQCSettings.interfaceWindowButtonsShow)
        butsize.loadAndSetDefault(PQCSettings.interfaceWindowButtonsSize)
        set_windowbuttons.curEntries = PQCSettings.interfaceWindowButtonsItems
        populateModel()

        wb_followaccent.loadAndSetDefault(PQCSettings.interfaceWindowButtonsFollowAccentColor)

        autohide_always.loadAndSetDefault(!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_anymove.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_topedge.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
        autohide_timeout.loadAndSetDefault(PQCSettings.interfaceWindowButtonsAutoHideTimeout/1000)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceWindowButtonsShow = integbut_show.checked
        PQCSettings.interfaceWindowButtonsItems = set_windowbuttons.curEntries
        PQCSettings.interfaceWindowButtonsSize = butsize.value

        PQCSettings.interfaceWindowButtonsFollowAccentColor = wb_followaccent.checked

        PQCSettings.interfaceWindowButtonsAutoHide = (autohide_anymove.checked || autohide_topedge.checked)
        PQCSettings.interfaceWindowButtonsAutoHideTopEdge = autohide_topedge.checked
        PQCSettings.interfaceWindowButtonsAutoHideTimeout = autohide_timeout.value*1000

        integbut_show.saveDefault()
        butsize.saveDefault()

        wb_followaccent.saveDefault()

        autohide_always.saveDefault()
        autohide_anymove.saveDefault()
        autohide_topedge.saveDefault()
        autohide_timeout.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function populateModel() {
        model.clear()
        for(var j = 0; j < set_windowbuttons.curEntries.length; ++j) {
            var val = set_windowbuttons.curEntries[j]
            var comp = val.split("_")[0]
            var parts = val.split("_")[1].split("|")
            var fs = (parts[0]==="1")
            var wm = (parts[1]==="1")
            var ot = (parts[2]==="1")
            model.append({"component": comp, "index": j, "fullscreenonly" : fs, "windowedonly" : wm, "alwaysontop" : ot})
        }
    }

}
