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
pragma ComponentBehavior: Bound

import QtQuick
import QtMultimedia
import PhotoQt

Item {

    id: slideshowhandler_top

    property string backupAnimType: ""
    property int backupAnimSpeed: 0
    property list<int> shuffledIndices: []
    property int shuffledCurrentIndex: -1
    property bool running: false

    property real volume: 1.0

    property list<string> musicFileOrder: []
    property int currentMusicIndex: 0

    Loader {

        id: loader_audioplayer
        active: PQCSettings.slideshowMusic

        sourceComponent:
        MediaPlayer {
            id: audioplayer
            audioOutput: AudioOutput {
                id: audiooutput
                property real reduceVolume: (PQCSettings.slideshowMusicVolumeVideos === 0 ? 0 : (PQCSettings.slideshowMusicVolumeVideos === 1 ? 0.1 : 1))
                volume: PQCConstants.slideshowVolume*(slideshowhandler_top.videoWithVolume ? reduceVolume : 1)
                Behavior on volume { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                // this is needed to ensure we don't play music if the very first file is a video file with sound
                Component.onCompleted: {
                    slideshowhandler_top.videoWithVolume = (PQCConstants.currentlyShowingVideo && PQCConstants.currentlyShowingVideoHasAudio)
                }

            }

            onPlaybackStateChanged: {
                if(playbackState === MediaPlayer.StoppedState && PQCConstants.slideshowRunningAndPlaying && PQCConstants.slideshowRunning) {
                    if(PQCSettings.slideshowMusic) {
                        currentMusicIndex = (currentMusicIndex+1)%PQCSettings.slideshowMusicFiles.length

                        var startingIndex = currentMusicIndex
                        while(!PQCScriptsFilesPaths.doesItExist(musicFileOrder[currentMusicIndex]) && currentMusicIndex != startingIndex)
                            currentMusicIndex += (currentMusicIndex+1)%PQCSettings.slideshowMusicFiles.length

                        audioplayer.source = encodeURI("file:" + musicFileOrder[currentMusicIndex])
                    }
                }
            }

            onSourceChanged:
                play()

            function checkPlayPause() {
                if(PQCConstants.slideshowRunningAndPlaying)
                    audioplayer.play()
                else
                    audioplayer.pause()
            }

        }

    }


    // check whether a video contains audio and re-enable it with a short delay
    // this avoids the music from shortly pop up with back-to-back video files
    property bool videoWithVolume: false
    Connections {
        target: PQCConstants
        function onCurrentlyShowingVideoChanged() : void {
            if(PQCConstants.currentlyShowingVideo && PQCConstants.currentlyShowingVideoHasAudio) {
                resetVolumeWithDelay.stop()
                videoWithVolume = true
            } else
                resetVolumeWithDelay.restart()
        }
        function onCurrentlyShowingVideoHasAudioChanged() : void {
            if(PQCConstants.currentlyShowingVideo && PQCConstants.currentlyShowingVideoHasAudio) {
                resetVolumeWithDelay.stop()
                videoWithVolume = true
            } else
                resetVolumeWithDelay.restart()
        }
    }

    Timer {
        id: resetVolumeWithDelay
        interval: 250
        onTriggered: {
            videoWithVolume = (PQCConstants.currentlyShowingVideo && PQCConstants.currentlyShowingVideoHasAudio)
        }
    }

    Timer {
        id: checkAudio
        interval: 500
        running: PQCSettings.slideshowMusic && loader_audioplayer.item.playbackState===MediaPlayer.PausedState
        onTriggered:
            loader_audioplayer.item.checkPlayPause()
    }

    Connections {

        target: PQCConstants

        function onSlideshowRunningAndPlayingChanged() {
            if(PQCSettings.slideshowMusic)
                loader_audioplayer.item.checkPlayPause()
        }

    }

    property bool ignoreVideoChanges: false

    Connections {

        target: PQCConstants

        function onCurrentlyShowingVideoPlayingChanged() {
            if(PQCSettings.slideshowMusic)
                loader_audioplayer.item.checkPlayPause()
            if(PQCConstants.slideshowRunningAndPlaying && !PQCConstants.currentlyShowingVideoPlaying && !ignoreVideoChanges) {
                switcher.triggered()
                ignoreVideoChanges = false
            }
            if(PQCSettings.slideshowMusic)
                loader_audioplayer.item.checkPlayPause()
        }
    }

    Timer {
        id: switcher
        interval: Math.max(1000, Math.min(300*1000, PQCSettings.slideshowTime*1000))
        repeat: true
        running: PQCConstants.slideshowRunningAndPlaying&&!PQCConstants.currentlyShowingVideo
        onTriggered: {
            slideshowhandler_top.loadNextImage()
            if(PQCSettings.slideshowMusic)
                loader_audioplayer.item.checkPlayPause()
        }
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === "SlideshowHandler")
                    slideshowhandler_top.show()

            } else if(what === "hide") {

                if(param[0] === "SlideshowHandler")
                    slideshowhandler_top.hide()

            } else if(PQCConstants.slideshowRunning) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape)
                        slideshowhandler_top.hide()

                    else if(param[0] === Qt.Key_Space)
                        slideshowhandler_top.toggle()

                }

            }

        }

    }

    Connections {

        target: PQCNotify

        function onSlideshowHideHandler() {
            slideshowhandler_top.hide()
        }

        function onSlideshowToggle() {
            slideshowhandler_top.toggle()
        }

        function onSlideshowNextImage(switchedManually : bool) {
            slideshowhandler_top.loadNextImage(switchedManually)
        }

        function onSlideshowPrevImage(switchedManually : bool) {
            slideshowhandler_top.loadPrevImage(switchedManually)
        }

    }

    function show() {

        backupAnimType = PQCSettings.imageviewAnimationType
        backupAnimSpeed = PQCSettings.imageviewAnimationDuration

        PQCSettings.imageviewAnimationType = PQCSettings.slideshowTypeAnimation
        PQCSettings.imageviewAnimationDuration = PQCSettings.slideshowImageTransition

        // This effect only exists for slideshow and not for normal viewing
        // Thus we need to make sure it is not set to the imageviewAnimationType
        // as otherwise old images will not be removed from view
        if(PQCSettings.imageviewAnimationType === "kenburns")
            PQCSettings.imageviewAnimationType = "opacity"

        var sortby = 1
        if(PQCSettings.imageviewSortImagesBy === "name")
            sortby = 0
        else if(PQCSettings.imageviewSortImagesBy === "time")
            sortby = 2
        else if(PQCSettings.imageviewSortImagesBy === "size")
            sortby = 3
        else if(PQCSettings.imageviewSortImagesBy === "type")
            sortby = 4

        if(PQCSettings.slideshowIncludeSubFolders)
            PQCFileFolderModel.includeFilesInSubFolders = true

        if(PQCSettings.slideshowShuffle) {

            slideshowhandler_top.shuffledIndices = []
            for(var k = 0; k < PQCFileFolderModel.countMainView; ++k) {
                if(k !== PQCFileFolderModel.currentIndex)
                    slideshowhandler_top.shuffledIndices.push(k)
            }
            shuffle(slideshowhandler_top.shuffledIndices)
            slideshowhandler_top.shuffledIndices.push(PQCFileFolderModel.currentIndex)
            slideshowhandler_top.shuffledCurrentIndex = -1

        }

        PQCConstants.slideshowRunningAndPlaying = true
        PQCConstants.slideshowRunning = true

        if(PQCSettings.slideshowMusic) {
            currentMusicIndex = 0
            musicFileOrder = PQCSettings.slideshowMusicFiles
            if(PQCSettings.slideshowMusicShuffle)
                shuffle(musicFileOrder)
            while(!PQCScriptsFilesPaths.doesItExist(musicFileOrder[currentMusicIndex]) && currentMusicIndex < musicFileOrder.length)
                currentMusicIndex += 1
            loader_audioplayer.item.position = 0
            loader_audioplayer.item.source = encodeURI("file:" + musicFileOrder[currentMusicIndex])
        }

        if(PQCSettings.slideshowTypeAnimation === "kenburns") {
            PQCScriptsShortcuts.sendShortcutZoomKenBurns()
            PQCScriptsShortcuts.sendShortcutRotateReset()
            PQCScriptsShortcuts.sendShortcutMirrorReset()
        } else {
            PQCScriptsShortcuts.sendShortcutZoomReset()
        }

    }

    function hide() {

        var tmp = PQCConstants.slideshowRunningAndPlaying

        PQCConstants.slideshowRunning = false
        PQCConstants.slideshowRunningAndPlaying = false
        if(PQCSettings.slideshowMusic)
            loader_audioplayer.item.checkPlayPause()
        PQCNotify.loaderRegisterClose("SlideshowHandler")

        PQCSettings.imageviewAnimationType = backupAnimType
        PQCSettings.imageviewAnimationDuration = backupAnimSpeed

        PQCScriptsShortcuts.sendShortcutZoomReset()

        if(tmp)
            PQCNotify.playPauseAnimationVideo()

    }

    function loadPrevImage(switchedManually = false) {

        ignoreVideoChanges = PQCConstants.currentlyShowingVideoPlaying

        if(!PQCSettings.slideshowShuffle) {
            if(PQCFileFolderModel.currentIndex > 0)
                --PQCFileFolderModel.currentIndex
            else if(PQCSettings.slideshowLoop)
                PQCFileFolderModel.currentIndex = PQCFileFolderModel.countMainView-1
            else
                hide()
        } else {
            if(slideshowhandler_top.shuffledCurrentIndex > 0) {
                --slideshowhandler_top.shuffledCurrentIndex
                PQCFileFolderModel.currentIndex = slideshowhandler_top.shuffledIndices[slideshowhandler_top.shuffledCurrentIndex]
            } else if(PQCSettings.slideshowLoop) {
                slideshowhandler_top.shuffledCurrentIndex = slideshowhandler_top.shuffledIndices.length-1
                PQCFileFolderModel.current = slideshowhandler_top.shuffledIndices[slideshowhandler_top.shuffledCurrentIndex]
            } else
                hide()

        }

    }

    function loadNextImage(switchedManually = false) {

        ignoreVideoChanges = PQCConstants.currentlyShowingVideoPlaying

        if(!PQCSettings.slideshowShuffle) {
            if(PQCFileFolderModel.currentIndex < PQCFileFolderModel.countMainView-1)
                ++PQCFileFolderModel.currentIndex
            else if(PQCSettings.slideshowLoop)
                PQCFileFolderModel.currentIndex = 0
            else
                hide()
        } else {
            if(slideshowhandler_top.shuffledCurrentIndex < slideshowhandler_top.shuffledIndices.length-1) {
                ++slideshowhandler_top.shuffledCurrentIndex
                PQCFileFolderModel.currentIndex = slideshowhandler_top.shuffledIndices[slideshowhandler_top.shuffledCurrentIndex]
            } else if(PQCSettings.slideshowLoop) {
                slideshowhandler_top.shuffledCurrentIndex = 0
                PQCFileFolderModel.current = slideshowhandler_top.shuffledIndices[slideshowhandler_top.shuffledCurrentIndex]
            } else
                hide()

        }

    }

    function toggle() {
        if(!PQCConstants.slideshowRunning) return
        // The following two lines HAVE to be in this order!!
        PQCConstants.slideshowRunningAndPlaying = !PQCConstants.slideshowRunningAndPlaying
        if(PQCSettings.slideshowMusic)
            loader_audioplayer.item.checkPlayPause()
        PQCNotify.playPauseAnimationVideo()
    }

    /***************************************/
    // The Fisher–Yates shuffle algorithm
    // Code found at http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript
    // (adapted from http://bost.ocks.org/mike/shuffle/)
    function shuffle(array) {
        var counter = array.length, temp, index;

        // While there are elements in the array
        while (counter > 0) {
            // Pick a random index
            index = Math.floor(Math.random() * counter);

            // Decrease counter by 1
            counter--;

            // And swap the last element with it
            temp = array[counter];
            array[counter] = array[index];
            array[index] = temp;
        }

        return array;
    }

}
