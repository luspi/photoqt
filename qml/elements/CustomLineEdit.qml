import QtQuick 2.5
import QtQuick.Controls 1.4
import PContextMenu 1.0
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
    signal tabPressed()

    TextInput {

        id: ed1

        x: 3
        y: (parent.height-height)/2

        enabled: ele_top.visible

        width: parent.width-6

        // This is catched and processed here as otherwise it would be processed (i.e., the LineEdit loses focus) BEFORE the shortcuts engine would receive it
        Keys.onTabPressed:
            tabPressed()

        color: enabled ? colour.text : colour.text_disabled
        selectedTextColor: colour.text_selected
        selectionColor: enabled ? colour.text_selection_color : colour.text_selection_color_disabled
        Behavior on selectionColor { ColorAnimation { duration: variables.animationSpeed/2 } }
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

        PContextMenu {

            id: contextmenu

            Component.onCompleted: {

                //: As in 'Undo latest change'
                addItem(em.pty+qsTr("Undo"))  // 0

                //: As in 'Redo latest change'
                addItem(em.pty+qsTr("Redo"))  // 1

                addSeparator()

                //: selection = selected text
                addItem(em.pty+qsTr("Cut selection"))  // 2

                //: selection = selected text
                addItem(em.pty+qsTr("Copy selection to clipboard"))  // 3

                addItem(em.pty+qsTr("Paste clipboard content"))  // 4

                //: content refers to text content in a line edit
                addItem(em.pty+qsTr("Delete content"))  // 5

                addSeparator()

                //: Refering to all text
                addItem(em.pty+qsTr("Select all"))  // 6

                //: In the sense of 'Selecting all text and copying it to clipboard'
                addItem(em.pty+qsTr("Select all and copy"))  // 7

            }

            onSelectedIndexChanged: {
                console.log("current Index changed:", index)
                if(index == 0)
                    ed1.undo()
                else if(index == 1)
                    ed1.redo()
                else if(index == 2)
                    ed1.cut()
                else if(index == 3)
                    ed1.copy()
                else if(index == 4)
                    ed1.paste()
                else if(index == 5)
                    ed1.text = ""
                else if(index == 6)
                    ele_top.selectAll()
                else if(index == 7) {
                    ele_top.selectAll()
                    ed1.copy()
                }
            }

        }

        Connections {
            target: ed1
            onCanUndoChanged:
                contextmenu.setEnabled(0, ed1.canUndo)
            onCanRedoChanged:
                contextmenu.setEnabled(1, ed1.canRedo)
            onSelectedTextChanged: {
                contextmenu.setEnabled(2, (!ele_top.readOnly && ed1.selectedText!=""))
                contextmenu.setEnabled(3, ed1.selectedText!="")
                contextmenu.setEnabled(5, (!ele_top.readOnly && ed1.selectedText!=""))
            }
            onCanPasteChanged:
                contextmenu.setEnabled(4, (!ele_top.readOnly && ed1.canPaste))
            onTextChanged: {
                contextmenu.setEnabled(6, ed1.text!="")
                contextmenu.setEnabled(7, ed1.text!="")
            }
        }

        Connections {
            target: ele_top
            onReadOnlyChanged: {
                contextmenu.setEnabled(2, (!ele_top.readOnly && ed1.selectedText!=""))
                contextmenu.setEnabled(4, (!ele_top.readOnly && ed1.canPaste))
                contextmenu.setEnabled(5, (!ele_top.readOnly && ed1.selectedText!=""))
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
