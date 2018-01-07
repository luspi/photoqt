import QtQuick 2.6

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    height: 50

    color: "#44000000"

    CustomButton {
        x: 0
        text: "list"
        onClickedButton:
            openvariables.filesViewMode = "list"
    }

    CustomButton {
        x: 100
        text: "icon"
        onClickedButton:
            openvariables.filesViewMode = "icon"
    }

}
