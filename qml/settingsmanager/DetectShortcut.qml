import QtQuick 2.6

import "../elements"
import "../shortcuts/mouseshortcuts.js" as AnalyseMouse

Rectangle {

    id: detect_top

    anchors.fill: parent
    color: "#ee000000"

    Component.onCompleted: show()

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: (opacity!=0)

    property string category: "key"

    // The top row displaying icons for the two categories
    Item {

        id: toprow

        // size and position
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 150

        // This item contains the icon and is centered in the rectangle
        Item {

            // Centered, a little smaller in height than the parent
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: categoryKey.width+categoryMouse.width+50
            height: 100

            // Mouse shortcut
            Image {
                id: categoryMouse
                opacity: detect_top.category=="mouse" ? 1 : 0.2
                width: 100
                height: 100
                source: "qrc:/img/settings/shortcuts/categorymouse.png"
            }

            // Keyboard shortcut
            Image {
                id: categoryKey
                opacity: detect_top.category=="key" ? 1 : 0.2
                x: categoryMouse.width+50
                width: 100
                height: 100
                source: "qrc:/img/settings/shortcuts/categorykeyboard.png"
            }

        }

    }

    // Separator line
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: toprow.bottom
        }
        height: 1
        color: "white"
    }

    // The area in the middle displays the performed shortcut and is the hotarea for mouse shortcut detection
    Item {

        id: middlearea

        // The modifiers pressed, used for both key and mouse shortcuts
        property string modifiers: ""

        // The key shortcut
        property string keycombo: ""

        // The mouse shortcut
        property string mouseButton: ""
        property string mouseWheel: ""
        property string mousePath: ""
        property string mousePathDisplay: ""

        // position and size
        anchors {
            top: toprow.bottom
            left: parent.left
            right: parent.right
            bottom: bottomrow.top
        }

        // text label to display key/mouse combo
        Text {
            id: keymousecombo
            anchors.fill: parent
            color: "white"
            font.pointSize: 30
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            // display either key or mouse combo, they are set/cleared during the detection process below
            text: middlearea.keycombo!=""
                        ? middlearea.modifiers+middlearea.keycombo
                        : (middlearea.mouseWheel==""?middlearea.modifiers:"")
                            + middlearea.mouseButton+middlearea.mouseWheel
                            + (middlearea.mousePathDisplay!=""?"+":"")
                            + middlearea.mousePathDisplay
        }

        // hot area for detecting mouse actions
        MouseArea {

            id: mouseSH

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

            // This is used for detecting the previous waypoint during a mouse gesture
            property point pressedPos: Qt.point(-1,-1)

            // Which one is currently pressed
            property bool mousePressed: false
            property bool keysPressed: false

            // mouse movement
            onPositionChanged:
                handleMousePositionChange(mouse)

            // pressing a button
            onPressed: {

                // if no keys are pressed, reset modifiers
                if(!keysPressed)
                    middlearea.modifiers = ""

                // set category to mouse
                detect_top.category = "mouse"
                mousePressed = true

                // the starting waypoint, needed for gestures
                pressedPos = Qt.point(mouse.x, mouse.y)

                // update shortcut text
                middlearea.mouseButton = getMouseButton(mouse)
                middlearea.mousePath = ""
                middlearea.mousePathDisplay = ""
                middlearea.mouseWheel = ""
                middlearea.keycombo = ""

            }
            onReleased: {

                // ensure category is set to mouse, even though mouse gesture is done
                detect_top.category = "mouse"
                mousePressed = false

                // Set gesture to empty after we're done
                variables.shortcutsMouseGesture = []

            }

            onWheel: {

                // set category to mouse
                detect_top.category = "mouse"

                // update the shortcut text
                middlearea.mouseWheel = AnalyseMouse.analyseWheelEvent(wheel)
                middlearea.mousePath = ""
                middlearea.mousePathDisplay = ""
                middlearea.mouseButton = ""

            }

            Connections {

                target: call

                onShortcut: {
                    // ignore if not visible
                    if(!detect_top.visible) return

                    // keys are pressed!
                    mouseSH.keysPressed = true

                    // if no mouse action is currently performed, reset shortcut text
                    if(!mouseSH.mousePressed) {
                        middlearea.mouseButton = ""
                        middlearea.mousePath = ""
                        middlearea.mousePathDisplay = ""
                        middlearea.mouseWheel = ""
                    }

                    // split key combo into seperate keys
                    var allKey = sh.split("+")
                    // this string will hold the key combo without modifier keys
                    var allKeyWithoutMod = ""

                    // for now reset modifier text
                    middlearea.modifiers = ""

                    // loop through all keys
                    for(var i = 0; i < allKey.length; ++i) {

                        // ignore empty elements
                        if(allKey[i] == "")
                            continue

                        // check for modifier keys
                        if(allKey[i] == "Ctrl")
                            middlearea.modifiers += str_keys.get("ctrl") + "+"
                        else if(allKey[i] == "Alt")
                            middlearea.modifiers += str_keys.get("alt") + "+"
                        else if(allKey[i] == "Shift")
                            middlearea.modifiers += str_keys.get("shift") + "+"
                        else if(allKey[i] == "Meta")
                            middlearea.modifiers += str_keys.get("meta") + "+"
                        else if(allKey[i] == "Keypad")
                            middlearea.modifiers += str_keys.get("keypad") + "+"

                        // any other key is a 'normal' key
                        else {
                            if(allKeyWithoutMod.length > 0)
                                allKeyWithoutMod += "+"
                            allKeyWithoutMod += allKey[i]
                        }

                    }

                    // if no mouse action is currently performed, set key combo
                    if(!mouseSH.mousePressed) {
                        middlearea.keycombo = allKeyWithoutMod
                        detect_top.category = "key"
                    }

                }

                // key combo finished
                onKeysReleased:
                    mouseSH.keysPressed = false

            }

            // get the current mouse button
            function getMouseButton(event) {
                if(event.button == Qt.LeftButton)
                    return "Left Button"
                else if(event.button == Qt.MiddleButton)
                    return "Middle Button"
                else if(event.button == Qt.RightButton)
                    return "Right Button"
            }

            // handle a mouse movement
            function handleMousePositionChange(event) {

                // if no mouse button is currently pressed, ignore movement
                if(!mousePressed)
                    return

                // ensure category is set to mouse
                detect_top.category = "mouse"

                // analyse latest movement. If no waypoint added, update pressedPos position
                if(AnalyseMouse.analyseMouseGestureUpdate(event.x, event.y, pressedPos))
                    pressedPos = Qt.point(event.x, event.y)

                // For displaying, we use full words instead of just letters
                var repl = ({"E" : qsTr("East"),
                             "N" : qsTr("North"),
                             "W" : qsTr("West"),
                             "S" : qsTr("South")})

                // store movement
                var movement = ""
                var movementdisp = ""

                // look through gesture array
                for(var i = 0; i < variables.shortcutsMouseGesture.length; ++i) {

                    // Add separator
                    if(i > 0) {
                        movement += "-"
                        movementdisp += "-"
                    }

                    // update movement strings
                    movement += variables.shortcutsMouseGesture[i]
                    movementdisp += repl[variables.shortcutsMouseGesture[i]]

                }

                // if movement has changed, update shortcut text
                if(middlearea.mousePath != movement) {
                    middlearea.mousePath = movement
                    middlearea.mousePathDisplay = movementdisp
                }

            }

        }

    }

    // Separator line
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomrow.top
        }
        height: 1
        color: "white"
    }

    // An area at the bottom for cancel/ok buttons and instruction text
    Item {

        id: bottomrow

        // size and position
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 150

        // Button to cancel
        CustomButton {

            id: cancelbut

            // size and position
            anchors {
                left: parent.left
                leftMargin: 5
                top: parent.top
                topMargin: 5
                bottom: parent.bottom
                bottomMargin: 5
            }
            width: parent.height*3

            // some font styling
            fontsize: 30
            fontBold: true

            text: qsTr("Cancel")

            onClickedButton: hide()

        }

        Text {

            // size and position
            anchors {
                left: cancelbut.right
                leftMargin: 10
                right: okbut.left
                rightMargin: 10
                top: parent.top
                bottom: parent.bottom
            }

            // some styling
            font.pointSize: 15
            font.bold: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: "white"

            text: qsTr("Perform any mouse action or press any key combination.") + "\n" + qsTr("When your satisfied, click the button to the right.")

        }

        CustomButton {

            id: okbut

            // size and position
            anchors {
                right: parent.right
                rightMargin: 5
                top: parent.top
                topMargin: 5
                bottom: parent.bottom
                bottomMargin: 5
            }
            width: parent.height*3

            // some styling
            fontsize: 30
            fontBold: true

            text: "Ok, set shortcut"

        }

    }

    function show() {
        middlearea.keycombo = "..."
        middlearea.modifiers = ""
        opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
