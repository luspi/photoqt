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

            //: The hot edge refers to the left and right screen edge (here in particular only to the left one). When the mouse cursor enters the hot edge area, then the metadata element is shown
            title: em.pty+qsTr("Enable 'Hot Edge'")
            helptext: em.pty+qsTr("Per default the info widget can be shown two ways: Moving the mouse cursor to the left screen edge to fade it in temporarily (as long as the mouse is hovering it), or permanently by clicking the checkbox (checkbox only stored per session, can't be saved permanently!). Alternatively the widget can also be triggered by shortcut or main menu item. On demand the mouse triggering can be disabled, so that the widget would only show on shortcut/menu item.")

        }

        EntrySetting {

            id: entry

            CustomCheckBox {

                id: triggeronmouse
                //: The hot edge refers to the area on the very left of the screen that triggers the showing of the metadata element when the mouse enters it
                text: em.pty+qsTr("DISABLE Hot Edge")

            }

        }

    }

    function setData() {
        triggeronmouse.checkedButton = !settings.metadataEnableHotEdge
    }

    function saveData() {
        settings.metadataEnableHotEdge = !triggeronmouse.checkedButton
    }

}
