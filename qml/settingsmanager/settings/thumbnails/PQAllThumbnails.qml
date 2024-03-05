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

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

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

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Spacing")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt preloads thumbnails for all files in the current folder and lines them up side by side. In between each thumbnail image it is possible to add a little bit of blank space to better separate the individual images.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {

            x: (parent.width-width)/2

            PQText {
                text: "0px"
            }

            PQSlider {
                id: spacing_slider
                from: 0
                to: 50
                value: PQCSettings.thumbnailsSpacing
                onValueChanged: checkDefault()
            }

            PQText {
                text: "50px"
            }

        }

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "current value:") + " " + spacing_slider.value + "px"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Highlight")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The thumbnail corresponding to the currently loaded image is highlighted so that it is easy to spot. The same highlight effect is used when hovering over a thumbnail image. The different effects can be combined as desired.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            PQCheckBox {
                id: highlight_invertbg
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "invert background color")
                checked: PQCSettings.thumbnailsHighlightAnimation.includes("invertbg")
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: highlight_invertlabel
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "invert label color")
                checked: PQCSettings.thumbnailsHighlightAnimation.includes("invertlabel")
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: highlight_line
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "line below")
                checked: PQCSettings.thumbnailsHighlightAnimation.includes("line")
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: highlight_magnify
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "magnify")
                checked: PQCSettings.thumbnailsHighlightAnimation.includes("magnify")
                onCheckedChanged: checkDefault()
            }

            Row {
                PQCheckBox {
                    id: highlight_liftup_check
                    //: effect for highlighting active thumbnail
                    text: qsTranslate("settingsmanager", "lift up") + ":"
                    checked: PQCSettings.thumbnailsHighlightAnimation.includes("liftup")
                    onCheckedChanged: checkDefault()
                }
                PQText {
                    y: (highlight_liftup_check.height-height)/2
                    enabled: highlight_liftup_check.checked
                    text: "0px"
                }
                PQSlider {
                    id: highlight_liftup_slider
                    y: (highlight_liftup_check.height-height)/2
                    enabled: highlight_liftup_check.checked
                    from: 0
                    to: 100
                    value: PQCSettings.thumbnailsHighlightAnimationLiftUp
                    onValueChanged: checkDefault()
                }
                PQText {
                    y: (highlight_liftup_check.height-height)/2
                    enabled: highlight_liftup_check.checked
                    text: "100px"
                }
            }

            Row {
                enabled: highlight_liftup_check.checked
                Item {
                    width: highlight_liftup_check.width
                    height: 1
                }
                PQText {
                    width: highlight_liftup_slider.width+50
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTranslate("settingsmanager", "current value:") + " " + highlight_liftup_slider.value + "px"
                }
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Center on active")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When switching between images PhotoQt always makes sure that the thumbnail corresponding to the currently viewed image is visible somewhere along the thumbnail bar. Additionally it is possible to tell PhotoQt to not only keep it visible but also keep it in the center of the edge.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: thumb_center
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "keep active thumbnail in center")
            checked: PQCSettings.thumbnailsCenterOnActive
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Visibility")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The visibility of the thumbnail bar can be set depending on personal choice. The bar can either always be kept visible, it can be hidden unless the mouse cursor is close to the respective screen edge, or it can be kept visible unless the main image has been zoomed in.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            PQRadioButton {
                id: vis_needed
                //: used as in: hide thumbnail bar when not needed
                text: qsTranslate("settingsmanager", "hide when not needed")
                checked: PQCSettings.thumbnailsVisibility===0
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: vis_always
                //: used as in: always keep thumbnail bar visible
                text: qsTranslate("settingsmanager", "always keep visible")
                checked: PQCSettings.thumbnailsVisibility===1
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: vis_zoomed
                //: used as in: hide thumbnail bar when zoomed in
                text: qsTranslate("settingsmanager", "hide when zoomed in")
                checked: PQCSettings.thumbnailsVisibility===2
                onCheckedChanged: checkDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (spacing_slider.hasChanged() || highlight_invertbg.hasChanged() || highlight_invertlabel.hasChanged() ||
                          highlight_line.hasChanged() || highlight_magnify.hasChanged() || highlight_liftup_check.hasChanged() ||
                          highlight_liftup_slider.hasChanged() || thumb_center.hasChanged() || vis_needed.hasChanged() ||
                          vis_always.hasChanged() || vis_zoomed.hasChanged())

    }

    function load() {

        spacing_slider.loadAndSetDefault(PQCSettings.thumbnailsSpacing)

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

        PQCSettings.thumbnailsSpacing = spacing_slider.value

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
