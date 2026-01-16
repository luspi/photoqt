/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import PhotoQt

PQSetting {

    id: set_bar

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: Settings title
            title: qsTranslate("settingsmanager", "Spacing")

            helptext: qsTranslate("settingsmanager", "PhotoQt preloads thumbnails for all files in the current folder and lines them up side by side. In between each thumbnail image it is possible to add a little bit of blank space to better separate the individual images.")

        },

        PQAdvancedSlider {
            id: spacing_slider
            width: set_bar.contentWidth
            minval: 0
            maxval: 100
            title: ""
            suffix: " px"
            onValueChanged:
                set_bar.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                spacing_slider.setValue(PQCSettings.getDefaultForThumbnailsSpacing())

                set_bar.checkForChanges()

            }
        },

        /*****************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Highlight")

            helptext: qsTranslate("settingsmanager", "The thumbnail corresponding to the currently loaded image is highlighted so that it is easy to spot. The same highlight effect is used when hovering over a thumbnail image. The different effects can be combined as desired.")

        },

        Column {

            spacing: 5

            PQCheckBox {
                id: highlight_invertbg
                enforceMaxWidth: set_bar.contentWidth
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "invert background color")
                onCheckedChanged: set_bar.checkForChanges()
            }

            PQCheckBox {
                id: highlight_invertlabel
                enforceMaxWidth: set_bar.contentWidth
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "invert label color")
                onCheckedChanged: set_bar.checkForChanges()
            }

            PQCheckBox {
                id: highlight_line
                enforceMaxWidth: set_bar.contentWidth
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "line below")
                onCheckedChanged: set_bar.checkForChanges()
            }

            PQCheckBox {
                id: highlight_magnify
                enforceMaxWidth: set_bar.contentWidth
                //: effect for highlighting active thumbnail
                text: qsTranslate("settingsmanager", "magnify")
                onCheckedChanged: set_bar.checkForChanges()
            }

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
                        onCheckedChanged: set_bar.checkForChanges()
                    }
                }

                PQAdvancedSlider {
                    id: highlight_liftup_slider
                    width: set_bar.contentWidth - highlight_liftup_check.width
                    minval: 0
                    maxval: 100
                    title: ""
                    suffix: " px"
                    enabled: highlight_liftup_check.checked
                    onValueChanged:
                        set_bar.checkForChanges()
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var val = PQCSettings.getDefaultForThumbnailsHighlightAnimation()
                highlight_invertbg.checked = (val.includes("invertbg"))
                highlight_invertlabel.checked = (val.includes("invertlabel"))
                highlight_line.checked = (val.includes("line"))
                highlight_magnify.checked = (val.includes("magnify"))
                highlight_liftup_check.checked = (val.includes("liftup"))
                highlight_liftup_slider.setValue(PQCSettings.getDefaultForThumbnailsHighlightAnimationLiftUp())

                set_bar.checkForChanges()

            }
        },

        /****************************************/

        PQSettingSubtitle {

            visible: PQCSettings.generalInterfaceVariant==="integrated"

            //: Settings title
            title: qsTranslate("settingsmanager", "Top or Bottom")

            helptext: qsTranslate("settingsmanager", "With the integrated interface, the thumbnail bar can be shown along the top or bottom edge of the main area. Note that this setting is preserved when changing the interface variant.")

        },

        PQCheckBox {
            id: thumb_enable
            visible: PQCSettings.generalInterfaceVariant==="integrated"
            text: qsTranslate("settingsmanager", "Enable thumbnail bar")
        },

        Column {

            x: 20
            visible: PQCSettings.generalInterfaceVariant==="integrated"
            enabled: thumb_enable.checked
            spacing: 3

            PQRadioButton {
                id: thumb_top
                //: as in: the top edge of the window (for thumbnails bar)
                text: qsTranslate("settingsmanager", "top edge")
            }

            PQRadioButton {
                id: thumb_bot
                //: as in: the bottom edge of the window (for thumbnails bar)
                text: qsTranslate("settingsmanager", "bottom edge")
            }

        },

        PQSettingsResetButton {
            visible: PQCSettings.generalInterfaceVariant==="integrated"
            onResetToDefaults: {

                var defbot = PQCSettings.getDefaultForInterfaceEdgeBottomAction()
                var deftop = PQCSettings.getDefaultForInterfaceEdgeTopAction()

                thumb_enable.loadAndSetDefault(defbot==="thumbnails" || deftop==="thumbnails")
                thumb_top.loadAndSetDefault(deftop==="thumbnails")
                thumb_bot.loadAndSetDefault(deftop!=="thumbnails")

                set_bar.checkForChanges()

            }
        },

        /****************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Center on active")

            helptext: qsTranslate("settingsmanager", "When switching between images PhotoQt always makes sure that the thumbnail corresponding to the currently viewed image is visible somewhere along the thumbnail bar. Additionally it is possible to tell PhotoQt to not only keep it visible but also keep it in the center of the edge.")

        },

        PQCheckBox {
            id: thumb_center
            enforceMaxWidth: set_bar.contentWidth
            text: qsTranslate("settingsmanager", "keep active thumbnail in center")
            onCheckedChanged: set_bar.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                thumb_center.checked = PQCSettings.getDefaultForThumbnailsCenterOnActive()

                set_bar.checkForChanges()

            }
        },

        /*****************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Visibility")

            helptext: qsTranslate("settingsmanager", "The visibility of the thumbnail bar can be set depending on personal choice. The bar can either always be kept visible, it can be hidden unless the mouse cursor is close to the respective screen edge, or it can be kept visible unless the main image has been zoomed in.")

        },

        Column {

            spacing: 5

            PQRadioButton {
                id: vis_needed
                enforceMaxWidth: set_bar.contentWidth
                //: used as in: hide thumbnail bar when not needed
                text: qsTranslate("settingsmanager", "hide when not needed")
                onCheckedChanged: set_bar.checkForChanges()
            }

            PQRadioButton {
                id: vis_always
                enforceMaxWidth: set_bar.contentWidth
                //: used as in: always keep thumbnail bar visible
                text: qsTranslate("settingsmanager", "always keep visible")
                onCheckedChanged: set_bar.checkForChanges()
            }

            PQRadioButton {
                id: vis_zoomed
                enforceMaxWidth: set_bar.contentWidth
                //: used as in: hide thumbnail bar when zoomed in
                text: qsTranslate("settingsmanager", "hide when zoomed in")
                onCheckedChanged: set_bar.checkForChanges()
            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var val = PQCSettings.getDefaultForThumbnailsVisibility()
                vis_needed.checked = (val===0)
                vis_always.checked = (val===1)
                vis_zoomed.checked = (val===2)

                set_bar.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        spacing_slider.acceptValue()
        highlight_liftup_slider.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (spacing_slider.hasChanged() || highlight_invertbg.hasChanged() || highlight_invertlabel.hasChanged() ||
                                                      highlight_line.hasChanged() || highlight_magnify.hasChanged() || highlight_liftup_check.hasChanged() ||
                                                      highlight_liftup_slider.hasChanged() || thumb_center.hasChanged() || vis_needed.hasChanged() ||
                                                      vis_always.hasChanged() || vis_zoomed.hasChanged() || thumb_enable.hasChanged() ||
                                                      thumb_top.hasChanged() || thumb_bot.hasChanged())

    }

    function load() {

        settingsLoaded = false

        spacing_slider.loadAndSetDefault(PQCSettings.thumbnailsSpacing)

        highlight_invertbg.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("invertbg"))
        highlight_invertlabel.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("invertlabel"))
        highlight_line.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("line"))
        highlight_magnify.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("magnify"))
        highlight_liftup_check.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimation.includes("liftup"))
        highlight_liftup_slider.loadAndSetDefault(PQCSettings.thumbnailsHighlightAnimationLiftUp)

        thumb_center.loadAndSetDefault(PQCSettings.thumbnailsCenterOnActive)

        var defbot = PQCSettings.interfaceEdgeBottomAction
        var deftop = PQCSettings.interfaceEdgeTopAction
        thumb_enable.loadAndSetDefault(defbot==="thumbnails" || deftop==="thumbnails")
        thumb_top.loadAndSetDefault(deftop==="thumbnails")
        thumb_bot.loadAndSetDefault(deftop!=="thumbnails")

        vis_needed.loadAndSetDefault(PQCSettings.thumbnailsVisibility===0)
        vis_always.loadAndSetDefault(PQCSettings.thumbnailsVisibility===1)
        vis_zoomed.loadAndSetDefault(PQCSettings.thumbnailsVisibility===2)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsSpacing = spacing_slider.value
        spacing_slider.saveDefault()

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

        if(thumb_enable.checked) {
            if(thumb_top.checked) {
                PQCSettings.interfaceEdgeTopAction = "thumbnails"
                if(PQCSettings.interfaceEdgeLeftAction === "thumbnails") PQCSettings.interfaceEdgeLeftAction = ""
                if(PQCSettings.interfaceEdgeRightAction === "thumbnails") PQCSettings.interfaceEdgeRightAction = ""
                if(PQCSettings.interfaceEdgeBottomAction === "thumbnails") PQCSettings.interfaceEdgeBottomAction = ""
            }
            if(thumb_bot.checked) {
                PQCSettings.interfaceEdgeBottomAction = "thumbnails"
                if(PQCSettings.interfaceEdgeLeftAction === "thumbnails") PQCSettings.interfaceEdgeLeftAction = ""
                if(PQCSettings.interfaceEdgeRightAction === "thumbnails") PQCSettings.interfaceEdgeRightAction = ""
                if(PQCSettings.interfaceEdgeTopAction === "thumbnails") PQCSettings.interfaceEdgeTopAction = ""
            }
        } else {
            if(PQCSettings.interfaceEdgeLeftAction === "thumbnails") PQCSettings.interfaceEdgeLeftAction = ""
            if(PQCSettings.interfaceEdgeRightAction === "thumbnails") PQCSettings.interfaceEdgeRightAction = ""
            if(PQCSettings.interfaceEdgeTopAction === "thumbnails") PQCSettings.interfaceEdgeTopAction = ""
            if(PQCSettings.interfaceEdgeBottomAction === "thumbnails") PQCSettings.interfaceEdgeBottomAction = ""
        }
        thumb_enable.saveDefault()
        thumb_top.saveDefault()
        thumb_bot.saveDefault()

        PQCSettings.thumbnailsHighlightAnimationLiftUp = highlight_liftup_slider.value

        highlight_invertbg.saveDefault()
        highlight_invertlabel.saveDefault()
        highlight_line.saveDefault()
        highlight_magnify.saveDefault()
        highlight_liftup_check.saveDefault()
        highlight_liftup_slider.saveDefault()


        PQCSettings.thumbnailsCenterOnActive = thumb_center.checked
        thumb_center.saveDefault()

        if(vis_needed.checked)
            PQCSettings.thumbnailsVisibility = 0
        else if(vis_always.checked)
            PQCSettings.thumbnailsVisibility = 1
        else if(vis_zoomed.checked)
            PQCSettings.thumbnailsVisibility = 2
        vis_needed.saveDefault()
        vis_always.saveDefault()
        vis_zoomed.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
