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

            id: entrytitle

            title: em.pty+qsTr("Filename Thumbnail")
            helptext: em.pty+qsTr("If you don't want PhotoQt to always load the actual image thumbnail in the background, but you still want to have something for better navigating, then you can set a filename-only thumbnail, i.e. PhotoQt wont load any thumbnail images but simply puts the file name into the box. You can also adjust the font size of this text.")

        }

        EntrySetting {

            id: entry

            Row {

                spacing: 10

                CustomCheckBox {
                    id: filenameonly
                    text: em.pty+qsTr("Use filename-only thumbnail")
                }

                Rectangle { color: "transparent"; width: 10; height: 1; }

                Text {
                    id: txt_fontsize
                    color: enabled ? colour.text : colour.text_inactive
                    Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
                    y: (parent.height-height)/2
                    enabled: filenameonly.checkedButton
                    opacity: enabled ? 1 : 0.5
                    text: em.pty+qsTr("Fontsize") + ":"
                }

                CustomSlider {

                    id: filenameonly_fontsize_slider

                    width: Math.min(400, Math.max(50,settings_top.width-entrytitle.width-filenameonly.width-txt_fontsize.width-filenameonly_fontsize_spinbox.width-80))
                    y: (parent.height-height)/2

                    minimumValue: 5
                    maximumValue: 20

                    enabled: filenameonly.checkedButton

                    value: filenameonly_fontsize_spinbox.value
                    stepSize: 1
                    scrollStep: 1
                    tickmarksEnabled: true

                }

                CustomSpinBox {

                    id: filenameonly_fontsize_spinbox

                    width: 75

                    minimumValue: 5
                    maximumValue: 20

                    enabled: filenameonly.checkedButton

                    value: filenameonly_fontsize_slider.value

                }

            }

        }

    }

    function setData() {
        filenameonly.checkedButton = settings.thumbnailFilenameInstead
        filenameonly_fontsize_slider.value = settings.thumbnailFilenameInsteadFontSize
    }

    function saveData() {
        settings.thumbnailFilenameInstead = filenameonly.checkedButton
        settings.thumbnailFilenameInsteadFontSize = filenameonly_fontsize_slider.value
    }

}
