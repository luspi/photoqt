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

            //: Along the lines of 'zoom small images until they fill the window'
            title: em.pty+qsTr("Fit in Window")
            helptext: em.pty+qsTr("If the image dimensions are smaller than the screen dimensions, PhotoQt can automatically zoom those images to make them fit into the window.")

        }

        EntrySetting {

            CustomCheckBox {

                id: fitinwindow
                text: em.pty+qsTr("Fit Smaller Images in Window")

            }

        }

    }

    function setData() {
        fitinwindow.checkedButton = settings.fitInWindow
    }

    function saveData() {
        settings.fitInWindow = fitinwindow.checkedButton
    }

}
