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
import org.photoqt.qml

Loader {
    id: kenburnsBG
    asynchronous: false

    active: false
    sourceComponent:
        PQImageNormal {
            ignoreSignals: true
        }

    source: "imageitems/PQImageNormal.qml"

    property bool performAni: false
    property real useScale: 1.0

    NumberAnimation {
        id: kenburnsBG_ani
        running: kenburnsBG.performAni && loader_top.visible && PQCConstants.slideshowRunningAndPlaying && !PQCConstants.currentlyShowingVideo // qmllint disable unqualified
        target: kenburnsBG.item
        property: "scale"
        from: kenburnsBG.useScale
        to: kenburnsBG.useScale + duration/(1000*10)
        duration: Math.max(1000, Math.min(300*1000, PQCSettings.slideshowTime*1000)) // qmllint disable unqualified
    }

    Timer {
        id: waitForItem
        interval: 50
        running: false
        onTriggered: {
            if(kenburnsBG.item === null)
                waitForItem.restart()
            else {
                kenburnsBG.item.scale = kenburnsBG.useScale
                kenburnsBG.performAni = true
            }
        }
    }

    Connections {
        target: PQCConstants // qmllint disable unqualified
        function onSlideshowRunningChanged() {
            kenburnsBG.checkForBG()
        }
    }

    Connections {
        target: loader_top // qmllint disable unqualified
        function onVisibleChanged() {
            kenburnsBG.checkForBG()
        }
    }

    function checkForBG() {

        // compute the starting scale factor
        var sc = 1.1 * 1.0/(image_wrapper.scale * Math.max(flickable.contentWidth/flickable.width, flickable.contentHeight/flickable.height)) // qmllint disable unqualified

        if(loader_top.videoLoaded)
            sc = Math.max(flickable.width/image_wrapper.width, flickable.height/image_wrapper.height)

        // If scale factor is invalid or not needed -> stop
        if(!PQCConstants.slideshowRunning || PQCSettings.slideshowTypeAnimation !== "kenburns" || sc < loader_top.defaultScale*1.1 || sc === Number.POSITIVE_INFINITY) {
            kenburnsBG.active = false
            waitForItem.stop()
            performAni = false
            return
        }

        // already handled
        if(kenburnsBG.active)
            return

        // store scale factor
        kenburnsBG.useScale = sc

        // load item and start animation
        kenburnsBG.active = true
        waitForItem.restart()

    }

}
