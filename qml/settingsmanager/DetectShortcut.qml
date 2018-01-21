import QtQuick 2.5

import "../elements"
import "../shortcuts/mouseshortcuts.js" as AnalyseMouse

Rectangle {

    id: detect_top

    anchors.fill: parent
    color: "#ee000000"

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    visible: (opacity!=0)

    property string category: "key"

    signal gotNewShortcut(var sh)
    signal abortedShortcutDetection()

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
    Text {

        id: combo

        // position and size
        anchors {
            top: toprow.bottom
            left: parent.left
            right: parent.right
            bottom: bottomrow.top
        }

        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter

        color: "white"
        font.pointSize: 30
        font.bold: true
        textFormat: Text.RichText
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        // display either key or mouse combo, they are set/cleared during the detection process below
        text: "..."

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

            text: em.pty+qsTr("Cancel")

            onClickedButton: {
                abortedShortcutDetection()
                hide()
            }

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

            text: em.pty+qsTr("Perform any mouse action or press any key combination.") + "\n"
                  + em.pty+qsTr("When your satisfied, click the button to the right.")

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

            text: em.pty+qsTr("Ok, set shortcut")

            onClickedButton: {
                gotNewShortcut(combo.text)
                hide()
            }

        }

    }

    Connections {
        target: call
        onShortcut: {
            // ignore if not visible
            if(!detect_top.visible) return
            if(!combo.mouseEventInProgress)
                combo.text = sh
        }
    }

    MouseArea {

        anchors.fill: combo

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

        property point pressedPosStart: Qt.point(-1,-1)
        property point pressedPosEnd: Qt.point(-1,-1)

        property bool mouseEventInProgress: false
        property int buttonId: 0

        onPositionChanged:
            handleMousePositionChange(mouse)
        onPressed: {
            buttonId = mouse.button
            mouseEventInProgress = true
            pressedPosStart = Qt.point(mouse.x, mouse.y)
            variables.shorcutsMouseGesturePointIntermediate = Qt.point(-1,-1)
        }
        onReleased: {
            var txt = AnalyseMouse.analyseMouseEvent(pressedPosStart, mouse, buttonId)
            if(txt != "") combo.text = txt
            pressedPosEnd = Qt.point(mouse.x, mouse.y)
            pressedPosStart = Qt.point(-1,-1)
            mouseEventInProgress = false
        }
        onWheel: {
            var txt = AnalyseMouse.analyseWheelEvent(wheel, true)
            if(txt != "") {
                combo.text = txt
                wheelEventDone.start()
            }
        }
        Timer {
            id: wheelEventDone
            interval: 1000
            repeat: false
            onTriggered: {
                variables.wheelUpDown = 0
                variables.wheelLeftRight = 0
            }
        }

        function handleMousePositionChange(mouse) {

            if(pressedPosStart.x != -1 || pressedPosStart.y != -1) {
                var before = variables.shorcutsMouseGesturePointIntermediate
                if(variables.shorcutsMouseGesturePointIntermediate.x == -1 || variables.shorcutsMouseGesturePointIntermediate.y == -1)
                    before = pressedPosStart
                AnalyseMouse.analyseMouseGestureUpdate(mouse.x, mouse.y, before)
                var txt = AnalyseMouse.analyseMouseEvent(pressedPosStart, mouse, buttonId, true)
                if(txt != "") combo.text = txt
            }

        }

    }

    function show() {
        combo.text = "..."
        opacity = 1
    }

    function hide() {
        opacity = 0
    }


}
