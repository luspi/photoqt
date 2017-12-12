import QtQuick 2.6
import QtQuick.Window 2.2

import PSettings 1.0
import PFileFormats 1.0
import PGetAndDoStuff 1.0
import PGetMetaData 1.0
import PToolTip 1.0
import PColour 1.0
import QtGraphicalEffects 1.0
import PImageWatch 1.0
import PImgur 1.0
import PClipboard 1.0

import "./mainview"
import "./shortcuts"

Window {

    id: mainwindow

    // just a temporary solution for loading images. Will be replaced by OpenFile dialog
    property int currentSample: 0
    property var samples: ["file:///home..."]

    visible: true
    // Some signals for communicating back to the C++ code base
    signal verboseMessage(string loc, string msg);

    // The minimum size of the window
    minimumWidth: 640
    minimumHeight: 480

    // Transparent background, the Background element handles the actual background
    color: "transparent"

    // Without this nothing will be visible
    visible: true

    // Some window styling
    title: qsTr("PhotoQt Image Viewer")
    flags: Qt.Window|Qt.FramelessWindowHint


    /**************************************************************
     *                                                            *
     * SOME INVISIBLE ELEMENTS FOR INTERACTING WITH C++ CODE BASE *
     *                                                            *
     **************************************************************/

    // All the permanent settings
    PSettings { id: settings }
    // The fileformats known to PhotoQt
    PFileFormats { id: fileformats; }
    // The colouring of PhotoQt
    PColour { id: colour; }
    // A whole bunch of C++ helper functions for QML
    PGetAndDoStuff { id: getanddostuff; }
    // Read the Exif/IPTC metadata of images
    PGetMetaData { id: getmetadata; }
    // Watch for changes to images in the currently loaded folder
    PImageWatch { id: imagewatch }
    // Share images to imgur.com
    PImgur { id: shareonline_imgur; }
    // Interact with the clipboard
    PClipboard { id: clipboard; }


    /*******************************************
     *                                         *
     * SOME INVISIBLE ELEMENTS FOR QML CLASSES *
     *                                         *
     *******************************************/

    // The shortcuts engine
    Shortcuts {
        id: shortcuts;

        // Temporary solution for initial development
        onShortcutReceived: {
            if(combo == "Left") {
                --currentSample
                if(currentSample < 0) currentSample = samples.length-1
                imageitem.loadImage(samples[currentSample])
            } else if(combo == "Right") {
                ++currentSample
                if(currentSample >= samples.length) currentSample = 0
                imageitem.loadImage(samples[currentSample])
            } else if(combo == "R")
                imageitem.resetPosition()
            else if(combo == "+")
                imageitem.zoomIn()
            else if(combo == "-")
                imageitem.zoomOut()
            else if(combo == "0")
                imageitem.resetZoom()
            else if(combo == "1")
                imageitem.rotateLeft45()
            else if(combo == "2")
                imageitem.rotateLeft90()
            else if(combo == "3")
                imageitem.rotateRight45()
            else if(combo == "4")
                imageitem.rotateRight90()
            else if(combo == "5")
                imageitem.rotate180()
            else if(combo == "6")
                imageitem.resetRotation()
        }
    }


    /************************************
     *                                  *
     * THE VISIBLE ELEMENTS FOR THE GUI *
     *                                  *
     ************************************/

    // Managing the background begind everything
    Background { id: background }

    // The item for displaying the main image
    MainImage { id: imageitem }



    /************************************
     ************************************/


    Component.onCompleted: {
        setWindowFlags()
    }


    /**************************************************
     *                                                *
     * A WHOLE BUNCH OF FUNCTIONS TO DO GENERAL STUFF *
     *                                                *
     **************************************************/

    function setWindowFlags() {

        verboseMessage("mainwindow.qml > setWindowFlags()", "starting processing")

        if(settings.windowmode) {
            if(settings.keepOnTop) {
                if(settings.windowDecoration)
                    mainwindow.flags = Qt.Window|Qt.WindowStaysOnTopHint
                else
                    mainwindow.flags = Qt.Window|Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint
            } else {
                if(settings.windowDecoration)
                    mainwindow.flags = Qt.Window
                else
                    mainwindow.flags = Qt.Window|Qt.FramelessWindowHint
            }
            if(settings.saveWindowGeometry) {
                var rect = getanddostuff.getStoredGeometry()
                if(rect.width < 100 || rect.height < 100)
                    showMaximized()
                else {
                    show()
                    mainwindow.x = rect.x
                    mainwindow.y = rect.y
                    mainwindow.width = rect.width
                    mainwindow.height = rect.height
                }
            } else
                mainwindow.showMaximized()
        } else {

            if(settings.keepOnTop)
                mainwindow.flags = Qt.WindowStaysOnTopHint|Qt.FramelessWindowHint
            else
                mainwindow.flags = Qt.FramelessWindowHint

            if(getanddostuff.detectWindowManager() == "enlightenment")
                showMaximized()
            else
                showFullScreen()

        }

    }

}
