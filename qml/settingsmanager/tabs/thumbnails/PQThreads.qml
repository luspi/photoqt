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
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title, as in: How many threads to use to generate thumbnails.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "threads")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "How many threads to use to create thumbnails. Too many threads can slow down your computer!")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "1"
            }

            PQSlider {
                id: thrds
                y: (parent.height-height)/2
                from: 1
                to: 8
                toolTipPrefix: em.pty+qsTranslate("settingsmanager_thumbnails", "Threads:") + " "
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "8"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailMaxNumberThreads = thrds.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thrds.value = PQSettings.thumbnailMaxNumberThreads
    }

}
