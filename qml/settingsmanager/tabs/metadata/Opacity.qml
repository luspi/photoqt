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

    property int val: 200

    title: em.pty+qsTr("Opacity")
    helptext: em.pty+qsTr("By default, the metadata widget is overlapping the main image, thus you might prefer a different\
 alpha value for opacity to increase/decrease readability. Values can be in the range of 0-255.")

    content: [

        Row {

            spacing: 10

            CustomSlider {

                id: opacity_slider

                width: Math.min(200, Math.max(200, parent.parent.width-opacity_spinbox.width-50))
                y: (parent.height-height)/2

                minimumValue: 0
                maximumValue: 255

                stepSize: 5
                scrollStep: 5

                onValueChanged:
                    entrytop.val = value

            }

            CustomSpinBox {

                id: opacity_spinbox

                width: 75

                minimumValue: 0
                maximumValue: 255

                value: entrytop.val

                onValueChanged:
                    opacity_slider.value = value

            }

        }

    ]

    function setData() {
        opacity_slider.value = settings.metadataOpacity
    }

    function saveData() {
        settings.metadataOpacity = opacity_slider.value
    }

}
