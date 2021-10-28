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
    //: A settings title for looping through images in folder
    title: em.pty+qsTranslate("settingsmanager_imageview", "looping")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "What to do when the end of a folder has been reached: stop or loop back to first image in folder.")
    content: [

        PQCheckbox {
            id: loop_check
            text: em.pty+qsTranslate("settingsmanager_imageview", "loop through images in folder")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.imageviewLoopThroughFolder = loop_check.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        loop_check.checked = PQSettings.imageviewLoopThroughFolder
    }

}
