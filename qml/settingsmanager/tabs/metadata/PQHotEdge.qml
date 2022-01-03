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
    //: A settings title. The hot edge refers to the area along the left edge of PhotoQt where the mouse cursor triggers the visibility of the metadata element.
    title: em.pty+qsTranslate("settingsmanager_metadata", "hot edge")
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "Show metadata element when the mouse cursor is close to the window edge")
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: meta_hot
            text: em.pty+qsTranslate("settingsmanager_metadata", "enable")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metadataElementHotEdge = meta_hot.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        meta_hot.checked = PQSettings.metadataElementHotEdge
    }

}
