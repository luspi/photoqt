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
    //: A settings title referring to whether to show images by default at actual size
    title: em.pty+qsTranslate("settingsmanager_imageview", "size on image load")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "PhotoQt by default makes sure that images are fully visible no matter their size. With this setting you can tell PhotoQt to always load images by default at full size. For images larger than the window this will then require zooming out in order to see the full image.")
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: alwact
            text: em.pty+qsTranslate("settingsmanager_imageview", "always show actual instead of scaled size")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.imageviewAlwaysActualSize = alwact.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        alwact.checked = PQSettings.imageviewAlwaysActualSize
    }

}
