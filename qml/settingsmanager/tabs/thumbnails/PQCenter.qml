/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
    //: A settings title. Used as in: Keep thumbnail for current main image in center.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "keep in center")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Keep currently active thumbnail in the center of the screen")
    content: [
        PQCheckbox {
            id: thb_center
            text: em.pty+qsTranslate("settingsmanager_thumbnails", "center on active thumbnail")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailsCenterOnActive = thb_center.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thb_center.checked = PQSettings.thumbnailsCenterOnActive
    }

}
