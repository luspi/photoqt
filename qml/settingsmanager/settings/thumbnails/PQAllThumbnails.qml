/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import PQCNotify

import "../../../elements"

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
                            checked: PQCSettings.thumbnailsHighlightAnimation.includes("liftup") // qmllint disable unqualified
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

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        spacing_slider.closeContextMenus()
        spacing_slider.acceptValue()
        highlight_liftup_slider.closeContextMenus()
        highlight_liftup_slider.acceptValue()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        settingChanged = (spacing_slider.hasChanged() || highlight_invertbg.hasChanged() || highlight_invertlabel.hasChanged() ||
                          highlight_line.hasChanged() || highlight_magnify.hasChanged() || highlight_liftup_check.hasChanged() ||
                          highlight_liftup_slider.hasChanged() || thumb_center.hasChanged() || vis_needed.hasChanged() ||
                          vis_always.hasChanged() || vis_zoomed.hasChanged())

    }

    function load() {

        spacing_slider.loadAndSetDefault(PQCSettings.thumbnailsSpacing) // qmllint disable unqualified

        highlight_invertbg.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("invertbg"))
        highlight_invertlabel.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("invertlabel"))
        highlight_line.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("line"))
        highlight_magnify.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("magnify"))
        highlight_liftup_check.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("liftup"))
        highlight_liftup_slider.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimationLiftUp)

        thumb_center.loadAndSetDefault(PQCSettings.thumbnailsCenterOnActive)

        vis_needed.loadAndSetDefault(PQCSettings.thumbnailsVisibility===0)
        vis_always.loadAndSetDefault(PQCSettings.thumbnailsVisibility===1)
        vis_zoomed.loadAndSetDefault(PQCSettings.thumbnailsVisibility===2)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsSpacing = spacing_slider.value // qmllint disable unqualified

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
        PQCSettings.thumbnailsHighlightAnimation = opt

        PQCSettings.thumbnailsHighlightAnimationLiftUp = highlight_liftup_slider.value

        PQCSettings.thumbnailsCenterOnActive = thumb_center.checked

        if(vis_needed.checked)
            PQCSettings.thumbnailsVisibility = 0
        else if(vis_always.checked)
            PQCSettings.thumbnailsVisibility = 1
        else if(vis_zoomed.checked)
            PQCSettings.thumbnailsVisibility = 2

        spacing_slider.saveDefault()
        highlight_invertbg.saveDefault()
        highlight_invertlabel.saveDefault()
        highlight_line.saveDefault()
        highlight_magnify.saveDefault()
        highlight_liftup_check.saveDefault()
        highlight_liftup_slider.saveDefault()
        thumb_center.saveDefault()
        vis_needed.saveDefault()
        vis_always.saveDefault()
        vis_zoomed.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
