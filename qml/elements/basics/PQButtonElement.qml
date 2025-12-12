/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

import QtQuick
import QtQuick.Controls
import PhotoQt

PQButton {

    height: 40

    flat: true
    opacity: enabled ? 1 : 0.5
    enableRadiusModern: false

    fontPointSize: PQCLook.fontSize
    fontWeight: PQCLook.fontWeightBold

    Rectangle {
        x: 0
        y: 0
        width: 1
        height: parent.height
        color: PQCLook.baseBorder
        z: parent.z+1
    }

    Rectangle {
        x: parent.width-width
        y: 0
        width: 1
        height: parent.height
        color: PQCLook.baseBorder
        z: parent.z+1
    }

}

