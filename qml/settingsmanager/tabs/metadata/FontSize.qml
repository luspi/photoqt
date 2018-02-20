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

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Font Size")
            helptext: em.pty+qsTr("The fontsize of the metadata element can be adjusted independently of the rest of the application.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: fontsize_slider

                    width: 400
                    y: (parent.height-height)/2

                    minimumValue: 5
                    maximumValue: 20

                    tickmarksEnabled: true
                    stepSize: 1

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: fontsize_spinbox

                    width: 75

                    minimumValue: 5
                    maximumValue: 20

                    suffix: " pt"

                    value: entry.val

                    onValueChanged:
                        fontsize_slider.value = value

                }

            }

        }

    }

    function setData() {
        fontsize_slider.value = settings.metadataFontSize
    }

    function saveData() {
        settings.metadataFontSize = fontsize_slider.value
    }

}
