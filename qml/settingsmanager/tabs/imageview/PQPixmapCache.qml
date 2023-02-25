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
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "pixmap cache")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Size of runtime cache for fully loaded images. This cache is cleared when the application quits.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            PQText {
                y: (parent.height-height)/2
                text: "15 MB"
            }

            PQSlider {
                id: pixcache
                y: (parent.height-height)/2
                from: 15
                to: 4096
                toolTipSuffix: " MB"
            }

            PQText {
                y: (parent.height-height)/2
                text: "4 GB"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.imageviewCache = pixcache.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        pixcache.value = PQSettings.imageviewCache
    }

}
