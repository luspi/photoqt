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

    id: set_zomi

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Zoom")

            helptext: qsTranslate("settingsmanager",  "PhotoQt allows for a great deal of flexibility in viewing images at the perfect size. Additionally it allows for control of how fast the zoom happens (both in relative and absolute terms), and if there is a minimum/maximum zoom level at which it should always stop no matter what. Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")

            showLineAbove: false

        },

        PQSliderSpinBox {
            id: zoomspeed
            width: set_zomi.contentWidth
            minval: 1
            maxval: 100
            title: qsTranslate("settingsmanager", "zoom speed:")
            suffix: " %"
            onValueChanged:
                set_zomi.checkForChanges()
        },

        Flow {
            PQRadioButton {
                id: zoom_rel
                text: qsTranslate("settingsmanager", "relative zoom speed")
                checked: PQCSettings.imageviewZoomSpeedRelative
                onCheckedChanged: set_zomi.checkForChanges()
            }
            PQRadioButton {
                id: zoom_abs
                text: qsTranslate("settingsmanager", "absolute zoom speed")
                checked: !zoom_rel.checked
                onCheckedChanged: set_zomi.checkForChanges()
            }
        },

        Item {
            width: 1
            height: 5
        },

        Flow {
            width: set_zomi.contentWidth
            PQCheckBox {
                id: minzoom_check
                text: qsTranslate("settingsmanager", "minimum zoom") + (checked ? ": " : "  ")
                onCheckedChanged: set_zomi.checkForChanges()
            }

            PQSliderSpinBox {
                id: minzoom_slider
                width: set_zomi.contentWidth - minzoom_check.width - 10
                minval: 1
                maxval: 100
                enabled: minzoom_check.checked
                animateWidth: true
                title: ""
                suffix: " %"
                onValueChanged:
                    set_zomi.checkForChanges()
            }

        },

        Flow {

            width: set_zomi.contentWidth

            PQCheckBox {
                id: maxzoom_check
                text: qsTranslate("settingsmanager", "maximum zoom") + (checked ? ": " : "  ")
                onCheckedChanged: set_zomi.checkForChanges()
            }

            PQSliderSpinBox {
                id: maxzoom_slider
                width: set_zomi.contentWidth - maxzoom_check.width - 10
                minval: 100
                maxval: 10000
                enabled: maxzoom_check.checked
                animateWidth: true
                title: ""
                suffix: " %"
                onValueChanged:
                    set_zomi.checkForChanges()
            }

        },

        Item {
            width: 1
            height: 5
        },

        Flow {

            width: set_zomi.contentWidth

            PQText {
                height: zoom_mousepos.height
                verticalAlignment: Text.AlignVCenter
                text: qsTranslate("settingsmanager", "Zoom to/from:")
            }

            PQRadioButton {
                id: zoom_mousepos
                //: refers to where to zoom to/from
                text: qsTranslate("settingsmanager", "mouse position")
                onCheckedChanged: set_zomi.checkForChanges()
            }

            PQRadioButton {
                id: zoom_imcent
                //: refers to where to zoom to/from
                text: qsTranslate("settingsmanager", "image center")
                onCheckedChanged: set_zomi.checkForChanges()
            }

        }

    ]

    onResetToDefaults: {

        zoomspeed.setValue(PQCSettings.getDefaultForImageviewZoomSpeed())
        zoom_rel.checked = PQCSettings.getDefaultForImageviewZoomSpeedRelative()===1
        zoom_abs.checked = PQCSettings.getDefaultForImageviewZoomSpeedRelative()===0
        minzoom_check.checked = PQCSettings.getDefaultForImageviewZoomMinEnabled()
        minzoom_slider.setValue(PQCSettings.getDefaultForImageviewZoomMin())
        maxzoom_check.checked = PQCSettings.getDefaultForImageviewZoomMaxEnabled()
        maxzoom_slider.setValue(PQCSettings.getDefaultForImageviewZoomMax())
        zoom_mousepos.checked = PQCSettings.getDefaultForImageviewZoomToCenter()===0
        zoom_imcent.checked = PQCSettings.getDefaultForImageviewZoomToCenter()===1

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {
        zoomspeed.acceptValue()
        minzoom_slider.acceptValue()
        maxzoom_slider.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        PQCConstants.settingsManagerSettingChanged = (zoomspeed.hasChanged() || minzoom_check.hasChanged() || minzoom_slider.hasChanged() ||
                                                      zoom_rel.hasChanged() || zoom_abs.hasChanged() || maxzoom_check.hasChanged() ||
                                                      maxzoom_slider.hasChanged() || zoom_mousepos.hasChanged() || zoom_imcent.hasChanged())

    }

    function load() {

        settingsLoaded = false

        zoomspeed.loadAndSetDefault(PQCSettings.imageviewZoomSpeed)
        zoom_rel.loadAndSetDefault(PQCSettings.imageviewZoomSpeedRelative)
        zoom_abs.loadAndSetDefault(!PQCSettings.imageviewZoomSpeedRelative)
        minzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMinEnabled)
        minzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMin)
        maxzoom_check.loadAndSetDefault(PQCSettings.imageviewZoomMaxEnabled)
        maxzoom_slider.loadAndSetDefault(PQCSettings.imageviewZoomMax)
        zoom_mousepos.loadAndSetDefault(!PQCSettings.imageviewZoomToCenter)
        zoom_imcent.loadAndSetDefault(PQCSettings.imageviewZoomToCenter)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewZoomSpeed = zoomspeed.value
        PQCSettings.imageviewZoomSpeedRelative = zoom_rel.checked
        PQCSettings.imageviewZoomMinEnabled = minzoom_check.checked
        PQCSettings.imageviewZoomMin = minzoom_slider.value
        PQCSettings.imageviewZoomMaxEnabled = maxzoom_check.checked
        PQCSettings.imageviewZoomMax = maxzoom_slider.value
        PQCSettings.imageviewZoomToCenter = zoom_imcent.checked

        zoomspeed.saveDefault()
        zoom_rel.saveDefault()
        zoom_abs.saveDefault()
        minzoom_check.saveDefault()
        minzoom_slider.saveDefault()
        maxzoom_check.saveDefault()
        maxzoom_slider.saveDefault()
        zoom_mousepos.saveDefault()
        zoom_imcent.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
