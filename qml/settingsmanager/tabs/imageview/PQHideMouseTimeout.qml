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
    //: A settings title about the margin around the main image
    title: em.pty+qsTranslate("settingsmanager_imageview", "hide mouse")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Specify a timeout in seconds after which an idle mouse cursor is hidden.")
    content: [

        Row {

            spacing: 10

            PQText {
                y: (parent.height-height)/2
                // The translation context here needs to be unique otherwise this string will be conflated with a different 'none' in tabs/filetypes/PQAdvancedTuning.qml
                //: As in: keep the mouse cursor always visible
                text: em.pty+qsTranslate("settingsmanager_imageview", "keep visible")
            }

            PQSlider {
                id: hidetimeout
                y: (parent.height-height)/2
                from: 0
                to: 10
                toolTipSuffix: " s"
            }

            PQText {
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager_imageview", "long timeout")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.imageviewHideCursorTimeout = hidetimeout.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        hidetimeout.value = PQSettings.imageviewHideCursorTimeout
    }

}
