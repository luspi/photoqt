/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
    //: A settings title referring to the type of interpolation to use for small images
    title: em.pty+qsTranslate("settingsmanager_imageview", "interpolation")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "There are many different interpolation algorithms out there. Depending on the choice of interpolation algorithm, the image (when zoomed in) will look slightly differently. PhotoQt uses mipmaps to get the best quality for images. However, for very small images, that might lead to too much blurring causing them to look rather ugly. For those images, the 'Nearest Neighbour' algorithm tends to be a better choice. The threshold defines at which size to switch from one to the other algorithm.")
    expertmodeonly: true
    content: [

        Column {

            spacing: 15

            PQCheckbox {
                id: interp_check
                //: A type of interpolation to use for small images
                text: em.pty+qsTranslate("settingsmanager_imageview", "use 'nearest neighbour' algorithm for upscaling")
            }

            Row {

                spacing: 5
                height: interp_thr.height

                Text {
                    y: (parent.height-height)/2
                    //: The threshold (in pixels) at which to switch interpolation algorithm
                    text: em.pty+qsTranslate("settingsmanager_imageview", "threshold:")
                    color: interp_check.checked ? "white" : "#cccccc"
                }

                Text {
                    y: (parent.height-height)/2
                    text: interp_thr.from + " px"
                    color: interp_check.checked ? "white" : "#cccccc"
                }

                PQSlider {
                    id: interp_thr
                    toolTipSuffix: " px"
                    from: 0
                    to: 1000
                    stepSize: 50
                    wheelStepSize: 50
                }

                Text {
                    y: (parent.height-height)/2
                    text: interp_thr.to + " px"
                    color: interp_check.checked ? "white" : "#cccccc"
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.interpolationNearestNeighbourUpscale = interp_check.checked
            PQSettings.interpolationNearestNeighbourThreshold = interp_thr.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        interp_check.checked = PQSettings.interpolationNearestNeighbourUpscale
        interp_thr.value = PQSettings.interpolationNearestNeighbourThreshold
    }

}
