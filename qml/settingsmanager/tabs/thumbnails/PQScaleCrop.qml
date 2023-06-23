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

    //: A settings title. Used as in: Keep thumbnail for current main image in center.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "thumbnail image")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Whether the thumbnail image should be fit into the available thumbnail space or whether it should be scaled and cropped to fill out the entire available thumbnail space.")
    expertmodeonly: true
    content: [

        Flow {

            spacing: 5
            width: set.contwidth

            PQRadioButton {
                id: fitfull
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "fit thumbnails")
            }

            PQRadioButton {
                id: scalecrop
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "scale and crop thumbnails")
            }

            PQCheckbox {
                id: keepsmall
                text: em.pty+qsTranslate("settingsmanager_thumbnails", "keep small thumbnails small")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailsCropToFit = scalecrop.checked
            PQSettings.thumbnailsSmallThumbnailsKeepSmall = keepsmall.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        scalecrop.checked = PQSettings.thumbnailsCropToFit
        fitfull.checked = !scalecrop.checked
        keepsmall.checked = PQSettings.thumbnailsSmallThumbnailsKeepSmall
    }

}
