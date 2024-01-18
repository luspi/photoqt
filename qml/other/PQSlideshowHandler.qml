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

Item {

    id: slideshowhandler_top

    property string backupAnimType: ""
    property var shuffledIndices: []
    property int shuffledCurrentIndex: -1
    property bool running: false

    property alias volume: audiooutput.volume

    MediaPlayer {
        id: audioplayer
        audioOutput: AudioOutput { id: audiooutput }
    }

    Timer {
        id: switcher
        interval: Math.max(1000, Math.min(300*1000, PQCSettings.slideshowTime*1000))
        repeat: true
        running: slideshowhandler_top.running
        onTriggered: loadNextImage()
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

        PQCSettings.imageviewAnimationType = PQCSettings.slideshowTypeAnimation

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

        if(PQCSettings.slideshowMusicFile !== "") {
            audioplayer.source = "file://" + PQCSettings.slideshowMusicFile
            audioplayer.play()
        } else
            audioplayer.source = ""

    }

    function hide() {

        PQCNotify.slideshowRunning = false
        slideshowhandler_top.running = false
        audioplayer.stop()
        loader.elementClosed("slideshowhandler")

    }

    function loadPrevImage() {

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

    function loadNextImage() {

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
        if(slideshowhandler_top.running) {
            slideshowhandler_top.running = false
            audioplayer.pause()
        } else {
            slideshowhandler_top.running = true
            if(PQCSettings.slideshowMusicFile !== "")
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
