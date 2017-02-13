import QtQuick 2.3
import QtQuick.Controls 1.2
import QtMultimedia 5.3

import "../elements"

Rectangle {

    id: bar

    // Background/Border color
    color: colour.fadein_slidein_bg
    border.width: 1
    border.color: colour.fadein_slidein_border

    // Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
    x: -1
    y: -height

    // Adjust size
    width: background.width+2
    height: pause.height+20

    // paused?
    property bool paused: false

    property var images: []
    property int current: 0

    CustomButton {
        id: pause
        x: 10
        y: 10
        text: paused ? qsTr("Play Slideshow") : qsTr("Pause Slideshow")
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
                text: qsTr("Music Volume:")
                font.pointSize: 10
                y: (volumerect.height-height)/2
                color: settings.slideShowMusicFile == "" ? colour.text_disabled : colour.text
            }
            CustomSlider {
                id: volumeslider
                minimumValue: 0
                maximumValue: 100
                stepSize: 1
                scrollStep: 5
                value: 80
                enabled: settings.slideShowMusicFile != ""
                y: (volumerect.height-height)/2
            }
            Text {
                text: "" + volumeslider.value + "%"
                font.pointSize: 10
                y: (volumerect.height-height)/2
                color: settings.slideShowMusicFile == "" ? colour.text_disabled : colour.text
            }
        }
    }

    CustomButton {
        id: exit
        x: bar.width-width-10
        y: 10
        text: qsTr("Quit Slideshow")
        onClickedButton: stopSlideshow()
    }

    // Audio element
    Audio {
        id: slideshowmusic
        volume: volumeslider.value/100.0
        onError: console.error("AUDIO ERROR:",errorString,"-",source)
    }

    // Display the bar
    function showBar() {
        verboseMessage("SlideshowBar::showBar()",bar.y + "/" + bar.height + " (" + slideshowRunning + ")")
        if(bar.y <= -bar.height && slideshowRunning)
            showBarAni.start()
    }
    // Hide the bar
    function hideBar() {
        if(!paused)
            hideBarAni.start()
    }

    // Show and hide the bar shortly after again (used at start and end of slideshow)
    function showAndHideBar() {
        verboseMessage("SlideshowBar::showAndHideBar()","Show and Hide")
        showBar()
        hidebarsoon.start()
    }

    // Start a slideshow
    function startSlideshow() {

        verboseMessage("SlideshowBar::startSlideshow()","Starting Slideshow...")

        // Set some variables
        slideshowRunning = true
        blocked = true
        softblocked = 1

        // Update the quickinfo (i.e., hide if requested)
        quickInfo.updateQuickInfo(quickInfo._pos,thumbnailBar.totalNumberImages,thumbnailBar.currentFile)

        // Set music file
        if(settings.slideShowMusicFile != "") {
            slideshowmusic.source = "file:/" + settings.slideShowMusicFile
            slideshowmusic.play()
        }

        // Reset changes to current image
        mainview.resetZoom()
        mainview.resetRotation()
        mainview.resetMirror()

        setImageInteractiveMode(false)

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
            for(var i = quickInfo._pos+1; i < thumbnailBar.totalNumberImages; ++i)
                images.push(i);

            // Option 2
            if(settings.slideShowLoop) {
                for(var i = 0; i <= quickInfo._pos; ++i)
                    images.push(i);
            }

        // Option 3
        } else {

            for(var i = 0; i < thumbnailBar.totalNumberImages; ++i)
                if(i != quickInfo._pos)
                    images.push(i)

            // Shuffle function at end of file
            images = shuffle(images)

            // We always end up again at the currently displayed one
            images.push(quickInfo._pos)

        }

        // Set up timer for switching images
        imageswitcher.interval = settings.slideShowTime*1000
        imageswitcher.start()

        // Slide in and out bar to signal start of slideshow
        showAndHideBar()

    }

    // Pause/Play slideshow
    function pauseSlideshow() {

        verboseMessage("SlideshowBar::pauseSlideshow()",paused)

        // Pause
        if(!paused) {
            // Pause music (if set)
            if(settings.slideShowMusicFile != "")
                slideshowmusic.pause()
            paused = true
            imageswitcher.stop()
            // The bar remains shown when slideshow paused
            showBar()
        // Play
        } else {
            // Play music (if set)
            if(settings.slideShowMusicFile != "")
                slideshowmusic.play()
            paused = false
            imageswitcher.start()
        }
    }

    // Stop slideshow
    function stopSlideshow() {

        verboseMessage("SlideshowBar::stopSlideshow()","Stopping show...")

        // We're definitely not paused anymore
        paused = false

        // Stop switching images
        imageswitcher.stop()

        // Signal end by slide in/out of bar
        showAndHideBar()

        // Stop music (if started)
        if(settings.slideShowMusicFile != "")
            slideshowmusic.stop()

        // Update variables
        slideshowRunning = false
        blocked = false
        softblocked = 0

        setImageInteractiveMode(true)

        // Update quickinfo state
        quickInfo.updateQuickInfo(quickInfo._pos,thumbnailBar.totalNumberImages,thumbnailBar.currentFile)

    }

    // Load a new image
    function switchImage() {

        if(!slideshowRunning) {
            imageswitcher.stop()
            setImageInteractiveMode(true)
            return
        }

        verboseMessage("SlideshowBar::switchImage()",current + "/" + images.length + " - " + settings.slideShowLoop + " - " + settings.slideShowShuffle)

        // If we reached the end of the array
        if(current == images.length) {

            // If looping the array
            if(settings.slideShowLoop) {

                // Start back at beginning of array
                current = 0
                // If shuffled, we create a new random sequence
                if(settings.slideShowShuffle) {
                    images = []
                    for(var i = 0; i < thumbnailBar.totalNumberImages; ++i)
                        if(i != quickInfo._pos)
                            images.push(i)
                    images = shuffle(images)
                    images.push(quickInfo._pos)
                }
            // End of array, not looping -> stop slideshow
            } else {
                stopSlideshow()
                return;
            }
        }
        // Display new image and increment counter
        thumbnailBar.displayImage(images[current])
        ++current
    }

    PropertyAnimation {
        id: hideBarAni
        target: bar
        property: "y"
        to: -bar.height
        onStopped: bar.y = -bar.height-safetyDistanceForSlidein
    }
    PropertyAnimation {
        id: showBarAni
        target: bar
        property: "y"
        from: -bar.height
        to: -1
        onStarted: hideBarAni.stop()
    }


    Timer {
        id: hidebarsoon
        interval: 500
        repeat: false
        running: false
        onTriggered: hideBar()
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
