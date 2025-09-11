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

    id: set_arc

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Archives")

            helptext: qsTranslate("settingsmanager",  "PhotoQt allows the browsing of all images contained in an archive file (ZIP, RAR, etc.) as if they all are located in a folder. By default, PhotoQt uses Libarchive for this purpose, but for RAR archives in particular PhotoQt can call the external tool unrar to load and display the archive and its contents. Note that this requires unrar to be installed and located in your path.")

            showLineAbove: false

        },

        PQCheckBox {
            id: arc_extunrar
            enforceMaxWidth: set_arc.contentWidth
            text: qsTranslate("settingsmanager", "use external tool: unrar")
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQSettingSubtitle {

            showLineAbove: false

            helptext: qsTranslate("settingsmanager",  "When an archive is loaded it is possible to browse through the contents of such a file either through floating controls that show up when the archive contains more than one file, or by entering the viewer mode. When the viewer mode is activated all files in the archive are loaded as thumbnails. The viewer mode can be activated by shortcut or through a small button located below the status info and as part of the floating controls.")

        },

        PQCheckBox {
            id: archivecontrols
            enforceMaxWidth: set_arc.contentWidth
            text: qsTranslate("settingsmanager", "show floating controls for archives")
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQCheckBox {
            id: archiveleftright
            enforceMaxWidth: set_arc.contentWidth
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next page")
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQCheckBox {
            id: archive_escape
            text: qsTranslate("settingsmanager", "Escape key leaves archive viewer")
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQCheckBox {
            id: archive_exitbutton
            text: qsTranslate("settingsmanager", "Show button to exit archive viewer")
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQCheckBox {
            id: archive_autoenter
            text: qsTranslate("settingsmanager", "Automatically enter archive viewer")
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQCheckBox {
            id: archive_comautoenter
            text: qsTranslate("settingsmanager", "Automatically enter comic book viewer")
            onCheckedChanged: set_arc.checkForChanges()
        }

    ]

    onResetToDefaults: {

        arc_extunrar.checked = PQCSettings.getDefaultForFiletypesExternalUnrar()
        archivecontrols.checked = PQCSettings.getDefaultForFiletypesArchiveControls()
        archiveleftright.checked = PQCSettings.getDefaultForFiletypesArchiveLeftRight()
        archive_escape.checked = PQCSettings.getDefaultForImageviewEscapeExitArchive()
        archive_exitbutton.checked = PQCSettings.getDefaultForFiletypesArchiveViewerModeExitButton()
        archive_autoenter.checked = PQCSettings.getDefaultForFiletypesArchiveAlwaysEnterAutomatically()
        archive_comautoenter.checked = PQCSettings.getDefaultForFiletypesComicBookAlwaysEnterAutomatically()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (arc_extunrar.hasChanged() || archivecontrols.hasChanged() || archiveleftright.hasChanged() ||
                                                      archive_escape.hasChanged() || archive_exitbutton.hasChanged() || archive_autoenter.hasChanged() ||
                                                      archive_comautoenter.hasChanged())

    }

    function load() {

        settingsLoaded = false

        arc_extunrar.loadAndSetDefault(PQCSettings.filetypesExternalUnrar)
        archivecontrols.loadAndSetDefault(PQCSettings.filetypesArchiveControls)
        archiveleftright.loadAndSetDefault(PQCSettings.filetypesArchiveLeftRight)
        archive_escape.loadAndSetDefault(PQCSettings.imageviewEscapeExitArchive)
        archive_exitbutton.loadAndSetDefault(PQCSettings.filetypesArchiveViewerModeExitButton)
        archive_autoenter.loadAndSetDefault(PQCSettings.filetypesArchiveAlwaysEnterAutomatically)
        archive_comautoenter.loadAndSetDefault(PQCSettings.filetypesComicBookAlwaysEnterAutomatically)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesExternalUnrar = arc_extunrar.checked
        PQCSettings.filetypesArchiveControls = archivecontrols.checked
        PQCSettings.filetypesArchiveLeftRight = archiveleftright.checked
        PQCSettings.imageviewEscapeExitArchive = archive_escape.checked
        PQCSettings.filetypesArchiveViewerModeExitButton = archive_exitbutton.checked
        PQCSettings.filetypesArchiveAlwaysEnterAutomatically = archive_autoenter.checked
        PQCSettings.filetypesComicBookAlwaysEnterAutomatically = archive_comautoenter.checked
        arc_extunrar.saveDefault()
        archivecontrols.saveDefault()
        archiveleftright.saveDefault()
        archive_escape.saveDefault()
        archive_exitbutton.saveDefault()
        archive_autoenter.saveDefault()
        archive_comautoenter.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
