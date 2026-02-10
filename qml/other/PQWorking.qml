/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import PhotoQt

Rectangle {

    id: exportRunning

    opacity: 0
    visible: opacity>0
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { id: opacityAny; duration: 200 } }

    onOpacityChanged: {
        if(opacity === 0) {
            exportbusy.opacity = 0
            exportfailure.opacity = 0
            exportsuccess.opacity = 0
        }
    }

    anchors.fill: parent
    color: "#44000000"

    property int circleHeight: 206
    property bool animationRunning: true

    property real customScaling: 1

    signal successHidden()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: (mouse) => { mouse.accepted = true }
        onWheel: (wheel) => { wheel.accepted = true }
        onPositionChanged: (mouse) => {
            var pos = mapToItem(fullscreenitem, mouse.x, mouse.y)
            PQCNotify.mouseMove(pos.x, pos.y)
        }
    }

    Item {

        id: exportbusy
        anchors.fill: parent

        opacity: 1
        visible: opacity>0
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

        Repeater {

            model: 3

            delegate: Canvas {
                id: load
                required property int modelData
                x: (parent.width-width)/2
                y: (parent.height-height)/2
                width: (206 - modelData*25)*exportRunning.customScaling
                height: (206 - modelData*25)*exportRunning.customScaling
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
                    from: load.modelData%2 ? 360 : 0
                    to: load.modelData%2 ? 0 : 360
                    duration: 2000 - load.modelData*200
                    running: (exportRunning.visible&&exportRunning.animationRunning)
                    loops: Animation.Infinite
                }
            }

        }

    }

    Image {
        id: exportsuccess
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 200*exportRunning.customScaling
        height: 200*exportRunning.customScaling
        opacity: 0
        visible: opacity>0
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        source: "image://svg/:/" + PQCLook.iconShade + "/checkmark.svg"
        sourceSize: Qt.size(width, height)
        Timer {
            running: exportsuccess.visible
            interval: 1000
            onTriggered: {
                exportfailure.opacity = 0
                exportsuccess.opacity = 0
                exportRunning.opacity = 0
                exportRunning.hide()
                exportRunning.successHidden()
            }
        }
    }

    Image {
        id: exportfailure
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 125*exportRunning.customScaling
        height: 125*exportRunning.customScaling
        opacity: 0
        visible: opacity>0
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        source: "image://svg/:/" + PQCLook.iconShade + "/x.svg"
        sourceSize: Qt.size(width, height)
        Timer {
            id: failuretimer
            interval: 1000
            onTriggered: {
                exportfailure.opacity = 0
                exportsuccess.opacity = 0
                exportRunning.opacity = 0
                exportRunning.hide()
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

    function showFailure(keep : bool) {
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
