/**************************************************************************
 **                                                                      **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import PQCShortcuts
import PQCExtensionsHandler

import org.photoqt.qml

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: addnewgrp.contextmenu.visible || listview.delegContextMenu || filter_category.popup.visible

    property var actions: {

        // IMAGE VIEWING

                                 //: Name of shortcut action
        "__next":               [qsTranslate("settingsmanager", "Next image"), "viewingimages"],
                                 //: Name of shortcut action
        "__prev":               [qsTranslate("settingsmanager", "Previous image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToFirst":          [qsTranslate("settingsmanager", "Go to first image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToLast":           [qsTranslate("settingsmanager", "Go to last image"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomIn":             [qsTranslate("settingsmanager", "Zoom In"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomOut":            [qsTranslate("settingsmanager", "Zoom Out"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomActual":         [qsTranslate("settingsmanager", "Zoom to Actual Size"), "viewingimages"],
                                 //: Name of shortcut action
        "__zoomReset":          [qsTranslate("settingsmanager", "Reset Zoom"), "viewingimages"],
                                 //: Name of shortcut action
        "__rotateR":            [qsTranslate("settingsmanager", "Rotate Right"), "viewingimages"],
                                 //: Name of shortcut action
        "__rotateL":            [qsTranslate("settingsmanager", "Rotate Left"), "viewingimages"],
                                 //: Name of shortcut action
        "__rotate0":            [qsTranslate("settingsmanager", "Reset Rotation"), "viewingimages"],
                                 //: Name of shortcut action
        "__flipH":              [qsTranslate("settingsmanager", "Mirror Horizontally"), "viewingimages"],
                                 //: Name of shortcut action
        "__flipV":              [qsTranslate("settingsmanager", "Mirror Vertically"), "viewingimages"],
                                 //: Name of shortcut action
        "__flipReset":          [qsTranslate("settingsmanager", "Reset Mirror"), "viewingimages"],
                                 //: Name of shortcut action
        "__loadRandom":         [qsTranslate("settingsmanager", "Load a random image"), "viewingimages"],
                                 //: Name of shortcut action
        "__showFaceTags":       [qsTranslate("settingsmanager", "Hide/Show face tags (stored in metadata)"), "viewingimages"],
                                 //: Name of shortcut action
        "__fitInWindow":        [qsTranslate("settingsmanager", "Toggle: Fit in window"), "viewingimages"],
                                 //: Name of shortcut action
        "__toggleAlwaysActualSize": [qsTranslate("settingsmanager", "Toggle: Show always actual size by default"), "viewingimages"],
                                 //: Name of shortcut action
        "__chromecast":         [qsTranslate("settingsmanager", "Stream content to Chromecast device"), "viewingimages"],
                                 //: Name of shortcut action
        "__flickViewLeft":      [qsTranslate("settingsmanager", "Flick view left"), "viewingimages"],
                                 //: Name of shortcut action
        "__flickViewRight":     [qsTranslate("settingsmanager", "Flick view right"), "viewingimages"],
                                 //: Name of shortcut action
        "__flickViewUp":        [qsTranslate("settingsmanager", "Flick view up"), "viewingimages"],
                                 //: Name of shortcut action
        "__flickViewDown":      [qsTranslate("settingsmanager", "Flick view down"), "viewingimages"],
                                 //: Name of shortcut action
        "__moveViewLeft":       [qsTranslate("settingsmanager", "Move view left"), "viewingimages"],
                                 //: Name of shortcut action
        "__moveViewRight":      [qsTranslate("settingsmanager", "Move view right"), "viewingimages"],
                                 //: Name of shortcut action
        "__moveViewUp":         [qsTranslate("settingsmanager", "Move view up"), "viewingimages"],
                                 //: Name of shortcut action
        "__moveViewDown":       [qsTranslate("settingsmanager", "Move view down"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToLeftEdge":       [qsTranslate("settingsmanager", "Go to left edge of image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToRightEdge":      [qsTranslate("settingsmanager", "Go to right edge of image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToTopEdge":        [qsTranslate("settingsmanager", "Go to top edge of image"), "viewingimages"],
                                 //: Name of shortcut action
        "__goToBottomEdge":     [qsTranslate("settingsmanager", "Go to bottom edge of image"), "viewingimages"],


        // SPECIAL ACTION WITH CURRENT IMAGE

                                 //: Name of shortcut action
        "__viewerMode":         [qsTranslate("settingsmanager", "Enter viewer mode"), "currentimage"],
                                 //: Name of shortcut action
        "__rename":             [qsTranslate("settingsmanager", "Rename File"), "currentimage"],
                                 //: Name of shortcut action
        "__delete":             [qsTranslate("settingsmanager", "Delete File"), "currentimage"],
                                 //: Name of shortcut action
        "__deletePermanent":    [qsTranslate("settingsmanager", "Delete File permanently (without confirmation)"), "currentimage"],
                                 //: Name of shortcut action
        "__deleteTrash":        [qsTranslate("settingsmanager", "Move file to trash (without confirmation)"), "currentimage"],
                                 //: Name of shortcut action
        "__undoTrash":          [qsTranslate("settingsmanager", "Restore file from trash"), "currentimage"],
                                 //: Name of shortcut action
        "__copy":               [qsTranslate("settingsmanager", "Copy File to a New Location"), "currentimage"],
                                 //: Name of shortcut action
        "__move":               [qsTranslate("settingsmanager", "Move File to a New Location"), "currentimage"],
                                 //: Name of shortcut action
        "__clipboard":          [qsTranslate("settingsmanager", "Copy Image to Clipboard"), "currentimage"],
                                 //: Name of shortcut action
        "__saveAs":             [qsTranslate("settingsmanager", "Save image in another format"), "currentimage"],
                                 //: Name of shortcut action
        "__print":              [qsTranslate("settingsmanager", "Print current photo"), "currentimage"],
                                 //: Name of shortcut action
        "__imgurAnonym":        [qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)"), "currentimage"],
                                 //: Name of shortcut action
        "__imgur":              [qsTranslate("settingsmanager", "Upload to imgur.com user account"), "currentimage"],
                                 //: Name of shortcut action
        "__playPauseAni":       [qsTranslate("settingsmanager", "Play/Pause animation/video"), "currentimage"],
                                 //: Name of shortcut action
        "__videoJumpForwards":  [qsTranslate("settingsmanager", "Go ahead 5 seconds in video"), "currentimage"],
                                 //: Name of shortcut action
        "__videoJumpBackwards": [qsTranslate("settingsmanager", "Go back 5 seconds in video"), "currentimage"],
                                 //: Name of shortcut action
        "__tagFaces":           [qsTranslate("settingsmanager", "Start tagging faces"), "currentimage"],
                                 //: Name of shortcut action
        "__enterPhotoSphere":   [qsTranslate("settingsmanager", "Enter photo sphere"), "currentimage"],
                                 //: Name of shortcut action
        "__detectBarCodes":     [qsTranslate("settingsmanager", "Detect QR and barcodes"), "currentimage"],
                                 //: Name of shortcut action
        "__crop":               [qsTranslate("settingsmanager", "Crop image"), "currentimage"],


        // ACTION WITH CURRENT FOLDER

                                 //: Name of shortcut action
        "__open":               [qsTranslate("settingsmanager", "Open file (browse images)"), "currentfolder"],
                                 //: Name of shortcut action
        "__showMapExplorer":    [qsTranslate("settingsmanager", "Show map explorer"), "currentfolder"],
                                //: Name of shortcut action
        "__filterImages":       [qsTranslate("settingsmanager", "Filter images in folder"), "currentfolder"],
                                 //: Name of shortcut action
        "__advancedSort":       [qsTranslate("settingsmanager", "Advanced image sort (Setup)"), "currentfolder"],
                                 //: Name of shortcut action
        "__advancedSortQuick":  [qsTranslate("settingsmanager", "Advanced image sort (Quickstart)"), "currentfolder"],
                                 //: Name of shortcut action
        "__slideshow":          [qsTranslate("settingsmanager", "Start Slideshow (Setup)"), "currentfolder"],
                                 //: Name of shortcut action
        "__slideshowQuick":     [qsTranslate("settingsmanager", "Start Slideshow (Quickstart)"), "currentfolder"],


        // INTERFACE

                                 //: Name of shortcut action
        "__contextMenu":        [qsTranslate("settingsmanager", "Show Context Menu"), "interface"],
                                 //: Name of shortcut action
        "__showMainMenu":       [qsTranslate("settingsmanager", "Hide/Show main menu"), "interface"],
                                 //: Name of shortcut action
        "__showMetaData":       [qsTranslate("settingsmanager", "Hide/Show metadata"), "interface"],
                                 //: Name of shortcut action
        "__showThumbnails":     [qsTranslate("settingsmanager", "Hide/Show thumbnails"), "interface"],
                                 //: Name of shortcut action
        "__fullscreenToggle":   [qsTranslate("settingsmanager", "Toggle fullscreen mode"), "interface"],
                                 //: Name of shortcut action
        "__close":              [qsTranslate("settingsmanager", "Close window (hides to system tray if enabled)"), "interface"],
                                 //: Name of shortcut action
        "__quit":               [qsTranslate("settingsmanager", "Quit PhotoQt"), "interface"],



        // OTHER ELEMENTS

                                //: Name of shortcut action
        "__settings":           [qsTranslate("settingsmanager", "Show Settings"), "other"],
                                //: Name of shortcut action
        "__about":              [qsTranslate("settingsmanager", "About PhotoQt"), "other"],
                                //: Name of shortcut action
        "__logging":            [qsTranslate("settingsmanager", "Show log/debug messages"), "other"],
                                //: Name of shortcut action
        "__resetSession":       [qsTranslate("settingsmanager", "Reset current session"), "other"],
                                //: Name of shortcut action
        "__resetSessionAndHide":[qsTranslate("settingsmanager", "Reset current session and hide window"), "other"],

    }

    property list<string> extensions: PQCExtensionsHandler.getExtensions()

    property var idToEntr: ({})
    property var currentEntries: []
    property var defaultEntries: []
    property var entriesHeights: []

    signal highlightEntry(var idx)

    property var handleExisting: ({})
    signal highlightExisting(var entryindex, var entryid)

    Column {

        id: contcol

        spacing: 10

        Column {

            id: toppart

            spacing: 10

            PQTextXL {
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                //: Settings title
                text: qsTranslate("settingsmanager", "Shortcuts")
                font.capitalization: Font.SmallCaps
            }

            PQText {
                width: setting_top.width
                text:qsTranslate("settingsmanager",  "Shortcuts are grouped by key combination. Multiple actions can be set for each group of key combinations, with the option of cycling through them one by one, or executing all of them at the same time. When cycling through them one by one, a timeout can be set after which the cycle will be reset to the beginning. Any group that has no key combinations set will be deleted when saving all changes.")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            PQButton {
                id: addnewgrp
                text: qsTranslate("settingsmanager", "Add new shortcuts group")
                onClicked: {
                    filter_combo.text = ""
                    filter_action.text = ""

                    for(var i in setting_top.idToEntr)
                        setting_top.idToEntr[i] = setting_top.idToEntr[i]+1

                    var newid = PQCScriptsOther.getUniqueId()
                    setting_top.idToEntr[newid] = 0

                    setting_top.currentEntries.unshift([[],[],1,0,0])

                    shmodel.insert(0,
                                   {"combosstr" : "",
                                    "commandsstr" : "",
                                    "cycling" : 1,
                                    "cycletimeout" : 0,
                                    "simultaneous" : 0,
                                    "uniqueid" : newid})
                    highlightNew.restart()
                }
            }
            // We use a short timeout to make sure the newly added item has been added and heights updated
            Timer {
                id: highlightNew
                interval: 100
                repeat: false
                running: false
                onTriggered: {
                    listview.positionViewAtBeginning()
                    setting_top.highlightEntry(0)
                    listview.positionViewAtBeginning()
                }
            }

            PQText {
                width: setting_top.width
                text: qsTranslate("settingsmanager", "The shortcuts can be filtered by either the key combinations, shortcut actions, category, or all three. For the string search, PhotoQt will by default check if any action/key combination includes whatever string is entered. Adding a dollar sign ($) at the start or end of the search term forces a match to be either at the start or the end of a key combination or action.")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Row {

                spacing: 5

                PQLineEdit {
                    id: filter_combo
                    width: Math.min(800, parent.width/2)+10
                    enabled: (newaction.opacity<1 && newshortcut.opacity<1)
                    placeholderText: qsTranslate("settingsmanager", "Filter key combinations")
                    onControlActiveFocusChanged: {
                        PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus // qmllint disable unqualified
                    }
                }

                PQLineEdit {
                    id: filter_action
                    width: (setting_top.width-filter_combo.width)/2-10
                    enabled: (newaction.opacity<1 && newshortcut.opacity<1)
                    placeholderText: qsTranslate("settingsmanager", "Filter shortcut actions")
                    onControlActiveFocusChanged: {
                        PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus // qmllint disable unqualified
                    }
                }

                PQComboBox {
                    id: filter_category
                    width: (setting_top.width-filter_combo.width)/2-20
                    height: filter_action.height
                    property list<string> modeldata: [qsTranslate("settingsmanager", "Show all categories"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "Viewing images"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "Current image"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "Current folder"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "Interface"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "Extensions"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "Other"),
                        qsTranslate("settingsmanager", "Category:") + " " + qsTranslate("settingsmanager", "External")]
                    model: modeldata                }

            }

        }

        Timer {
            id: timerCheckDefault
            interval: 250
            onTriggered:
                setting_top.checkDefault()
        }

        ListView {

            id: listview

            width: setting_top.width
            height: setting_top.height - toppart.height-20

            orientation: ListView.Vertical
            clip: true

            model: ListModel { id: shmodel }

            ScrollBar.vertical: PQVerticalScrollBar {}

            property bool delegContextMenu: false
            signal closeMenus()

            delegate: Rectangle {

                id: deleg

                width: setting_top.width

                required property int index
                required property string combosstr
                required property string commandsstr
                required property int cycling
                required property int cycletimeout
                required property int simultaneous
                required property string uniqueid

                property bool doneWithSetup: false
                Timer {
                    running: true
                    interval: 300
                    onTriggered:
                        deleg.doneWithSetup = true
                }

                property list<string> combos: combosstr==="" ? [] : combosstr.split(":://::")
                property list<string> commands: commandsstr==="" ? [] : commandsstr.split(":://::")

                onCombosChanged: {
                    if(!doneWithSetup) return
                    var ind = setting_top.idToEntr[uniqueid]
                    setting_top.currentEntries[ind][0] = combos
                    timerCheckDefault.restart()
                }
                onCommandsChanged: {
                    if(!doneWithSetup) return
                    var ind = setting_top.idToEntr[uniqueid]
                    setting_top.currentEntries[ind][1] = commands
                    timerCheckDefault.restart()
                }
                onCyclingChanged: {
                    if(!doneWithSetup) return
                    var ind = setting_top.idToEntr[uniqueid]
                    setting_top.currentEntries[ind][2] = cycling
                    timerCheckDefault.restart()
                }
                onCycletimeoutChanged: {
                    if(!doneWithSetup) return
                    var ind = setting_top.idToEntr[uniqueid]
                    setting_top.currentEntries[ind][3] = cycletimeout
                    timerCheckDefault.restart()
                }
                onSimultaneousChanged: {
                    if(!doneWithSetup) return
                    var ind = setting_top.idToEntr[uniqueid]
                    setting_top.currentEntries[ind][4] = simultaneous
                    timerCheckDefault.restart()
                }

                Behavior on opacity { NumberAnimation { duration: 200 } }

                height: opacity>0 ? Math.max(ontheleft.height, ontheright.height)+behaviorcont.height : 0
                Behavior on height { NumberAnimation { duration: 200 } }
                visible: height>0

                property bool deleteMe: false
                onOpacityChanged: {
                    if(!deleteMe || opacity > 0)
                        return
                    height = 0
                }

                onHeightChanged: {
                    setting_top.entriesHeights[deleg.index] = height

                    if(!deleteMe || height > 0)
                        return
                    shmodel.remove(deleg.index)
                }

                clip: true

                color: PQCLook.baseColorAccent // qmllint disable unqualified
                Behavior on color {
                    SequentialAnimation {
                        loops: 4
                        ColorAnimation { from: PQCLook.baseColorAccent; to: PQCLook.baseColorHighlight; duration: 400 } // qmllint disable unqualified
                        ColorAnimation { from: PQCLook.baseColorHighlight; to: PQCLook.baseColorAccent; duration: 400 } // qmllint disable unqualified
                    }
                }

                /************************/
                // SHORTCUT COMBOS
                Column {
                    id: ontheleft
                    y: (ontheright.height>height ? ((ontheright.height-height)/2) : 0)
                    width: Math.min(800, parent.width/2)

                    spacing: 5

                    // key combo strings
                    Flow {

                        width: parent.width

                        padding: 5

                        Item {

                            width: ontheleft.width
                            height: deleg.combos.length===0 ? (n.height+20) : 0
                            visible: height > 0
                            opacity: (height-n.height-20 < 1) ? 1 : 0

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            Behavior on height { NumberAnimation { duration: 200 } }

                            // no key combination selected
                            PQText {
                                id: n
                                x: 5
                                y: 10
                                text: qsTranslate("settingsmanager", "no key combination set")
                                opacity: 0.4
                                font.italic: true
                            }
                        }

                        Repeater {
                            model: deleg.combos.length
                            delegate:

                                Item {

                                    id: combodeleg

                                    required property int index

                                    x: (ontheleft.width-width)/2
                                    height: 60
                                    width: comborect.width+10

                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    Behavior on width { NumberAnimation { duration: 200 } }

                                    property bool deleteMe: false
                                    onOpacityChanged: {
                                        if(deleteMe && opacity<1e-6)
                                            width = 0
                                    }

                                    onWidthChanged: {

                                        if(!deleteMe || width>0)
                                            return

                                        var oldcombos = deleg.combos
                                        oldcombos.splice(index,1)
                                        deleg.combosstr = oldcombos.join(":://::")

                                    }

                                    Rectangle {

                                        id: comborect

                                        x: 5
                                        y: 5
                                        height: 50
                                        width: delrect.width+combolabel.width+35
                                        radius: 10

                                        color: combomouse.containsMouse ? PQCLook.baseColorActive : PQCLook.baseColorHighlight // qmllint disable unqualified
                                        Behavior on color { ColorAnimation { duration: 200 } }

                                        // deletion 'x' for shortcut
                                        Rectangle {
                                            id: delrect
                                            x: 15
                                            y: (parent.height-height)/2
                                            width: 20
                                            height: 20
                                            color: "red"
                                            radius: 5
                                            opacity: 0.2
                                            Behavior on opacity { NumberAnimation { duration: 200 } }
                                            Text {
                                                anchors.centerIn: parent
                                                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                                color: "white"
                                                text: "x"
                                            }
                                        }

                                        PQText {
                                            id: combolabel
                                            x: delrect.width+20
                                            y: (parent.height-height)/2
                                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                            text: PQCScriptsShortcuts.translateShortcut(deleg.combos[combodeleg.index])
                                            color: PQCLook.textColor // qmllint disable unqualified
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                        }

                                        PQMouseArea {

                                            id: combomouse

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            text: qsTranslate("settingsmanager", "Click to change key combination")

                                            onClicked:
                                                newshortcut.show(deleg.index, combodeleg.index)

                                        }

                                        PQMouseArea {
                                            anchors.fill: delrect
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            text: qsTranslate("settingsmanager", "Click to delete key combination")
                                            onEntered:
                                                delrect.opacity = 0.8
                                            onExited:
                                                delrect.opacity = 0.2
                                            onClicked: {
                                                combodeleg.deleteMe = true
                                                combodeleg.opacity = 0
                                            }
                                        }
                                    }

                                }
                        }

                        Item {

                            height: 60
                            width: addcombocont.width+6

                            Rectangle {
                                id: addcombocont
                                x: 3
                                y: (parent.height-height)/2
                                width: addcombo.width+6
                                height: addcombo.height+6
                                color: addmouse.containsMouse ? PQCLook.baseColorActive : PQCLook.baseColorHighlight // qmllint disable unqualified
                                Behavior on color { ColorAnimation { duration: 200 } }
                                radius: 5
                                PQTextS {
                                    id: addcombo
                                    x: 3
                                    y: 3
                                    //: Written on small button, used as in: add new key combination. Please keep short!
                                    text: qsTranslate("settingsmanager", "ADD")
                                    color: PQCLook.textColor // qmllint disable unqualified
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                PQMouseArea {

                                    id: addmouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    text: qsTranslate("settingsmanager", "Click to add new key combination")

                                    onClicked: {
                                        newshortcut.show(deleg.index, -1)
                                    }

                                }
                            }

                        }

                    }

                    Rectangle {

                        id: exstre

                        width: parent.width
                        height: exstre_col.height+20
                        color: PQCLook.baseColorAccent // qmllint disable unqualified

                        opacity: 0
                        visible: opacity>0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        SequentialAnimation {
                            loops: Animation.Infinite
                            running: exstre.visible
                            PropertyAnimation { target: exstre; property: "color"; from: PQCLook.baseColorAccent; to: PQCLook.baseColorHighlight; duration: 400 } // qmllint disable unqualified
                            PropertyAnimation { target: exstre; property: "color"; from: PQCLook.baseColorHighlight; to: PQCLook.baseColorAccent; duration: 400 } // qmllint disable unqualified
                        }

                        Connections {
                            target: setting_top
                            function onHighlightExisting(entryindex: int, entryid: string) {
                                if(entryindex === deleg.index) {
                                    countdwn.s = 5
                                    undobut.entryid = entryid
                                    exstre.opacity = 1
                                }
                            }
                        }

                        Column {

                            id: exstre_col

                            x: 5
                            y: 10
                            spacing: 10
                            width: parent.width

                            PQText {
                                width: parent.width
                                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTranslate("settingsmanager", "The new shortcut was in use by another shortcuts group. It has been reassigned to this group.")
                            }

                            Row {

                                x: 5
                                spacing: 10

                                PQButton {
                                    id: undobut
                                    property string entryid: ""
                                    text: qsTranslate("settingsmanager", "Undo reassignment")
                                    onClicked: {
                                        var dat = setting_top.handleExisting[entryid]
                                        shmodel.get(dat[0]).combosstr = (shmodel.get(dat[0]).combosstr==="" ? dat[2] : (shmodel.get(dat[0]).combos + ":://::"+dat[2]))
                                        var oldcombos = deleg.combos
                                        oldcombos.splice(deleg.combos.indexOf(dat[2]), 1)
                                        deleg.combosstr = oldcombos.join(":://::")
                                        exstre.opacity = 0
                                    }
                                    contextmenu.onVisibleChanged: {
                                        listview.delegContextMenu = visible
                                    }
                                }

                                PQText {
                                    id: countdwn
                                    y: (undobut.height-height)/2
                                    property int s: 5
                                    text: s
                                    Timer {
                                        interval: 1000
                                        running: exstre.opacity>0.99
                                        repeat: true
                                        onTriggered: {
                                            countdwn.s -= 1
                                            if(countdwn.s == 0)
                                                exstre.opacity = 0
                                        }
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
                    color: PQCLook.baseColorHighlight // qmllint disable unqualified
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
                        height: deleg.commands.length===0 ? (c.height+10) : 0
                        visible: opacity > 0
                        opacity: height>0 ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        Behavior on height { NumberAnimation { duration: 200 } }

                        // no shortcut action selected
                        PQText {
                            id: c
                            x: 5
                            y: (parent.height-height)/2
                            //: The action here is a shortcut action
                            text: qsTranslate("settingsmanager", "no action selected")
                            opacity: 0.4
                            font.italic: true
                        }
                    }

                    // show all shortcut actions
                    Repeater {
                        model: deleg.commands.length

                        Rectangle {

                            id: cmddeleg

                            required property int index

                            property string cmd: deleg.commands[index]

                            width: ontheright.width
                            height: c2.height+10
                            radius: 5

                            color: actmouse.containsMouse ? PQCLook.baseColorActive : PQCLook.baseColorHighlight // qmllint disable unqualified
                            Behavior on color { ColorAnimation { duration: 200 } }

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            Behavior on height { NumberAnimation { duration: 200 } }

                            property bool deleteMe: false
                            onOpacityChanged: {
                                if(!deleteMe || opacity > 0)
                                    return
                                height = 0
                            }
                            onHeightChanged: {
                                if(!deleteMe || height > 0)
                                    return
                                var oldcommands = deleg.commands
                                oldcommands.splice(index,1)
                                deleg.commandsstr = oldcommands.join(":://::")
                            }

                            // shortcut action
                            PQText {
                                id: c2
                                x: 30
                                y: (parent.height-height)/2
                                text: cmddeleg.cmd.startsWith("__")
                                            ? (cmddeleg.cmd in setting_top.actions
                                               ? setting_top.actions[cmddeleg.cmd][0]
                                                 //: The unknown here refers to an unknown internal action that was set as shortcut
                                               : (PQCExtensionsHandler.getAllShortcuts().indexOf(cmddeleg.cmd)>-1
                                                  ? PQCExtensionsHandler.getDescriptionForShortcut(cmddeleg.cmd)
                                                  : ("<i>"+qsTranslate("settingsmanager", "unknown:")+"</i> "+cmddeleg.cmd)))
                                              //: This is an identifier in the shortcuts settings used to identify an external shortcut.
                                            : ("<i>" + qsTranslate("settingsmanager", "external") + "</i>: " +
                                               cmddeleg.cmd.split(":/:/:")[0] + " " + cmddeleg.cmd.split(":/:/:")[1] +
                                               //: This is used for listing external commands for shortcuts, showing if the quit after checkbox has been checked
                                               (cmddeleg.cmd.split(":/:/:")[2]*1==1 ? " (" + qsTranslate("settingsmanager", "quit after") + ")" : ""))
                                color: PQCLook.textColor // qmllint disable unqualified
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            PQMouseArea {
                                id: actmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Click to change shortcut action")
                                onClicked: {
                                    newaction.change(deleg.index, cmddeleg.index, deleg.uniqueid)
                                }
                            }

                            // deletion 'x' for action
                            Rectangle {
                                x: 5
                                y: (parent.height-height)/2
                                width: 20
                                height: 20
                                color: "red"
                                radius: 5
                                opacity: 0.2
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                Text {
                                    anchors.centerIn: parent
                                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                    color: "white"
                                    text: "x"
                                }
                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    text: qsTranslate("settingsmanager", "Click to delete shortcut action")
                                    onEntered:
                                        parent.opacity = 0.8
                                    onExited:
                                        parent.opacity = 0.2
                                    onClicked: {
                                        cmddeleg.deleteMe = true
                                        cmddeleg.opacity = 0
                                    }
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
                            color: addactmouse.containsMouse ? PQCLook.baseColorActive : PQCLook.baseColorHighlight // qmllint disable unqualified
                            Behavior on color { ColorAnimation { duration: 200 } }
                            radius: 5
                            PQTextS {
                                id: addaction
                                x: 3
                                y: 3
                                //: Written on small button, used as in: add new shortcut action. Please keep short!
                                text: qsTranslate("settingsmanager", "ADD")
                                color: PQCLook.textColor // qmllint disable unqualified
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            PQMouseArea {

                                id: addactmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a shortcut action
                                text: qsTranslate("settingsmanager", "Click to add new action")
                                onClicked: {
                                    newaction.show(deleg.index)
                                }

                            }
                        }

                    }


                }

                /************************/
                // What to do with multiple actions
                Item {

                    id: behaviorcont

                    y: Math.max(ontheleft.height, ontheright.height)
                    width: setting_top.width
                    height: deleg.commands.length>1 ? behavior.height+20 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }

                    visible: height>0
                    clip: true

                    ButtonGroup { id: radioGroup }

                    Column {
                        id: behavior
                        x: 20
                        y: 10
                        width: parent.width-2*x

                        spacing: 5

                        Row {

                            spacing: 5

                            Item {
                                width: 1
                                height: 1
                            }

                            PQRadioButton {
                                id: radio_cycle
                                //: The actions here are shortcut actions
                                text: qsTranslate("settingsmanager", "cycle through actions one by one")
                                font.pointSize: PQCLook.fontSizeS // qmllint disable unqualified
                                checked: deleg.cycling
                                ButtonGroup.group: radioGroup
                                onCheckedChanged: {
                                    deleg.cycling = (checked ? 1 : 0)
                                    deleg.simultaneous = (checked ? 0 : 1)
                                }
                            }

                            Item {
                                width: timeout_check.width
                                height: radio_cycle.height
                                enabled: radio_cycle.checked
                                PQCheckBox {
                                    id: timeout_check
                                    y: (parent.height-height)/2
                                    checked: deleg.cycletimeout>0
                                    //: The cycle here is the act of cycling through shortcut actions one by one
                                    text: qsTranslate("settingsmanager", "timeout for resetting cycle:")
                                    font.pointSize: PQCLook.fontSizeS // qmllint disable unqualified
                                    onCheckedChanged: {
                                        cycletimeout_slider.value = 0
                                    }
                                }
                            }

                            Item {
                                width: cycletimeout_slider.width+valtxt.width+5
                                height: radio_cycle.height
                                PQSlider {
                                    id: cycletimeout_slider
                                    y: (parent.height-height)/2
                                    from: 0
                                    to: 10
                                    value: deleg.cycletimeout
                                    enabled: timeout_check.checked&&radio_cycle.checked
                                    onValueChanged: {
                                        deleg.cycletimeout = cycletimeout_slider.value
                                    }
                                }

                                PQText {
                                    id: valtxt
                                    x: cycletimeout_slider.width+5
                                    y: (parent.height-height)/2
                                    enabled: timeout_check.checked&&radio_cycle.checked
                                    text: cycletimeout_slider.value + "s"
                                }
                            }

                        }

                        Row {

                            spacing: 5

                            Item {
                                width: 1
                                height: 1
                            }

                            PQRadioButton {
                                x: 40
                                //: The actions here are shortcut actions
                                text: qsTranslate("settingsmanager", "run all actions at once")
                                font.pointSize: PQCLook.fontSizeS // qmllint disable unqualified
                                ButtonGroup.group: radioGroup
                                checked: deleg.simultaneous
                                onCheckedChanged: {
                                    deleg.cycling = (checked ? 0 : 1)
                                    deleg.simultaneous = (checked ? 1 : 0)
                                }
                            }

                        }
                    }


                }

                Rectangle {
                    y: parent.height-1
                    width: parent.width
                    height: 1
                    color: PQCLook.baseColorHighlight // qmllint disable unqualified
                }

                Connections {
                    target: filter_combo
                    function onTextChanged() {
                        deleg.performFilter()
                    }
                }
                Connections {
                    target: filter_action
                    function onTextChanged() {
                        deleg.performFilter()
                    }
                }
                Connections {
                    target: filter_category
                    function onCurrentIndexChanged() {
                        deleg.performFilter()
                    }
                }

                Connections {
                    target: setting_top
                    function onHighlightEntry(idx: int) {
                        if(idx === deleg.index) {
                            deleg.color = PQCLook.baseColorHighlight // qmllint disable unqualified
                        }
                    }
                }

                Component.onCompleted: {

                    setting_top.entriesHeights[deleg.index] = height
                    performFilter()
                }

                function performFilter() : void {

                    if((filter_combo.text === "" || filter_combo.text === "$") && (filter_action.text === "" || filter_action.text === "$") && filter_category.currentIndex===0) {
                        deleg.opacity = 1
                        return
                    }

                    var longcommands = []
                    for(var i in commands) {
                        var cmd = commands[i]
                        if(cmd.startsWith("__")) {
                            if(cmd in setting_top.actions)
                                longcommands.push(setting_top.actions[cmd][0])
                            longcommands.push(cmd)
                        } else
                            longcommands.push(cmd.split(":/:/:")[0] + " " + cmd.split(":/:/:")[1] + (cmd.split(":/:/:")[2]*1==1 ? " (quit after)" : ""))
                    }

                    var vis = true

                    if(filter_combo.text !== "") {
                        var c = filter_combo.text.toLowerCase()
                        var yes = false
                        for(var j = 0; j < combos.length; ++j) {
                            if(c.startsWith("$") && !c.endsWith("$")) {
                                if(combos[j].toLowerCase().startsWith(c.substring(1)))
                                    yes = true
                            } else if(!c.startsWith("$") && c.endsWith("$")) {
                                if(combos[j].toLowerCase().endsWith(c.substring(0,c.length-1)))
                                    yes = true
                            } else if(c.startsWith("$") && c.endsWith("$")) {
                                if(combos[j].toLowerCase() === c.substring(1,c.length-1))
                                    yes = true
                            } else {
                                if(combos[j].toLowerCase().includes(c))
                                    yes = true
                            }
                        }
                        if(!yes)
                            vis = false
                    }

                    if(filter_action.text !== "") {
                        var c2 = filter_action.text.toLowerCase()
                        var yes2 = false
                        for(var k = 0; k < longcommands.length; ++k) {
                            if(c2.startsWith("$") && !c2.endsWith("$")) {
                                if(longcommands[k].toLowerCase().startsWith(c2.substring(1)))
                                    yes2 = true
                            } else if(!c2.startsWith("$") && c2.endsWith("$")) {
                                if(longcommands[k].toLowerCase().endsWith(c2.substring(0,c2.length-1)))
                                    yes2 = true
                            } else if(c2.startsWith("$") && c2.endsWith("$")) {
                                if(longcommands[k].toLowerCase() === c2.substring(1,c2.length-1))
                                    yes2 = true
                            } else {
                                if(longcommands[k].toLowerCase().includes(c2))
                                    yes2 = true
                            }
                        }
                        if(!yes2)
                            vis = false
                    }

                    if(filter_category.currentIndex !== 0) {

                        var categories = ["viewingimages","currentimage","currentfolder","interface","extensions","other","external"]
                        var filtercat = categories[filter_category.currentIndex-1]

                        var yes3 = false
                        for(var l = 0; l < commands.length; ++l) {
                            if(setting_top.actions[commands[l]][1] === filtercat)
                                yes3 = true
                        }
                        if(!yes3)
                            vis = false

                    }

                    deleg.opacity = (vis ? 1 : 0)
                }

            }

        }


    }

    PQNewShortcut {

        id: newshortcut

        onNewCombo: (index, subindex, combo) => {

            console.log("args: index =", index)
            console.log("args: subindex =", subindex)
            console.log("args: combo =", combo)

            // this case should never actually happen
            if(combo.startsWith("Left Button")) {
                return
            }

            // first we need to check if that shortcut is already used somewhere
            var usedIndex = -1
            for(var i = 0; i < shmodel.count; ++i) {
                if(index === i) {
                    // if we checking the current index, if the shortcut is already set we don't need to do anything
                    if(shmodel.get(i).combosstr.split(":://::").includes(combo))
                        return
                } else if(shmodel.get(i).combosstr.split(":://::").includes(combo)) {
                    usedIndex = i
                    break
                }
            }

            // reassign shortcut, save reassignment data, and show undo button
            if(usedIndex != -1) {
                var newid = PQCScriptsOther.getUniqueId() // qmllint disable unqualified
                setting_top.handleExisting[newid] = [usedIndex, index, combo]
                var val = shmodel.get(usedIndex).combosstr.split(":://::")
                val.splice(val.indexOf(combo), 1)
                shmodel.get(usedIndex).combosstr = val.join(":://::")
                setting_top.highlightExisting(index, newid)
            }

            if(subindex === -1) {
                if(shmodel.get(index).combosstr === "")
                    shmodel.get(index).combosstr = combo
                else
                    shmodel.get(index).combosstr += ":://::"+combo
            } else {
                var val2 = shmodel.get(index).combosstr.split(":://::")
                val2[subindex] = combo
                shmodel.get(index).combosstr = val2.join(":://::")
            }

        }

    }

    PQNewAction {

        id: newaction

        actions: setting_top.actions

        onAddAction: (idx, act) => {

            if(shmodel.get(idx).commandsstr === "")
                shmodel.get(idx).commandsstr = act
            else
                shmodel.get(idx).commandsstr += ":://::"+act

        }

        onUpdateAction: (idx, subidx, act) => {

            var val = shmodel.get(idx).commandsstr.split(":://::")
            val[subidx] = act
            shmodel.get(idx).commandsstr = val.join(":://::")

        }

    }

    Component.onCompleted:
        load()

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEnterEsc = false // qmllint disable unqualified

    function handleEscape() {
        addnewgrp.contextmenu.close()
        listview.closeMenus()
        filter_category.popup.close()
    }

    // do not make this function typed, it will break
    function areTwoListsEqual(l1, l2) {

        if(l1.length !== l2.length)
            return false

        for(var i = 0; i < l1.length; ++i) {

            if(l1[i].length !== l2[i].length)
                return false

            for(var j = 0; j < l1[i].length; ++j) {
                // check sublist if any
                if(l1[i][j].constructor === Array) {
                    var ret = areTwoListsEqual(l1[i][j], l2[i][j])
                    if(!ret)
                        return false;
                } else if(l1[i][j] !== l2[i][j])
                    return false
            }
        }

        return true
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        settingChanged = !areTwoListsEqual(currentEntries, defaultEntries)

    }

    function ensureVisible(index: int) {

        if(listview.contentHeight > listview.height) {

            var offset = 0
            for(var idx = 0; idx < index; ++idx)
                offset += setting_top.entriesHeights[idx]

            var cy_top = Math.min(listview.y + offset, listview.contentHeight-listview.height)
            var cy_bot = Math.min(listview.y + offset-listview.height+setting_top.entriesHeights[index], listview.contentHeight-listview.height)
            if(listview.contentY > cy_top)
                listview.contentY = cy_top
            else if(listview.contentY < cy_bot)
                listview.contentY = cy_bot

        }

        setting_top.highlightEntry(index)

    }

    function load() {
        filter_action.text = ""
        filter_combo.text = ""
        filter_category.currentIndex = 0

        currentEntries = PQCShortcuts.getAllCurrentShortcuts()
        defaultEntries = PQCShortcuts.getAllCurrentShortcuts()

        shmodel.clear()

        for(var i = 0; i < currentEntries.length; ++i) {

            var newid = i.toString()
            idToEntr[newid] = i

            shmodel.append({"combosstr" : currentEntries[i][0].join(":://::"),
                            "commandsstr" : currentEntries[i][1].join(":://::"),
                            "cycling" : currentEntries[i][2],
                            "cycletimeout" : currentEntries[i][3],
                            "simultaneous" : currentEntries[i][4],
                            "uniqueid" : newid})
        }

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCShortcuts.saveAllCurrentShortcuts(currentEntries) // qmllint disable unqualified
        defaultEntries = PQCShortcuts.getAllCurrentShortcuts()
        settingChanged = false
    }

    function revertChanges() {
        load()
    }

}
