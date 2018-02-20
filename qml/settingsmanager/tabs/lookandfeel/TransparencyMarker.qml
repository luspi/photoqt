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

            //: Refers to looping through the folder, i.e., from the last image go back to the first one (and vice versa)
            title: em.pty+qsTr("Transparency Marker")
            helptext: em.pty+qsTr("Transparency in image viewers is often signalled by displaying a pattern of light and dark grey squares. PhotoQt can do the same, by default it will, however, show transparent areas as transparent.")

        }

        EntrySetting {

            CustomCheckBox {

                id: transparency
                text: em.pty+qsTr("Show Transparency Marker")

            }

        }

    }

    function setData() {
        transparency.checkedButton = settings.showTransparencyMarkerBackground
    }

    function saveData() {
        settings.showTransparencyMarkerBackground = transparency.checkedButton
    }

}
