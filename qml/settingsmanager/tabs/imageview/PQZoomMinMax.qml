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

                PQSlider {
                    id: zoommin
                    y: (parent.height-height)/2
                    from: 1
                    to: 100
                    toolTipSuffix: " %"
                }

                Text {
                    y: (parent.height-height)/2
                    color: "white"
                    text: em.pty+qsTranslate("settingsmanager_imageview", "minimum zoom: %1\%").arg(zoommin.value)
                }

            }

            Row {

                spacing: 10

                PQSlider {
                    id: zoommax
                    y: (parent.height-height)/2
                    from: 100
                    to: 1000
                    toolTipSuffix: " %"
                }

                Text {
                    y: (parent.height-height)/2
                    color: "white"
                    text: em.pty+qsTranslate("settingsmanager_imageview", "maximum zoom: %1\%").arg(zoommax.value)
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
            PQSettings.imageviewZoomMin = zoommin.value
            PQSettings.imageviewZoomMax = zoommax.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        zoommin.value = PQSettings.imageviewZoomMin
        zoommax.value = PQSettings.imageviewZoomMax
    }

}
