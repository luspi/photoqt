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
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_popo

    SystemPalette { id: pqtPalette }

    //: Used as identifying name for one of the elements in the interface
    property list<var> pops: [["interfacePopoutFileDialog", qsTranslate("settingsmanager", "File dialog")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMapExplorer", qsTranslate("settingsmanager", "Map explorer")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSettingsManager", qsTranslate("settingsmanager", "Settings manager")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMainMenu", qsTranslate("settingsmanager", "Main menu")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutMetadata", qsTranslate("settingsmanager", "Metadata")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSlideshowSetup", qsTranslate("settingsmanager", "Slideshow setup")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutSlideshowControls", qsTranslate("settingsmanager", "Slideshow controls")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileRename", qsTranslate("settingsmanager", "Rename file")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFileDelete", qsTranslate("settingsmanager", "Delete file")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutAbout", qsTranslate("settingsmanager", "About")],
                        //: Noun, not a verb. Used as identifying name for one of the elements in the interface
                        ["interfacePopoutFilter", qsTranslate("settingsmanager", "Filter")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutAdvancedSort", qsTranslate("settingsmanager", "Advanced image sort")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfacePopoutChromecast", qsTranslate("settingsmanager", "Streaming (Chromecast)")],
                        //: Used as identifying name for one of the elements in the interface
                        ["interfaceMinimapPopout", qsTranslate("settingsmanager", "Minimap")]]

    property list<string> currentCheckBoxStates: ["0","0","0","0","0",
                                                  "0","0","0","0","0",
                                                  "0","0","0","0","0",
                                                  "0","0","0","0","0",
                                                  "0"]
    property string _defaultCurrentCheckBoxStates: ""
    onCurrentCheckBoxStatesChanged:
        checkForChanges()

    signal popoutLoadDefault()
    signal popoutResetToDefault()
    signal popoutSaveChanges()

    signal selectAllPopouts()
    signal selectNoPopouts()
    signal invertPopoutSelection()

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Popout")

            helptext: qsTranslate("settingsmanager", "Almost all of the elements for displaying information or performing actions can either be shown integrated into the main window or shown popped out in their own window. Most of them can also be popped out/in through a small button at the top left corner of each elements.")

        },

        Rectangle {

            width: Math.min(parent.width, 600)
            height: 350
            color: "transparent"
            border.width: 1
            border.color: PQCLook.baseBorder

            PQLineEdit {
                id: popout_filter
                width: parent.width
                //: placeholder text in a text edit
                placeholderText: qsTranslate("settingsmanager", "Filter popouts")
            }

            Flickable {

                id: popout_flickable

                x: 5
                y: popout_filter.height
                width: parent.width - (popout_scroll.visible ? 5 : 10)
                height: parent.height-popout_filter.height-popout_buts.height

                contentHeight: popout_col.height
                clip: true

                ScrollBar.vertical: PQVerticalScrollBar { id: popout_scroll }

                Grid {

                    id: popout_col
                    spacing: 5

                    columns: 3
                    padding: 5

                    Repeater {

                        model: set_popo.pops.length

                        Rectangle {

                            id: deleg

                            required property int modelData

                            property bool matchesFilter: (popout_filter.text===""||set_popo.pops[modelData][1].toLowerCase().indexOf(popout_filter.text.toLowerCase()) > -1)

                            width: (popout_flickable.width - (popout_scroll.visible ? popout_scroll.width : 0))/3 - popout_col.spacing
                            height: matchesFilter ? 30 : 0
                            opacity: matchesFilter ? 1 : 0
                            radius: 5

                            Behavior on height { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            property bool hovered: false

                            color: hovered||check.checked ? PQCLook.baseBorder : pqtPalette.base
                            Behavior on color { ColorAnimation { duration: 200 } }

                            PQToolTip {
                                delay: 500
                                timeout: 5000
                                visible: deleg.hovered
                                text: set_popo.pops[deleg.modelData][1]
                            }

                            PQCheckBox {
                                id: check
                                x: 10
                                width: deleg.width-20
                                y: (parent.height-height)/2
                                text: set_popo.pops[deleg.modelData][1]
                                font.weight: PQCLook.fontWeightNormal
                                font.pointSize: PQCLook.fontSizeS
                                elide: Text.ElideRight
                                onCheckedChanged: {
                                    set_popo.currentCheckBoxStates[deleg.modelData] = (checked ? "1" : "0")
                                    set_popo.currentCheckBoxStatesChanged()
                                }

                                Connections {
                                    target: set_popo
                                    function onSelectAllPopouts() {
                                        check.checked = true
                                    }
                                    function onSelectNoPopouts() {
                                        check.checked = false
                                    }
                                    function onInvertPopoutSelection() {
                                        check.checked = !check.checked
                                    }
                                }

                            }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered:
                                    deleg.hovered = true
                                onExited:
                                    deleg.hovered = false
                                onClicked:
                                    check.checked = !check.checked
                            }

                            Connections {

                                target: set_popo

                                function onPopoutLoadDefault() {

                                    var p = set_popo.pops[deleg.modelData][0]

                                    if(p === "interfacePopoutFileDialog") check.checked = PQCSettings.interfacePopoutFileDialog
                                    else if(p === "interfacePopoutMapExplorer") check.checked = PQCSettings.interfacePopoutMapExplorer
                                    else if(p === "interfacePopoutSettingsManager") check.checked = PQCSettings.interfacePopoutSettingsManager
                                    else if(p === "interfacePopoutMainMenu") check.checked = PQCSettings.interfacePopoutMainMenu
                                    else if(p === "interfacePopoutMetadata") check.checked = PQCSettings.interfacePopoutMetadata

                                    else if(p === "interfacePopoutSlideshowSetup") check.checked = PQCSettings.interfacePopoutSlideshowSetup
                                    else if(p === "interfacePopoutSlideshowControls") check.checked = PQCSettings.interfacePopoutSlideshowControls

                                    else if(p === "interfacePopoutFileRename") check.checked = PQCSettings.interfacePopoutFileRename
                                    else if(p === "interfacePopoutFileDelete") check.checked = PQCSettings.interfacePopoutFileDelete
                                    else if(p === "interfacePopoutAbout") check.checked = PQCSettings.interfacePopoutAbout

                                    else if(p === "interfacePopoutFilter") check.checked = PQCSettings.interfacePopoutFilter
                                    else if(p === "interfacePopoutAdvancedSort") check.checked = PQCSettings.interfacePopoutAdvancedSort
                                    else if(p === "interfacePopoutChromecast") check.checked = PQCSettings.interfacePopoutChromecast
                                    else if(p === "interfaceMinimapPopout") check.checked = PQCSettings.interfaceMinimapPopout

                                }
                                function onPopoutResetToDefault() {

                                    var p = set_popo.pops[deleg.modelData][0]

                                    if(p === "interfacePopoutFileDialog") check.checked = PQCSettings.getDefaultForInterfacePopoutFileDialog()
                                    else if(p === "interfacePopoutMapExplorer") check.checked = PQCSettings.getDefaultForInterfacePopoutMapExplorer()
                                    else if(p === "interfacePopoutSettingsManager") check.checked = PQCSettings.getDefaultForInterfacePopoutSettingsManager()
                                    else if(p === "interfacePopoutMainMenu") check.checked = PQCSettings.getDefaultForInterfacePopoutMainMenu()
                                    else if(p === "interfacePopoutMetadata") check.checked = PQCSettings.getDefaultForInterfacePopoutMetadata()

                                    else if(p === "interfacePopoutSlideshowSetup") check.checked = PQCSettings.getDefaultForInterfacePopoutSlideshowSetup()
                                    else if(p === "interfacePopoutSlideshowControls") check.checked = PQCSettings.getDefaultForInterfacePopoutSlideshowControls()

                                    else if(p === "interfacePopoutFileRename") check.checked = PQCSettings.getDefaultForInterfacePopoutFileRename()
                                    else if(p === "interfacePopoutFileDelete") check.checked = PQCSettings.getDefaultForInterfacePopoutFileDelete()
                                    else if(p === "interfacePopoutAbout") check.checked = PQCSettings.getDefaultForInterfacePopoutAbout()

                                    else if(p === "interfacePopoutFilter") check.checked = PQCSettings.getDefaultForInterfacePopoutFilter()
                                    else if(p === "interfacePopoutAdvancedSort") check.checked = PQCSettings.getDefaultForInterfacePopoutAdvancedSort()
                                    else if(p === "interfacePopoutChromecast") check.checked = PQCSettings.getDefaultForInterfacePopoutChromecast()
                                    else if(p === "interfaceMinimapPopout") check.checked = PQCSettings.getDefaultForInterfaceMinimapPopout()

                                }

                                function onPopoutSaveChanges() {
                                    PQCSettings[set_popo.pops[deleg.modelData][0]] = check.checked
                                }
                            }

                        }

                    }

                    Item {
                        width: 1
                        height: 1
                    }

                }

            }

            Item {

                id: popout_buts
                y: (parent.height-height)
                width: parent.width
                height: 50

                Rectangle {
                    width: parent.width
                    height: 1
                    color: PQCLook.baseBorder
                }

                Row {
                    x: 5
                    y: (parent.height-height)/2
                    spacing: 5
                    PQButton {
                        id: butselall
                        width: (popout_buts.width-20)/3
                        //: written on button
                        text: qsTranslate("settingsmanager", "Select all")
                        smallerVersion: true
                        onClicked:
                            set_popo.selectAllPopouts()
                    }
                    PQButton {
                        id: butselnone
                        width: (popout_buts.width-20)/3
                        //: written on button
                        text: qsTranslate("settingsmanager", "Select none")
                        smallerVersion: true
                        onClicked:
                            set_popo.selectNoPopouts()
                    }
                    PQButton {
                        id: butselinv
                        width: (popout_buts.width-20)/3
                        //: written on button, referring to inverting the selected options
                        text: qsTranslate("settingsmanager", "Invert")
                        smallerVersion: true
                        onClicked:
                            set_popo.invertPopoutSelection()
                    }
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                popoutResetToDefault()

                set_popo.checkForChanges()

            }
        },

        /****************************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Non-modal popouts")
            helptext: qsTranslate("settingsmanager", "All popouts by default are modal windows. That means that they block the main interface until they are closed again. Some popouts can be switched to a non-modal behavior, allowing them to stay open while using the main interface.") + "<br><br>" + qsTranslate("settingsmanager", "Please note: If a popout is set to be non-modal then it will not be able to receive any shortcut commands anymore.")
        },

        PQCheckBox {
            id: keepopen_fd_check
            enforceMaxWidth: set_popo.contentWidth
            text: qsTranslate("settingsmanager", "make file dialog non-modal")
            onCheckedChanged:
                set_popo.checkForChanges()
        },

        PQCheckBox {
            id: keepopen_me_check
            enforceMaxWidth: set_popo.contentWidth
            text: qsTranslate("settingsmanager", "make map explorer non-modal")
            onCheckedChanged:
                set_popo.checkForChanges()
        },

        PQCheckBox {
            id: keepopen_sm_check
            enforceMaxWidth: set_popo.contentWidth
            text: qsTranslate("settingsmanager", "make settings manager non-modal")
            onCheckedChanged:
                set_popo.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                keepopen_fd_check.checked = PQCSettings.getDefaultForInterfacePopoutFileDialogNonModal()
                keepopen_me_check.checked = PQCSettings.getDefaultForInterfacePopoutMapExplorerNonModal()
                keepopen_sm_check.checked = PQCSettings.getDefaultForInterfacePopoutSettingsManagerNonModal()

                set_popo.checkForChanges()

            }
        },

        /****************************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Pop out when window is small")
            helptext: qsTranslate("settingsmanager",  "Some elements might not be as usable or function well when the window is too small. Thus it is possible to force such elements to be popped out automatically whenever the application window is too small.")
        },

        PQCheckBox {
            id: checksmall
            enforceMaxWidth: set_popo.contentWidth
            text: qsTranslate("settingsmanager",  "pop out when application window is small")
            onCheckedChanged:
                set_popo.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                checksmall.checked = PQCSettings.getDefaultForInterfacePopoutWhenWindowIsSmall()

                set_popo.checkForChanges()

            }
        }

    ]

    Timer {
        interval: 100
        id: saveDefaultCheckTimer
        onTriggered: {
            set_popo._defaultCurrentCheckBoxStates = set_popo.currentCheckBoxStates.join("")
        }
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (_defaultCurrentCheckBoxStates !== currentCheckBoxStates.join("") ||
                                                      keepopen_fd_check.hasChanged() || keepopen_me_check.hasChanged() ||
                                                      keepopen_sm_check.hasChanged() || checksmall.hasChanged())

    }

    function load() {

        settingsLoaded = false

        popoutLoadDefault()
        saveDefaultCheckTimer.restart()

        keepopen_fd_check.loadAndSetDefault(PQCSettings.interfacePopoutFileDialogNonModal)
        keepopen_me_check.loadAndSetDefault(PQCSettings.interfacePopoutMapExplorerNonModal)
        keepopen_sm_check.loadAndSetDefault(PQCSettings.interfacePopoutSettingsManagerNonModal)

        checksmall.loadAndSetDefault(PQCSettings.interfacePopoutWhenWindowIsSmall)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        popoutSaveChanges()
        _defaultCurrentCheckBoxStates = currentCheckBoxStates.join("")

        PQCSettings.interfacePopoutFileDialogNonModal = keepopen_fd_check.checked
        PQCSettings.interfacePopoutMapExplorerNonModal = keepopen_me_check.checked
        PQCSettings.interfacePopoutSettingsManagerNonModal = keepopen_sm_check.checked
        keepopen_fd_check.saveDefault()
        keepopen_me_check.saveDefault()
        keepopen_sm_check.saveDefault()

        PQCSettings.interfacePopoutWhenWindowIsSmall = checksmall.checked
        checksmall.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
