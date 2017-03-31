import QtQuick 2.4
import "../elements/"

Rectangle {

    id: hidden
    y: (parent.height-height)/2
    width: hiddencheck.width
    height: hiddencheck.height
    color: "#00000000"

    signal updateHidden()

    CustomCheckBox {
        id: hiddencheck
        fsize: 9
        text: qsTr("Show hidden files/folders")
        onCheckedButtonChanged:
            updateHidden()
    }

    function getHiddenFolders() {
        return hiddencheck.checkedButton
    }

}
