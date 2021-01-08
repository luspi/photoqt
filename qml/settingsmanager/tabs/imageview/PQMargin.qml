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
    //: A settings title about the margin around the main image
    title: em.pty+qsTranslate("settingsmanager_imageview", "margin")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "How much space to show between the main image and the application border.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                // The translation context here needs to be unique otherwise this string will be conflated with a different 'none' in tabs/filetypes/PQAdvancedTuning.qml
                //: As in: no margin between the main image and the window edges
                text: em.pty+qsTranslate("settingsmanager_imageview", "none")
            }

            PQSlider {
                id: marginwidth
                y: (parent.height-height)/2
                from: 0
                to: 100
                toolTipSuffix: " px"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "100 px"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.marginAroundImage = marginwidth.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        marginwidth.value = PQSettings.marginAroundImage
    }

}
