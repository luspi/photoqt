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

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: The empty area is the area around the main image
            title: em.pty+qsTr("Click on Empty Area")
            helptext: em.pty+qsTr("This option makes PhotoQt behave a bit like the JavaScript image viewers you find on many websites. A click outside of the image on the empty background will close the application. This way PhotoQt will feel even more like a 'floating layer', however, this can easily be triggered accidentally. Note that if you use a mouse click for a shortcut already, then this option wont have any effect!")

        }

        EntrySetting {

            CustomCheckBox {

                id: closeongrey
                //: The empty area is the area around the main image
                text: em.pty+qsTr("Close on click in empty area")

            }

        }

    }

    function setData() {
        closeongrey.checkedButton = settings.closeOnEmptyBackground
    }

    function saveData() {
        settings.closeOnEmptyBackground = closeongrey.checkedButton
    }

}
