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

    id: set_look

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Margin")

            helptext: qsTranslate("settingsmanager",  "PhotoQt shows the main image fully stretched across its application window. For an improved visual experience, it can add a small margin of some pixels around the image to not have it stretch completely from edge to edge. Note that once an image is zoomed in the margin might be filled, it only applies to the default zoom level of an image.")

            showLineAbove: false

        },

        PQAdvancedSlider {
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

        PQText {

            x: -set_look.indentWidth

            width: set_look.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            text: qsTranslate("settingsmanager", "Note that if PhotoQt is told to preserve zoom levels across images, then this setting here will have no effect.")

        },

        /***********************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Rescaling and Interpolation")

            helptext: qsTranslate("settingsmanager", "Whenever an image is shown at a size that is not its original size, PhotoQt employs various techniques to make the image look right. By default, after a transformation (for example zooming) has completed, it loads and displays a properly rescaled version of the image. In certain cases it can be desirable to not do any rescaling for small images (that is, images that are smaller than the window size). It is also possible to disable this behavior altogether for all images (not recommended). When an image is not to be rescaled, then some real-time interpolation can be applied to the displayed image.")

        },

        PQRadioButton {
            id: interp_all
            ButtonGroup { id: interp_grp }
            text: qsTranslate("settingsmanager", "Rescale all images")
            ButtonGroup.group: interp_grp
        },

        PQRadioButton {
            id: interp_nosmall
            text: qsTranslate("settingsmanager", "Rescale all images except for small ones")
            ButtonGroup.group: interp_grp
        },

        PQRadioButton {
            id: interp_none
            text: qsTranslate("settingsmanager", "Do not rescale any images")
            ButtonGroup.group: interp_grp
        },

        Flow {
            spacing: 10
            width: set_look.contentWidth
            enabled: !interp_all.checked
            PQText {
                text: qsTranslate("settingsmanager", "real-time interpolation instead of rescaling:")
            }
            PQCheckBox {
                id: interp_smooth
                text: "smooth"
            }
            PQCheckBox {
                id: interp_mipmap
                text: "mipmap"
            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                interp_all.checked = PQCSettings.getDefaultForImageviewRescalingDisableForImages()===0
                interp_nosmall.checked = PQCSettings.getDefaultForImageviewRescalingDisableForImages()===1
                interp_none.checked = PQCSettings.getDefaultForImageviewRescalingDisableForImages()===2

                interp_smooth.checked = (PQCSettings.getDefaultForImageviewInterpolationFullImage()===1||PQCSettings.getDefaultForImageviewInterpolationFullImage()===3)
                interp_mipmap.checked = (PQCSettings.getDefaultForImageviewInterpolationFullImage()===2||PQCSettings.getDefaultForImageviewInterpolationFullImage()===3)

                set_look.checkForChanges()

            }
        },

        /***********************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Rescaling Mode")

            helptext: qsTranslate("settingsmanager", "Images that are requested that have a different size than their original size need to be rescaled accordingly. Many image plugins support two types of rescaling: Using bilinear smoothing for best quality, or without any smoothing for faster rescaling but potentially resulting in minor artifacts.")

        },

        PQComboBox {
            id: rescalemode
            width: 300
            model: [qsTranslate("settingsmanager", "no smoothing (faster)"),
                    qsTranslate("settingsmanager", "bilinear filtering (better quality)")]
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                rescalemode.currentIndex = PQCSettings.getDefaultForImageviewRescalingSmooth() ? 1 : 0

                set_look.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        marginslider.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (marginslider.hasChanged() || large_fit.hasChanged() || large_full.hasChanged() ||
                                                      small_fit.hasChanged() || small_asis.hasChanged() || scale_check.hasChanged() ||
                                                      interp_all.hasChanged() || interp_nosmall.hasChanged() || interp_none.hasChanged() ||
                                                      rescalemode.hasChanged() || interp_smooth.hasChanged() || interp_mipmap.hasChanged())

    }

    function load() {

        settingsLoaded = false

        marginslider.loadAndSetDefault(PQCSettings.imageviewMargin)

        large_fit.loadAndSetDefault(!PQCSettings.imageviewAlwaysActualSize)
        large_full.loadAndSetDefault(PQCSettings.imageviewAlwaysActualSize)
        small_fit.loadAndSetDefault(PQCSettings.imageviewFitInWindow)
        small_asis.loadAndSetDefault(!PQCSettings.imageviewFitInWindow)
        scale_check.loadAndSetDefault(PQCSettings.imageviewRespectDevicePixelRatio)

        interp_all.loadAndSetDefault(PQCSettings.imageviewRescalingDisableForImages===0)
        interp_nosmall.loadAndSetDefault(PQCSettings.imageviewRescalingDisableForImages===1)
        interp_none.loadAndSetDefault(PQCSettings.imageviewRescalingDisableForImages===2)

        rescalemode.loadAndSetDefault(PQCSettings.imageviewRescalingSmooth ? 1 : 0)

        // PQCSettings.getDefaultForImageviewInterpolationFullImage values:
        // 0 := none
        // 1 := smooth only
        // 2 := mipmap only
        // 3 := smooth and mipmap
        interp_smooth.loadAndSetDefault(PQCSettings.getDefaultForImageviewInterpolationFullImage()===1||PQCSettings.getDefaultForImageviewInterpolationFullImage()===3)
        interp_mipmap.loadAndSetDefault(PQCSettings.getDefaultForImageviewInterpolationFullImage()===2||PQCSettings.getDefaultForImageviewInterpolationFullImage()===3)

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

        PQCSettings.imageviewRescalingDisableForImages = (interp_all.checked ? 0 : (interp_nosmall.checked ? 1 : 2))
        PQCSettings.imageviewRescalingSmooth = rescalemode.currentIndex
        PQCSettings.imageviewInterpolationFullImage = (interp_smooth.checked&&interp_mipmap.checked ?
                                                           3 :
                                                           (interp_mipmap.checked ?
                                                                2 :
                                                                (interp_smooth.checked ? 1 : 0)))

        interp_all.saveDefault()
        interp_nosmall.saveDefault()
        interp_none.saveDefault()
        rescalemode.saveDefault()
        interp_smooth.saveDefault()
        interp_mipmap.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
