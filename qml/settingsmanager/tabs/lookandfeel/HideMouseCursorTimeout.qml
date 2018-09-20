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

Entry {


    title: em.pty+qsTr("Hide Mouse Cursor")
    helptext: em.pty+qsTr("A mouse cursor is nice and helpful, but sometimes it can simply be in the way of viewing your favourite photos. Thus, PhotoQt can automatically hide the mouse cursor after it hasn't been moved for some seconds. Here, this timeout can be set (in seconds). Setting a value of 0 disables this feature and keeps the mouse cursor always visible.")

    content: [

        CustomSlider {

            id: timeoutSlider

            width: Math.min(200, Math.max(200, parent.width-timeoutSpinbox.width-50))
            height: timeoutSpinbox.height

            minimumValue: 0
            maximumValue: 20

            stepSize: 1
            scrollStep: 1

        },

        CustomSpinBox {

            id: timeoutSpinbox

            width: 75

            minimumValue: 0
            maximumValue: 20

            value: timeoutSlider.value
            onValueChanged: timeoutSlider.value = value
            suffix: " s"

        }

    ]

    function setData() {
        timeoutSlider.value = settings.hideMouseCursorTimeout
    }

    function saveData() {
        settings.hideMouseCursorTimeout = timeoutSlider.value
    }

}
