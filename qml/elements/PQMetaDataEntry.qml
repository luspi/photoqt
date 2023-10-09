import QtQuick

import PQCFileFolderModel

Column {

    id: entry

    property alias whichtxt: which.text
    property string valtxt: ""

    property bool fadeout: valtxt==""

    property bool enableMouse: false
    property string tooltip: ""

    signal clicked()

    PQText {
        id: which
        font.weight: PQCLook.fontWeightBold
        opacity: fadeout ? 0.4 : 1
        visible: PQCFileFolderModel.countMainView>0
    }

    PQText {
        id: val
        text: "  " + (valtxt=="" ? "--" : valtxt)
        opacity: fadeout ? 0.4 : 1
        visible: PQCFileFolderModel.countMainView>0

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: enableMouse
            text: tooltip
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked:
                entry.clicked()
        }
    }

}

