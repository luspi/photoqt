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

Rectangle {

    id: exportRunning

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    anchors.fill: parent
    color: "#88000000"

    property int circleHeight: 206
    property bool animationRunning: true

    signal successHidden()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: { mouse.accepted = true }
        onWheel: { wheel.accepted = true }
    }

    Item {

        id: exportbusy
        anchors.fill: parent

        opacity: 1
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }

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
                    duration: 2000 - index*200
                    running: (exportRunning.visible&&animationRunning)
                    loops: Animation.Infinite
                }
            }

        }

    }

    Image {
        id: exportsuccess
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 200
        height: 200
        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        source: "/other/checkmark.svg"
        sourceSize: Qt.size(width, height)
        Timer {
            running: parent.visible
            interval: 1000
            onTriggered: {
                exportfailure.opacity = 0
                exportsuccess.opacity = 0
                exportRunning.opacity = 0
                hide()
                exportRunning.successHidden()
            }
        }
    }

    Image {
        id: exportfailure
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 125
        height: 125
        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        source: "/other/x.svg"
        sourceSize: Qt.size(width, height)
        Timer {
            id: failuretimer
            interval: 1000
            onTriggered: {
                exportfailure.opacity = 0
                exportsuccess.opacity = 0
                exportRunning.opacity = 0
                hide()
                exportRunning.successHidden()
            }
        }
    }

    function showBusy() {
        exportbusy.opacity = 1
        exportfailure.opacity = 0
        exportsuccess.opacity = 0
        opacity = 1
    }

    function showSuccess() {
        exportbusy.opacity = 0
        exportfailure.opacity = 0
        exportsuccess.opacity = 1
        opacity = 1
    }

    function showFailure(keep) {
        exportbusy.opacity = 0
        exportfailure.opacity = 1
        exportsuccess.opacity = 0
        if(!keep)
            failuretimer.restart()
        opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
