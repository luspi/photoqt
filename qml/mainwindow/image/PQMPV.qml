/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import PQMPVObject 1.0
import "../../elements"

// for better control on fillMode we embed it inside an item
Item {

    id: elem

    x: 0 // offset taking care of in container
    y: PQSettings.imageviewMargin
    width: container.width-2*PQSettings.imageviewMargin
    height: container.height-2*PQSettings.imageviewMargin

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.imageviewAnimationDuration*100 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.imageviewAnimationDuration*100 } }

    MouseArea {
        enabled: PQSettings.imageviewLeftButtonMoveImage
        anchors.fill: parent
        onPressed: {
            if(PQSettings.interfaceCloseOnEmptyBackground || PQSettings.interfaceNavigateOnEmptyBackground) {
                var paintedX = (container.width-renderer.width)/2
                var paintedY = (container.height-renderer.height)/2
                if(mouse.x < paintedX || mouse.x > paintedX+renderer.width ||
                   mouse.y < paintedY || mouse.y > paintedY+renderer.height) {
                    if(PQSettings.interfaceCloseOnEmptyBackground)
                        toplevel.close()
                    else if(PQSettings.interfaceNavigateOnEmptyBackground) {
                        if(mouse.x < width/2)
                            imageitem.loadPrevImage()
                        else
                            imageitem.loadNextImage()
                    }
                }
            }
        }
    }

    // video element
    PQMPVObject {

        id: renderer

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: mediaInfoWidth
        height: mediaInfoHeight

        property bool playing: true

        property int mediaInfoWidth: 100
        property int mediaInfoHeight: 100

    }

    Timer {
        id: delayLoad
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            renderer.command(["loadfile", src])
            deleg.imageStatus = Image.Ready
            getProps.start()
        }
    }

    Timer {
        id: getProps
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            renderer.mediaInfoWidth = renderer.getProperty("width")
            renderer.mediaInfoHeight = renderer.getProperty("height")
        }
    }

    Timer {
        id: getPropsConfirm
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            renderer.mediaInfoWidth = renderer.getProperty("width")
            renderer.mediaInfoHeight = renderer.getProperty("height")
        }
    }

    function restorePosZoomRotationMirror() {
//        if(PQSettings.imageviewRememberZoomRotationMirror && src in variables.zoomRotationMirror) {

//            elem.x = variables.zoomRotationMirror[src][0].x
//            elem.y = variables.zoomRotationMirror[src][0].y

//            elem.scale = variables.zoomRotationMirror[src][1]
//            elem.rotation = variables.zoomRotationMirror[src][2]
//            elem.mirror = variables.zoomRotationMirror[src][3]

//        }
    }

    function storePosRotZoomMirror() {

//        variables.zoomRotationMirror[src] = [Qt.point(elem.x, elem.y), elem.rotation, elem.scale, elem.mirror]

    }


}
