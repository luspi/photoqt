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

    title: em.pty+qsTr("Exit button")
    helptext: em.pty+qsTr("The exit button is shown in the top right corner. It can have one of two looks: a normal 'x' or a plain text'x'.\
 The normal 'x' fits in better with the overall design of PhotoQt, but the plain text 'x' is smaller and more discreet.")

    ExclusiveGroup { id: clo; }

    content: [

        Item {

            width: closingx_fancy.width+closingx_normal.width+10
            height: childrenRect.height

            CustomRadioButton {
                id: closingx_fancy
                //: This is a type of exit button ('x' in top right screen corner)
                text: em.pty+qsTr("Normal")
                exclusiveGroup: clo
            }

            CustomRadioButton {
                id: closingx_normal
                x: closingx_fancy.width+10
                //: This is a type of exit button ('x' in top right screen corner), showing a simple text 'x'
                text: em.pty+qsTr("Plain")
                exclusiveGroup: clo
                checked: true
            }

        },

        Item {
            width: 10
            height: 1
        },

        Item {

            width: txt_small.width+closingx_sizeslider.width+txt_large.width+10
            height: childrenRect.height

            Text {
                id: txt_small
                x: 0
                color: colour.text
                font.pointSize: 10
                //: The size of the exit button ('x' in top right screen corner)
                text: em.pty+qsTr("Small")
            }

            CustomSlider {

                id: closingx_sizeslider

                x: txt_small.width+5
                y: (txt_small.height-height)/2
                width: 100

                minimumValue: 5
                maximumValue: 25

                stepSize: 1
                scrollStep: 1

            }

            Text {
                id: txt_large
                x: txt_small.width+closingx_sizeslider.width+10
                color: colour.text
                font.pointSize: 10
                //: The size of the exit button ('x' in top right screen corner)
                text: em.pty+qsTr("Large")
            }

        }

    ]

    function setData() {
        closingx_fancy.checked = settings.quickInfoFullX
        closingx_sizeslider.value = settings.quickInfoCloseXSize
    }

    function saveData() {
        settings.quickInfoFullX = closingx_fancy.checked
        settings.quickInfoCloseXSize = closingx_sizeslider.value
    }

}
