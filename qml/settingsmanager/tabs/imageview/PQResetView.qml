/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_imageview", "reset view")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "The current view can be changed in many ways (moving the image, zooming in/out, etc.). Once changed a small button can be shown that will fade in whenever the mouse has been moved, and it will fade out again after some timeout defined here.")
    content: [

        Column {

            spacing: 15

            PQCheckbox {
                id: reset_show
                text: em.pty+qsTranslate("settingsmanager_imageview", "enable reset button")
            }

            Flow {

                spacing: 10

                width: set.contwidth
                enabled: reset_show.checked

                PQText {
                    text: em.pty+qsTranslate("settingsmanager_imageview", "Timeout for hiding once shown:")
                }

                PQSlider {
                    id: reset_slider
                    from: 500
                    to: 5000
                    stepSize: 100
                    wheelStepSize: 100
                    tooltip: value/1000
                }

                PQText {
                    text: reset_slider.value/1000 + " s"
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

            PQSettings.imageviewResetViewShow = reset_show.checked
            PQSettings.imageviewResetViewAutoHideTimeout = reset_slider.value

        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        reset_show.checked = PQSettings.imageviewResetViewShow
        reset_slider.value = PQSettings.imageviewResetViewAutoHideTimeout
    }

}
