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

    title: em.pty+qsTr("Zoom speed")
    helptext: em.pty+qsTr("Images in PhotoQt are zoomed at a relative speed. The current zoom level is increased (or decreased) by the percentage\
 specified here. If you prefer a faster or slower zoom, you can increase or decrease this value. A higher value means faster zoom.")

    content: [

        Row {

            id: entryrow

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            spacing: 10

            CustomSlider {

                id: zoomspeed_sizeslider

                width: Math.min(200, Math.max(200, parent.width-zoomspeed_sizespinbox.width-50))
                y: (parent.height-height)/2

                minimumValue: 1
                maximumValue: 100

                stepSize: 1
                scrollStep: 5

                value: entryrow.val

                onValueChanged:
                    entryrow.val = value

            }

            CustomSpinBox {

                id: zoomspeed_sizespinbox

                width: 85

                minimumValue: 0
                maximumValue: 100

                suffix: " %"

                value: entryrow.val

                onValueChanged:
                    entryrow.val = value

            }

        }

     ]

    function setData() {
        entryrow.val = settings.zoomSpeed
    }

    function saveData() {
        settings.zoomSpeed = entryrow.val
    }

}
