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
    title: em.pty+qsTr("Disable thumbnails")
    helptext: em.pty+qsTr("If you just don't need or don't want any thumbnails whatsoever, then you can disable them here completely. This will\
 increase the speed of PhotoQt, but will make navigating with the mouse harder.")

    content: [

        CustomCheckBox {

            id: disable
            text: em.pty+qsTr("Disable Thumbnails altogether")

        }

    ]

    function setData() {
        disable.checkedButton = settings.thumbnailDisable
    }

    function saveData() {
        settings.thumbnailDisable = disable.checkedButton
    }

}
