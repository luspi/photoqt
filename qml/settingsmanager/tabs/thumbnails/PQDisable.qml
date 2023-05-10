/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {

    id: set

    title: em.pty+qsTranslate("settingsmanager_thumbnails", "what to show")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Whether to show thumbnail images and/or thumbnail bar.")
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: thb_icnonly
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "show only icons")
            }
            PQCheckbox {
                id: thb_disable
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "disable thumbnail bar")
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailsDisable = thb_disable.checked
            PQSettings.thumbnailsIconsOnly = thb_icnonly.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thb_disable.checked = PQSettings.thumbnailsDisable
        thb_icnonly.checked = PQSettings.thumbnailsIconsOnly
    }

}
