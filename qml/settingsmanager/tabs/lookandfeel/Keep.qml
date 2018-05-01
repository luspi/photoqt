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

    //: Refers to keeping zoom/rotation/flip/position when switching images
    title: em.pty+qsTr("Keep between images")
    helptext: em.pty+qsTr("By default, PhotoQt resets the zoom, rotation, flipping/mirroring and position when switching to a different image.\
 For certain tasks, for example for comparing two images, it can be helpful to keep these properties.")

    content: [

        CustomCheckBox {
            id: keep_box
            //: Remember all these levels when switching between images
            text: em.pty+qsTr("Keep Zoom, Rotation, Flip, Position")
        }

    ]

    function setData() {
        keep_box.checkedButton = settings.keepZoomRotationMirror
    }

    function saveData() {
        settings.keepZoomRotationMirror = keep_box.checkedButton
    }

}
