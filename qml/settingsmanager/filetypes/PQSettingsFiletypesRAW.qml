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

    id: set_raw

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "RAW images")

            helptext: qsTranslate("settingsmanager",  "Some RAW images have embedded thumbnail images. If available, PhotoQt will always use those for generating a thumbnail image. Some embedded thumbnails are even as large as the actual RAW image. In that case, PhotoQt can simply load those embedded images instead of the full RAW image. This can result in much faster load times.")

            showLineAbove: false

        },

        PQCheckBox {
            id: rawembed
            enforceMaxWidth: set_raw.contentWidth
            text: qsTranslate("settingsmanager", "use embedded image if available")
            onCheckedChanged: set_raw.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                rawembed.checked = PQCSettings.getDefaultForFiletypesRAWUseEmbeddedIfAvailable()

                set_raw.checkForChanges()

            }
        }

    ]

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = rawembed.hasChanged()

    }

    function load() {

        settingsLoaded = false

        rawembed.loadAndSetDefault(PQCSettings.filetypesRAWUseEmbeddedIfAvailable)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesRAWUseEmbeddedIfAvailable = rawembed.checked
        rawembed.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
