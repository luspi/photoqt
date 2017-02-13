import QtQuick 2.3

Rectangle {

    id: ele_top

    width: 200
    height: 30

    radius: global_item_radius
    color: colour.element_bg_color

    border.color: colour.element_border_color

    property string text: ed1.text
    property int fontsize: 10

    property string tooltip: ""

    // This message is displayed in the background when the TextEdit is empty
    property string emptyMessage: ""

    signal textEdited()
    signal accepted()
    signal rejected()

    signal arrowUp()
    signal arrowDown()
    signal pageUp()
    signal pageDown()
    signal gotoHome()
    signal gotoEnd()

    signal altLeft()
    signal altRight()
    signal altUp()

    signal clicked()

    signal historyBack()
    signal historyForwards()

    TextInput {

        id: ed1

        x: 3
        y: (parent.height-height)/2

        width: parent.width-6

        color: colour.text
        selectedTextColor: colour.text_selected
        selectionColor: colour.text_selection_color
        text: parent.text
        font.pointSize: parent.fontsize

        clip: true

        onTextChanged: parent.textEdited()

        ToolTip {

            text: parent.parent.tooltip

            property bool held: false

            anchors.fill: parent
            cursorShape: Qt.IBeamCursor

            // We use these to re-implement selecting text by mouse (otherwise it'll be overwritten by dragging feature)
            onClicked: parent.parent.clicked()
            onDoubleClicked: parent.selectAll()
            onPressed: { held = true; ed1.cursorPosition = ed1.positionAt(mouse.x,mouse.y); parent.forceActiveFocus() }
            onReleased: held = false
            onPositionChanged: {if(held) ed1.moveCursorSelection(ed1.positionAt(mouse.x,mouse.y)) }

        }

        Keys.onPressed: {

            if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return)

                ele_top.accepted()

            else if(event.key === Qt.Key_Escape)

                ele_top.rejected()

            else if(event.key === Qt.Key_Up) {

                if(event.modifiers & Qt.ControlModifier)
                    ele_top.gotoHome()
                else if(event.modifiers & Qt.AltModifier)
                    ele_top.altUp()
                else
                    ele_top.arrowUp()

            } else if(event.key === Qt.Key_Down) {

                if(event.modifiers & Qt.ControlModifier)
                    ele_top.gotoEnd()
                else
                    ele_top.arrowDown()

            } else if(event.key === Qt.Key_PageUp)

                ele_top.pageUp()

            else if(event.key === Qt.Key_PageDown)

                ele_top.pageDown()

            else if(event.key === Qt.Key_Left) {

                if(event.modifiers & Qt.AltModifier)
                    ele_top.altLeft()

            } else if(event.key === Qt.Key_Right) {

                if(event.modifiers & Qt.AltModifier)
                    ele_top.altRight()

            } else if(event.key === Qt.Key_F) {
                if(event.modifiers & Qt.ControlModifier)
                    ele_top.historyForwards()
            } else if(event.key === Qt.Key_B) {
                if(event.modifiers & Qt.ControlModifier)
                    ele_top.historyBack()
            }

        }

    }

    Text {
        anchors.fill: ed1
        visible: ed1.text==""
        color: colour.text_inactive
        text: parent.emptyMessage
    }

    function selectAll() {
        ed1.focus = true
        ed1.selectAll()
    }

    function getText() {
        return ed1.text
    }

}
