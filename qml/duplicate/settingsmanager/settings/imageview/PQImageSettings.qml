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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - imageviewMargin
// - imageviewFitInWindow
// - imageviewAlwaysActualSize
// - imageviewTransparencyMarker
// - imageviewCache
// - imageviewInterpolationThreshold
// - imageviewInterpolationDisableForSmallImages

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingsLoaded: false
    property bool catchEscape: marginslider.editMode || cache_slider.editMode

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    SystemPalette { id: pqtPalette }

    property list<string> colorprofiles: []
    property list<string> colorprofiledescs: []
    property list<string> colorprofiles_contextmenu: []
    property list<string> colorprofiles_contextmenu_default: []

    signal selectAllColorProfiles()
    signal selectNoColorProfiles()
    signal invertColorProfileSelection()
    signal colorProfileLoadDefault()

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_margin

            //: Settings title
            title: qsTranslate("settingsmanager", "Margin")

            helptext: qsTranslate("settingsmanager", "PhotoQt shows the main image fully stretched across its application window. For an improved visual experience, it can add a small margin of some pixels around the image to not have it stretch completely from edge to edge. Note that once an image is zoomed in the margin might be filled, it only applies to the default zoom level of an image.")

            content: [

                PQSliderSpinBox {
                    id: marginslider
                    width: set_margin.rightcol
                    minval: 0
                    maxval: 100
                    title: qsTranslate("settingsmanager", "margin:")
                    suffix: " px"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                marginslider.setValue(PQCSettings.getDefaultForImageviewMargin())
            }

            function handleEscape() {
                marginslider.acceptValue()
            }

            function hasChanged() {
                return marginslider.hasChanged()
            }

            function load() {
                marginslider.loadAndSetDefault(PQCSettings.imageviewMargin)
            }

            function applyChanges() {
                PQCSettings.imageviewMargin = marginslider.value
                marginslider.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sze

            //: Settings title
            title: qsTranslate("settingsmanager", "Image size")

            helptext: qsTranslate("settingsmanager", "PhotoQt ensures that an image is fully visible when first loaded. To achieve this, large images are zoomed out to fit into the view, but images smaller than the view are left as-is. Alternatively, large images can be loaded at full scale, and small images can be zoomed in to also fit into view. The latter option might result in small images appearing pixelated.") + "<br><br>" + qsTranslate("settingsmanager", "In addition, PhotoQt by default scales the displayed images according to the scale factor of the screen so that images are displayed in their true size. If disabled then the main image will be scaled accordingly with the rest of the application.")

            content: [

                Flow {
                    width: set_sze.rightcol
                    Item {
                        width: large_txt.width
                        height: large_fit.height
                        PQText {
                            id: large_txt
                            y: (parent.height-height)/2
                            text: qsTranslate("settingsmanager", "large images:")
                        }
                    }
                    PQRadioButton {
                        id: large_fit
                        text: qsTranslate("settingsmanager", "fit to view")
                    }
                    PQRadioButton {
                        id: large_full
                        text: qsTranslate("settingsmanager", "load at full scale")
                        checked: PQCSettings.imageviewAlwaysActualSize
                        onCheckedChanged: setting_top.checkDefault()
                    }
                },

                Flow {
                    width: set_sze.rightcol
                    Item {
                        width: small_txt.width
                        height: small_fit.height
                        PQText {
                            id: small_txt
                            y: (parent.height-height)/2
                            text: qsTranslate("settingsmanager", "small images:")
                        }
                    }
                    PQRadioButton {
                        id: small_fit
                        text: qsTranslate("settingsmanager", "fit to view")
                        checked: PQCSettings.imageviewFitInWindow
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: small_asis
                        text: qsTranslate("settingsmanager", "load as-is")
                    }
                },

                PQCheckBox {
                    id: scale_check
                    text: qsTranslate("settingsmanager", "respect scale factor of screen")
                    checked: PQCSettings.imageviewRespectDevicePixelRatio
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                large_fit.checked = (PQCSettings.getDefaultForImageviewAlwaysActualSize() === 0)
                large_full.checked = (PQCSettings.getDefaultForImageviewAlwaysActualSize() === 1)
                small_fit.checked = (PQCSettings.getDefaultForImageviewFitInWindow() === 1)
                small_asis.checked = (PQCSettings.getDefaultForImageviewFitInWindow() === 0)
                scale_check.checked = PQCSettings.getDefaultForImageviewRespectDevicePixelRatio()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (large_fit.hasChanged() || large_full.hasChanged() || small_fit.hasChanged() || small_asis.hasChanged() || scale_check.hasChanged())
            }

            function load() {
                large_fit.loadAndSetDefault(!PQCSettings.imageviewAlwaysActualSize)
                large_full.loadAndSetDefault(PQCSettings.imageviewAlwaysActualSize)
                small_fit.loadAndSetDefault(PQCSettings.imageviewFitInWindow)
                small_asis.loadAndSetDefault(!PQCSettings.imageviewFitInWindow)
                scale_check.loadAndSetDefault(PQCSettings.imageviewRespectDevicePixelRatio)
            }

            function applyChanges() {
                PQCSettings.imageviewAlwaysActualSize = large_full.checked
                PQCSettings.imageviewFitInWindow = small_fit.checked
                PQCSettings.imageviewRespectDevicePixelRatio = scale_check.checked
                large_fit.saveDefault()
                large_full.saveDefault()
                small_fit.saveDefault()
                small_asis.saveDefault()
                scale_check.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_trans

            //: Settings title
            title: qsTranslate("settingsmanager", "Transparency marker")

            helptext: qsTranslate("settingsmanager", "When an image contains transparent areas, then that area can be left transparent resulting in the background of PhotoQt to show. Alternatively, it is possible to show a checkerboard pattern behind the image, exposing the transparent areas of an image much clearer.")

            content: [
                PQCheckBox {
                    id: checkerboard
                    enforceMaxWidth: set_trans.rightcol
                    text: qsTranslate("settingsmanager", "show checkerboard pattern")
                    checked: PQCSettings.imageviewTransparencyMarker
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                checkerboard.checked = PQCSettings.getDefaultForImageviewTransparencyMarker()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return checkerboard.hasChanged()
            }

            function load() {
                checkerboard.loadAndSetDefault(PQCSettings.imageviewTransparencyMarker)
            }

            function applyChanges() {
                PQCSettings.imageviewTransparencyMarker = checkerboard.checked
                checkerboard.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_interp

            //: Settings title
            title: qsTranslate("settingsmanager", "Interpolation")

            helptext: qsTranslate("settingsmanager", "PhotoQt makes use of interpolation algorithms to show smooth lines and avoid potential artefacts to be shown. However, for small images this can lead to blurry images when no interpolation is necessary. Thus, for small images under the specified threshold PhotoQt can skip the use of interpolation algorithms. Note that both the width and height of an image need to be smaller than the threshold for it to be applied.")

            content: [

                PQCheckBox {
                    id: interp_check
                    enforceMaxWidth: set_interp.rightcol
                    text: qsTranslate("settingsmanager", "disable interpolation for small images")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQSliderSpinBox {
                    id: interp_spin
                    width: set_interp.rightcol
                    minval: 0
                    maxval: 1000
                    title: qsTranslate("settingsmanager", "threshold:")
                    suffix: " px"
                    enabled: interp_check.checked
                    animateHeight: true
                    onValueChanged:
                        setting_top.checkDefault()
                }


            ]

            onResetToDefaults: {
                interp_check.checked = PQCSettings.getDefaultForImageviewInterpolationDisableForSmallImages()
            }

            function handleEscape() {
                interp_spin.acceptValue()
            }

            function hasChanged() {
                return interp_check.hasChanged()||interp_spin.hasChanged()
            }

            function load() {
                interp_check.loadAndSetDefault(PQCSettings.imageviewInterpolationDisableForSmallImages)
                interp_spin.loadAndSetDefault(PQCSettings.imageviewInterpolationThreshold)
            }

            function applyChanges() {
                PQCSettings.imageviewInterpolationDisableForSmallImages = interp_check.checked
                PQCSettings.imageviewInterpolationThreshold = interp_spin.value
                interp_check.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_cache

            //: Settings title
            title: qsTranslate("settingsmanager", "Cache")

            helptext: qsTranslate("settingsmanager", "Whenever an image is loaded in full, PhotoQt caches such images in order to greatly improve performance if that same image is shown again soon after. This is done up to a certain memory limit after which the first images in the cache will be removed again to free up the required memory. Depending on the amount of memory available on the system, a higher value can lead to an improved user experience.")

            content: [

                PQSliderSpinBox {
                    id: cache_slider
                    width: set_cache.rightcol
                    minval: 256
                    maxval: 5120
                    title: qsTranslate("settingsmanager", "cache size:")
                    suffix: " MB"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                cache_slider.setValue(PQCSettings.getDefaultForImageviewCache())
            }

            function handleEscape() {
                cache_slider.acceptValue()
            }

            function hasChanged() {
                return cache_slider.hasChanged()
            }

            function load() {
                cache_slider.loadAndSetDefault(PQCSettings.imageviewCache)
            }

            function applyChanges() {
                PQCSettings.imageviewCache = cache_slider.value
                cache_slider.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_col

            //: Settings title
            title: qsTranslate("settingsmanager", "Color profiles")

            helptext: qsTranslate("settingsmanager", "There are a variety of options available for handling color profiles. Depending on availability, PhotoQt can use a possibly embedded color profile or apply a custom selected default color profile, and it can offer a customized selection of color profiles through the context menu for choosing a different profile on-the-fly.")

            content: [

                PQCheckBox {
                    id: color_enable
                    enforceMaxWidth: set_col.rightcol
                    text: qsTranslate("settingsmanager", "Enable color profile management")
                    onCheckedChanged:
                        setting_top.checkDefault()
                },

                Item {

                    width: color_col.width
                    height: color_enable.checked ? color_col.height : 0
                    opacity: color_enable.checked ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    clip: true

                    Column {

                        id: color_col
                        spacing: 10

                        PQCheckBox {
                            id: color_embed
                            enforceMaxWidth: set_col.rightcol
                            text: qsTranslate("settingsmanager", "Look for and load embedded color profiles")
                            onCheckedChanged:
                                setting_top.checkDefault()
                        }

                        Flow {

                            spacing: 5
                            width: set_col.rightcol

                            PQCheckBox {
                                id: color_default
                                text: qsTranslate("settingsmanager", "Change default color profile") + (checked ? ":" : " ")
                                onCheckedChanged:
                                    setting_top.checkDefault()
                            }

                            Item {
                                width: color_default.checked ? color_defaultcombo.width : 0
                                height: color_defaultcombo.height
                                opacity: color_default.checked ? 1 : 0
                                Behavior on width { NumberAnimation { duration: 200 } }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                clip: true
                                PQComboBox {
                                    id: color_defaultcombo
                                    extrawide: true
                                    model: [qsTranslate("settingsmanager", "(no default color profile)")].concat(setting_top.colorprofiledescs)
                                    onCurrentIndexChanged:
                                        setting_top.checkDefault()
                                }
                            }

                        }

                        Column {

                            spacing: 5

                            PQText {
                                width: set_col.rightcol
                                elide: Text.ElideMiddle
                                text: qsTranslate("settingsmanager", "Select which color profiles should be offered through the context menu:")
                            }

                            Rectangle {

                                width: Math.min(set_col.rightcol, 600)
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

                                            model: setting_top.colorprofiledescs.length

                                            Rectangle {

                                                id: deleg

                                                required property int modelData

                                                property bool matchesFilter: (color_filter.text===""||setting_top.colorprofiledescs[deleg.modelData].toLowerCase().indexOf(color_filter.text.toLowerCase()) > -1)

                                                width: (color_flickable.width - (color_scroll.visible ? color_scroll.width : 0))/2 - color_grid.spacing
                                                height: matchesFilter ? 30 : 0
                                                opacity: matchesFilter ? 1 : 0
                                                radius: 5

                                                Behavior on height { NumberAnimation { duration: 200 } }
                                                Behavior on opacity { NumberAnimation { duration: 150 } }

                                                color: tilemouse.containsMouse||check.checked ? PQCLook.baseBorder : pqtPalette.base

                                                property bool delegSetup: false
                                                Timer {
                                                    interval: 1000
                                                    running: setting_top.settingsLoaded
                                                    onTriggered:
                                                        deleg.delegSetup = true
                                                }

                                                PQCheckBox {
                                                    id: check
                                                    x: 10
                                                    y: (parent.height-height)/2
                                                    width: parent.width-20  - (delImported.visible ? delImported.width : 0)
                                                    elide: Text.ElideMiddle
                                                    text: setting_top.colorprofiledescs[deleg.modelData]
                                                    font.weight: PQCLook.fontWeightNormal
                                                    font.pointSize: PQCLook.fontSizeS
                                                    extraHovered: tilemouse.containsMouse
                                                    onCheckedChanged: {
                                                        if(!deleg.delegSetup) return
                                                        var curid = PQCScriptsColorProfiles.getColorProfileID(deleg.modelData)
                                                        var arrayIndex = colorprofiles_contextmenu.indexOf(curid)
                                                        if(checked && arrayIndex == -1)
                                                            setting_top.colorprofiles_contextmenu.push(curid)
                                                        else if(!checked && arrayIndex != -1)
                                                            setting_top.colorprofiles_contextmenu.splice(arrayIndex,1)
                                                        setting_top.checkDefault()
                                                    }

                                                    Connections {
                                                        target: setting_top
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
                                                                setting_top.colorprofiledescs = PQCScriptsColorProfiles.getColorProfileDescriptions()
                                                            }
                                                        }
                                                    }
                                                }

                                                Connections {

                                                    target: setting_top

                                                    function onColorProfileLoadDefault() {
                                                        deleg.loadDefault()
                                                    }

                                                }

                                                Component.onCompleted: {
                                                    deleg.loadDefault()
                                                }

                                                function loadDefault() {
                                                    check.checked = (setting_top.colorprofiles_contextmenu_default.indexOf(PQCScriptsColorProfiles.getColorProfileID(deleg.modelData))>-1)
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
                                                setting_top.selectAllColorProfiles()
                                        }
                                        PQButton {
                                            id: butselnone
                                            width: (color_buts.width-20)/3
                                            //: written on button
                                            text: qsTranslate("settingsmanager", "Select none")
                                            smallerVersion: true
                                            onClicked:
                                                setting_top.selectNoColorProfiles()
                                        }
                                        PQButton {
                                            id: butselinv
                                            width: (color_buts.width-20)/3
                                            //: written on button, referring to inverting the selected options
                                            text: qsTranslate("settingsmanager", "Invert")
                                            smallerVersion: true
                                            onClicked:
                                                setting_top.invertColorProfileSelection()
                                        }
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
                                    setting_top.colorprofiledescs = PQCScriptsColorProfiles.getColorProfileDescriptions()
                                }
                            }
                        }

                    }

                }

            ]

            Timer {
                id: setDefaultAfterReset
                interval: 100
                onTriggered: {
                    setting_top.colorprofiles_contextmenu_default = PQCSettings.imageviewColorSpaceContextMenu
                    setting_top.checkDefault()
                }
            }

            onResetToDefaults: {

                setting_top.colorprofiles_contextmenu_default = PQCSettings.getDefaultForImageviewColorSpaceContextMenu()
                setting_top.colorProfileLoadDefault()
                setDefaultAfterReset.restart()

                color_enable.checked = PQCSettings.getDefaultForImageviewColorSpaceEnable()
                color_embed.checked = PQCSettings.getDefaultForImageviewColorSpaceLoadEmbedded()
                if(PQCSettings.getDefaultForImageviewColorSpaceDefault() === "") {
                    color_defaultcombo.currentIndex = 0
                    color_default.checked = false
                } else {
                    color_defaultcombo.currentIndex = (colorprofiles.indexOf(PQCSettings.imageviewColorSpaceDefault)+1)
                    color_default.loadAndSetDefault(true)
                }

            }

            function handleEscape() {}

            function hasChanged() {

                if(color_enable.hasChanged() || color_embed.hasChanged() || color_default.hasChanged() || color_defaultcombo.hasChanged()) {
                    return true
                }

                if(setting_top.colorprofiles_contextmenu.length == setting_top.colorprofiles_contextmenu_default.length) {
                    setting_top.colorprofiles_contextmenu_default.sort()
                    setting_top.colorprofiles_contextmenu.sort()
                    var chg = false
                    for(var i in setting_top.colorprofiles_contextmenu) {
                        if(setting_top.colorprofiles_contextmenu[i] !== setting_top.colorprofiles_contextmenu_default[i]) {
                            chg = true
                            break
                        }
                    }
                    return chg
                }

                return true

            }

            function load() {

                // we need to load this before setting up the element below
                setting_top.colorProfileLoadDefault()

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

            }

            function applyChanges() {

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

            }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_margin.handleEscape()
        set_sze.handleEscape()
        set_trans.handleEscape()
        set_interp.handleEscape()
        set_cache.handleEscape()
        set_col.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (set_margin.hasChanged() || set_sze.hasChanged() || set_trans.hasChanged() ||
                                                      set_interp.hasChanged() || set_cache.hasChanged() || set_col.hasChanged())

    }

    function load() {

        set_margin.load()
        set_sze.load()
        set_trans.load()
        set_interp.load()
        set_cache.load()
        set_col.load()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_margin.applyChanges()
        set_sze.applyChanges()
        set_trans.applyChanges()
        set_interp.applyChanges()
        set_cache.applyChanges()
        set_col.applyChanges()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function revertChanges() {
        load()
    }

}
