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
import PhotoQt

PQSetting {

    id: set_capr

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Cache")

            helptext: qsTranslate("settingsmanager",  "Whenever an image is loaded in full, PhotoQt caches such images in order to greatly improve performance if that same image is shown again soon after. This is done up to a certain memory limit after which the first images in the cache will be removed again to free up the required memory. Depending on the amount of memory available on the system, a higher value can lead to an improved user experience.")

            showLineAbove: false

        },

        PQAdvancedSlider {
            id: cache_slider
            width: set_capr.contentWidth
            minval: 256
            maxval: 5120
            title: qsTranslate("settingsmanager", "cache size:")
            suffix: " MB"
            onValueChanged:
                set_capr.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                cache_slider.setValue(PQCSettings.getDefaultForImageviewCache())

                set_capr.checkForChanges()

            }
        },

        /*************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Preloading")
            helptext: qsTranslate("settingsmanager", "The number of images in both directions (previous and next) that should be preloaded in the background. Images are not preloaded until the main image has been displayed. This improves navigating through all images in the folder, but the tradeoff is an increased memory consumption. It is recommended to keep this at a low number.")
        },

        Column {

            id: preloadcol

            spacing: 5

            PQAdvancedSlider {
                id: preload
                width: set_capr.contentWidth
                minval: 0
                maxval: 5
                title: ""
                suffix: ""
                onValueChanged:
                    set_capr.checkForChanges()
            }

            PQText {
                width: set_capr.contentWidth
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: preload.value == 0 ?
                          qsTranslate("settingsmanager", "only current image will be loaded") :
                          (preload.value == 1 ?
                               qsTranslate("settingsmanager", "preload 1 image in both directions") :
                               qsTranslate("settingsmanager", "preload %1 images in both directions").arg(preload.value))

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                preload.setValue(PQCSettings.getDefaultForImageviewPreloadInBackground())

                set_capr.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        cache_slider.acceptValue()
        preload.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = cache_slider.hasChanged() || preload.hasChanged()

    }

    function load() {

        settingsLoaded = false

        cache_slider.loadAndSetDefault(PQCSettings.imageviewCache)
        preload.loadAndSetDefault(PQCSettings.imageviewPreloadInBackground)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewCache = cache_slider.value
        cache_slider.saveDefault()

        PQCSettings.imageviewPreloadInBackground = preload.value
        preload.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
