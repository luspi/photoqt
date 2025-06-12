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
import org.photoqt.qml

Menu {

    id: control

    // setting the inset and padding properties are necessary in particular on Windows
    // See: https://bugreports.qt.io/browse/QTBUG-131499

    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0

    topPadding: 1
    leftPadding: 1
    rightPadding: 1
    bottomPadding: 1

    delegate: PQMenuItem {
        moveToRightABit: true
    }

    background: Rectangle {
        implicitWidth: 250
        implicitHeight: 40
        color: PQCLook.baseColor // qmllint disable unqualified
        border.color: PQCLook.inverseColorHighlight // qmllint disable unqualified
        border.width: 1
        radius: 2
    }

}
