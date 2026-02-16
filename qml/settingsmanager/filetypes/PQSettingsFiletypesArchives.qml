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

            title: qsTranslate("settingsmanager", "Navigation")

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
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                arc_extunrar.checked = PQCSettings.getDefaultForFiletypesExternalUnrar()
                archivecontrols.checked = PQCSettings.getDefaultForFiletypesArchiveControls()
                archiveleftright.checked = PQCSettings.getDefaultForFiletypesArchiveLeftRight()
                archive_escape.checked = PQCSettings.getDefaultForImageviewEscapeExitArchive()
                archive_exitbutton.checked = PQCSettings.getDefaultForFiletypesArchiveViewerModeExitButton()
                archive_autoenter.checked = PQCSettings.getDefaultForFiletypesArchiveAlwaysEnterAutomatically()
                archive_comautoenter.checked = PQCSettings.getDefaultForFiletypesComicBookAlwaysEnterAutomatically()

                set_arc.checkForChanges()

            }
        },

        PQSettingSubtitle {

            title: qsTranslate("settingsmanager", "Loading Archives")

            helptext: qsTranslate("settingsmanager", "By default, PhotoQt loads any archive it can find and checks it for any supported file type. This can take a few seconds with very large archives (multible Gigabytes). In situations where such large archives are common, it might be preferential to skip over archives of a certain size, or to limit the number of files that are listed from inside the archive.")

        },

        PQCheckBox {
            id: archive_ignoresizecheck
            text: qsTranslate("settingsmanager", "Ignore archives larger than this size:")
            checked: PQCSettings.filetypesArchiveIgnoreLargerThan
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQAdvancedSlider {
            id: archive_ignoresize
            enabled: archive_ignoresizecheck.checked
            minval: 128
            maxval: 10240
            suffix: "MB"
            value: PQCSettings.filetypesArchiveIgnoreLargerThanSize
        },

        PQCheckBox {
            id: archive_ignorecountcheck
            text: qsTranslate("settingsmanager", "Don't load more than this many files:")
            checked: PQCSettings.filetypesArchiveDontLoadMoreFilesThan
            onCheckedChanged: set_arc.checkForChanges()
        },

        PQAdvancedSlider {
            id: archive_ignorecount
            enabled: archive_ignorecountcheck.checked
            minval: 1
            maxval: 10000
            value: PQCSettings.filetypesArchiveIgnoreLargerThanSize
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                archive_ignoresizecheck.checked = PQCSettings.getDefaultForFiletypesArchiveIgnoreLargerThan()
                archive_ignorecountcheck.checked = PQCSettings.getDefaultForFiletypesArchiveDontLoadMoreFilesThan()
                archive_ignoresize.setValue(PQCSettings.getDefaultForFiletypesArchiveIgnoreLargerThanSize())
                archive_ignorecount.setValue(PQCSettings.getDefaultForFiletypesArchiveDontLoadMoreFilesThanCount())

                set_arc.checkForChanges()

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

        PQCConstants.settingsManagerSettingChanged = (arc_extunrar.hasChanged() || archivecontrols.hasChanged() || archiveleftright.hasChanged() ||
                                                      archive_escape.hasChanged() || archive_exitbutton.hasChanged() || archive_autoenter.hasChanged() ||
                                                      archive_comautoenter.hasChanged() || archive_ignoresize.hasChanged() || archive_ignoresizecheck.hasChanged() ||
                                                      archive_ignorecount.hasChanged() || archive_ignorecountcheck.hasChanged())

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

        archive_ignoresizecheck.loadAndSetDefault(PQCSettings.filetypesArchiveIgnoreLargerThan)
        archive_ignoresize.loadAndSetDefault(PQCSettings.filetypesArchiveIgnoreLargerThanSize)
        archive_ignorecountcheck.loadAndSetDefault(PQCSettings.filetypesArchiveDontLoadMoreFilesThan)
        archive_ignorecount.loadAndSetDefault(PQCSettings.filetypesArchiveDontLoadMoreFilesThanCount)

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

        PQCSettings.filetypesArchiveIgnoreLargerThan = archive_ignoresizecheck.checked
        PQCSettings.filetypesArchiveIgnoreLargerThanSize = archive_ignoresize.value
        PQCSettings.filetypesArchiveDontLoadMoreFilesThan = archive_ignorecountcheck.checked
        PQCSettings.filetypesArchiveDontLoadMoreFilesThanCount = archive_ignorecount.value

        arc_extunrar.saveDefault()
        archivecontrols.saveDefault()
        archiveleftright.saveDefault()
        archive_escape.saveDefault()
        archive_exitbutton.saveDefault()
        archive_autoenter.saveDefault()
        archive_comautoenter.saveDefault()
        archive_ignoresize.saveDefault()
        archive_ignoresizecheck.saveDefault()
        archive_ignorecount.saveDefault()
        archive_ignorecountcheck.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
