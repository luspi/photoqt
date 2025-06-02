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

import PQCFileFolderModel

Item {

    id: aniDeleg

    // the aniIndex is calculated when needed and determines the animation used
    property int aniIndex: -1

    // the speed is depending on the user settings
    property int aniSpeed: Math.max(15-PQCSettings.slideshowImageTransition,1)*5 // qmllint disable unqualified

    // Animation: left to right
    SequentialAnimation {

        id: kb_lefttorightani

        loops: Animation.Infinite
        running: false

        // this keeps the image vertically centered
        onStarted:
            flickable.contentY = Qt.binding(function() { return -(flickable.height-flickable.contentHeight)/2 }) // qmllint disable unqualified

        // animate from middle to the right
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentX";
            from: -(flickable.width-flickable.contentWidth)/2 // qmllint disable unqualified
            to: -(flickable.width-flickable.contentWidth) // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate to the left
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentX";
            from: -(flickable.width-flickable.contentWidth) // qmllint disable unqualified
            to: 0
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate from right to the middle
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentX";
            from: 0
            to: -(flickable.width-flickable.contentWidth)/2 // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

    }

    // Animation: right to left
    SequentialAnimation {

        id: kb_righttoleftani

        loops: Animation.Infinite
        running: false

        // this keeps the image vertically centered
        onStarted:
            flickable.contentY = Qt.binding(function() { return -(flickable.height-flickable.contentHeight)/2 }) // qmllint disable unqualified

        // animate from middle to the left
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentX";
            from: -(flickable.width-flickable.contentWidth)/2 // qmllint disable unqualified
            to: 0
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate to the right
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentX";
            from: 0
            to: -(flickable.width-flickable.contentWidth) // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate from right to the middle
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentX";
            from: -(flickable.width-flickable.contentWidth) // qmllint disable unqualified
            to: -(flickable.width-flickable.contentWidth)/2 // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

    }

    // Animation: top to bottom
    SequentialAnimation {

        id: kb_toptobottomani

        loops: Animation.Infinite
        running: false

        // this keeps the image horizontally centered
        onStarted:
            flickable.contentX = Qt.binding(function() { return -(flickable.width-flickable.contentWidth)/2 }) // qmllint disable unqualified

        // animate from middle to the bottom
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentY";
            from: -(flickable.height-flickable.contentHeight)/2 // qmllint disable unqualified
            to: -(flickable.height-flickable.contentHeight) // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate to the top
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentY";
            from: -(flickable.height-flickable.contentHeight) // qmllint disable unqualified
            to: 0
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate from bottom to the middle
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentY";
            from: 0
            to: -(flickable.height-flickable.contentHeight)/2 // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

    }

    // Animation: bottom to top
    SequentialAnimation {

        id: kb_bottomtotopani

        loops: Animation.Infinite
        running: false

        // this keeps the image horizontally centered
        onStarted:
            flickable.contentX = Qt.binding(function() { return -(flickable.width-flickable.contentWidth)/2 }) // qmllint disable unqualified

        // animate from middle to the top
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentY";
            from: -(flickable.height-flickable.contentHeight)/2 // qmllint disable unqualified
            to: 0
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate to the bottom
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentY";
            from: 0
            to: -(flickable.height-flickable.contentHeight) // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

        // animate from bottom to the middle
        NumberAnimation {
            target: flickable; // qmllint disable unqualified
            property: "contentY";
            from: -(flickable.height-flickable.contentHeight) // qmllint disable unqualified
            to: -(flickable.height-flickable.contentHeight)/2 // qmllint disable unqualified
            duration: Math.abs(from-to)*aniDeleg.aniSpeed
        }

    }

    // Animation: zoom in the out
    SequentialAnimation {

        id: kb_zoominout

        loops: Animation.Infinite
        running: false

        // this keeps the image centered
        onStarted: {
            flickable.contentX = Qt.binding(function() { return -(flickable.width-flickable.contentWidth)/2 }) // qmllint disable unqualified
            flickable.contentY = Qt.binding(function() { return -(flickable.height-flickable.contentHeight)/2 })
        }

        // zoom in
        NumberAnimation {
            target: image_wrapper; // qmllint disable unqualified
            property: "scale";
            from: image_wrapper.kenBurnsZoomFactor // qmllint disable unqualified
            to: image_wrapper.kenBurnsZoomFactor*1.5 // qmllint disable unqualified
            duration: aniDeleg.aniSpeed*250
        }

        // zoom out
        NumberAnimation {
            target: image_wrapper; // qmllint disable unqualified
            property: "scale";
            from: image_wrapper.kenBurnsZoomFactor*1.5 // qmllint disable unqualified
            to: image_wrapper.kenBurnsZoomFactor // qmllint disable unqualified
            duration: aniDeleg.aniSpeed*250
        }

    }

    // Animation: zoom out the in
    SequentialAnimation {

        id: kb_zoomoutin

        loops: Animation.Infinite
        running: false

        onStarted: {
            flickable.contentX = Qt.binding(function() { return -(flickable.width-flickable.contentWidth)/2 }) // qmllint disable unqualified
            flickable.contentY = Qt.binding(function() { return -(flickable.height-flickable.contentHeight)/2 })
        }

        // zoom out
        NumberAnimation {
            target: image_wrapper; // qmllint disable unqualified
            property: "scale";
            from: image_wrapper.kenBurnsZoomFactor*1.5 // qmllint disable unqualified
            to: image_wrapper.kenBurnsZoomFactor // qmllint disable unqualified
            duration: aniDeleg.aniSpeed*250
        }

        // zoom in
        NumberAnimation {
            target: image_wrapper; // qmllint disable unqualified
            property: "scale";
            from: image_wrapper.kenBurnsZoomFactor // qmllint disable unqualified
            to: image_wrapper.kenBurnsZoomFactor*1.5 // qmllint disable unqualified
            duration: aniDeleg.aniSpeed*250
        }

    }

    Connections {
        target: loader_top // qmllint disable unqualified

        // if we become the current image, make sure an animation is running
        function onIsMainImageChanged() {
            aniDeleg.manageAni()
        }
    }

    Connections {

        target: flickable // qmllint disable unqualified

        // a change in the content width/height necessitates handling the animation

        function onContentWidthChanged() {
            aniDeleg.manageAni()
        }
        function onContentHeightChanged() {
            aniDeleg.manageAni()
        }
    }

    // slideshow paused/resumed
    Connections {

        target: loader_slideshowhandler.item // qmllint disable unqualified

        function onRunningChanged() {
            if(loader_slideshowhandler.item.running) // qmllint disable unqualified
                aniDeleg.manageAni()
            else
                aniDeleg.stopAni()
        }

    }

    // slideshow started/stopped
    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onSlideshowRunningChanged() {
            aniDeleg.handleSlideshowStatusChanged()
        }

    }

    // check slideshow status when completed
    Component.onCompleted: {
        aniDeleg.handleSlideshowStatusChanged()
    }

    // handle slideshow status
    function handleSlideshowStatusChanged() {

        if(PQCSettings.slideshowTypeAnimation === "kenburns") { // qmllint disable unqualified

            if(PQCNotify.slideshowRunning) {

                if(!image_top.currentlyShowingVideo && !PQCNotify.showingPhotoSphere)
                    loader_top.zoomInForKenBurns()
                flickable.returnToBounds()
                aniDeleg.manageAni()

            } else

                image_top.zoomReset()

        }
    }

    // calculate the animation to be used for this image
    function figureOutAniIndex() {

        if(PQCNotify.showingPhotoSphere) { // qmllint disable unqualified
            image_top.animatePhotoSpheres(loader_top.mainItemIndex%2)
            return
        }

        image_top.animatePhotoSpheres(-1)

        var fac = image_wrapper.width/image_wrapper.height

        // image is much higher than wide
        if(fac < 0.75)
            aniDeleg.aniIndex = 3 + loader_top.mainItemIndex%3

        // image is much wider than high
        else if(fac > 2)
            aniDeleg.aniIndex = loader_top.mainItemIndex%3

        // more "normal" image
        else
            aniDeleg.aniIndex = loader_top.mainItemIndex%6
    }

    // after switched away from this image we repeatedly check whether the image is still visible
    // once it is not we finally stop the animation
    Timer {
        id: stopAfterFadeOut
        interval: PQCSettings.imageviewAnimationDuration*100 // qmllint disable unqualified
        onTriggered: {
            if(loader_top.opacity > 1e-6) // qmllint disable unqualified
                stopAfterFadeOut.restart()
            else
                aniDeleg.stopAni()
        }
    }

    // This is a safetry check to make sure we don't ever get stuck
    // If a slideshow is running with this effect then AN animation should always be running
    Timer {
        interval: 250
        running: PQCNotify.slideshowRunning // qmllint disable unqualified
        repeat: true
        onTriggered: {
            if(loader_slideshowhandler.item !== null && // qmllint disable unqualified
                    loader_slideshowhandler.item.running &&
                    PQCNotify.slideshowRunning &&
                    PQCSettings.slideshowTypeAnimation === "kenburns") {
                if(!kb_lefttorightani.running && !kb_righttoleftani.running &&
                        !kb_toptobottomani.running && !kb_bottomtotopani.running &&
                        !kb_zoominout.running && !kb_zoomoutin.running) {
                    aniDeleg.manageAni()
                }
            }
        }
    }

    // manage the animation
    function manageAni() {

        // no animation should be running -> stop!
        if(!loader_top.isMainImage || !PQCNotify.slideshowRunning || // qmllint disable unqualified
                PQCSettings.slideshowTypeAnimation!=="kenburns" || loader_top.videoLoaded ||
                loader_top.defaultScale >= 1 || !loader_slideshowhandler.item.running) {
            stopAfterFadeOut.restart()
            return
        }

        // make sure image is well positioned
        flickable.returnToBounds()

        // get animation index if needed
        if(aniIndex == -1)
            figureOutAniIndex()

        // start the right animation
        if(aniIndex == 0) {

            if(kb_lefttorightani.paused)
                kb_lefttorightani.resume()
            else if(!kb_lefttorightani.running)
                kb_lefttorightani.start()

        } else if(aniIndex == 1) {

            if(kb_righttoleftani.paused)
                kb_righttoleftani.resume()
            else if(!kb_righttoleftani.running)
                kb_righttoleftani.start()

        } else if(aniIndex == 2) {

            if(kb_zoominout.paused)
                kb_zoominout.resume()
            else if(!kb_zoominout.running)
                kb_zoominout.start()

        } else if(aniIndex == 3) {

            if(kb_toptobottomani.paused)
                kb_toptobottomani.resume()
            else if(!kb_toptobottomani.running)
                kb_toptobottomani.start()

        } else if(aniIndex == 4) {

            if(kb_bottomtotopani.paused)
                kb_bottomtotopani.resume()
            else if(!kb_bottomtotopani.running)
                kb_bottomtotopani.start()

        } else if(aniIndex == 5) {

            if(kb_zoomoutin.paused)
                kb_zoomoutin.resume()
            else if(!kb_zoomoutin.running)
                kb_zoomoutin.start()

        }
    }

    // pause any running animation
    function stopAni() {

        if(kb_lefttorightani.running)
            kb_lefttorightani.pause()

        if(kb_righttoleftani.running)
            kb_righttoleftani.pause()

        if(kb_toptobottomani.running)
            kb_toptobottomani.pause()

        if(kb_bottomtotopani.running)
            kb_bottomtotopani.pause()

        if(kb_zoominout.running)
            kb_zoominout.pause()

        if(kb_zoomoutin.running)
            kb_zoomoutin.pause()

    }

}
