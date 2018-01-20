import QtQuick 2.5
import QtQuick.Controls 1.4
import "./"

Rectangle {

    id: ele_top

    width: 200
    height: 30

    radius: variables.global_item_radius
    color: colour.element_bg_color

    border.color: colour.element_border_color

    property bool readOnly: false

    property string text: ed1.text
    property int fontsize: 10

    property string tooltip: ""

    // This message is displayed in the background when the TextEdit is empty
    property string emptyMessage: ""

    signal textEdited()

    TextInput {

        id: ed1

        x: 3
        y: (parent.height-height)/2

        enabled: ele_top.visible

        width: parent.width-6

        color: enabled ? colour.text : colour.text_disabled
        selectedTextColor: colour.text_selected
        selectionColor: enabled ? colour.text_selection_color : colour.text_selection_color_disabled
        Behavior on selectionColor { ColorAnimation { duration: 150; } }
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
            propagateComposedEvents: true

            // We use these to re-implement selecting text by mouse (otherwise it'll be overwritten by dragging feature)
            onClicked:
                if(mouse.button == Qt.RightButton)
                    contextmenu.popup()
            onDoubleClicked:
                parent.selectAll()
            onPressed: { if(mouse.button == Qt.LeftButton) { held = true; ed1.cursorPosition = ed1.positionAt(mouse.x,mouse.y); } parent.forceActiveFocus() }
            onReleased: { if(mouse.button == Qt.LeftButton) held = false }
            onPositionChanged: {if(held) ed1.moveCursorSelection(ed1.positionAt(mouse.x,mouse.y)) }

        }

        ContextMenu {
            id: contextmenu
            MenuItem {
                //: As in 'Undo latest change'
                text: em.pty+qsTr("Undo")
                enabled: ed1.canUndo
                onTriggered:
                    ed1.undo()
            }
            MenuItem {
                //: As in 'Redo latest change'
                text: em.pty+qsTr("Redo")
                enabled: ed1.canRedo
                onTriggered:
                    ed1.redo()
            }
            MenuSeparator { }
            MenuItem {
                //: selection = selected text
                text: em.pty+qsTr("Cut selection")
                enabled: !ele_top.readOnly && ed1.selectedText!=""
                onTriggered:
                    ed1.cut()
            }
            MenuItem {
                //: selection = selected text
                text: em.pty+qsTr("Copy selection to clipboard")
                enabled: ed1.selectedText!=""
                onTriggered:
                    ed1.copy()
            }
            MenuItem {
                text: em.pty+qsTr("Paste clipboard content")
                enabled: !ele_top.readOnly && ed1.canPaste
                onTriggered:
                    ed1.paste()
            }
            MenuItem {
                //: content refers to text content in a line edit
                text: em.pty+qsTr("Delete content")
                enabled: !ele_top.readOnly && ed1.selectedText!=""
                onTriggered:
                    ed1.text = ""
            }
            MenuSeparator { }
            MenuItem {
                //: Refering to all text
                text: em.pty+qsTr("Select all")
                enabled: ed1.text!=""
                onTriggered:
                    ele_top.selectAll()
            }
            MenuItem {
                //: In the sense of 'Selecting all text and copying it to clipboard'
                text: em.pty+qsTr("Select all and copy")
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
        ed1.forceActiveFocus()
        ed1.selectAll()
    }

    function getText() {
        return ed1.text
    }

    function clear() {
        ed1.text = ""
    }

}
