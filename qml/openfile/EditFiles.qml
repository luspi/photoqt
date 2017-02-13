import QtQuick 2.3
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

    property bool inCurrentFocus: filename_edit.activeFocus

    CustomLineEdit {

        id: filename_edit

        width: parent.width-10
        x: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5

        onTextEdited: filenameEdit(getText())
        onAccepted: edit_rect.accepted()

        onArrowUp: focusOnPrevItem()
        onArrowDown: focusOnNextItem()

        onPageUp: moveFocusFiveUp()
        onPageDown: moveFocusFiveDown()

        onGotoHome: focusOnFirstItem()
        onGotoEnd: focusOnLastItem()

        onAltLeft: focusOnFolderView()
        onAltRight: focusOnUserPlaces()
        onAltUp: moveOneLevelUp()

        onHistoryBack: goBackHistory()
        onHistoryForwards: goForwardsHistory()

    }

    function setEditText(txt) {

        filename_edit.text = txt

    }

    function focusOnInput() {
        filename_edit.forceActiveFocus()
        filename_edit.selectAll()
    }

}
