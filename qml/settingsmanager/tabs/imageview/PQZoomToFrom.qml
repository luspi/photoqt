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
    //: A settings title, the zoom here is the zoom of the main image
    title: em.pty+qsTranslate("settingsmanager_imageview", "zoom to/from")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "This controls whether the image is zoomed to/from the mouse position or to/from the image center. Note that this only applies when zooming by mouse, zooming by keyboard shortcut always zooms to/from the image center.")
    expertmodeonly: false
    content: [

        Flow {
            spacing: 10
            width: set.contwidth
            PQRadioButton {
                id: zoommouse
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_imageview", "mouse position")
            }
            PQRadioButton {
                id: zoomcenter
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_imageview", "image center")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.imageviewZoomToCenter = zoomcenter.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        zoomcenter.checked = PQSettings.imageviewZoomToCenter
        zoommouse.checked = !PQSettings.imageviewZoomToCenter
    }

}
