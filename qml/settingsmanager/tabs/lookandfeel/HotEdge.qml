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

Entry {

    //: The hot edge refers to the left and right screen edge.
    //: When the mouse cursor enters the hot edge area, then the main menu/metadata element is shown
    title: em.pty+qsTr("Size of 'Hot Edge'")
    helptext: em.pty+qsTr("Here you can adjust the sensitivity of the metadata and main menu elements. The main menu opens when your mouse cursor\
 gets close to the right screen edge, the metadata element when you go to the left screen edge. This setting controls how close to the screen edge\
 you have to get before they are shown.")

    content: [

        Row {

            spacing: 10

            Text {
                id: txt_small
                color: colour.text
                //: This refers to the size of the hot edge, you have to get close to the screen edge to trigger the main menu or metadata element
                text: em.pty+qsTr("Small")
                font.pointSize: 10
            }

            CustomSlider {

                id: hotedgewidth

                width: Math.min(200, Math.max(200, parent.width-txt_small.width-txt_large.width-50))
                y: (parent.height-height)/2

                minimumValue: 1
                maximumValue: 20

                stepSize: 1
                scrollStep: 1

            }

            Text {
                id: txt_large
                color: colour.text
                //: This refers to the size of the hot edge, you don't have to get close to the screen edge to trigger the mainmenu/metadata element
                text: em.pty+qsTr("Large")
                font.pointSize: 10
            }

        }

    ]

    function setData() {
        hotedgewidth.value = settings.hotEdgeWidth
    }

    function saveData() {
        settings.hotEdgeWidth = hotedgewidth.value
    }

}
