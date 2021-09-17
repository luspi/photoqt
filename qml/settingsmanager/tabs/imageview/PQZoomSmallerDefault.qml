/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "zooming further out")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Zooming is mostly used to view an image larger. However, PhotoQt can also show an image smaller if desired, allowing zooming out of an image beyond its default size.")
    content: [

        PQCheckbox {
            id: zoom_chk
            text: em.pty+qsTranslate("settingsmanager_imageview", "allow zooming out of images beyond default size")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.zoomSmallerThanDefault = zoom_chk.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        zoom_chk.checked = PQSettings.zoomSmallerThanDefault
    }

}
