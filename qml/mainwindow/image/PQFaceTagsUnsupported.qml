/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9
import "../../elements"

Rectangle {

    id: facetagsunsupported_top

    visible: opacity>0
    opacity: 0
    Behavior on opacity { NumberAnimation { id: opacity_timer; duration: 100 } }
    onOpacityChanged: {
        if(opacity > 0.9)
            fadeout.restart()
    }

    width: txt.width+40
    height: txt.height+40

    border.width: 10
    border.color: "#888888"

    radius: 10

    color: "#000000"

    function show() {
        fadeout.stop()
        opacity_timer.duration = 100
        facetagsunsupported_top.opacity = 1
        if(facetagsunsupported_top.opacity > 0.9)
            fadeout.restart()
    }

    Text {
        id: txt
        x: 20
        y: 20
        text: em.pty+qsTranslate("facetagging", "File type does not support face tags.")
        color: "white"
        font.pointSize: 20
        wrapMode: Text.WordWrap
    }

    Timer {
        id: fadeout
        interval: 2000
        repeat: false
        running: false
        onTriggered: {
            opacity_timer.duration = 500
            facetagsunsupported_top.opacity = 0
        }
    }

}
