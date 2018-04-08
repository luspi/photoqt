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

    //: Refers to looping through the folder, i.e., from the last image go back to the first one (and vice versa)
    title: em.pty+qsTr("Looping")
    helptext: em.pty+qsTr("PhotoQt can loop over the images in the folder, i.e., when reaching the last image it continues to the first one and vice versa. If disabled, it will stop at the first/last image.")

    content: [

        CustomCheckBox {

            id: loopfolder
            text: em.pty+qsTr("Loop through images in folder")

        }

    ]

    function setData() {
        loopfolder.checkedButton = settings.loopThroughFolder
    }

    function saveData() {
        settings.loopThroughFolder = loopfolder.checkedButton
    }

}
