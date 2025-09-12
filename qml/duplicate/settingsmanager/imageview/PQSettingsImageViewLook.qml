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
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_look

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Margin")

            helptext: qsTranslate("settingsmanager",  "PhotoQt shows the main image fully stretched across its application window. For an improved visual experience, it can add a small margin of some pixels around the image to not have it stretch completely from edge to edge. Note that once an image is zoomed in the margin might be filled, it only applies to the default zoom level of an image.")

            showLineAbove: false

        },

        PQSliderSpinBox {
            id: marginslider
            width: set_look.contentWidth
            minval: 0
            maxval: 100
            title: qsTranslate("settingsmanager", "margin:")
            suffix: " px"
            onValueChanged:
                set_look.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                marginslider.setValue(PQCSettings.getDefaultForImageviewMargin())

                set_look.checkForChanges()

            }
        },

        /***********************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Image size")

            helptext: qsTranslate("settingsmanager",  "PhotoQt ensures that an image is fully visible when first loaded. To achieve this, large images are zoomed out to fit into the view, but images smaller than the view are left as-is. Alternatively, large images can be loaded at full scale, and small images can be zoomed in to also fit into view. The latter option might result in small images appearing pixelated.") + "<br><br>" + qsTranslate("settingsmanager", "In addition, PhotoQt by default scales the displayed images according to the scale factor of the screen so that images are displayed in their true size. If disabled then the main image will be scaled accordingly with the rest of the application.")

        },

        Flow {
            width: set_look.contentWidth
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
                onCheckedChanged: set_look.checkForChanges()
            }
        },

        Flow {
            width: set_look.contentWidth
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
                onCheckedChanged: set_look.checkForChanges()
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
            onCheckedChanged: set_look.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                large_fit.checked = !PQCSettings.getDefaultForImageviewAlwaysActualSize()
                large_full.checked = PQCSettings.getDefaultForImageviewAlwaysActualSize()
                small_fit.checked = PQCSettings.getDefaultForImageviewFitInWindow()
                small_asis.checked = !PQCSettings.getDefaultForImageviewFitInWindow()
                scale_check.checked = PQCSettings.getDefaultForImageviewRespectDevicePixelRatio()

                set_look.checkForChanges()

            }
        },

        /***********************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Interpolation")

            helptext: qsTranslate("settingsmanager",  "PhotoQt makes use of interpolation algorithms to show smooth lines and avoid potential artefacts to be shown. However, for small images this can lead to blurry images when no interpolation is necessary. Thus, for small images under the specified threshold PhotoQt can skip the use of interpolation algorithms. Note that both the width and height of an image need to be smaller than the threshold for it to be applied.")

        },

        PQCheckBox {
            id: interp_check
            enforceMaxWidth: set_look.contentWidth
            text: qsTranslate("settingsmanager", "disable interpolation for small images")
            onCheckedChanged: set_look.checkForChanges()
        },

        PQSliderSpinBox {
            id: interp_spin
            width: set_look.contentWidth
            minval: 0
            maxval: 1000
            title: qsTranslate("settingsmanager", "threshold:")
            suffix: " px"
            enabled: interp_check.checked
            onValueChanged:
                set_look.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                interp_check.checked = PQCSettings.getDefaultForImageviewInterpolationDisableForSmallImages()
                interp_spin.setValue(PQCSettings.getDefaultForImageviewInterpolationThreshold())

                set_look.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        marginslider.acceptValue()
        interp_spin.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (marginslider.hasChanged() || large_fit.hasChanged() || large_full.hasChanged() ||
                                                      small_fit.hasChanged() || small_asis.hasChanged() || scale_check.hasChanged() ||
                                                      interp_check.hasChanged() || interp_spin.hasChanged())

    }

    function load() {

        settingsLoaded = false

        marginslider.loadAndSetDefault(PQCSettings.imageviewMargin)

        large_fit.loadAndSetDefault(!PQCSettings.imageviewAlwaysActualSize)
        large_full.loadAndSetDefault(PQCSettings.imageviewAlwaysActualSize)
        small_fit.loadAndSetDefault(PQCSettings.imageviewFitInWindow)
        small_asis.loadAndSetDefault(!PQCSettings.imageviewFitInWindow)
        scale_check.loadAndSetDefault(PQCSettings.imageviewRespectDevicePixelRatio)

        interp_check.loadAndSetDefault(PQCSettings.imageviewInterpolationDisableForSmallImages)
        interp_spin.loadAndSetDefault(PQCSettings.imageviewInterpolationThreshold)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewMargin = marginslider.value
        marginslider.saveDefault()

        PQCSettings.imageviewAlwaysActualSize = large_full.checked
        PQCSettings.imageviewFitInWindow = small_fit.checked
        PQCSettings.imageviewRespectDevicePixelRatio = scale_check.checked
        large_fit.saveDefault()
        large_full.saveDefault()
        small_fit.saveDefault()
        small_asis.saveDefault()
        scale_check.saveDefault()

        PQCSettings.imageviewInterpolationDisableForSmallImages = interp_check.checked
        PQCSettings.imageviewInterpolationThreshold = interp_spin.value
        interp_check.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
