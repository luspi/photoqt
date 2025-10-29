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
import PhotoQt

PQSetting {

    id: set_shcu

    disabledAutoIndentation: true
    addBlankSpaceBottom: false

    property string defaultSettings: ""

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property list<var> allcategories: [
        [qsTranslate("settingsmanager", "Viewing Images"), "Viewing Images"],
        [qsTranslate("settingsmanager", "Current File"), "Current File"],
        [qsTranslate("settingsmanager", "Current Folder"), "Current Folder"],
        [qsTranslate("settingsmanager", "Interface"), "Interface"],
        [qsTranslate("settingsmanager", "Other"), "Other"]
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
        ["__goToBottomEdge",     qsTranslate("settingsmanager", "Go to bottom edge of image"), "Go to bottom edge of image", 0],


        /***********************************************************************************/
        // current file

        ["-",                    allcategories[1][0]],

                                 //: Name of shortcut action
        ["__viewerMode",         qsTranslate("settingsmanager", "Enter viewer mode"), "Enter viewer mode", 1],
                                 //: Name of shortcut action
        ["__rename",             qsTranslate("settingsmanager", "Rename File"), "Rename File", 1],
                                 //: Name of shortcut action
        ["__delete",             qsTranslate("settingsmanager", "Delete File"), "Delete File", 1],
                                 //: Name of shortcut action
        ["__deletePermanent",    qsTranslate("settingsmanager", "Delete File permanently (without confirmation)"), "Delete File permanently (without confirmation)", 1],
                                 //: Name of shortcut action
        ["__deleteTrash",        qsTranslate("settingsmanager", "Move file to trash (without confirmation)"), "Move file to trash (without confirmation)", 1],
                                 //: Name of shortcut action
        ["__undoTrash",          qsTranslate("settingsmanager", "Restore file from trash"), "Restore file from trash", 1],
                                 //: Name of shortcut action
        ["__copy",               qsTranslate("settingsmanager", "Copy File to a New Location"), "Copy File to a New Location", 1],
                                 //: Name of shortcut action
        ["__move",               qsTranslate("settingsmanager", "Move File to a New Location"), "Move File to a New Location", 1],
                                 //: Name of shortcut action
        ["__clipboard",          qsTranslate("settingsmanager", "Copy Image to Clipboard"), "Copy Image to Clipboard", 1],
                                 //: Name of shortcut action
        ["__saveAs",             qsTranslate("settingsmanager", "Save image in another format"), "Save image in another format", 1],
                                 //: Name of shortcut action
        ["__print",              qsTranslate("settingsmanager", "Print current photo"), "Print current photo", 1],
                                 //: Name of shortcut action
        ["__imgurAnonym",        qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)"), "Upload to imgur.com (anonymously)", 1],
                                 //: Name of shortcut action
        ["__imgur",              qsTranslate("settingsmanager", "Upload to imgur.com user account"), "Upload to imgur.com user account", 1],
                                 //: Name of shortcut action
        ["__playPauseAni",       qsTranslate("settingsmanager", "Play/Pause animation/video"), "Play/Pause animation/video", 1],
                                 //: Name of shortcut action
        ["__videoJumpForwards",  qsTranslate("settingsmanager", "Go ahead 5 seconds in video"), "Go ahead 5 seconds in video", 1],
                                 //: Name of shortcut action
        ["__videoJumpBackwards", qsTranslate("settingsmanager", "Go back 5 seconds in video"), "Go back 5 seconds in video", 1],
                                 //: Name of shortcut action
        ["__tagFaces",           qsTranslate("settingsmanager", "Start tagging faces"), "Start tagging faces", 1],
                                 //: Name of shortcut action
        ["__enterPhotoSphere",   qsTranslate("settingsmanager", "Enter photo sphere"), "Enter photo sphere", 1],
                                 //: Name of shortcut action
        ["__detectBarCodes",     qsTranslate("settingsmanager", "Detect QR and barcodes"), "Detect QR and barcodes", 1],
                                 //: Name of shortcut action
        ["__crop",               qsTranslate("settingsmanager", "Crop image"), "Crop image", 1],


        /***********************************************************************************/
        // current folder

        ["-",                    allcategories[2][0]],

                                 //: Name of shortcut action
        ["__open",               qsTranslate("settingsmanager", "Open file (browse images)"), "Open file (browse images)", 2],
                                 //: Name of shortcut action
        ["__showMapExplorer",    qsTranslate("settingsmanager", "Show map explorer"), "Show map explorer", 2],
                                //: Name of shortcut action
        ["__filterImages",       qsTranslate("settingsmanager", "Filter images in folder"), "Filter images in folder", 2],
                                 //: Name of shortcut action
        ["__advancedSort",       qsTranslate("settingsmanager", "Advanced image sort (Setup)"), "Advanced image sort (Setup)", 2],
                                 //: Name of shortcut action
        ["__advancedSortQuick",  qsTranslate("settingsmanager", "Advanced image sort (Quickstart)"), "Advanced image sort (Quickstart)", 2],
                                 //: Name of shortcut action
        ["__slideshow",          qsTranslate("settingsmanager", "Start Slideshow (Setup)"), "Start Slideshow (Setup)", 2],
                                 //: Name of shortcut action
        ["__slideshowQuick",     qsTranslate("settingsmanager", "Start Slideshow (Quickstart)"), "Start Slideshow (Quickstart)", 2],


        /***********************************************************************************/
        // interface

        ["-",                    allcategories[3][0]],

                                 //: Name of shortcut action
        ["__contextMenu",        qsTranslate("settingsmanager", "Show Context Menu"), "Show Context Menu", 3],
                                 //: Name of shortcut action
        ["__showMainMenu",       qsTranslate("settingsmanager", "Hide/Show main menu"), "Hide/Show main menu", 3],
                                 //: Name of shortcut action
        ["__showMetaData",       qsTranslate("settingsmanager", "Hide/Show metadata"), "Hide/Show metadata", 3],
                                 //: Name of shortcut action
        ["__showThumbnails",     qsTranslate("settingsmanager", "Hide/Show thumbnails"), "Hide/Show thumbnails", 3],
                                 //: Name of shortcut action
        ["__fullscreenToggle",   qsTranslate("settingsmanager", "Toggle fullscreen mode"), "Toggle fullscreen mode", 3],
                                 //: Name of shortcut action
        ["__close",              qsTranslate("settingsmanager", "Close window (hides to system tray if enabled)"), "Close window (hides to system tray if enabled)", 3],
                                 //: Name of shortcut action
        ["__quit",               qsTranslate("settingsmanager", "Quit PhotoQt"), "Quit PhotoQt", 3],


        /***********************************************************************************/
        // other

        ["-",                    allcategories[4][0]],

                                //: Name of shortcut action
        ["__settings",           qsTranslate("settingsmanager", "Show Settings"), "Show Settings", 4],
                                //: Name of shortcut action
        ["__about",              qsTranslate("settingsmanager", "About PhotoQt"), "About PhotoQt", 4],
                                //: Name of shortcut action
        ["__logging",            qsTranslate("settingsmanager", "Show log/debug messages"), "Show log/debug messages", 4],
                                //: Name of shortcut action
        ["__resetSession",       qsTranslate("settingsmanager", "Reset current session"), "Reset current session", 4],
                                //: Name of shortcut action
        ["__resetSessionAndHide",qsTranslate("settingsmanager", "Reset current session and hide window"), "Reset current session and hide window", 4]

    ]

    Component.onCompleted: {
        PQCConstants.settingsManagerCacheShortcutNames = list_shortcuts
    }

    property var defaultData: ({})
    property var currentData: ({})

    onCurrentDataChanged:
        checkForChanges()

    property list<string> duplicateCombos: []

    content: [

        PQSettingSubtitle {

            showLineAbove: false
            noIndent: true

            title: qsTranslate("settingsmanager", "Shortcuts")

            helptext: qsTranslate("settingsmanager", "PhotoQt is highly customizable by shortcuts. Both key shortcuts and mouse gestures can be used. The list of all available actions is available below and can be filtered by keywords. A key shortcut or mouse gesture can be assigned to multiple actions. How this situation is handled can be adjusted from another subtab that can be found along the left side of the window.")

        },

        Row {

            spacing: 5
            visible: set_shcu.duplicateCombos.length>0

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
                width: set_shcu.contentWidth
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "This symbol indicates a key or mouse combination that is set for more than one shortcut action (for internal and external actions combined).")
            }

        },

        PQLineEdit {
            id: filter_edit
            width: set_shcu.contentWidth
            placeholderText: qsTranslate("settingsmanager", "Type here any text to filter the list of shortcuts and key/mouse combinations")
        },

        ListView {

            id: masterview

            width: set_shcu.contentWidth
            height: set_shcu.availableHeight - masterview.y
            clip: true

            // this is adjusted in load()
            model: 0

            // this ensures all entries are always set up
            cacheBuffer: list_shortcuts.length*60

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
                property string desc_en: cmd==="-" ? "" : dat[2]
                property string cat: cmd==="-" ? "" : set_shcu.allcategories[dat[3]][0]
                property string cat_en: cmd==="-" ? "" : set_shcu.allcategories[dat[3]][1]

                // this bool determines whether the current entry is supposed to be visible
                // it gets adjusted based on what is entered in the filter box
                property bool keepVisible: true

                width: set_shcu.contentWidth
                height: keepVisible ? ((deleg.cmd === "-") ? 40 : 50) : 0
                visible: height>0
                clip: true

                Behavior on height { NumberAnimation { duration: 200 } }

                // this is the header item with no shortcuts
                Loader {

                    // a header is identiied by a single '-' in its command field
                    active: (deleg.cmd === "-")

                    sourceComponent:
                    Item {

                        y: 5
                        width: deleg.width
                        height: 30

                        Rectangle {
                            anchors.fill: parent
                            color: pqtPalette.text
                            opacity: 0.6
                            radius: 5
                        }

                        PQText {
                            x: 10
                            y: (parent.height-height)/2
                            text: deleg.desc
                            font.weight: PQCLook.fontWeightBold
                            color: pqtPalette.base
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
                        height: 40

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
                                width: Math.max(200, Math.min(entrycomp.width/2, 350))

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.weight: PQCLook.fontWeightBold
                                font.pointSize: (PQCLook.fontSize+PQCLook.fontSizeS)/2

                                text: deleg.desc

                            }

                            PQButtonIcon {
                                id: addbutton
                                y: (entrycomp.height-height)/2
                                implicitWidth: 20
                                implicitHeight: 20
                                iconScale: 0.75
                                source: "image://svg/:/" + PQCLook.iconShade + "/zoomin.svg"
                                onClicked: {
                                    PQCNotify.settingsmanagerSendCommand("newShortcut", [deleg.modelData])
                                }
                            }

                            // all the currently set combos
                            ListView {

                                id: comboview

                                y: 5
                                width: entrycomp.width-header.width-addbutton.width-20
                                height: entrycomp.height-10

                                clip: true
                                orientation: ListView.Horizontal
                                boundsBehavior: ListView.StopAtBounds
                                spacing: 10

                                ScrollBar.horizontal: PQHorizontalScrollBar {}

                                // the combos for this command
                                property list<string> combos: PQCShortcuts.getShortcutsForCommand(deleg.cmd)
                                property list<string> default_combos: PQCShortcuts.getShortcutsForCommand(deleg.cmd)
                                onCombosChanged: {
                                    if(!PQF.areTwoListsEqual(combos, default_combos)) {
                                        set_shcu.currentData[deleg.cmd] = comboview.combos
                                        default_combos = combos
                                        set_shcu.calculateDuplicates()
                                        set_shcu.currentDataChanged()
                                    }
                                }

                                model: combos.length

                                // we store two copies of it, one where we track all the changes and one where we store the original state
                                Component.onCompleted: {
                                    set_shcu.defaultData[deleg.cmd] = comboview.default_combos
                                    set_shcu.currentData[deleg.cmd] = comboview.combos
                                }

                                Connections {

                                    target: PQCNotify

                                    function onSettingsmanagerSendCommand(what : string, args : list<var>) {
                                        console.log("args: what =", what)
                                        console.log("args: args =", args)
                                        if(what === "newShortcut") {
                                            if(deleg.modelData === args[0] && args[1] === -1) {
                                                comboview.combos.push(args[2])
                                                comboview.combosChanged()
                                            }
                                        }
                                    }

                                }

                                delegate:
                                Rectangle {

                                    id: shdeleg

                                    required property int modelData

                                    // the current combo
                                    property string combo: comboview.combos[modelData]
                                    onComboChanged: {
                                        if(combo !== comboview.combos[modelData]) {
                                            comboview.combos[modelData] = combo
                                            comboview.combosChanged()
                                        }
                                    }

                                    width: combotxt.width + del_button.width +14 + (mult_loader.active ? mult_loader.width : 0)
                                    height: comboview.height

                                    border.width: 1
                                    border.color: PQCLook.baseBorder
                                    radius: 5

                                    color: pqtPalette.alternateBase

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

                                    PQHighlightMarker {
                                        visible: changemouse.containsMouse
                                    }

                                    Loader {
                                        id: mult_loader
                                        active: set_shcu.duplicateCombos.indexOf(shdeleg.combo)>-1
                                        x: 5
                                        y: (shdeleg.height-height)/2
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
                                            PQCNotify.settingsmanagerSendCommand("changeShortcut", [shdeleg.combo, deleg.modelData, shdeleg.modelData])
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
                                                comboview.combos = comboview.combos.filter(item => item !== shdeleg.combo)
                                            }
                                        }
                                    }

                                    Connections {

                                        target: PQCNotify

                                        function onSettingsmanagerSendCommand(what : string, args : list<var>) {
                                            if(what === "newShortcut") {
                                                if(deleg.modelData === args[0] && shdeleg.modelData === args[1]) {
                                                    shdeleg.combo = args[2]
                                                    set_shcu.calculateDuplicates()
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

    function calculateDuplicates() {

        duplicateCombos = []

        var allsh = []

        for(var cmd in currentData) {
            var combos = currentData[cmd]
            for(var i in combos) {
                var c = combos[i]
                // if we also have an external command set for this combo then we have it at least twice (external and here, internal)
                if(PQCShortcuts.getNumberExternalCommandsForShortcut(c) > 0) {
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

        masterview.model = 0
        masterview.model = list_shortcuts.length

        calculateDuplicates()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var lst = []
        for(var i in currentData) {
            var cur = [i, currentData[i]]
            lst.push(cur)
        }
        PQCShortcuts.saveInternalShortcutCombos(lst)

        PQCConstants.settingsManagerSettingChanged = false

    }

}
