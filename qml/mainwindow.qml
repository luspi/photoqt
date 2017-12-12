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

    // The minimum size of the window
    minimumWidth: 640
    minimumHeight: 480

    // Transparent background, the Background element handles the actual background
    color: "transparent"

    // Without this nothing will be visible
    visible: true
    Component.onCompleted: showMaximized()

    // Some window styling
    title: qsTr("PhotoQt Image Viewer")
    flags: Qt.Window|Qt.FramelessWindowHint

    // Managing the background begind everything
    Background { id: background }

    // The item for displaying the main image
    MainImage { id: imageitem }

    PSettings { id: settings }

    PFileFormats { id: fileformats; }
    PColour { id: colour; }
    PGetAndDoStuff { id: getanddostuff; }

    PGetMetaData { id: getmetadata; }
    PImageWatch { id: imagewatch }
    PImgur { id: shareonline_imgur; }
    PClipboard { id: clipboard; }

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

}
