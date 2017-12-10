import QtQuick 2.6

Item {

    id: top

//    property var keycodes: ({
//                                 : "Left"
//                            })

    signal shortcutReceived(var combo)

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Left:
            console.log("Left")
            shortcutReceived("Left")
            break
        case Qt.Key_Right:
            console.log("Right")
            shortcutReceived("Right")
            break
        case Qt.Key_Up:
            console.log("Up")
            shortcutReceived("Up")
            break
        case Qt.Key_Down:
            console.log("Down")
            shortcutReceived("Down")
            break
        case Qt.Key_Escape:
            console.log("Escape")
            shortcutReceived("Escape")
            break
        case Qt.Key_R:
            console.log("R")
            shortcutReceived("R")
            break
        default:
            console.log(event.key)
            shortcutReceived(event.key)
        }
    }

    Component.onCompleted: top.forceActiveFocus()

    onActiveFocusChanged:
        top.forceActiveFocus()

}
