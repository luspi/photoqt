import QtQuick 2.3
import QtQuick.Controls 1.2
import "./"

Rectangle {

    id: ele_top

    width: 200
    height: 30

    radius: global_item_radius
    color: colour.element_bg_color

    border.color: colour.element_border_color

    property bool readOnly: false

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
    signal doubleClicked()

    signal historyBack()
    signal historyForwards()

    TextInput {

        id: ed1

        x: 3
        y: (parent.height-height)/2

        width: parent.width-6

        color: enabled ? colour.text : colour.text_disabled
        selectedTextColor: colour.text_selected
        selectionColor: enabled ? colour.text_selection_color : colour.text_selection_color_disabled
        text: parent.text
        font.pointSize: parent.fontsize

        readOnly: parent.readOnly

        clip: true

        onTextChanged: parent.textEdited()

        ToolTip {

            text: parent.parent.tooltip

            property bool held: false

            anchors.fill: parent
            acceptedButtons: Qt.LeftButton|Qt.RightButton
            cursorShape: Qt.IBeamCursor

            // We use these to re-implement selecting text by mouse (otherwise it'll be overwritten by dragging feature)
            onClicked: {
                if(mouse.button == Qt.LeftButton)
                    parent.parent.clicked()
                else
                    contextmenu.popup()

            }
            onDoubleClicked: {
                parent.selectAll()
                parent.parent.doubleClicked()
            }
            onPressed: { if(mouse.button == Qt.LeftButton) { held = true; ed1.cursorPosition = ed1.positionAt(mouse.x,mouse.y); } parent.forceActiveFocus() }
            onReleased: { if(mouse.button == Qt.LeftButton) held = false }
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

        ContextMenu {
            id: contextmenu
            MenuItem {
                text: "Undo"
                enabled: ed1.canUndo
                onTriggered:
                    ed1.undo()
            }
            MenuItem {
                text: "Redo"
                enabled: ed1.canRedo
                onTriggered:
                    ed1.redo()
            }
            MenuSeparator { }
            MenuItem {
                text: "Cut selection"
                enabled: !ele_top.readOnly && ed1.selectedText!=""
                onTriggered:
                    ed1.cut()
            }
            MenuItem {
                text: "Copy selection to clipboard"
                enabled: ed1.selectedText!=""
                onTriggered:
                    ed1.copy()
            }
            MenuItem {
                text: "Paste clipboard content"
                enabled: !ele_top.readOnly && ed1.canPaste
                onTriggered:
                    ed1.paste()
            }
            MenuItem {
                text: "Delete content"
                enabled: !ele_top.readOnly && ed1.selectedText!=""
                onTriggered:
                    ed1.text = ""
            }
            MenuSeparator { }
            MenuItem {
                text: "Select all"
                enabled: ed1.text!=""
                onTriggered:
                    ele_top.selectAll()
            }
            MenuItem {
                text: "Select all and copy"
                enabled: ed1.text!=""
                onTriggered: {
                    ele_top.selectAll()
                    ed1.copy()
                }
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

    function clear() {
        ed1.text = ""
    }

}
