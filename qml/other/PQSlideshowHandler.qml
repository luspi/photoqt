/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import QtMultimedia

import PQCFileFolderModel
import PQCNotify
import PQCScriptsFilesPaths

Item {

    id: slideshowhandler_top

    property string backupAnimType: ""
    property int backupAnimSpeed: 0
    property var shuffledIndices: []
    property int shuffledCurrentIndex: -1
    property bool running: false

    property real volume: 1.0

    property var musicFileOrder: []
    property int currentMusicIndex: 0

    MediaPlayer {
        id: audioplayer
        audioOutput: AudioOutput {
            id: audiooutput
            property real reduceVolume: PQCSettings.slideshowMusicVolumeVideos === 0 ?
                                            0 :
                                            (PQCSettings.slideshowMusicVolumeVideos === 1 ?
                                                0.1 :
                                                1)

            property bool videoWithVolume: image.currentlyShowingVideo&&image.currentlyShowingVideoHasAudio

            onVolumeChanged: {
                if(volume < 1e-4)
                    audioplayer.pause()
                else
                    audioplayer.play()
            }

            volume: slideshowhandler_top.volume*(videoWithVolume ? reduceVolume : 1)
            Behavior on volume { NumberAnimation { duration: 200 } }

        }

        onPlaybackStateChanged: {
            if(playbackState === MediaPlayer.StoppedState && slideshowhandler_top.running) {
                if(PQCSettings.slideshowMusic) {
                    currentMusicIndex = (currentMusicIndex+1)%PQCSettings.slideshowMusicFiles.length

                    var startingIndex = currentMusicIndex
                    while(!PQCScriptsFilesPaths.doesItExist(musicFileOrder[currentMusicIndex]) && currentMusicIndex != startingIndex)
                        currentMusicIndex += (currentMusicIndex+1)%PQCSettings.slideshowMusicFiles.length

                    audioplayer.source = "file://" + musicFileOrder[currentMusicIndex]
                    audioplayer.play()
                }
            }
        }
    }

    Timer {
        id: switcher
        interval: Math.max(1000, Math.min(300*1000, PQCSettings.slideshowTime*1000))
        repeat: true
        running: false
        onTriggered: {
            ignoreVideoSwitcher = false
            loadNextImage()
        }
    }

    // this is needed for one specific use case:
    // when manually switching away from a playing video during a slidehow
    // then the special switcher below would get activated for the next image
    // this bool prevents that from happening
    property bool ignoreVideoSwitcher: false

    Timer {
        id: switcherAfterVideo
        interval: 500
        onTriggered: {
            if(!ignoreVideoSwitcher)
                loadNextImage()
            ignoreVideoSwitcher = false
        }
    }

    Connections {

        target: image
        function onCurrentlyShowingVideoChanged() {
            if(!slideshowhandler_top.running)
                return
            if(image.currentlyShowingVideo) {
                switcherAfterVideo.stop()
                switcher.stop()
            } else {
                switcherAfterVideo.restart()
            }
        }

    }

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === "slideshowhandler")
                    show()

            } else if(what === "hide") {

                if(param === "slideshowhandler")
                    hide()

            } else if(PQCNotify.slideshowRunning) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape)
                        hide()

                    else if(param[0] === Qt.Key_Space)
                        toggle()

                }

            }

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

        slideshowhandler_top.running = true
        PQCNotify.slideshowRunning = true

        if(!image.currentlyShowingVideo)
            switcher.restart()

        if(PQCSettings.slideshowMusic) {
            currentMusicIndex = 0
            musicFileOrder = PQCSettings.slideshowMusicFiles
            if(PQCSettings.slideshowMusicShuffle)
                shuffle(musicFileOrder)
            while(!PQCScriptsFilesPaths.doesItExist(musicFileOrder[currentMusicIndex]) && currentMusicIndex < musicFileOrder.length)
                currentMusicIndex += 1
            audioplayer.source = "file://" + musicFileOrder[currentMusicIndex]
            audioplayer.play()
        } else
            audioplayer.source = ""

    }

    function hide() {

        var tmp = slideshowhandler_top.running

        PQCNotify.slideshowRunning = false
        slideshowhandler_top.running = false
        audioplayer.stop()
        loader.elementClosed("slideshowhandler")

        PQCSettings.imageviewAnimationType = backupAnimType
        PQCSettings.imageviewAnimationDuration = backupAnimSpeed

        image.zoomReset()

        if(tmp)
            image.playPauseAnimationVideo()

    }

    function loadPrevImage(switchedManually = false) {

        if(switchedManually)
            ignoreVideoSwitcher = true

        switcher.stop()

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

        switcher.running = Qt.binding(function() { return slideshowhandler_top.running; })

    }

    function loadNextImage(switchedManually = false) {

        if(switchedManually)
            ignoreVideoSwitcher = true

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

        switcher.running = Qt.binding(function() { return slideshowhandler_top.running; })

    }

    function toggle() {
        image.playPauseAnimationVideo()
        if(slideshowhandler_top.running) {
            slideshowhandler_top.running = false
            audioplayer.pause()
        } else {
            slideshowhandler_top.running = true
            if(PQCSettings.slideshowMusic)
                audioplayer.play()
        }
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
