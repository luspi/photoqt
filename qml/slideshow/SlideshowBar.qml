/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtMultimedia 5.5

import "../elements"

import "../handlestuff.js" as Handle

Rectangle {

    id: bar

    // Background/Border color
    color: colour.fadein_slidein_bg

    // Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
    x: 0
    y: 0

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    visible: opacity!=0

    // Adjust size
    width: mainwindow.width+2
    height: pause.height+20

    // make sure settings values are valid
    property int settingsSlideShowTime: Math.max(1000, Math.min(300*1000, settings.slideShowTime*1000))
    property string settingsSlideShowMusicFile: getanddostuff.doesThisExist(settings.slideShowMusicFile) ? settings.slideShowMusicFile : ""

    // paused?
    property bool paused: false

    property var images: []
    property int current: 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    CustomButton {
        id: pause
        x: 10
        y: 10
        text: paused
                 //: Stays alone like that, not part of a full sentence. Written on button to allow user to play a currently paused slideshow.
               ? em.pty+qsTr("Play Slideshow")
                 //: Stays alone like that, not part of a full sentence. Written on button to allow user to pause a currently playing slideshow.
               : em.pty+qsTr("Pause Slideshow")
        onClickedButton: pauseSlideshow()
    }

    Rectangle {
        id: volumerect
        color: "#00000000"
        width: childrenRect.width
        y: 10
        height: pause.height
        x: (bar.width-width)/2

        Row {
            spacing: 5
            Text {
                text: em.pty+qsTr("Music Volume:")
                font.pointSize: 10
                y: (volumerect.height-height)/2
                color: settingsSlideShowMusicFile == "" ? colour.text_disabled : colour.text
            }
            CustomSlider {
                id: volumeslider
                minimumValue: 0
                maximumValue: 100
                stepSize: 1
                scrollStep: 5
                value: 80
                enabled: settingsSlideShowMusicFile != ""
                y: (volumerect.height-height)/2
            }
            Text {
                text: "" + volumeslider.value + "%"
                font.pointSize: 10
                y: (volumerect.height-height)/2
                color: settingsSlideShowMusicFile == "" ? colour.text_disabled : colour.text
            }
        }
    }

    CustomButton {
        id: exit
        x: bar.width-width-10
        y: 10
        text: em.pty+qsTr("Quit Slideshow")
        onClickedButton: stopSlideshow()
    }

    // Audio element
    Audio {
        id: slideshowmusic
        volume: volumeslider.value/100.0
        onError: console.error("AUDIO ERROR:",errorString,"-",source)
        onStopped: if(variables.slideshowRunning) slideshowmusic.play()
    }

    Connections {
        target: call
        onSlideshowStart: {
            if(variables.currentFile === "") return
            startSlideshow()
        }
        onSlideshowBarShow:
            showBar()
        onSlideshowBarHide:
            hideBar()
        onShortcut: {
            if(!variables.slideshowRunning) return
            if(sh == "Escape")
                stopSlideshow()
            else if(sh == "Space")
                pauseSlideshow()
        }
        onCloseAnyElement:
            if(variables.slideshowRunning)
                stopSlideshow()
    }

    // Display the bar
    function showBar() {
        if(variables.slideshowRunning) {
            verboseMessage("Slideshow/SlideshowBar", "showBar()")
            opacity = 1
        } else
            verboseMessage("Slideshow/SlideshowBar", "showbar(): no slideshow running")
    }
    // Hide the bar
    function hideBar() {
        if(!paused) {
            verboseMessage("Slideshow/SlideshowBar", "hideBar()")
            opacity = 0
        } else
            verboseMessage("Slideshow/SlideshowBar", "hideBar(): slideshow paused")
    }

    // Show and hide the bar shortly after again (used at start and end of slideshow)
    function showAndHideBar() {
        verboseMessage("Slideshow/SlideshowBar", "showAndHideBar()")
        call.show("slideshowbar")
        hidebarsoon.start()
    }

    // Start a slideshow
    function startSlideshow() {

        verboseMessage("Slideshow/SlideshowBar", "startSlideshow()")

        // Set some variables
        variables.slideshowRunning = true
        variables.guiBlocked = true

        // Set music file
        if(settingsSlideShowMusicFile != "") {
            slideshowmusic.source = "file://" + settingsSlideShowMusicFile
            slideshowmusic.play()
            console.log("playing music:", slideshowmusic.source)
        }

        variables.imageItemBlocked = true

        // Setup an array with image indices
        // Three possibilities (say, current index = 5, total number = 8)
        // 1) not shuffled, not looped: array = [5,6,7]
        // 2) not shuffled, looped: array = [5,6,7,0,1,2,3,4]
        // 3) shuffled: array random (see below for algorithm)
        //    -> once through the array, we rework a new random array to not simply repeat same sequence
        images = []
        current = 0	// We obviously start at beginning of array
        if(!settings.slideShowShuffle) {

            // Option 1
            for(var i = variables.currentFilePos+1; i < variables.totalNumberImagesCurrentFolder; ++i)
                images.push(i);

            // Option 2
            if(settings.slideShowLoop) {
                for(var j = 0; j <= variables.currentFilePos; ++j)
                    images.push(j);
            }

        // Option 3
        } else {

            for(var k = 0; k < variables.totalNumberImagesCurrentFolder; ++k)
                if(k !== variables.currentFilePos) {
                    images.push(k)
                }

            // Shuffle function at end of file
            images = shuffle(images)

            // We always end up again at the currently displayed one
            images.push(variables.currentFilePos)

        }

        // Set up timer for switching images
        imageswitcher.interval = settingsSlideShowTime+settings.slideShowImageTransition*150
        imageswitcher.start()

        // Slide in and out bar to signal start of slideshow
        showAndHideBar()

    }

    // Pause/Play slideshow
    function pauseSlideshow() {

        verboseMessage("Slideshow/SlideshowBar", "pauseSlideshow()")

        // Pause
        if(!paused) {
            // Pause music (if set)
            if(settingsSlideShowMusicFile != "")
                slideshowmusic.pause()
            paused = true
            imageswitcher.stop()
            // The bar remains shown when slideshow paused
            call.show("slideshowbar")
        // Play
        } else {
            // Play music (if set)
            if(settingsSlideShowMusicFile != "")
                slideshowmusic.play()
            paused = false
            imageswitcher.start()
            call.hide("slideshowbar")
        }
    }

    // Stop slideshow
    function stopSlideshow() {

        verboseMessage("Slideshow/SlideshowBar", "stopSlideshow()")

        // slideshow ended
        variables.slideshowRunning = false

        // We're definitely not paused anymore
        paused = false

        // Stop switching images
        imageswitcher.stop()

        // Signal end by slide in/out of bar
        showAndHideBar()

        // Stop music (if started)
        if(settingsSlideShowMusicFile != "")
            slideshowmusic.stop()

        // Update variables
        variables.guiBlocked = false
        variables.imageItemBlocked = false

    }

    // Load a new image
    function switchImage() {

        if(!variables.slideshowRunning) {
            imageswitcher.stop()
            variables.imageItemBlocked = false
            return
        }

        verboseMessage("Slideshow/SlideshowBar", "switchImage(): " + current + " / " +
                                                                     images.length + " / " +
                                                                     settings.slideShowLoop + " / " +
                                                                     settings.slideShowShuffle)

        // If we reached the end of the array
        if(current == images.length) {

            // If looping the array
            if(settings.slideShowLoop) {

                // Start back at beginning of array
                current = 0
                // If shuffled, we create a new random sequence
                if(settings.slideShowShuffle) {
                    images = []
                    for(var i = 0; i < variables.totalNumberImagesCurrentFolder; ++i)
                        if(i !== variables.currentFilePos)
                            images.push(i)
                    images = shuffle(images)
                    images.push(variables.currentFilePos)
                }
            // End of array, not looping -> stop slideshow
            } else {
                stopSlideshow()
                return;
            }
        }

        // Display new image and increment counter
        Handle.loadFile(variables.allFilesCurrentDir[images[current]], variables.filter)
        ++current
    }


    Timer {
        id: hidebarsoon
        interval: 500
        repeat: false
        running: false
        onTriggered: call.hide("slideshowbar")
    }

    Timer {
        id: imageswitcher
        repeat: true
        running: false
        onTriggered: switchImage()
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
