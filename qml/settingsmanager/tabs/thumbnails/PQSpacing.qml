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
    //: A settings title referring to the spacing of thumbnails, i.e., how much empty space to have between each.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "spacing")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "How much space to show between the thumbnails.")
    content: [

        Row {

            spacing: 10

            PQText {
                y: (parent.height-height)/2
                text: "0 px"
            }

            PQSlider {
                id: spacing_slider
                y: (parent.height-height)/2
                from: 0
                to: 50
                toolTipSuffix: " px"
            }

            PQText {
                y: (parent.height-height)/2
                text: "50 px"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailsSpacing = spacing_slider.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        spacing_slider.value = PQSettings.thumbnailsSpacing
    }

}
