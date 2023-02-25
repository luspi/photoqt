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
    //: A settings title, the zoom here is the zoom of the main image
    title: em.pty+qsTranslate("settingsmanager_imageview", "zoom speed")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Images are zoomed at a relative speed as specified by this percentage. A higher value means faster zoom.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            PQText {
                y: (parent.height-height)/2
                //: This refers to the zoom speed, the zoom here is the zoom of the main image
                text: em.pty+qsTranslate("settingsmanager_imageview", "super slow")
            }

            PQSlider {
                id: zoomspeed
                y: (parent.height-height)/2
                from: 1
                to: 100
                toolTipSuffix: " %"
            }

            PQText {
                y: (parent.height-height)/2
                //: This refers to the zoom speed, the zoom here is the zoom of the main image
                text: em.pty+qsTranslate("settingsmanager_imageview", "very fast")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.imageviewZoomSpeed = zoomspeed.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        zoomspeed.value = PQSettings.imageviewZoomSpeed
    }

}
