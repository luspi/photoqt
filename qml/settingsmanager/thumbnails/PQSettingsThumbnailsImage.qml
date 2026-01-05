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
import PhotoQt

PQSetting {

    id: set_thumb

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Size")

            helptext: qsTranslate("settingsmanager", "The thumbnails are typically hidden behind one of the screen edges. Which screen edge can be specified in the interface settings. The size of the thumbnails refers to the maximum size of each individual thumbnail image.")

        },

        PQAdvancedSlider {
            id: thumb_size
            width: set_thumb.contentWidth
            sliderExtraWide: true
            minval: 32
            maxval: 4000
            title: ""
            suffix: " px"
            onValueChanged:
                set_thumb.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                thumb_size.setValue(PQCSettings.getDefaultForThumbnailsSize())

                set_thumb.checkForChanges()

            }
        },

        /***********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Scale and crop")

            helptext: qsTranslate("settingsmanager", "The thumbnail for an image can either be scaled to fit fully inside the maximum size specified above, or it can be scaled and cropped such that it takes up all available space. In the latter case some parts of a thumbnail image might be cut off. In addition, thumbnails that are smaller than the size specified above can be kept at their original size.") +
                      "<br><br>" + qsTranslate("settingsmanager", "A third option is to scale all thumbnails to the height of the bar and vary their width. Note that this requires all thumbnails to be preloaded at the start potentially causing short stutters in the interface. Such a listing of images at various widths can also be a little more difficult to scroll through.")

        },

        Column {

            spacing: 5

            PQRadioButton {
                ButtonGroup { id: grp_scalecrop }
                id: thumb_fit
                enforceMaxWidth: set_thumb.contentWidth
                text: qsTranslate("settingsmanager", "fit thumbnail")
                onCheckedChanged: set_thumb.checkForChanges()
                ButtonGroup.group: grp_scalecrop
            }

            PQRadioButton {
                id: thumb_crop
                enforceMaxWidth: set_thumb.contentWidth
                text: qsTranslate("settingsmanager", "scale and crop thumbnail")
                onCheckedChanged: set_thumb.checkForChanges()
                ButtonGroup.group: grp_scalecrop
            }

            PQRadioButton {
                id: thumb_sameheight
                enforceMaxWidth: set_thumb.contentWidth
                text: qsTranslate("settingsmanager", "same height, varying width")
                onCheckedChanged: set_thumb.checkForChanges()
                ButtonGroup.group: grp_scalecrop
            }

        },

        PQCheckBox {
            id: thumb_small
            enforceMaxWidth: set_thumb.contentWidth
            text: qsTranslate("settingsmanager", "keep small thumbnails small")
            onCheckedChanged: set_thumb.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var valCropToFit = PQCSettings.getDefaultForThumbnailsCropToFit()
                var valSameHeight = PQCSettings.getDefaultForThumbnailsSameHeightVaryWidth()
                var valKeepSmall = PQCSettings.getDefaultForThumbnailsSmallThumbnailsKeepSmall()
                thumb_fit.checked = (!valCropToFit && !valSameHeight)
                thumb_crop.checked = valCropToFit
                thumb_sameheight.checked = valSameHeight
                thumb_small.checked = valKeepSmall

                set_thumb.checkForChanges()

            }
        },

        /***********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Icons only")

            helptext: qsTranslate("settingsmanager", "Instead of loading actual thumbnail images in the background, PhotoQt can instead simply show the respective icon for the filetype. This requires much fewer resources and time but is not as user friendly.")

        },

        Column {

            spacing: 5

            PQRadioButton {
                ButtonGroup { id: grp_icon }
                id: thumb_actual
                enforceMaxWidth: set_thumb.contentWidth
                //: The word actual is used with the same meaning as: real
                text: qsTranslate("settingsmanager", "use actual thumbnail images")
                onCheckedChanged: set_thumb.checkForChanges()
                ButtonGroup.group: grp_icon
            }

            PQRadioButton {
                id: thumb_icon
                enforceMaxWidth: set_thumb.contentWidth
                text: qsTranslate("settingsmanager", "use filetype icons")
                onCheckedChanged: set_thumb.checkForChanges()
                ButtonGroup.group: grp_icon
            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                thumb_actual.checked = PQCSettings.getDefaultForThumbnailsIconsOnly()
                thumb_icon.checked = !thumb_actual.checked

                set_thumb.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        thumb_size.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = thumb_size.hasChanged() || thumb_fit.hasChanged() || thumb_crop.hasChanged() || thumb_small.hasChanged() ||
                                                     thumb_sameheight.hasChanged() || thumb_actual.hasChanged() || thumb_icon.hasChanged()

    }

    function load() {

        settingsLoaded = false

        thumb_size.loadAndSetDefault(PQCSettings.thumbnailsSize)

        thumb_fit.loadAndSetDefault(!PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth)
        thumb_crop.loadAndSetDefault(PQCSettings.thumbnailsCropToFit)
        thumb_sameheight.loadAndSetDefault(PQCSettings.thumbnailsSameHeightVaryWidth)
        thumb_small.loadAndSetDefault(PQCSettings.thumbnailsSmallThumbnailsKeepSmall)

        thumb_actual.loadAndSetDefault(!PQCSettings.thumbnailsIconsOnly)
        thumb_icon.loadAndSetDefault(PQCSettings.thumbnailsIconsOnly)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsSize = thumb_size.value
        thumb_size.saveDefault()

        PQCSettings.thumbnailsCropToFit = thumb_crop.checked
        PQCSettings.thumbnailsSameHeightVaryWidth = thumb_sameheight.checked
        PQCSettings.thumbnailsSmallThumbnailsKeepSmall = thumb_small.checked
        thumb_fit.saveDefault()
        thumb_crop.saveDefault()
        thumb_sameheight.saveDefault()
        thumb_small.saveDefault()

        PQCSettings.thumbnailsIconsOnly = thumb_icon.checked
        thumb_actual.saveDefault()
        thumb_icon.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
