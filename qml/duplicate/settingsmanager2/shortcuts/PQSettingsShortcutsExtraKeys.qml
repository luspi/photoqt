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

    id: set_exke

    content: [

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Escape key handling")

            helptext: qsTranslate("settingsmanager", "The Escape key can be used to cancel special actions or modes instead of any configured shortcut action. Here the behavior in certain specific situations can be configured.")

            showLineAbove: false

        },

        PQCheckBox {
            id: escape_doc
            enforceMaxWidth: set_exke.contentWidth
            text: qsTranslate("settingsmanager", "leave document viewer if inside")
            onCheckedChanged: set_exke.checkForChanges()
        },
        PQCheckBox {
            id: escape_arc
            enforceMaxWidth: set_exke.contentWidth
            text: qsTranslate("settingsmanager", "leave archive viewer if inside")
            onCheckedChanged: set_exke.checkForChanges()
        },
        PQCheckBox {
            id: escape_bar
            enforceMaxWidth: set_exke.contentWidth
            text: qsTranslate("settingsmanager", "hide barcodes if any visible")
            onCheckedChanged: set_exke.checkForChanges()
        },
        PQCheckBox {
            id: escape_flt
            enforceMaxWidth: set_exke.contentWidth
            text: qsTranslate("settingsmanager", "remove filter if any set")
            onCheckedChanged: set_exke.checkForChanges()
        },
        PQCheckBox {
            id: escape_sph
            enforceMaxWidth: set_exke.contentWidth
            text: qsTranslate("settingsmanager", "leave photo sphere if any entered")
            onCheckedChanged: set_exke.checkForChanges()
        }

    ]

    onResetToDefaults: {

        escape_doc.checked = PQCSettings.getDefaultForImageviewEscapeExitDocument()
        escape_arc.checked = PQCSettings.getDefaultForImageviewEscapeExitArchive()
        escape_bar.checked = PQCSettings.getDefaultForImageviewEscapeExitBarcodes()
        escape_flt.checked = PQCSettings.getDefaultForImageviewEscapeExitFilter()
        escape_sph.checked = PQCSettings.getDefaultForImageviewEscapeExitSphere()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (escape_doc.hasChanged() || escape_arc.hasChanged() || escape_bar.hasChanged() ||
                                                      escape_flt.hasChanged() || escape_sph.hasChanged())

    }

    function load() {

        settingsLoaded = false

        escape_doc.loadAndSetDefault(PQCSettings.imageviewEscapeExitDocument)
        escape_arc.loadAndSetDefault(PQCSettings.imageviewEscapeExitArchive)
        escape_bar.loadAndSetDefault(PQCSettings.imageviewEscapeExitBarcodes)
        escape_flt.loadAndSetDefault(PQCSettings.imageviewEscapeExitFilter)
        escape_sph.loadAndSetDefault(PQCSettings.imageviewEscapeExitSphere)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.imageviewEscapeExitDocument = escape_doc.checked
        PQCSettings.imageviewEscapeExitArchive = escape_arc.checked
        PQCSettings.imageviewEscapeExitBarcodes = escape_bar.checked
        PQCSettings.imageviewEscapeExitFilter = escape_flt.checked
        PQCSettings.imageviewEscapeExitSphere = escape_sph.checked

        escape_doc.saveDefault()
        escape_arc.saveDefault()
        escape_bar.saveDefault()
        escape_flt.saveDefault()
        escape_sph.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
