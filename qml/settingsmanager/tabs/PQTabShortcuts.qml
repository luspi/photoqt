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

    property var entries: [
        [["R"], ["__rotateL","__rotateR"],1,0,0],
        [["P"], ["__settings"],1,0,0],
        [["O","Ctrl+O","Open","Shift+Open"], ["__open"],1,0,0],
        [["F"], ["__flipH","__flipV","__rotateL","__rotateR"], 1,2,0],
        [["S"], ["__rotateL","__zoomActual"],0,0,1],
    ]

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

                width: cont.width
                height: childrenRect.height

                orientation: ListView.Vertical
                interactive: false

                model: tab_shortcuts.entries.length

                delegate: Item {

                    id: deleg

                    width: cont.width
                    height: Math.max(ontheleft.height, ontheright.height)+behaviorcont.height

                    property var combos: tab_shortcuts.entries[index][0]
                    property var commands: tab_shortcuts.entries[index][1]
                    property int cycle: tab_shortcuts.entries[index][2]
                    property int cycletimeout: tab_shortcuts.entries[index][3]
                    property int simultaneous: tab_shortcuts.entries[index][4]

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

                                        x: (parent.width-width)/2
                                        height: 60
                                        width: comborect.width+10

                                        Rectangle {

                                            id: comborect

                                            x: 5
                                            y: 5
                                            height: 50
                                            width: combolabel.width+50

                                            color: "#2f2f2f"

                                            radius: 10
                                            PQText {
                                                id: combolabel
                                                x: (parent.width-width)/2
                                                y: (parent.height-height)/2
                                                font.weight: baselook.boldweight
                                                text: deleg.combos[index]
                                            }

                                            PQMouseArea {

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                tooltip: "Click to change key combination"

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
                        width: cont.width-x

                        spacing: 5

                        // show all shortcut actions
                        Repeater {
                            model: deleg.commands.length

                            Item {

                                width: parent.width
                                height: c.height+10

                                // shortcut action
                                PQText {
                                    id: c
                                    y: (parent.height-height)/2
                                    text: tab_shortcuts.actions[deleg.commands[index]][0]
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
                                    tooltip: "Click to add new shortcut action"
                                    onClicked: {
                                        newaction.show()
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
                                checked: true
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
                                    text: "reset cycle timeout:"
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
                                    enabled: timeout_check.checked&&radio_cycle.checked
                                    tooltip: "Timeout: " + (value==0 ? "none" : (value+"s"))
                                }
                            }

                            PQRadioButton {
                                x: 40
                                text: "run all commands simultaneously"
                                font.pointSize: baselook.fontsize_s
                                ButtonGroup.group: radioGroup
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
    }

}
