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

            //: The type of interpolation to use for small images
            title: em.pty+qsTr("Interpolation")
            helptext: em.pty+qsTr("There are many different interpolation algorithms out there. Depending on the choice of interpolation algorithm, the image (when zoomed in) will look slightly differently. PhotoQt uses mipmaps to get the best quality for images. However, for very small images, that might lead to too much blurring causing them to look rather ugly. For those images, the 'Nearest Neighbour' algorithm tends to be a better choice. The threshold defines for which images to use which algorithm.");

        }

        EntrySetting {

            Row {

                spacing: 10

                Text {

                    id: txt_label
                    color: colour.text
                    //: When to trigger an action, below which threshold
                    text: em.pty+qsTr("Threshold:")
                    font.pointSize: 10
                    y: (parent.height-height)/2

                }

                CustomSpinBox {

                    id: interpolationthreshold

                    width: 100

                    minimumValue: 0
                    maximumValue: 99999

                    stepSize: 5

                    value: 100
                    suffix: " px"

                }

                Rectangle { color: "transparent"; width: 1; height: 1; }
                Rectangle { color: "transparent"; width: 1; height: 1; }
                Rectangle { color: "transparent"; width: 1; height: 1; }

                CustomCheckBox {

                    id: interpolationupscale
                    y: (parent.height-height)/2
                    wrapMode: Text.WordWrap
                    fixedwidth: settings_top.width-entrytitle.width-txt_label.width-interpolationthreshold.width-90
                    //: 'Nearest Neighbour' is the name of a specific algorithm
                    text: em.pty+qsTr("Use 'Nearest Neighbour' algorithm for upscaling")

                }

            }

        }

    }

    function setData() {
        interpolationthreshold.value = settings.interpolationNearestNeighbourThreshold
        interpolationupscale.checkedButton = settings.interpolationNearestNeighbourUpscale
    }

    function saveData() {
        settings.interpolationNearestNeighbourThreshold = interpolationthreshold.value
        settings.interpolationNearestNeighbourUpscale = interpolationupscale.checkedButton
    }

}
