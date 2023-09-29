import QtQuick

import "../elements"

Rectangle {

    x: (toplevel.width-width)/2
    y: (toplevel.height-height)/2

    width: txt.width+100
    height: txt.height+30

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    color: PQCLook.transColor

    property alias statustext: txt.text

    radius: 15

    PQTextL {
        id: txt
        x: 50
        y: 15
        font.weight: PQCLook.fontWeightBold
        text: ""
    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {
                if(param === "notification")
                    show()
            }

        }

    }

    Timer {
        id: hideNotification
        interval: 2000
        onTriggered:
            hide()
    }

    function show() {
        opacity = 1
        hideNotification.restart()
    }

    function hide() {
        opacity = 0
    }

}
