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

Rectangle {

    id: loading_top

    anchors.fill: parent
    color: "#88000000"
    visible: false

    Repeater {

        model: 3

        delegate: Canvas {
            id: load
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: 206 - index*25
            height: 206 - index*25
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#ffffff";
                ctx.lineWidth = 3
                ctx.beginPath();
                ctx.arc(width/2, height/2, width/2-3, 0, 3.14, false);
                ctx.stroke();
            }
            RotationAnimator {
                target: load
                from: index%2 ? 360 : 0
                to: index%2 ? 0 : 360
                duration: 1000 - index*100
                running: loading_top.visible&&variables.visibleItem==""
                onStopped: {
                    if(loading_top.visible && variables.visibleItem=="")
                        start()
                }
            }
        }

    }

}
