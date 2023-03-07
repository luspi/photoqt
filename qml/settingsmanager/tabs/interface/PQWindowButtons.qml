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
    title: em.pty+qsTranslate("settingsmanager_interface", "window buttons")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "PhotoQt can show some integrated window buttons at the top right corner of the screen.")
    expertmodeonly: false
    content: [

        Column {
            spacing: 15
            Flow {
                spacing: 10
                width: set.contwidth
                PQCheckbox {
                    id: labels_windowbuttons
                    y: (parent.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager_interface", "show integrated window buttons")
                }
                PQCheckbox {
                    id: labels_windowduplicatebuttons
                    y: (parent.height-height)/2
                    enabled: labels_windowbuttons.checked
                    text: em.pty+qsTranslate("settingsmanager_interface", "also duplicate buttons from window decoration")
                }

            }

            Row {
                spacing: 5
                PQText {
                    y: (parent.height-height)/2
                    //: the size of the window buttons (the buttons shown in the top right corner of the window)
                    text: em.pty+qsTranslate("settingsmanager_interface", "size of window buttons") + ":"
                }
                PQSlider {
                    id: labels_windowbuttonssize
                    y: (parent.height-height)/2
                    from: 5
                    to: 25
                }
            }

            Row {
                spacing: 10
                PQCheckbox {
                    id: labels_autohide
                    y: (labels_autohide_howshow.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager_interface", "automatically hide")
                    enabled: labels_windowbuttons.checked
                }
                PQComboBox {
                    id: labels_autohide_howshow
                    width: 250
                    enabled: labels_autohide.checked
                    model: [em.pty+qsTranslate("settingsmanager_interface", "Show on any cursor move"),
                            em.pty+qsTranslate("settingsmanager_interface", "Show when cursor near top edge")]
                }
            }

            Flow {

                spacing: 10

                width: set.contwidth
                enabled: labels_autohide.checked

                PQText {
                    text: em.pty+qsTranslate("settingsmanager_interface", "Timeout for hiding once shown:")
                }

                PQSlider {
                    id: lt_slider
                    from: 0
                    to: 5000
                    stepSize: 100
                    wheelStepSize: 100
                }

                PQText {
                    text: lt_slider.value/1000 + " s"
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {

            labels_windowbuttons.checked = PQSettings.interfaceWindowButtonsShow
            labels_windowduplicatebuttons.checked = PQSettings.interfaceWindowButtonsDuplicateDecorationButtons

            labels_windowbuttonssize.value = PQSettings.interfaceWindowButtonsSize

            labels_autohide.checked = PQSettings.interfaceWindowButtonsAutoHide
            labels_autohide_howshow.currentIndex = (PQSettings.interfaceWindowButtonsAutoHideTopEdge ? 1 : 0)
            lt_slider.value = PQSettings.interfaceWindowButtonsAutoHideTimeout

        }

        onSaveAllSettings: {

            PQSettings.interfaceWindowButtonsShow = labels_windowbuttons.checked
            PQSettings.interfaceWindowButtonsDuplicateDecorationButtons = labels_windowduplicatebuttons.checked

            PQSettings.interfaceWindowButtonsSize = labels_windowbuttonssize.value

            PQSettings.interfaceWindowButtonsAutoHide = labels_autohide.checked
            PQSettings.interfaceWindowButtonsAutoHideTopEdge = labels_autohide_howshow.currentIndex
            PQSettings.interfaceWindowButtonsAutoHideTimeout = lt_slider.value

        }

    }

}
