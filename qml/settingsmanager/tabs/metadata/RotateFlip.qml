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

    title: em.pty+qsTr("Automatic Rotate/Flip")
    helptext: em.pty+qsTr("Some cameras can detect - while taking the photo - whether the camera was turned and might store this information in\
 the image exif data. If PhotoQt finds this information, it can rotate the image accordingly or simply ignore that information.")

    ExclusiveGroup { id: rotateflipgroup; }

    content: [

        CustomRadioButton {
            id: neverrotate
            text: em.pty+qsTr("Never rotate/flip images")
            exclusiveGroup: rotateflipgroup
            checked: true
        },

        CustomRadioButton {
            id: alwaysrotate
            text: em.pty+qsTr("Always rotate/flip images")
            exclusiveGroup: rotateflipgroup
        }

    ]

    function setData() {
        neverrotate.checked = !settings.metaApplyRotation
        alwaysrotate.checked = settings.metaApplyRotation
    }

    function saveData() {
        settings.metaApplyRotation = alwaysrotate.checked
    }

}
