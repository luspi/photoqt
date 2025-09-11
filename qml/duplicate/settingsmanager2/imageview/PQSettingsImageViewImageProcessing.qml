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

    id: set_copr

    property list<string> colorprofiles: []
    property list<string> colorprofiledescs: []
    property list<string> colorprofiles_contextmenu: []
    property list<string> colorprofiles_contextmenu_default: []

    signal selectAllColorProfiles()
    signal selectNoColorProfiles()
    signal invertColorProfileSelection()
    signal colorProfileLoadDefault()

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Transparency marker")

            helptext: qsTranslate("settingsmanager",  "When an image contains transparent areas, then that area can be left transparent resulting in the background of PhotoQt to show. Alternatively, it is possible to show a checkerboard pattern behind the image, exposing the transparent areas of an image much clearer.")

            showLineAbove: false

        },

        PQCheckBox {
            id: checkerboard
            enforceMaxWidth: set_copr.contentWidth
            text: qsTranslate("settingsmanager", "show checkerboard pattern")
            checked: PQCSettings.imageviewTransparencyMarker
            onCheckedChanged: set_copr.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                checkerboard.checked = PQCSettings.getDefaultForImageviewTransparencyMarker()

                set_copr.checkForChanges()

            }
        },

        /**********************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Color profiles")
            helptext: qsTranslate("settingsmanager", "There are a variety of options available for handling color profiles. Depending on availability, PhotoQt can use a possibly embedded color profile or apply a custom selected default color profile, and it can offer a customized selection of color profiles through the context menu for choosing a different profile on-the-fly.")
        },

        PQCheckBox {
            id: color_enable
            enforceMaxWidth: set_copr.contentWidth
            text: qsTranslate("settingsmanager", "Enable color profile management")
            onCheckedChanged:
                set_copr.checkForChanges()
        },

        Column {

            id: color_col
            spacing: 10

            enabled: color_enable.checked

            PQCheckBox {
                id: color_embed
                enforceMaxWidth: set_copr.contentWidth
                text: qsTranslate("settingsmanager", "Look for and load embedded color profiles")
                onCheckedChanged:
                    set_copr.checkForChanges()
            }

            Flow {

                spacing: 5
                width: set_copr.contentWidth

                PQCheckBox {
                    id: color_default
                    text: qsTranslate("settingsmanager", "Change default color profile") + (checked ? ":" : " ")
                    onCheckedChanged:
                        set_copr.checkForChanges()
                }

                PQComboBox {
                    id: color_defaultcombo
                    // opacity: color_default.checked ? 1 : 0.5
                    enabled: color_default.checked
                    extrawide: true
                    model: [qsTranslate("settingsmanager", "(no default color profile)")].concat(set_copr.colorprofiledescs)
                    onCurrentIndexChanged:
                        set_copr.checkForChanges()
                }

            }

            Column {

                spacing: 5

                PQText {
                    width: set_copr.contentWidth
                    elide: Text.ElideMiddle
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTranslate("settingsmanager", "Select which color profiles should be offered through the context menu:")
                }

                Rectangle {

                    width: Math.min(set_copr.contentWidth, 600)
                    height: 350
                    clip: true
                    color: "transparent"
                    border.width: 1
                    border.color: PQCLook.baseBorder

                    PQLineEdit {
                        id: color_filter
                        width: parent.width
                        //: placeholder text in a text edit
                        placeholderText: qsTranslate("settingsmanager", "Filter color profiles")
                    }

                    Flickable {

                        id: color_flickable

                        x: 5
                        y: color_filter.height
                        width: parent.width - (color_scroll.visible ? 5 : 10)
                        height: parent.height-color_filter.height-color_buts.height

                        contentHeight: color_grid.height
                        clip: true

                        ScrollBar.vertical: PQVerticalScrollBar { id: color_scroll }

                        Grid {

                            id: color_grid

                            columns: 2
                            spacing: 5
                            padding: 5

                            Repeater {

                                model: set_copr.colorprofiledescs.length

                                Rectangle {

                                    id: deleg

                                    required property int modelData

                                    property bool matchesFilter: (color_filter.text===""||set_copr.colorprofiledescs[deleg.modelData].toLowerCase().indexOf(color_filter.text.toLowerCase()) > -1)

                                    width: (color_flickable.width - (color_scroll.visible ? color_scroll.width : 0))/2 - color_grid.spacing
                                    height: matchesFilter ? 30 : 0
                                    opacity: matchesFilter ? 1 : 0
                                    radius: 5

                                    Behavior on height { NumberAnimation { duration: 200 } }
                                    Behavior on opacity { NumberAnimation { duration: 150 } }

                                    color: (enabled&&(tilemouse.containsMouse||check.checked)) ? PQCLook.baseBorder : pqtPalette.base

                                    property bool delegSetup: false
                                    Timer {
                                        interval: 1000
                                        running: set_copr.settingsLoaded
                                        onTriggered:
                                            deleg.delegSetup = true
                                    }

                                    PQCheckBox {
                                        id: check
                                        x: 10
                                        y: (parent.height-height)/2
                                        width: parent.width-20  - (delImported.visible ? delImported.width : 0)
                                        elide: Text.ElideMiddle
                                        text: set_copr.colorprofiledescs[deleg.modelData]
                                        font.weight: PQCLook.fontWeightNormal
                                        font.pointSize: PQCLook.fontSizeS
                                        extraHovered: tilemouse.containsMouse
                                        onCheckedChanged: {
                                            if(!deleg.delegSetup) return
                                            var curid = PQCScriptsColorProfiles.getColorProfileID(deleg.modelData)
                                            var arrayIndex = colorprofiles_contextmenu.indexOf(curid)
                                            if(checked && arrayIndex === -1)
                                                set_copr.colorprofiles_contextmenu.push(curid)
                                            else if(!checked && arrayIndex !== -1)
                                                set_copr.colorprofiles_contextmenu.splice(arrayIndex,1)
                                            set_copr.checkForChanges()
                                        }

                                        Connections {
                                            target: set_copr
                                            function onSelectAllColorProfiles() {
                                                check.checked = true
                                            }
                                            function onSelectNoColorProfiles() {
                                                check.checked = false
                                            }
                                            function onInvertColorProfileSelection() {
                                                check.checked = !check.checked
                                            }
                                        }

                                    }

                                    PQMouseArea {
                                        id: tilemouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked:
                                            check.checked = !check.checked
                                    }

                                    PQTextL {
                                        id: delImported
                                        x: (parent.width-width-5)
                                        y: (parent.height-height)/2
                                        opacity: delmouse.containsMouse ? 1 : 0.2
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                        visible: deleg.modelData < PQCScriptsColorProfiles.getImportedColorProfiles().length
                                        text: "x"
                                        color: "red"
                                        font.weight: PQCLook.fontWeightBold

                                        PQMouseArea {
                                            id: delmouse
                                            enabled: delImported.visible
                                            anchors.fill: delImported
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            text: qsTranslate("settingsmanager", "Remove imported color profile")
                                            onClicked: {
                                                check.checked = false
                                                if(PQCScriptsColorProfiles.removeImportedColorProfile(deleg.modelData)) {
                                                    set_copr.colorprofiledescs = PQCScriptsColorProfiles.getColorProfileDescriptions()
                                                }
                                            }
                                        }
                                    }

                                    Connections {

                                        target: set_copr

                                        function onColorProfileLoadDefault() {
                                            deleg.loadDefault()
                                        }

                                    }

                                    Component.onCompleted: {
                                        deleg.loadDefault()
                                    }

                                    function loadDefault() {
                                        check.checked = (set_copr.colorprofiles_contextmenu_default.indexOf(PQCScriptsColorProfiles.getColorProfileID(deleg.modelData))>-1)
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

                        id: color_buts
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
                                width: (color_buts.width-20)/3
                                //: written on button
                                text: qsTranslate("settingsmanager", "Select all")
                                smallerVersion: true
                                onClicked:
                                    set_copr.selectAllColorProfiles()
                            }
                            PQButton {
                                id: butselnone
                                width: (color_buts.width-20)/3
                                //: written on button
                                text: qsTranslate("settingsmanager", "Select none")
                                smallerVersion: true
                                onClicked:
                                    set_copr.selectNoColorProfiles()
                            }
                            PQButton {
                                id: butselinv
                                width: (color_buts.width-20)/3
                                //: written on button, referring to inverting the selected options
                                text: qsTranslate("settingsmanager", "Invert")
                                smallerVersion: true
                                onClicked:
                                    set_copr.invertColorProfileSelection()
                            }
                        }

                    }

                }

                PQButton {
                    id: butlcms2import
                    visible: PQCScriptsConfig.isLCMS2SupportEnabled()
                    text: qsTranslate("settingsmanager", "Import color profile")
                    onClicked: {
                        if(PQCScriptsColorProfiles.importColorProfile()) {
                            set_copr.colorprofiledescs = PQCScriptsColorProfiles.getColorProfileDescriptions()
                        }
                    }
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                colorprofiles_contextmenu_default = PQCSettings.getDefaultForImageviewColorSpaceContextMenu()
                colorProfileLoadDefault()
                colorProfilesSetDefaultAfterReset.restart()

                color_enable.checked = PQCSettings.getDefaultForImageviewColorSpaceEnable()
                color_embed.checked = PQCSettings.getDefaultForImageviewColorSpaceLoadEmbedded()
                if(PQCSettings.getDefaultForImageviewColorSpaceDefault() === "") {
                    color_defaultcombo.currentIndex = 0
                    color_default.checked = false
                } else {
                    color_defaultcombo.currentIndex = (colorprofiles.indexOf(PQCSettings.imageviewColorSpaceDefault)+1)
                    color_default.loadAndSetDefault(true)
                }

                set_copr.checkForChanges()

            }
        }

    ]

    Timer {
        id: colorProfilesSetDefaultAfterReset
        interval: 100
        onTriggered: {
            set_copr.colorprofiles_contextmenu_default = PQCSettings.imageviewColorSpaceContextMenu
            set_copr.checkForChanges()
        }
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        var chg = false
        if(colorprofiles_contextmenu.length == colorprofiles_contextmenu_default.length) {
            colorprofiles_contextmenu_default.sort()
            colorprofiles_contextmenu.sort()
            for(var i in colorprofiles_contextmenu) {
                if(colorprofiles_contextmenu[i] !== colorprofiles_contextmenu_default[i]) {
                    chg = true
                    break
                }
            }
        }

        PQCConstants.settingsManagerSettingChanged = (checkerboard.hasChanged() || color_enable.hasChanged() || color_embed.hasChanged() ||
                                                      color_default.hasChanged() || color_defaultcombo.hasChanged() || chg)

    }

    function load() {

        settingsLoaded = false

        checkerboard.loadAndSetDefault(PQCSettings.imageviewTransparencyMarker)

        // we need to load this before setting up the element below
        colorProfileLoadDefault()

        colorprofiledescs = PQCScriptsColorProfiles.getColorProfileDescriptions()
        colorprofiles = PQCScriptsColorProfiles.getColorProfiles()
        colorprofiles_contextmenu = PQCSettings.imageviewColorSpaceContextMenu
        colorprofiles_contextmenu_default = PQCSettings.imageviewColorSpaceContextMenu

        color_enable.loadAndSetDefault(PQCSettings.imageviewColorSpaceEnable)
        color_embed.loadAndSetDefault(PQCSettings.imageviewColorSpaceLoadEmbedded)
        if(PQCSettings.imageviewColorSpaceDefault === "") {
            color_defaultcombo.loadAndSetDefault(0)
            color_default.loadAndSetDefault(false)
        } else {
            color_defaultcombo.loadAndSetDefault(colorprofiles.indexOf(PQCSettings.imageviewColorSpaceDefault)+1)
            color_default.loadAndSetDefault(true)
        }

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewTransparencyMarker = checkerboard.checked
        checkerboard.saveDefault()

        PQCSettings.imageviewColorSpaceEnable = color_enable.checked
        if(color_defaultcombo.currentIndex === 0 || !color_default.checked)
            PQCSettings.imageviewColorSpaceDefault = ""
        else
            PQCSettings.imageviewColorSpaceDefault = colorprofiles[color_defaultcombo.currentIndex-1]
        PQCSettings.imageviewColorSpaceLoadEmbedded = color_embed.checked
        PQCSettings.imageviewColorSpaceContextMenu = colorprofiles_contextmenu
        colorprofiles_contextmenu_default = PQCSettings.imageviewColorSpaceContextMenu

        color_enable.saveDefault()
        color_embed.saveDefault()
        color_default.saveDefault()
        color_defaultcombo.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
