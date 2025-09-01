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

    id: set_docu

    content: [

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Documents")

            helptext: qsTranslate("settingsmanager", "When a document is loaded it is possible to navigate through the pages of such a file either through floating controls that show up when the document contains more than one page, or by entering the viewer mode. When the viewer mode is activated all pages are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating navigation.")

            showLineAbove: false

        },

        PQCheckBox {
            id: documentcontrols
            enforceMaxWidth: set_docu.contentWidth
            text: qsTranslate("settingsmanager", "show floating controls for documents")
            onCheckedChanged: set_docu.checkForChanges()
        },

        PQCheckBox {
            id: documentleftright
            enforceMaxWidth: set_docu.contentWidth
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
            onCheckedChanged: set_docu.checkForChanges()
        }

    ]

    onResetToDefaults: {

        documentcontrols.checked = PQCSettings.getDefaultForFiletypesDocumentControls()
        documentleftright.checked = PQCSettings.getDefaultForFiletypesDocumentLeftRight()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        PQCConstants.settingsManagerSettingChanged = (documentcontrols.hasChanged() || documentleftright.hasChanged())

    }

    function load() {

        settingsLoaded = false

        documentcontrols.loadAndSetDefault(PQCSettings.filetypesDocumentControls)
        documentleftright.loadAndSetDefault(PQCSettings.filetypesDocumentLeftRight)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesDocumentControls = documentcontrols.checked
        PQCSettings.filetypesDocumentLeftRight = documentleftright.checked
        documentcontrols.saveDefault()
        documentleftright.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
