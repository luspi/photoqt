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

import QtQuick
import QtQuick.Controls
import PhotoQt.Modern

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - thumbnailsSpacing
// - thumbnailsHighlightAnimation
// - thumbnailsHighlightAnimationLiftUp
// - thumbnailsVisibility
// - thumbnailsCenterOnActive

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: spacing_slider.contextMenuOpen || spacing_slider.editMode ||
                               highlight_liftup_slider.contextMenuOpen || highlight_liftup_slider.editMode

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_spacing

            //: Settings title
            title: qsTranslate("settingsmanager", "Spacing")

            helptext: qsTranslate("settingsmanager", "PhotoQt preloads thumbnails for all files in the current folder and lines them up side by side. In between each thumbnail image it is possible to add a little bit of blank space to better separate the individual images.")

            content: [

                PQSliderSpinBox {
                    id: spacing_slider
                    width: set_spacing.rightcol
                    minval: 0
                    maxval: 100
                    title: ""
                    suffix: " px"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                spacing_slider.setValue(PQCSettings.getDefaultForThumbnailsSpacing())
            }

            function handleEscape() {
                spacing_slider.closeContextMenus()
                spacing_slider.acceptValue()
            }

            function hasChanged() {
                return spacing_slider.hasChanged()
            }

            function load() {
                spacing_slider.loadAndSetDefault(PQCSettings.thumbnailsSpacing) 
            }

            function applyChanges() {
                PQCSettings.thumbnailsSpacing = spacing_slider.value 
                spacing_slider.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_high

            //: Settings title
            title: qsTranslate("settingsmanager", "Highlight")

            helptext: qsTranslate("settingsmanager", "The thumbnail corresponding to the currently loaded image is highlighted so that it is easy to spot. The same highlight effect is used when hovering over a thumbnail image. The different effects can be combined as desired.")

            content: [

                PQCheckBox {
                    id: highlight_invertbg
                    enforceMaxWidth: set_high.rightcol
                    //: effect for highlighting active thumbnail
                    text: qsTranslate("settingsmanager", "invert background color")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: highlight_invertlabel
                    enforceMaxWidth: set_high.rightcol
                    //: effect for highlighting active thumbnail
                    text: qsTranslate("settingsmanager", "invert label color")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: highlight_line
                    enforceMaxWidth: set_high.rightcol
                    //: effect for highlighting active thumbnail
                    text: qsTranslate("settingsmanager", "line below")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: highlight_magnify
                    enforceMaxWidth: set_high.rightcol
                    //: effect for highlighting active thumbnail
                    text: qsTranslate("settingsmanager", "magnify")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Flow {
                    Item {
                        width: highlight_liftup_check.width
                        height: highlight_liftup_slider.spinboxItemHeight
                        PQCheckBox {
                            id: highlight_liftup_check
                            y: (parent.height-height)/2
                            //: effect for highlighting active thumbnail
                            text: qsTranslate("settingsmanager", "lift up") + (checked ? ":" : " ")
                            checked: PQCSettings.thumbnailsHighlightAnimation.includes("liftup") 
                            onCheckedChanged: setting_top.checkDefault()
                        }
                    }

                    PQSliderSpinBox {
                        id: highlight_liftup_slider
                        width: set_high.rightcol - highlight_liftup_check.width
                        minval: 0
                        maxval: 100
                        title: ""
                        suffix: " px"
                        enabled: highlight_liftup_check.checked
                        animateWidth: true
                        onValueChanged:
                            setting_top.checkDefault()
                    }

                }

            ]

            onResetToDefaults: {
                var val = PQCSettings.getDefaultForThumbnailsHighlightAnimation()
                highlight_invertbg.checked = (val.includes("invertbg"))
                highlight_invertlabel.checked = (val.includes("invertlabel"))
                highlight_line.checked = (val.includes("line"))
                highlight_magnify.checked = (val.includes("magnify"))
                highlight_liftup_check.checked = (val.includes("liftup"))
                highlight_liftup_slider.setValue(PQCSettings.getDefaultForThumbnailsHighlightAnimationLiftUp())
            }

            function handleEscape() {
                highlight_liftup_slider.closeContextMenus()
                highlight_liftup_slider.acceptValue()
            }

            function hasChanged() {
                return (highlight_invertbg.hasChanged() || highlight_invertlabel.hasChanged() ||
                        highlight_line.hasChanged() || highlight_magnify.hasChanged() ||
                        highlight_liftup_check.hasChanged() ||highlight_liftup_slider.hasChanged())
            }

            function load() {
                highlight_invertbg.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("invertbg"))
                highlight_invertlabel.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("invertlabel"))
                highlight_line.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("line"))
                highlight_magnify.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("magnify"))
                highlight_liftup_check.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("liftup"))
                highlight_liftup_slider.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimationLiftUp)
            }

            function applyChanges() {
                var opt = []
                if(highlight_liftup_check.checked)
                    opt.push("liftup")
                if(highlight_invertbg.checked)
                    opt.push("invertbg")
                if(highlight_invertlabel.checked)
                    opt.push("invertlabel")
                if(highlight_line.checked)
                    opt.push("line")
                if(highlight_magnify.checked)
                    opt.push("magnify")
                // a line like this is needed. it seems like opt needs to be accessed for the value passed
                // on to PQCSettings to not be empty on older versions of Qt.
                console.log("thumbnails highlights:", opt)
                PQCSettings.thumbnailsHighlightAnimation = opt

                PQCSettings.thumbnailsHighlightAnimationLiftUp = highlight_liftup_slider.value

                highlight_invertbg.saveDefault()
                highlight_invertlabel.saveDefault()
                highlight_line.saveDefault()
                highlight_magnify.saveDefault()
                highlight_liftup_check.saveDefault()
                highlight_liftup_slider.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_cent

            //: Settings title
            title: qsTranslate("settingsmanager", "Center on active")

            helptext: qsTranslate("settingsmanager", "When switching between images PhotoQt always makes sure that the thumbnail corresponding to the currently viewed image is visible somewhere along the thumbnail bar. Additionally it is possible to tell PhotoQt to not only keep it visible but also keep it in the center of the edge.")

            content: [
                PQCheckBox {
                    id: thumb_center
                    enforceMaxWidth: set_cent.rightcol
                    text: qsTranslate("settingsmanager", "keep active thumbnail in center")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                thumb_center.checked = PQCSettings.getDefaultForThumbnailsCenterOnActive()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return thumb_center.hasChanged()
            }

            function load() {
                thumb_center.loadAndSetDefault(PQCSettings.thumbnailsCenterOnActive)
            }

            function applyChanges() {
                PQCSettings.thumbnailsCenterOnActive = thumb_center.checked
                thumb_center.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_vis

            //: Settings title
            title: qsTranslate("settingsmanager", "Visibility")

            helptext: qsTranslate("settingsmanager", "The visibility of the thumbnail bar can be set depending on personal choice. The bar can either always be kept visible, it can be hidden unless the mouse cursor is close to the respective screen edge, or it can be kept visible unless the main image has been zoomed in.")

            content: [

                PQRadioButton {
                    id: vis_needed
                    enforceMaxWidth: set_vis.rightcol
                    //: used as in: hide thumbnail bar when not needed
                    text: qsTranslate("settingsmanager", "hide when not needed")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: vis_always
                    enforceMaxWidth: set_vis.rightcol
                    //: used as in: always keep thumbnail bar visible
                    text: qsTranslate("settingsmanager", "always keep visible")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: vis_zoomed
                    enforceMaxWidth: set_vis.rightcol
                    //: used as in: hide thumbnail bar when zoomed in
                    text: qsTranslate("settingsmanager", "hide when zoomed in")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                var val = PQCSettings.getDefaultForThumbnailsVisibility()
                vis_needed.checked = (val===0)
                vis_always.checked = (val===1)
                vis_zoomed.checked = (val===2)
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (vis_needed.hasChanged() || vis_always.hasChanged() || vis_zoomed.hasChanged())
            }

            function load() {
                vis_needed.loadAndSetDefault(PQCSettings.thumbnailsVisibility===0)
                vis_always.loadAndSetDefault(PQCSettings.thumbnailsVisibility===1)
                vis_zoomed.loadAndSetDefault(PQCSettings.thumbnailsVisibility===2)
            }

            function applyChanges() {

                if(vis_needed.checked)
                    PQCSettings.thumbnailsVisibility = 0
                else if(vis_always.checked)
                    PQCSettings.thumbnailsVisibility = 1
                else if(vis_zoomed.checked)
                    PQCSettings.thumbnailsVisibility = 2


                vis_needed.saveDefault()
                vis_always.saveDefault()
                vis_zoomed.saveDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_spacing.handleEscape()
        set_high.handleEscape()
        set_cent.handleEscape()
        set_vis.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        settingChanged = (set_spacing.hasChanged() || set_high.hasChanged() || set_cent.hasChanged() || set_vis.hasChanged())

    }

    function load() {

        set_spacing.load()
        set_high.load()
        set_cent.load()
        set_vis.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_spacing.applyChanges()
        set_high.applyChanges()
        set_cent.applyChanges()
        set_vis.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
