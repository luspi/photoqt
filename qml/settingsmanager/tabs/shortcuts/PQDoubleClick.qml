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
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "Double Click Threshold")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Two clicks within the specified interval are interpreted as a double click. Note that too high a value will cause noticable delays in reacting to single clicks.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            PQSpinBox {
                id: dblclk
                from: 0
                to: 1000
            }
            PQText {
                y: (dblclk.height-height)/2
                font.weight: baselook.boldweight
                text: "ms"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.interfaceDoubleClickThreshold = dblclk.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        dblclk.value = PQSettings.interfaceDoubleClickThreshold
    }

}
