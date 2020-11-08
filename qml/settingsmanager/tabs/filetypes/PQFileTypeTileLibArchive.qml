/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.9

import "../../../elements"

PQFileTypeTile {

    title: "libarchive"

    available: PQImageFormats.getAvailableEndingsWithDescriptionArchive()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsArchive()
    currentlyEnabled: PQImageFormats.enabledFileformatsArchive
    projectWebpage: ["libarchive.org", "https://libarchive.org"]
    description: em.pty+qsTranslate("settingsmanager_filetypes", "PhotoQt takes advantage of tools such as libarchive to load packed files (zip, rar, tar, 7z). It can either load them together with the rest of the images (each (supported) file as one image) or it can ignore such files except when asked to open one, then it wont load any other images (like a document viewer).")
                 + "<br><br>"
                 + em.pty+qsTranslate("settingsmanager_filetypes", "Note regarding RAR archives: libarchive supports RAR archives only partially and might fail to read certain archives. If installed, PhotoQt can use the external tool unrar instead of libarchive for proper support of RAR archives.")

    additionalSetting: [
        Row {
            x: (parent.width-width)/2
            y: 10
            spacing: 10
            PQCheckbox {
                id: ext_unrar
                //: used for checkbox
                text: em.pty+qsTranslate("settingsmanager_filetypes", "use external 'unrar'")
            }
            PQCheckbox {
                id: isolate
                //: as in: when an archive is loaded all other files in the folder are ignored
                text: em.pty+qsTranslate("settingsmanager_filetypes", "isolate archives")
            }
        }
    ]
    additionalSettingShow: true

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsArchive = c
            PQSettings.archiveUseExternalUnrar = ext_unrar.checked
            PQSettings.archiveSingleFile = isolate.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        resetChecked()
        ext_unrar.checked = PQSettings.archiveUseExternalUnrar
        isolate.checked = PQSettings.archiveSingleFile
    }

}
