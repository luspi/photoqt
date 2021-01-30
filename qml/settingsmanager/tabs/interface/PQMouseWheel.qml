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
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "mouse wheel sensitivity")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "How sensitive the mouse wheel is for shortcuts, etc.")
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            Text {
                y: (parent.height-height)/2
                color: "white"
                //: The sensitivity here refers to the sensitivity of the mouse wheel
                text: em.pty+qsTranslate("settingsmanager_interface", "not sensitive")
            }

            PQSlider {
                id: wheelsensitivity
                y: (parent.height-height)/2
                from: 0
                to: 10
                stepSize: 1
                wheelStepSize: 1
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                //: The sensitivity here refers to the sensitivity of the mouse wheel
                text: em.pty+qsTranslate("settingsmanager_interface", "very sensitive")
            }
        }
    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            wheelsensitivity.value = PQSettings.mouseWheelSensitivity
        }

        onSaveAllSettings: {
            PQSettings.mouseWheelSensitivity = wheelsensitivity.value
        }

    }

}
