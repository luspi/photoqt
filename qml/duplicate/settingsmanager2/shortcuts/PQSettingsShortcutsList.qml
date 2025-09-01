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

    id: set_shcu

    disabledAutoIndentation: true
    addBlankSpaceBottom: false

    property string defaultSettings: ""

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property list<var> allcategories: [
        [qsTranslate("settingsmanager", "Viewing Images"), "Viewing Images"]
    ]

    // each entry is of the following structure:
    // 1. internal command ('-' for a heading)
    // 2. localized shortcut description
    // 3. english shortcut description
    // 4. category index
    property list<var> list_shortcuts: [

        /***********************************************************************************/
        // viewing images

        ["-",                    allcategories[0][0]],

                                 //: Name of shortcut action
        ["__next",               qsTranslate("settingsmanager", "Next image"), "Next image", 0],
                                 //: Name of shortcut action
        ["__prev",               qsTranslate("settingsmanager", "Previous image"), "Previous image", 0],
                                 //: Name of shortcut action
        ["__goToFirst",          qsTranslate("settingsmanager", "Go to first image"), "Go to first image", 0],
                                 //: Name of shortcut action
        ["__goToLast",           qsTranslate("settingsmanager", "Go to last image"), "Go to last image", 0],
                                 //: Name of shortcut action
        ["__nextArcDoc",         qsTranslate("settingsmanager", "Next archive or document"), "Next archive or document", 0],
                                 //: Name of shortcut action
        ["__prevArcDoc",         qsTranslate("settingsmanager", "Previous archive or document"), "Previous archive or document", 0],
                                 //: Name of shortcut action
        ["__zoomIn",             qsTranslate("settingsmanager", "Zoom In"), "Zoom In", 0],
                                 //: Name of shortcut action
        ["__zoomOut",            qsTranslate("settingsmanager", "Zoom Out"), "Zoom Out", 0],
                                 //: Name of shortcut action
        ["__zoomActual",         qsTranslate("settingsmanager", "Zoom to Actual Size (toggle)"), "Zoom to Actual Size (toggle)", 0],
                                 //: Name of shortcut action
        ["__fitInWindow",        qsTranslate("settingsmanager", "Zoom to Fit Window (toggle)"), "Zoom to Fit Window (toggle)", 0],
                                 //: Name of shortcut action
        ["__zoomReset",          qsTranslate("settingsmanager", "Reset Zoom"), "Reset Zoom", 0],
                                 //: Name of shortcut action
        ["__rotateR",            qsTranslate("settingsmanager", "Rotate Right"), "Rotate Right", 0],
                                 //: Name of shortcut action
        ["__rotateL",            qsTranslate("settingsmanager", "Rotate Left"), "Rotate Left", 0],
                                 //: Name of shortcut action
        ["__rotate0",            qsTranslate("settingsmanager", "Reset Rotation"), "Reset Rotation", 0],
                                 //: Name of shortcut action
        ["__flipH",              qsTranslate("settingsmanager", "Mirror Horizontally"), "Mirror Horizontally", 0],
                                 //: Name of shortcut action
        ["__flipV",              qsTranslate("settingsmanager", "Mirror Vertically"), "Mirror Vertically", 0],
                                 //: Name of shortcut action
        ["__flipReset",          qsTranslate("settingsmanager", "Reset Mirror"), "Reset Mirror", 0],
                                 //: Name of shortcut action
        ["__loadRandom",         qsTranslate("settingsmanager", "Load a random image"), "Load a random image", 0],
                                 //: Name of shortcut action
        ["__showFaceTags",       qsTranslate("settingsmanager", "Hide/Show face tags (stored in metadata)"), "Hide/Show face tags (stored in metadata)", 0],
                                 //: Name of shortcut action
        ["__toggleAlwaysActualSize", qsTranslate("settingsmanager", "Load image at actual size by default (toggle)"), "Load image at actual size by default (toggle)", 0],
                                 //: Name of shortcut action
        ["__chromecast",         qsTranslate("settingsmanager", "Stream content to Chromecast device"), "Stream content to Chromecast device", 0],
                                 //: Name of shortcut action
        ["__flickViewLeft",      qsTranslate("settingsmanager", "Flick view left"), "Flick view left", 0],
                                 //: Name of shortcut action
        ["__flickViewRight",     qsTranslate("settingsmanager", "Flick view right"), "Flick view right", 0],
                                 //: Name of shortcut action
        ["__flickViewUp",        qsTranslate("settingsmanager", "Flick view up"), "Flick view up", 0],
                                 //: Name of shortcut action
        ["__flickViewDown",      qsTranslate("settingsmanager", "Flick view down"), "Flick view down", 0],
                                 //: Name of shortcut action
        ["__moveViewLeft",       qsTranslate("settingsmanager", "Move view left"), "Move view left", 0],
                                 //: Name of shortcut action
        ["__moveViewRight",      qsTranslate("settingsmanager", "Move view right"), "Move view right", 0],
                                 //: Name of shortcut action
        ["__moveViewUp",         qsTranslate("settingsmanager", "Move view up"), "Move view up", 0],
                                 //: Name of shortcut action
        ["__moveViewDown",       qsTranslate("settingsmanager", "Move view down"), "Move view down", 0],
                                 //: Name of shortcut action
        ["__goToLeftEdge",       qsTranslate("settingsmanager", "Go to left edge of image"), "Go to left edge of image", 0],
                                 //: Name of shortcut action
        ["__goToRightEdge",      qsTranslate("settingsmanager", "Go to right edge of image"), "Go to right edge of image", 0],
                                 //: Name of shortcut action
        ["__goToTopEdge",        qsTranslate("settingsmanager", "Go to top edge of image"), "Go to top edge of image", 0],
                                 //: Name of shortcut action
        ["__goToBottomEdge",     qsTranslate("settingsmanager", "Go to bottom edge of image"), "Go to bottom edge of image", 0]
    ]

    property var defaultData: ({})
    property var currentData: ({})

    content: [

        Item {
            width: 1
            height: 5
        },

        PQText {
            width: set_shcu.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: "PhotoQt is highly customizable by shortcuts. Both key shortcuts and mouse gestures can be used. The list of all available actions is available below and can be filtered by keywords. A key shortcut or mouse gesture can be assigned to multiple actions. By default, these actions are all triggered together, however, this behavior can be adjusted so that PhotoQt cycles through the actions one by one each time the shortcut occurs. This behavior can be adjusted from another subtab that can be found along the left side of the window."
        },

        PQLineEdit {
            id: filter_edit
            width: set_shcu.contentWidth
            placeholderText: qsTranslate("settingsmanager", "Type here any text to filter the list of shortcuts and key/mouse combinations")
        },

        ListView {

            id: masterview

            // holds the current maximum header width to have all shortcuts start at the same spot
            property int headerWidth: 100
            // how wide the titles can be at most before wrapping
            property int maxHeaderWidth: 500

            width: set_shcu.contentWidth
            height: set_shcu.availableHeight

            model: list_shortcuts.length

            // this ensures all entries are always set up
            cacheBuffer: list_shortcuts.length*80

            ScrollBar.vertical: PQVerticalScrollBar {}

            // this is only visible if no shortcut is shown
            // this is only the case when a search string was entered and nothing matched
            PQTextXL {
                visible: masterview.contentHeight < 1
                x: (parent.height-height)/2
                y: 100
                color: pqtPaletteDisabled.text
                text: qsTranslate("settingsmanager", "no shortcut found")
                font.weight: PQCLook.fontWeightBold
                opacity: 0.5
            }

            delegate:
            Item {

                id: deleg

                // access and store the data for this entry
                required property int modelData
                property list<string> dat: list_shortcuts[modelData]
                property string cmd: dat[0]
                property string desc: dat[1]
                property string desc_en: dat[2]
                property string cat: set_shcu.allcategories[dat[3]][0]
                property string cat_en: set_shcu.allcategories[dat[3]][1]

                // this bool determines whether the current entry is supposed to be visible
                // it gets adjusted based on what is entered in the filter box
                property bool keepVisible: true

                width: set_shcu.contentWidth
                height: keepVisible ? 70 : 0
                visible: height>0
                clip: true

                Behavior on height { NumberAnimation { duration: 200 } }

                // this is the header item with no shortcuts
                Loader {

                    // a header is identiied by a single '-' in its command field
                    active: (deleg.cmd === "-")

                    sourceComponent:
                    Rectangle {

                        y: 5
                        width: deleg.width
                        height: 60

                        color: PQCLook.baseBorder
                        radius: 5

                        PQTextL {
                            x: 10
                            y: (parent.height-height)/2
                            text: deleg.desc
                            font.weight: PQCLook.fontWeightBold
                        }

                        Connections {
                            target: filter_edit
                            function onTextChanged() {
                                deleg.keepVisible = (filter_edit.text==="")
                            }
                        }
                    }
                }

                // this is the current shortcut entry
                Loader {

                    active: (deleg.cmd !== "-")

                    sourceComponent:
                    Rectangle {

                        id: entrycomp

                        y: 5
                        width: deleg.width
                        height: 60

                        border.width: 1
                        border.color: PQCLook.baseBorder
                        radius: 5

                        clip: true
                        color: pqtPalette.base

                        // we react to changes in the filter text and check whether this one passes
                        Connections {

                            target: filter_edit

                            function onTextChanged() {

                                var fil = filter_edit.text.toLowerCase()

                                // check for description and category in english and localized language
                                if(fil === "" || deleg.desc.toLowerCase().indexOf(fil) > -1 || deleg.desc_en.toLowerCase().indexOf(fil) > -1 ||
                                        deleg.cat.toLowerCase().indexOf(fil) > -1 || deleg.cat_en.toLowerCase().indexOf(fil) > -1) {
                                    deleg.keepVisible = true
                                    return
                                }

                                // translate all combos and check for filter string
                                for(var i in comboview.combos) {
                                    if(PQCScriptsShortcuts.translateShortcut(comboview.combos[i]).toLowerCase().indexOf(fil) > -1 ||
                                            comboview.combos[i].toLowerCase().indexOf(fil) > -1) {
                                        deleg.keepVisible = true
                                        return
                                    }
                                }

                                // arrived here? entry does not pass filter.
                                deleg.keepVisible = false

                            }
                        }

                        // a row containing (a) the title of the shortcut actions, and (b) a list of all the shortcuts combos set
                        Row {

                            x: 10
                            spacing: 10

                            // the title text
                            PQText {

                                id: header
                                y: (entrycomp.height-height)/2

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.weight: PQCLook.fontWeightBold

                                text: deleg.desc

                                // width changed? if not wider than limit width but wider than all others, record it
                                onWidthChanged: {
                                    if(width > masterview.maxHeaderWidth) {
                                        width = masterview.maxHeaderWidth
                                        masterview.headerWidth = masterview.maxHeaderWidth
                                    } else if(width > masterview.headerWidth+5)
                                        masterview.headerWidth = width
                                }
                                // max width changed? make sure we adopt it
                                Connections {
                                    target: masterview
                                    function onHeaderWidthChanged() {
                                        if(masterview.headerWidth > header.width)
                                            header.width = masterview.headerWidth
                                    }
                                }
                                // just created and some max width already set? adopt it
                                Component.onCompleted: {
                                    if(width > masterview.maxHeaderWidth) {
                                        width = masterview.maxHeaderWidth
                                        masterview.headerWidth = masterview.maxHeaderWidth
                                    } else if(masterview.headerWidth > width)
                                        header.width = masterview.headerWidth
                                }

                            }

                            // all the currently set combos
                            ListView {

                                id: comboview

                                y: 5
                                width: entrycomp.width-header.width-10
                                height: entrycomp.height-10

                                orientation: ListView.Horizontal
                                spacing: 10

                                // the combos for this command
                                property list<string> combos: PQCShortcuts.getShortcutsForCommand(deleg.cmd)

                                model: combos.length

                                // we store two copies of it, one where we track all the changes and one where we store the original state
                                Component.onCompleted: {
                                    set_shcu.defaultData[deleg.cmd] = comboview.combos
                                    set_shcu.currentData[deleg.cmd] = comboview.combos
                                }

                                delegate:
                                Rectangle {

                                    id: shdeleg

                                    required property int modelData

                                    // the current combo
                                    property string combo: comboview.combos[modelData]

                                    width: therow.width+12
                                    height: parent.height

                                    border.width: 1
                                    border.color: PQCLook.baseBorder
                                    radius: 5

                                    color: pqtPalette.alternateBase

                                    // the combo text and a delete button
                                    Row {

                                        id: therow

                                        x: 10
                                        spacing: 5

                                        PQText {
                                            y: (shdeleg.height-height)/2
                                            text: PQCScriptsShortcuts.translateShortcut(shdeleg.combo)
                                        }

                                        Image {
                                            y: 2
                                            width: 20
                                            height: 20
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
                                                    console.warn(">>> DELETE ME!")
                                                }
                                            }
                                        }
                                    }
                                }

                                // this is only visible if not combo was set for this action yet
                                PQText {
                                    visible: comboview.combos.length===0
                                    y: (parent.height-height)/2
                                    color: pqtPaletteDisabled.text
                                    text: qsTranslate("settingsmanager", "no key combination set")
                                    font.weight: PQCLook.fontWeightBold
                                    opacity: 0.5
                                }
                            }
                        }
                    }
                }

            }

        }

    ]

    onResetToDefaults: {


        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        // PQCConstants.settingsManagerSettingChanged =

    }

    function load() {

        settingsLoaded = false


        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {


        PQCConstants.settingsManagerSettingChanged = false

    }

}
