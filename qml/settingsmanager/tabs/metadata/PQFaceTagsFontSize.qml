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
    id: set
    //: A settings title. The face tags are labels that can be shown (if available) on faces including their name.
    title: em.pty+qsTranslate("settingsmanager_metadata", "face tags - font size")
    //: The name labels here are the labels with the name used for the face tags.
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "The font size of the name labels.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "5 pt"
                font.pointSize: baselook.fontsize
            }

            PQSlider {
                id: ft_fs
                y: (parent.height-height)/2
                from: 5
                to: 50
                toolTipSuffix: " pt"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "50 pt"
                font.pointSize: baselook.fontsize
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metadataFaceTagsFontSize = ft_fs.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        ft_fs.value = PQSettings.metadataFaceTagsFontSize
    }

}
