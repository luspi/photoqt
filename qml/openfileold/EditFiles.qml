import QtQuick 2.4
import "../elements/"

Rectangle {

    id: edit_rect

    signal filenameEdit(var filename)
    signal accepted()

    height: filename_edit.height+filename_edit.anchors.bottomMargin*2
    color: "#99000000"

    signal focusOnNextItem()
    signal focusOnPrevItem()
    signal moveFocusFiveUp()
    signal moveFocusFiveDown()
    signal focusOnFirstItem()
    signal focusOnLastItem()
    signal focusOnFolderView()
    signal focusOnUserPlaces()
    signal moveOneLevelUp()
    signal goBackHistory()
    signal goForwardsHistory()

    CustomLineEdit {

        id: filename_edit

        width: parent.width-10
        x: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5

        onTextEdited: filenameEdit(getText())

    }

    Connections {
        target: call
        onShortcut: {
            if(currentInFocus != "filesview" || !openfile_top.visible) return
            if(sh == "Enter" || sh == "Return")
                edit_rect.accepted()
            else if(sh == "Up")
                focusOnPrevItem()
            else if(sh == "Down")
                focusOnNextItem()
            else if(sh == "Page Up")
                moveFocusFiveUp()
            else if(sh == "Page Down")
                moveFocusFiveDown()
            else if(sh == "Home")
                focusOnFirstItem()
            else if(sh == "End")
                focusOnLastItem()
            else if(sh == "Alt+Left")
                focusOnFolderView()
            else if(sh == "Alt+Right")
                focusOnUserPlaces()
            else if(sh == "Alt+Up")
                moveOneLevelUp()
            else if(sh == "Ctrl+B")
                goBackHistory()
            else if(sh == "Ctrl+F")
                goForwardsHistory()
            else if(sh == "Ctrl++" || sh == "Ctrl+=")
                tweaks.zoomLarger()
            else if(sh == "Ctrl+-")
                tweaks.zoomSmaller()
            else if(sh == "Alt+." || sh == "Ctrl+H")
                tweaks.toggleHiddenFolders()

        }
    }

    function setEditText(txt) {

        filename_edit.text = txt

    }

    function focusOnInput() {
        filename_edit.selectAll()
    }

}
