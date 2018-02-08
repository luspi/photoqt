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

            title: em.pty+qsTr("Margin Around Image")
            helptext: em.pty+qsTr("Whenever you load an image, the image is per default not shown completely in fullscreen, i.e. it's not stretching from screen edge to screen edge. Instead there is a small margin around the image of a couple pixels. Here you can adjust the width of this margin (set to 0 to disable it).")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomSlider {

                    id: border_sizeslider

                    width: Math.min(400, settings_top.width-entrytitle.width-border_sizespinbox.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 100

                    tickmarksEnabled: true
                    stepSize: 1

                }

                CustomSpinBox {

                    id: border_sizespinbox

                    width: 75

                    minimumValue: 0
                    maximumValue: 100

                    value: border_sizeslider.value
                    onValueChanged:
                        border_sizeslider.value = value
                    suffix: " px"

                }

            }

        }

    }

    function setData() {
        border_sizeslider.value = settings.marginAroundImage
    }

    function saveData() {
        settings.marginAroundImage = border_sizeslider.value
    }

}
