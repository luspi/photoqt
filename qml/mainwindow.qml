import QtQuick 2.6
import QtQuick.Window 2.2

import "./mainview"
import "./shortcuts"

Window {

    id: mainwindow

    property int currentSample: 0
    property var samples: ["file:///home..."]

    visible: true

    minimumWidth: 640
    minimumHeight: 480

    title: qsTr("Hello World")

    flags: Qt.Window|Qt.FramelessWindowHint

    color: "transparent"

    Background { id: background }
    MainImage { id: imageitem }

    Shortcuts {
        id: shortcuts;
        onShortcutReceived: {
            if(combo == "Left") {
                --currentSample
                if(currentSample < 0) currentSample = samples.length-1
                imageitem.filename = samples[currentSample]
            } else if(combo == "Right") {
                ++currentSample
                if(currentSample >= samples.length) currentSample = 0
                imageitem.filename = samples[currentSample]
            } else if(combo == "R")
                imageitem.resetPosition()
        }
    }

    Component.onCompleted: showMaximized()
}
