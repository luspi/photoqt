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

    id: set_info

    SystemPalette { id: pqtPalette }

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: Settings title
            title: qsTranslate("settingsmanager", "Label")

            helptext: qsTranslate("settingsmanager", "On top of each thumbnail image PhotoQt can put a small text label with the filename. The font size of the filename is freely adjustable. If a filename is too long for the available space only the beginning and end of the filename will be visible. Additionally, the label of thumbnails that are neither loaded nor hovered can be shown with less opacity.")

        },

        PQCheckBox {
            id: label_enable
            enforceMaxWidth: set_info.contentWidth
            text: qsTranslate("settingsmanager", "show filename label")
            onCheckedChanged: set_info.checkForChanges()
        },

        Row {

            id: fontsizerow
            spacing: 10

            Item {
                width: 22
                height: 1
            }

            PQSliderSpinBox {
                id: label_fontsize
                width: set_info.contentWidth - 32
                enabled: label_enable.checked
                minval: 5
                maxval: 20
                title: qsTranslate("settingsmanager", "Font size:")
                suffix: " pt"
                onValueChanged:
                    set_info.checkForChanges()
            }

        },

        PQCheckBox {
            id: thumb_opaque
            enforceMaxWidth: set_info.contentWidth
            enabled: label_enable.checked
            text: qsTranslate("settingsmanager", "decrease opacity for inactive thumbnails")
            onCheckedChanged: set_info.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                label_enable.checked = PQCSettings.getDefaultForThumbnailsFilename()
                label_fontsize.setValue(PQCSettings.getDefaultForThumbnailsFontSize())
                thumb_opaque.checked = PQCSettings.getDefaultForThumbnailsInactiveTransparent()

                set_info.checkForChanges()

            }
        },

        /**************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Tooltip")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show additional information about an image in the form of a tooltip that is shown when the mouse cursor hovers above a thumbnail. The displayed information includes the full file name, file size, and file type.")

        },

        PQCheckBox {
            id: tooltips_show
            enforceMaxWidth: set_info.contentWidth
            text: qsTranslate("settingsmanager", "show tooltips")
            onCheckedChanged: set_info.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                tooltips_show.checked = PQCSettings.getDefaultForThumbnailsTooltip()

                set_info.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        label_fontsize.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (label_enable.hasChanged() || label_fontsize.hasChanged() || thumb_opaque.hasChanged() ||
                                                      tooltips_show.hasChanged())

    }

    function load() {

        settingsLoaded = false

        label_enable.loadAndSetDefault(PQCSettings.thumbnailsFilename)
        label_fontsize.loadAndSetDefault(PQCSettings.thumbnailsFontSize)
        thumb_opaque.loadAndSetDefault(PQCSettings.thumbnailsInactiveTransparent)

        tooltips_show.loadAndSetDefault(PQCSettings.thumbnailsTooltip)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsFilename = label_enable.checked
        PQCSettings.thumbnailsFontSize = label_fontsize.value
        PQCSettings.thumbnailsInactiveTransparent = thumb_opaque.checked
        label_enable.saveDefault()
        label_fontsize.saveDefault()
        thumb_opaque.saveDefault()

        PQCSettings.thumbnailsTooltip = tooltips_show.checked
        tooltips_show.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
