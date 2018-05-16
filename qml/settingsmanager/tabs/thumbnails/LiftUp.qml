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
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

Entry {

    id: entrytop

    title: em.pty+qsTr("Lift-Up of Thumbnails")
    helptext: em.pty+qsTr("When a thumbnail is hovered, it is lifted up some pixels. Here you can increase/decrease this value according to your\
 personal preference.")

    // This variable is needed to avoid a binding loop of slider<->spinbox
    property int val: 20

    content: [

        Row {

            spacing: 10

            CustomSlider {

                id: liftup_slider

                width: Math.min(200, Math.max(200, parent.parent.width-liftup_spinbox.width-50))
                y: (parent.height-height)/2

                minimumValue: 0
                maximumValue: 40

                stepSize: 1
                scrollStep: 1

                onValueChanged:
                    entrytop.val = value

            }

            CustomSpinBox {

                id: liftup_spinbox

                width: 75

                minimumValue: 0
                maximumValue: 40

                suffix: " px"

                value: entrytop.val

                onValueChanged: {
                    if(value%5 == 0)
                        liftup_slider.value = value
                }

            }

        }

    ]

    function setData() {
        liftup_slider.value = settings.thumbnailLiftUp
        entrytop.val = liftup_slider.value
    }

    function saveData() {
        settings.thumbnailLiftUp = liftup_spinbox.value
    }

}
