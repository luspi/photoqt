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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Loader {
    id: kenburnsBG
    asynchronous: false

    /*******************************************/
    // these values are READONLY

    property size imageWrapperSize
    property bool loaderTopVisible
    property real imageWrapperScale
    property size flickableSize
    property size flickableContentSize
    property bool videoLoaded
    property real defaultScale

    /*******************************************/

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
        running: kenburnsBG.performAni && kenburnsBG.loaderTopVisible && PQCConstants.slideshowRunningAndPlaying && !PQCConstants.currentlyShowingVideo
        target: kenburnsBG.item
        property: "scale"
        from: kenburnsBG.useScale
        to: kenburnsBG.useScale + duration/(1000*10)
        duration: Math.max(1000, Math.min(300*1000, PQCSettings.slideshowTime*1000))
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
        target: PQCConstants
        function onSlideshowRunningChanged() {
            kenburnsBG.checkForBG()
        }
    }

    function checkForBG() {

        // compute the starting scale factor
        var sc = 1.1 * 1.0/(kenburnsBG.imageWrapperScale * Math.max(flickableContentSize.width/flickableSize.width, flickableContentSize.height/flickableSize.height))

        if(videoLoaded)
            sc = Math.max(flickableSize.width/imageWrapperSize.width, flickableSize.height/imageWrapperSize.height)

        // If scale factor is invalid or not needed -> stop
        if(!PQCConstants.slideshowRunning || PQCSettings.slideshowTypeAnimation !== "kenburns" || sc < defaultScale*1.1 || sc === Number.POSITIVE_INFINITY) {
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
