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
import "../elements"

Rectangle {

    x: (toplevel.width-width)/2
    y: (toplevel.height-height)/2

    width: txt.width+100
    height: txt.height+30

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    color: "#88000000"

    property alias statustext: txt.text

    radius: 15

    PQTextL {
        id: txt
        x: 50
        y: 15
        font.weight: baselook.boldweight
        text: ""
    }

    Connections {

        target: loader

        onUnavailablePassOn: {

            if(what === "show")
                show()

        }

    }

    Timer {
        id: hideNotification
        interval: 2000
        onTriggered:
            hide()
    }

    function show() {
        opacity = 1
        hideNotification.restart()
    }

    function hide() {
        opacity = 0
    }

}
