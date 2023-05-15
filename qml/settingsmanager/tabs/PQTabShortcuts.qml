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

import "./shortcutsold"
import "../../elements"

Item {

    id: tab_shortcuts

    property var strings: {

        // NAVIGATION

                                //: Name of shortcut action
        "__open":               [em.pty+qsTranslate("settingsmanager", "Open file (browse images)"),
                                 //: A shortcuts category: navigation
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__filterImages":       [em.pty+qsTranslate("settingsmanager", "Filter images in folder"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__next":               [em.pty+qsTranslate("settingsmanager", "Next image"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__prev":               [em.pty+qsTranslate("settingsmanager", "Previous image"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__loadRandom":         [em.pty+qsTranslate("settingsmanager", "Load a random image"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__contextMenu":        [em.pty+qsTranslate("settingsmanager", "Show Context Menu"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__goToFirst":          [em.pty+qsTranslate("settingsmanager", "Go to first image"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__goToLast":           [em.pty+qsTranslate("settingsmanager", "Go to last image"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__viewerMode":         [em.pty+qsTranslate("settingsmanager", "Enter viewer mode"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__navigationFloating": [em.pty+qsTranslate("settingsmanager", "Show floating navigation buttons"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__close":              [em.pty+qsTranslate("settingsmanager", "Close window (hides to system tray if enabled)"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],
                                //: Name of shortcut action
        "__quit":               [em.pty+qsTranslate("settingsmanager", "Quit PhotoQt"),
                                 em.pty+qsTranslate("settingsmanager", "Navigation")],


        // IMAGE

                                //: Name of shortcut action
        "__zoomIn":             [em.pty+qsTranslate("settingsmanager", "Zoom In"),
                                 //: A shortcuts category: image manipulation
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__zoomOut":            [em.pty+qsTranslate("settingsmanager", "Zoom Out"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__zoomActual":         [em.pty+qsTranslate("settingsmanager", "Zoom to Actual Size"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__zoomReset":          [em.pty+qsTranslate("settingsmanager", "Reset Zoom"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__fitInWindow":        [em.pty+qsTranslate("settingsmanager", "Toggle 'Fit in window'"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__toggleAlwaysActualSize": [em.pty+qsTranslate("settingsmanager", "Toggle: Show always actual size by default"),
                                     em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__rotateR":            [em.pty+qsTranslate("settingsmanager", "Rotate Right"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__rotateL":            [em.pty+qsTranslate("settingsmanager", "Rotate Left"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__rotate0":            [em.pty+qsTranslate("settingsmanager", "Reset Rotation"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__flipH":              [em.pty+qsTranslate("settingsmanager", "Flip Horizontally"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__flipV":              [em.pty+qsTranslate("settingsmanager", "Flip Vertically"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__scale":              [em.pty+qsTranslate("settingsmanager", "Scale Image"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__playPauseAni":       [em.pty+qsTranslate("settingsmanager", "Play/Pause animation/video"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__showFaceTags":       [em.pty+qsTranslate("settingsmanager", "Hide/Show face tags (stored in metadata)"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__advancedSort":       [em.pty+qsTranslate("settingsmanager", "Advanced image sort (Setup)"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],
                                //: Name of shortcut action
        "__advancedSortQuick":  [em.pty+qsTranslate("settingsmanager", "Advanced image sort (Quickstart)"),
                                 em.pty+qsTranslate("settingsmanager", "Image")],


        // FILE

                                //: Name of shortcut action
        "__rename":             [em.pty+qsTranslate("settingsmanager", "Rename File"),
                                 //: A shortcuts category: file management
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__delete":             [em.pty+qsTranslate("settingsmanager", "Delete File"),
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__deletePermanent":    [em.pty+qsTranslate("settingsmanager", "Delete File (without confirmation)"),
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__copy":               [em.pty+qsTranslate("settingsmanager", "Copy File to a New Location"),
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__move":               [em.pty+qsTranslate("settingsmanager", "Move File to a New Location"),
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__clipboard":          [em.pty+qsTranslate("settingsmanager", "Copy Image to Clipboard"),
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__saveAs":             [em.pty+qsTranslate("settingsmanager", "Save image in another format"),
                                 em.pty+qsTranslate("settingsmanager", "File")],
                                //: Name of shortcut action
        "__print":              [em.pty+qsTranslate("settingsmanager", "Print current photo"),
                                 em.pty+qsTranslate("settingsmanager", "File")],

        // OTHER

                                //: Name of shortcut action
        "__showMainMenu":       [em.pty+qsTranslate("settingsmanager", "Hide/Show main menu"),
                                 //: A shortcuts category: other functions
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__showMetaData":       [em.pty+qsTranslate("settingsmanager", "Hide/Show metadata"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__keepMetaData":       [em.pty+qsTranslate("settingsmanager", "Keep metadata opened"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__showThumbnails":     [em.pty+qsTranslate("settingsmanager", "Hide/Show thumbnails"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__settings":           [em.pty+qsTranslate("settingsmanager", "Show Settings"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__slideshow":          [em.pty+qsTranslate("settingsmanager", "Start Slideshow (Setup)"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__slideshowQuick":     [em.pty+qsTranslate("settingsmanager", "Start Slideshow (Quickstart)"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__about":              [em.pty+qsTranslate("settingsmanager", "About PhotoQt"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__wallpaper":          [em.pty+qsTranslate("settingsmanager", "Set as Wallpaper"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__histogram":          [em.pty+qsTranslate("settingsmanager", "Show Histogram"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__imgurAnonym":        [em.pty+qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__imgur":              [em.pty+qsTranslate("settingsmanager", "Upload to imgur.com user account"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__chromecast":         [em.pty+qsTranslate("settingsmanager", "Stream content to Chromecast device"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__logging":            [em.pty+qsTranslate("settingsmanager", "Show log/debug messages"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__fullscreenToggle":   [em.pty+qsTranslate("settingsmanager", "Toggle fullscreen mode"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__resetSession":       [em.pty+qsTranslate("settingsmanager", "Reset current session"),
                                 em.pty+qsTranslate("settingsmanager", "Other")],
                                //: Name of shortcut action
        "__resetSessionAndHide":[em.pty+qsTranslate("settingsmanager", "Reset current session and hide window"),
                                 em.pty+qsTranslate("settingsmanager", "Other")]

    }

    property var entries: [
        ["R", ["__rotateL","__rotateR"],1,0,0],
        ["P", ["__settings"],1,0,0],
        ["O", ["__open"],1,0,0],
        ["F", ["__flipH","__flipV","__rotateL","__rotateR"], 1,2,0],
        ["S", ["__rotateL","__zoomActual"],0,0,1],
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
                    height: ontheright.height+behaviorcont.height

                    // LEFT COLUMN
                    Column {
                        id: ontheleft

                        y: (ontheright.height-height)/2
                        width: 300

                        spacing: 5

                        Item {
                            width: 1
                            height: 20
                        }

                        Rectangle {

                            x: (parent.width-width)/2
                            height: 50
                            width: combolabel.width+50

                            color: "#2f2f2f"

                            radius: 10

                            // key combo string
                            PQTextL {
                                id: combolabel
                                x: (parent.width-width)/2
                                y: (parent.height-height)/2
                                font.weight: baselook.boldweight
                                text: tab_shortcuts.entries[index][0]
                            }

                            PQMouseArea {

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                tooltip: "Click to change key combination"

                            }

                        }

                        Item {
                            width: 1
                            height: 20
                        }

                    }

                    // add button as white divider
                    PQButton {
                        id: addbutton
                        x: ontheleft.width
                        height: ontheright.height
                        color: "#555555"
                        text: "+"
                    }

                    // RIGHT COLUMN
                    Column {
                        id: ontheright
                        x: ontheleft.width+addbutton.width+20
                        width: cont.width-x

                        spacing: 5

                        property var cmds: tab_shortcuts.entries[index][1]

                        // show all shortcut actions
                        Repeater {
                            model: ontheright.cmds.length

                            Item {

                                width: parent.width
                                height: ontheright.cmds.length==1 ? 2*c.height+20 : c.height+10

                                // shortcut action
                                PQText {
                                    id: c
                                    y: (parent.height-height)/2
                                    text: tab_shortcuts.strings[ontheright.cmds[index]][0]
                                }

                            }

                        }


                    }

                    Rectangle {

                        id: behaviorcont

                        y: ontheright.height
                        width: cont.width
                        height: ontheright.cmds.length>1 ? behavior.height+20 : 0

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

                            PQCheckbox {
                                id: timeout_check
                                text: "reset cycle timeout (in seconds):"
                                font.pointSize: baselook.fontsize_s
                            }
                            PQSpinBox {
                                id: timeout_spin
                                enabled: timeout_check.checked
                                width: 75
                                height: timeout_check.height
                                font.pointSize: baselook.fontsize_s
                                value: 2
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

}
