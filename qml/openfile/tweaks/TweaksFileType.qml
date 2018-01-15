import QtQuick 2.5

import "../../elements"

Rectangle {
    id: hovprev_but
    anchors.right: remember.left
    y: 10
    width: select.width+20
    height: parent.height-20
    color: "#00000000"

    // Select which group of images to display
    CustomComboBox {
        id: select
        y: (parent.height-height)/2
        width: 200
        backgroundColor: "#313131"
        radius: 5
        showBorder: false
        currentIndex: 0
        onCurrentIndexChanged:
            openvariables.filesFileTypeSelection = currentIndex
        model: [qsTr("All supported images"), "Qt " +
            //: Used as in 'Qt images'
            qsTr("images"), "GraphicsMagick " +
            //: Used as in 'GraphicsMagick images'
            qsTr("images"), "LibRaw " +
            //: Used as in 'LibRaw images'
            qsTr("images")]
    }

}
