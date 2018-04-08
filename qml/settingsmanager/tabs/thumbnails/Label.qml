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

Entry {

    title: em.pty+qsTr("Label on Thumbnails")
    helptext: em.pty+qsTr("PhotoQt can write a label with some information on the thumbnails. Currently, only the filename is available. The slider adjusts the fontsize of the text for the filename.")

    content: [

        Item {

            width: writefilename.width
            height: fontsize_spinbox.height

            CustomCheckBox {
                id: writefilename
                y: (parent.height-height)/2
                //: Settings: Write the filename on a thumbnail
                text: em.pty+qsTr("Write Filename")
            }

        },

        Rectangle { color: "transparent"; width: 10; height: 1; },

        Row {

            spacing: 10

            Text {
                id: txt_fontsize
                color: enabled ? colour.text : colour.text_inactive
                Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
                y: (parent.height-height)/2
                enabled: writefilename.checkedButton
                opacity: enabled ? 1 : 0.5
                //: Settings: Write the filename with this fontsize on a thumbnail
                text: em.pty+qsTr("Fontsize") + ":"
            }

            CustomSlider {

                id: fontsize_slider

                width: Math.min(200, Math.max(200,parent.parent.width-writefilename.width-txt_fontsize.width-fontsize_spinbox.width-50))
                y: (parent.height-height)/2

                minimumValue: 5
                maximumValue: 20

                value: fontsize_spinbox.value
                stepSize: 1
                scrollStep: 1

                enabled: writefilename.checkedButton

            }

            CustomSpinBox {

                id: fontsize_spinbox
                y: (parent.height-height)/2

                width: 75

                minimumValue: 5
                maximumValue: 20

                suffix: " pt"

                value: fontsize_slider.value

                enabled: writefilename.checkedButton

            }

        }

    ]

    function setData() {
        writefilename.checkedButton = settings.thumbnailWriteFilename
        fontsize_slider.value = settings.thumbnailFontSize
    }

    function saveData() {
        settings.thumbnailWriteFilename = writefilename.checkedButton
        settings.thumbnailFontSize = fontsize_slider.value
    }

}
