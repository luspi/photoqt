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

import "./shortcuts"
import "../../elements"
import "../../modal"

Item {

    id: tab_shortcuts

    property var actions: {

        // IMAGE VIEWING

                                 //: Name of shortcut action
        "__next":               [em.pty+qsTranslate("settingsmanager", "Next image"), "viewingimages"],
                                 //: Name of shortcut action
        "__prev":               [em.pty+qsTranslate("settingsmanager", "Previous image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToFirst":          [em.pty+qsTranslate("settingsmanager", "Go to first image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToLast":           [em.pty+qsTranslate("settingsmanager", "Go to last image"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomIn":             [em.pty+qsTranslate("settingsmanager", "Zoom In"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomOut":            [em.pty+qsTranslate("settingsmanager", "Zoom Out"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomActual":         [em.pty+qsTranslate("settingsmanager", "Zoom to Actual Size"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomReset":          [em.pty+qsTranslate("settingsmanager", "Reset Zoom"), "viewingimages"],
                                 //: Name of shortcut action
        "__rotateR":            [em.pty+qsTranslate("settingsmanager", "Rotate Right"), "viewingimages"],
                                 //: Name of shortcut action
        "__rotateL":            [em.pty+qsTranslate("settingsmanager", "Rotate Left"), "viewingimages"],
                                 //: Name of shortcut action
        "__rotate0":            [em.pty+qsTranslate("settingsmanager", "Reset Rotation"), "viewingimages"],
                                 //: Name of shortcut action
        "__flipH":              [em.pty+qsTranslate("settingsmanager", "Flip Horizontally"), "viewingimages"],
                                 //: Name of shortcut action
        "__flipV":              [em.pty+qsTranslate("settingsmanager", "Flip Vertically"), "viewingimages"],
                                 //: Name of shortcut action
        "__loadRandom":         [em.pty+qsTranslate("settingsmanager", "Load a random image"), "viewingimages"],
                                 //: Name of shortcut action
        "__showFaceTags":       [em.pty+qsTranslate("settingsmanager", "Hide/Show face tags (stored in metadata)"), "viewingimages"],
                                 //: Name of shortcut action
        "__fitInWindow":        [em.pty+qsTranslate("settingsmanager", "Toggle 'Fit in window'"), "viewingimages"],
                                 //: Name of shortcut action
        "__toggleAlwaysActualSize": [em.pty+qsTranslate("settingsmanager", "Toggle: Show always actual size by default"), "viewingimages"],
                                 //: Name of shortcut action
        "__chromecast":         [em.pty+qsTranslate("settingsmanager", "Stream content to Chromecast device"), "viewingimages"],


        // SPECIAL ACTION WITH CURRENT IMAGE

                                 //: Name of shortcut action
        "__histogram":          [em.pty+qsTranslate("settingsmanager", "Show Histogram"), "currentimage"],
                                 //: Name of shortcut action
        "__viewerMode":         [em.pty+qsTranslate("settingsmanager", "Enter viewer mode"), "currentimage"],
                                 //: Name of shortcut action
        "__scale":              [em.pty+qsTranslate("settingsmanager", "Scale Image"), "currentimage"],
                                 //: Name of shortcut action
        "__rename":             [em.pty+qsTranslate("settingsmanager", "Rename File"), "currentimage"],
                                 //: Name of shortcut action
        "__delete":             [em.pty+qsTranslate("settingsmanager", "Delete File"), "currentimage"],
                                 //: Name of shortcut action
        "__deletePermanent":    [em.pty+qsTranslate("settingsmanager", "Delete File (without confirmation)"), "currentimage"],
                                 //: Name of shortcut action
        "__copy":               [em.pty+qsTranslate("settingsmanager", "Copy File to a New Location"), "currentimage"],
                                 //: Name of shortcut action
        "__move":               [em.pty+qsTranslate("settingsmanager", "Move File to a New Location"), "currentimage"],
                                 //: Name of shortcut action
        "__clipboard":          [em.pty+qsTranslate("settingsmanager", "Copy Image to Clipboard"), "currentimage"],
                                 //: Name of shortcut action
        "__saveAs":             [em.pty+qsTranslate("settingsmanager", "Save image in another format"), "currentimage"],
                                 //: Name of shortcut action
        "__print":              [em.pty+qsTranslate("settingsmanager", "Print current photo"), "currentimage"],
                                 //: Name of shortcut action
        "__wallpaper":          [em.pty+qsTranslate("settingsmanager", "Set as Wallpaper"), "currentimage"],
                                 //: Name of shortcut action
        "__imgurAnonym":        [em.pty+qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)"), "currentimage"],
                                 //: Name of shortcut action
        "__imgur":              [em.pty+qsTranslate("settingsmanager", "Upload to imgur.com user account"), "currentimage"],
                                 //: Name of shortcut action
        "__playPauseAni":       [em.pty+qsTranslate("settingsmanager", "Play/Pause animation/video"), "currentimage"],


        // ACTION WITH CURRENT FOLDER

                                //: Name of shortcut action
        "__open":               [em.pty+qsTranslate("settingsmanager", "Open file (browse images)"), "currentfolder"],
                                //: Name of shortcut action
        "__filterImages":       [em.pty+qsTranslate("settingsmanager", "Filter images in folder"), "currentfolder"],
                                 //: Name of shortcut action
        "__advancedSort":       [em.pty+qsTranslate("settingsmanager", "Advanced image sort (Setup)"), "currentfolder"],
                                 //: Name of shortcut action
        "__advancedSortQuick":  [em.pty+qsTranslate("settingsmanager", "Advanced image sort (Quickstart)"), "currentfolder"],
                                 //: Name of shortcut action
        "__slideshow":          [em.pty+qsTranslate("settingsmanager", "Start Slideshow (Setup)"), "currentfolder"],
                                 //: Name of shortcut action
        "__slideshowQuick":     [em.pty+qsTranslate("settingsmanager", "Start Slideshow (Quickstart)"), "currentfolder"],


        // INTERFACE

                                 //: Name of shortcut action
        "__contextMenu":        [em.pty+qsTranslate("settingsmanager", "Show Context Menu"), "interface"],
                                 //: Name of shortcut action
        "__showMainMenu":       [em.pty+qsTranslate("settingsmanager", "Hide/Show main menu"), "interface"],
                                 //: Name of shortcut action
        "__showMetaData":       [em.pty+qsTranslate("settingsmanager", "Hide/Show metadata"), "interface"],
                                 //: Name of shortcut action
        "__showThumbnails":     [em.pty+qsTranslate("settingsmanager", "Hide/Show thumbnails"), "interface"],
                                 //: Name of shortcut action
        "__navigationFloating": [em.pty+qsTranslate("settingsmanager", "Show floating navigation buttons"), "interface"],
                                 //: Name of shortcut action
        "__fullscreenToggle":   [em.pty+qsTranslate("settingsmanager", "Toggle fullscreen mode"), "interface"],
                                 //: Name of shortcut action
        "__close":              [em.pty+qsTranslate("settingsmanager", "Close window (hides to system tray if enabled)"), "interface"],
                                 //: Name of shortcut action
        "__quit":               [em.pty+qsTranslate("settingsmanager", "Quit PhotoQt"), "interface"],



        // OTHER ELEMENTS

                                //: Name of shortcut action
        "__settings":           [em.pty+qsTranslate("settingsmanager", "Show Settings"), "other"],
                                //: Name of shortcut action
        "__about":              [em.pty+qsTranslate("settingsmanager", "About PhotoQt"), "other"],
                                //: Name of shortcut action
        "__logging":            [em.pty+qsTranslate("settingsmanager", "Show log/debug messages"), "other"],
                                //: Name of shortcut action
        "__resetSession":       [em.pty+qsTranslate("settingsmanager", "Reset current session"), "other"],
                                //: Name of shortcut action
        "__resetSessionAndHide":[em.pty+qsTranslate("settingsmanager", "Reset current session and hide window"), "other"],

    }

    property var entries: []

    signal highlightEntry(var idx)

    Flickable {

        id: cont

        contentHeight: col.height
        onContentHeightChanged: {
            if(visible)
                settingsmanager_top.scrollBarVisible = scroll.visible
        }

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        maximumFlickVelocity: 1500
        boundsBehavior: Flickable.StopAtBounds

        Column {

            id: col

            x: 10

            spacing: 15

            Item {
                width: 1
                height: 1
            }

            PQTextXL {
                id: title
                width: cont.width-30
                horizontalAlignment: Text.AlignHCenter
                font.weight: baselook.boldweight
                text: em.pty+qsTranslate("settingsmanager", "Shortcuts")
            }

            Item {
                width: 1
                height: 1
            }

//            PQText {
//                id: desc
//                width: cont.width-30
//                wrapMode: Text.WordWrap
//                text: em.pty+qsTranslate("settingsmanager", "Here the shortcuts can be managed. Below you can add a new shortcut for any one of the available actions, both key combinations and mouse gestures are supported.") + "\n" + em.pty+qsTranslate("settingsmanager", "You can also set the same shortcut for multiple actions or multiple times for the same action. All actions for a shortcut will be executed sequentially, allowing a lot more flexibility in using PhotoQt.")
//            }

            PQHorizontalLine { expertModeOnly: dblclk.expertmodeonly }
            PQDoubleClick { id: dblclk }
            PQHorizontalLine { expertModeOnly: dblclk.expertmodeonly }

            ListView {

                id: entriesview

                width: cont.width
                height: childrenRect.height

                orientation: ListView.Vertical
                interactive: false

                model: tab_shortcuts.entries.length

                delegate: Rectangle {

                    id: deleg

                    width: cont.width
                    height: Math.max(ontheleft.height, ontheright.height)+behaviorcont.height

                    property var combos: tab_shortcuts.entries[index][0]
                    property var commands: tab_shortcuts.entries[index][1]
                    property int cycle: tab_shortcuts.entries[index][2]
                    property int cycletimeout: tab_shortcuts.entries[index][3]
                    property int simultaneous: tab_shortcuts.entries[index][4]

                    property int currentShortcutIndex: index

                    color: "#00000000"
                    Behavior on color {
                        SequentialAnimation {
                            loops: 5
                            ColorAnimation { from: "#00ffffff"; to: "#44ffffff"; duration: 500 }
                            ColorAnimation { from: "#44ffffff"; to: "#00ffffff"; duration: 500 }
                        }
                    }

                    Connections {
                        target: tab_shortcuts
                        onHighlightEntry: {
                            if(idx == deleg.currentShortcutIndex) {
                                deleg.color = "#44ffffff"
                            }
                        }
                    }

                    /************************/
                    // SHORTCUT COMBOS
                    Column {
                        id: ontheleft
                        y: (ontheright.height>height ? ((ontheright.height-height)/2) : 0)
                        width: 300

                        spacing: 5

                        // key combo strings
                        Flow {

                            width: parent.width

                            padding: 5

                            Repeater {
                                model: deleg.combos.length
                                delegate:

                                    Item {

                                        id: combodeleg

                                        x: (parent.width-width)/2
                                        height: 60
                                        width: comborect.width+10

                                        Rectangle {

                                            id: comborect

                                            x: 5
                                            y: 5
                                            height: 50
                                            width: combolabel.width+50

                                            color: combomouse.containsMouse ? "#484848" : "#2f2f2f"
                                            Behavior on color { ColorAnimation { duration: 200 } }

                                            radius: 10
                                            PQText {
                                                id: combolabel
                                                x: (parent.width-width)/2
                                                y: (parent.height-height)/2
                                                font.weight: baselook.boldweight
                                                text: deleg.combos[index]
                                            }

                                            PQMouseArea {

                                                id: combomouse

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                tooltip: "Click to change key combination"

                                                onClicked:
                                                    newshortcut.show(deleg.currentShortcutIndex, index)

                                            }
                                        }

                                        // deleetion 'x' for shortcut
                                        Rectangle {
                                            x: 0
                                            y: 0
                                            width: 20
                                            height: 20
                                            color: "#ff0000"
                                            radius: 5
                                            opacity: 0.2
                                            Behavior on opacity { NumberAnimation { duration: 200 } }
                                            Text {
                                                anchors.centerIn: parent
                                                font.weight: baselook.boldweight
                                                color: "white"
                                                text: "x"
                                            }
                                            PQMouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                tooltip: "Click to delete shortcut combo"
                                                onEntered:
                                                    parent.opacity = 0.8
                                                onExited:
                                                    parent.opacity = 0.2
                                                onClicked: {
                                                    tab_shortcuts.entries[deleg.currentShortcutIndex][0].splice(index,1)

                                                    if(tab_shortcuts.entries[deleg.currentShortcutIndex][0].length == 0) {
                                                        confirmEmptyDelete.hideIndex = deleg.currentShortcutIndex
                                                        confirmEmptyDelete.askForConfirmation("There is currently no shortcut set. If no shortcut is set before saving, then this entry will be deleted.",
                                                                                              "Do you already want to hide it from the view now?")
                                                    }
                                                    tab_shortcuts.entriesChanged()

                                                }
                                            }
                                        }

                                    }
                            }

                            Item {

                                height: 50
                                width: addcombocont.width+6

                                Rectangle {
                                    id: addcombocont
                                    x: 3
                                    y: parent.height-height
                                    width: addcombo.width+6
                                    height: addcombo.height+6
                                    color: "#2f2f2f"
                                    radius: 5
                                    PQTextS {
                                        id: addcombo
                                        x: 3
                                        y: 3
                                        text: "ADD"
                                    }

                                    PQMouseArea {

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        tooltip: "Click to add new key combination"

                                        onClicked: {
                                            newshortcut.show(deleg.currentShortcutIndex, -1)
                                        }

                                    }
                                }

                            }

                        }

                    }

                    /************************/
                    // white divider
                    Rectangle {
                        x: ontheleft.width
                        width: 1
                        height: Math.max(ontheleft.height, ontheright.height)
                        color: "#555555"
                    }

                    /************************/
                    // SHORTCUT ACTIONS
                    Column {
                        id: ontheright
                        y: (ontheleft.height>height ? ((ontheleft.height-height)/2) : 0)
                        x: ontheleft.width+20
                        width: deleg.width-ontheleft.width-40

                        spacing: 5

                        Item {
                            width: 1
                            height: 5
                        }

                        Item {

                            width: ontheright.width
                            height: c.height+10
                            visible: deleg.commands.length==0

                            // no shortcut action selected
                            PQText {
                                id: c
                                x: 5
                                y: (parent.height-height)/2
                                text: "no action selected"
                                opacity: 0.4
                                font.italic: true
                            }
                        }

                        // show all shortcut actions
                        Repeater {
                            model: deleg.commands.length

                            Rectangle {

                                width: ontheright.width
                                height: c2.height+10
                                radius: 5

                                color: "#222222"

                                // shortcut action
                                PQText {
                                    id: c2
                                    x: 5
                                    y: (parent.height-height)/2
                                    text: tab_shortcuts.actions[deleg.commands[index]][0]
                                }

                                // delete action
                                Rectangle {
                                    id: delrect
                                    anchors.fill: parent
                                    radius: 5
                                    color: "#88ff0000"
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    opacity: 0
                                    visible: opacity>0
                                    Text {
                                        anchors.centerIn: parent
                                        text: "x"
                                        color: "white"
                                        font.bold: true
                                    }
                                }
                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    tooltip: "Click to delete action"
                                    onEntered:
                                        delrect.opacity = 1
                                    onExited:
                                        delrect.opacity = 0
                                    onClicked: {
                                        tab_shortcuts.entries[deleg.currentShortcutIndex][1].splice(index,1)
                                        tab_shortcuts.entriesChanged()
                                    }
                                }

                            }

                        }

                        Item {

                            height: addactioncont.height+10
                            width: addactioncont.width+6

                            Rectangle {
                                id: addactioncont
                                x: 3
                                y: 3
                                width: addaction.width+6
                                height: addaction.height+6
                                color: "#2f2f2f"
                                radius: 5
                                PQTextS {
                                    id: addaction
                                    x: 3
                                    y: 3
                                    text: "ADD"
                                }

                                PQMouseArea {

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    tooltip: "Click to add new action"
                                    onClicked: {
                                        newaction.show(deleg.currentShortcutIndex)
                                    }

                                }
                            }

                        }


                    }

                    /************************/
                    // What to do with multiple actions
                    Rectangle {

                        id: behaviorcont

                        y: Math.max(ontheleft.height, ontheright.height)
                        width: cont.width
                        height: deleg.commands.length>1 ? behavior.height+20 : 0
                        Behavior on height { NumberAnimation { duration: 200 } }

                        visible: height>0
                        clip: true

                        color: "#1f1f1f"

                        ButtonGroup { id: radioGroup }

                        Flow {
                            id: behavior
                            x: 20
                            y: 10
                            width: parent.width-2*x

                            spacing: 10

                            Item {
                                width: 10
                                height: 1
                            }

                            PQRadioButton {
                                id: radio_cycle
                                text: "cycle through commands one by one"
                                font.pointSize: baselook.fontsize_s
                                checked: deleg.cycle
                                ButtonGroup.group: radioGroup
                            }

                            Item {
                                width: timeout_check.width
                                height: radio_cycle.height
                                enabled: radio_cycle.checked
                                PQCheckbox {
                                    id: timeout_check
                                    y: (parent.height-height)/2
                                    boxWidth: 15
                                    boxHeight: 15
                                    checked: deleg.cycletimeout>0
                                    text: "timeout for resetting cycle:"
                                    font.pointSize: baselook.fontsize_s
                                }
                            }

                            Item {
                                width: cycletimeout_slider.width
                                height: radio_cycle.height
                                PQSlider {
                                    id: cycletimeout_slider
                                    y: (parent.height-height)/2
                                    overrideBackgroundHeight: 4
                                    handleWidth: 15
                                    handleHeight: 15
                                    from: 0
                                    to: 10
                                    value: deleg.cycletimeout
                                    enabled: timeout_check.checked&&radio_cycle.checked
                                    tooltip: "Timeout: " + (value==0 ? "none" : (value+"s"))
                                }
                            }

                            PQRadioButton {
                                x: 40
                                text: "run all commands at the same time"
                                font.pointSize: baselook.fontsize_s
                                ButtonGroup.group: radioGroup
                                checked: deleg.simultaneous
                            }
                        }


                    }

                    Rectangle {
                        y: parent.height-1
                        width: parent.width
                        height: 1
                        color: "white"
                    }

                }


            }


            Item {
                width: 1
                height: 20
            }

        }

    }

    PQNewAction {

        id: newaction

        onAddAction: {

            tab_shortcuts.entries[idx][1].push(act)
            tab_shortcuts.entriesChanged()

        }

    }

    PQNewShortcut {
        id: newshortcut
        onNewCombo: {

            // first we need to check if that shortcut is already used somewhere
            var usedIndex = -1
            for(var i in tab_shortcuts.entries) {
                var combos = tab_shortcuts.entries[i][0]
                if(combos.includes(combo)) {
                    usedIndex = i
                    break
                }
            }

            if(usedIndex != -1) {

                informExisting.informUser("Duplicate shortcut", "The shortcut is already set somewhere else.", "It needs to be deleted there before it can be added here.")
                entriesview.positionViewAtIndex(usedIndex, ListView.Contain)
                tab_shortcuts.highlightEntry(usedIndex)

            } else {

                if(subindex == -1)
                    tab_shortcuts.entries[index][0].push(combo)
                else
                    tab_shortcuts.entries[index][0][subindex] = combo
                tab_shortcuts.entriesChanged()
            }

        }
    }

    PQModalConfirm {
        id: confirmEmptyDelete
        property int hideIndex: -1
        onYes: {
            if(hideIndex == -1)
                return
            tab_shortcuts.entries.splice(hideIndex,1)
            tab_shortcuts.entriesChanged()
        }
    }

    PQModalInform {
        id: informExisting
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        tab_shortcuts.entries = PQShortcuts.getAllCurrentShortcuts()
    }

}
