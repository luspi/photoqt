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
    //: A settings title. This refers to the lift up of thumbnail images when active/hovered.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "lift up")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "How many pixels to lift up thumbnails when either hovered or active.")
    content: [

        Row {

            spacing: 10

            PQText {
                y: (parent.height-height)/2
                text: "0 px"
            }

            PQSlider {
                id: liftup
                y: (parent.height-height)/2
                from: 0
                to: 100
                toolTipSuffix: " px"
            }

            PQText {
                y: (parent.height-height)/2
                text: "100 px"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailsLiftUp = liftup.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        liftup.value = PQSettings.thumbnailsLiftUp
    }

}
