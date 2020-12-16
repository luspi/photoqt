/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
    //: A settings title. The hot edge refers to the area along the edges of PhotoQt where the mouse cursor triggers an action (e.g., showing the thumbnails or the main menu)
    title: em.pty+qsTranslate("settingsmanager_interface", "size of 'hot edge'")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "Adjusts the sensitivity of the edges for showing elements like the metadata and main menu elements.")
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            Text {
                y: (parent.height-height)/2
                color: "white"
                //: used as in: small area
                text: em.pty+qsTranslate("settingsmanager_interface", "small")
            }

            PQSlider {
                id: hotedge_slider
                y: (parent.height-height)/2
                from: 1
                to: 20
                stepSize: 1
                wheelStepSize: 1

            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                //: used as in: large area
                text: em.pty+qsTranslate("settingsmanager_interface", "large")
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            hotedge_slider.value = PQSettings.hotEdgeWidth
        }

        onSaveAllSettings: {
            PQSettings.hotEdgeWidth = hotedge_slider.value
        }

    }

}
