import QtQuick 2.6

Item {

    // (VERY) TEMPORARY SHORTCUTS ENGINE

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
        case Qt.Key_Plus:
            console.log("+")
            shortcutReceived("+")
            break
        case Qt.Key_Minus:
            console.log("-")
            shortcutReceived("-")
            break
        case Qt.Key_0:
            console.log("0")
            shortcutReceived("0")
            break
        case Qt.Key_1:
            console.log("1")
            shortcutReceived("1")
            break
        case Qt.Key_2:
            console.log("2")
            shortcutReceived("2")
            break
        case Qt.Key_3:
            console.log("3")
            shortcutReceived("3")
            break
        case Qt.Key_4:
            console.log("4")
            shortcutReceived("4")
            break
        case Qt.Key_5:
            console.log("5")
            shortcutReceived("5")
            break
        case Qt.Key_6:
            console.log("6")
            shortcutReceived("6")
            break
        case Qt.Key_O:
            console.log("o")
            shortcutReceived("o")
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
