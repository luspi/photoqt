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

            title: em.pty+qsTr("Exit button ('x' in top right corner)")
            helptext: em.pty+qsTr("There are two looks for the exit button: a normal 'x' or a plain text'x'. The normal 'x' fits in better with the overall design of PhotoQt, but the plain text 'x' is smaller and more discreet.")

        }


        EntrySetting {

            Row {

                spacing: 10

                ExclusiveGroup { id: clo; }

                CustomRadioButton {
                    id: closingx_fancy
                    //: This is a type of exit button ('x' in top right screen corner)
                    text: em.pty+qsTr("Normal")
                    exclusiveGroup: clo
                }
                CustomRadioButton {
                    id: closingx_normal
                    //: This is a type of exit button ('x' in top right screen corner), showing a simple text 'x'
                    text: em.pty+qsTr("Plain")
                    exclusiveGroup: clo
                    checked: true
                }

                Rectangle { color: "transparent"; width: 1; height: 1; }
                Rectangle { color: "transparent"; width: 1; height: 1; }

                Row {

                    spacing: 5

                    Text {
                        id: txt_small
                        color: colour.text
                        font.pointSize: 10
                        //: The size of the exit button ('x' in top right screen corner)
                        text: em.pty+qsTr("Small Size")
                    }

                    CustomSlider {

                        id: closingx_sizeslider

                        width: Math.min(300, settings_top.width-entrytitle.width-closingx_fancy.width-closingx_normal.width
                               -txt_small.width-txt_large.width-80)
                        y: (parent.height-height)/2

                        minimumValue: 5
                        maximumValue: 25

                        tickmarksEnabled: true
                        stepSize: 1

                    }

                    Text {
                        id: txt_large
                        color: colour.text
                        font.pointSize: 10
                        //: The size of the exit button ('x' in top right screen corner)
                        text: em.pty+qsTr("Large Size")
                    }

                }

            }

        }

    }

    function setData() {
        closingx_fancy.checked = settings.quickInfoFullX
        closingx_sizeslider.value = settings.quickInfoCloseXSize
    }

    function saveData() {
        settings.quickInfoFullX = closingx_fancy.checked
        settings.quickInfoCloseXSize = closingx_sizeslider.value
    }

}
