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
    //: A settings title referring to the position of the thumbnails (upper or lower edge of PhotoQt).
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "position")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Which edge to show the thumbnails on, upper or lower edge.")
    content: [

        PQComboBox {
            id: edge
            //: The upper edge of PhotoQt
            model: [em.pty+qsTranslate("settingsmanager_thumbnails", "upper edge"),
                    //: The lower edge of PhotoQt
                    em.pty+qsTranslate("settingsmanager_thumbnails", "lower edge")]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            if(edge.currentIndex == 0)
                PQSettings.thumbnailsEdge = "Top"
            else
                PQSettings.thumbnailsEdge = "Bottom"
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        if(PQSettings.thumbnailsEdge == "Top")
            edge.currentIndex = 0
        else
            edge.currentIndex = 1
    }

}
