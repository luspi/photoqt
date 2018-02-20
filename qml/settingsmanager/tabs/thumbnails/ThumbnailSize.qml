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

            title: em.pty+qsTr("Thumbnail Size")
            helptext: em.pty+qsTr("Here you can adjust the thumbnail size. You can set it to any size between 20 and 256 pixel. Per default it is set to 80 pixel, but the optimal size depends on the screen resolution.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: size_slider

                    width: Math.min(400, settings_top.width-entrytitle.width-size_spinbox.width-50)
                    y: (parent.height-height)/2

                    minimumValue: 20
                    maximumValue: 256

                    tickmarksEnabled: true
                    stepSize: 5
                    scrollStep: 5

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: size_spinbox

                    width: 75

                    minimumValue: 20
                    maximumValue: 256

                    suffix: " px"

                    value: entry.val

                    onValueChanged: {
                        if(value%5 == 0)
                            size_slider.value = value
                    }

                }


            }

        }

    }

    function setData() {
        size_slider.value = settings.thumbnailSize
        entry.val = size_slider.value
    }

    function saveData() {
        settings.thumbnailSize = size_spinbox.value
    }

}
