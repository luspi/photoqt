/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

ScrollBar {
    id: control
    orientation: Qt.Vertical

    width: orientation==Qt.Vertical ? 6 : undefined
    height: orientation==Qt.Vertical ? undefined : 6

    contentItem: Rectangle {
        implicitWidth: control.size==1.0 ? 0 : (control.orientation==Qt.Vertical ? 6 : 100)
        implicitHeight: control.size==1.0 ? 0 : (control.orientation==Qt.Vertical ? 100 : 6)
        radius: control.orientation==Qt.Vertical ? width/2 : height/2
        color: control.pressed ? "#eeeeee" : "#aaaaaa"
        visible: !(control.size==1.0)
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    background: Rectangle {
        color: control.pressed ? "#88888888" : "#88666666"
        visible: control.size<1.0
        Behavior on color { ColorAnimation { duration: 100 } }
    }

}
