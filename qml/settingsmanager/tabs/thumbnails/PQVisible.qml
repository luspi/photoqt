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
    //: A settings title referring to the visibility of the thumbnails, i.e., if and when to hide them.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "visibility")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "If and how to keep thumbnails visible")
    content: [

        PQComboBox {
            id: thb_vis
                    //: This is talking about the thumbnails.
            model: [em.pty+qsTranslate("settingsmanager_thumbnails", "hide when not needed"),
                    //: This is talking about the thumbnails.
                    em.pty+qsTranslate("settingsmanager_thumbnails", "never hide"),
                    //: This is talking about the thumbnails.
                    em.pty+qsTranslate("settingsmanager_thumbnails", "hide when zoomed in")]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        // ThumbnailsVisibility
        // 0 = on demand
        // 1 = always
        // 2 = except when zoomed

        onSaveAllSettings:
            PQSettings.thumbnailsVisibility = thb_vis.currentIndex

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thb_vis.currentIndex = PQSettings.thumbnailsVisibility
    }

}
