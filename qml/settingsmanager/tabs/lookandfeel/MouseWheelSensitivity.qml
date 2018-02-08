/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            title: em.pty+qsTr("Mouse Wheel Sensitivity")
            helptext: em.pty+qsTr("The mouse can be used for various things, including many types of shortcuts. The sensitivity of the mouse wheel defines the distance the wheel has to be moved before triggering a shortcut.")

        }

        EntrySetting {

            Row {

                spacing: 10

                Text {

                    id: txt_no
                    color: colour.text
                    //: Refers to the sensitivity of the mouse wheel
                    text: em.pty+qsTr("Not at all sensitive")
                    font.pointSize: 10

                }

                CustomSlider {

                    id: wheelsensitivity

                    width: Math.min(400, settings_top.width-entrytitle.width-txt_no.width-txt_very.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 10

                    tickmarksEnabled: true
                    stepSize: 1

                }

                Text {

                    id: txt_very
                    color: colour.text
                    //: Refers to the sensitivity of the mouse wheel
                    text: em.pty+qsTr("Very sensitive")
                    font.pointSize: 10

                }

            }

        }

    }

    function setData() {
        wheelsensitivity.value = wheelsensitivity.maximumValue-settings.mouseWheelSensitivity
    }

    function saveData() {
        settings.mouseWheelSensitivity = wheelsensitivity.maximumValue-wheelsensitivity.value
    }

}
