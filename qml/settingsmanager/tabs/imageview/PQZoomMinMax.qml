/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
    //: A settings title, the zoom here is the zoom of the main image
    title: em.pty+qsTranslate("settingsmanager_imageview", "zoom min/max")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Specifies the minimum and maximum zoom levels for an image.") + "<br><br>" + qsTranslate("settingsmanager_imageview", "Note that the maximum zoom level is the absolute zoom level, the minimum zoom level is relative to the default zoom level (the zoom level when the image is first loaded).")
    expertmodeonly: true
    content: [

        Column {

            spacing: 10

            Row {

                spacing: 10

                property int minval: 20
                onMinvalChanged: {
                    zoommin.value = minval
                    zoommin_spin.value = minval
                }

                PQCheckbox {
                    id: zoommin_check
                    y: (parent.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager_imageview", "minimum zoom:")
                }

                PQSlider {
                    id: zoommin
                    enabled: zoommin_check.checked
                    y: (parent.height-height)/2
                    from: 1
                    to: 100
                    toolTipSuffix: " %"
                    onValueChanged:
                        parent.minval = value
                }

                PQSpinBox {
                    id: zoommin_spin
                    enabled: zoommin_check.checked
                    y: (parent.height-height)/2
                    from: 1
                    to: 100
                    onValueChanged:
                        parent.minval = value
                }

            }

            Row {

                spacing: 10

                property int maxval: 500
                onMaxvalChanged: {
                    zoommax.value = maxval
                    zoommax_spin.value = maxval
                }

                PQCheckbox {
                    id: zoommax_check
                    y: (parent.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager_imageview", "maximum zoom:")
                }

                PQSlider {
                    id: zoommax
                    enabled: zoommax_check.checked
                    y: (parent.height-height)/2
                    from: 100
                    to: 1000
                    toolTipSuffix: " %"
                    onValueChanged: {
                        parent.maxval = value
                    }
                }

                PQSpinBox {
                    id: zoommax_spin
                    enabled: zoommax_check.checked
                    y: (parent.height-height)/2
                    from: 100
                    to: 1000
                    onValueChanged:
                        parent.maxval = value
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
            PQSettings.imageviewZoomMinEnabled = zoommin_check.checked
            PQSettings.imageviewZoomMaxEnabled = zoommax_check.checked
            PQSettings.imageviewZoomMin = zoommin.value
            PQSettings.imageviewZoomMax = zoommax.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        zoommin_check.checked = PQSettings.imageviewZoomMinEnabled
        zoommax_check.checked = PQSettings.imageviewZoomMaxEnabled
        zoommin.value = PQSettings.imageviewZoomMin
        zoommax.value = PQSettings.imageviewZoomMax
    }

}
