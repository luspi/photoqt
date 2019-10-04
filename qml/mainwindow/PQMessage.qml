import QtQuick 2.9
import "../elements"

Item {

    x: variables.metaDataWidthWhenKeptOpen + 10
    Behavior on x { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    y: 10

    width: cont.width
    height: cont.height

    visible: (variables.allImageFilesInOrder.length==0&&!variables.filterSet) ||
             variables.faceTaggingActive

    Rectangle {

        id: cont
        width: childrenRect.width+20
        height: childrenRect.height+10

        clip: true

        Behavior on width { NumberAnimation { duration: 200 } }

        color: "#88000000"
        radius: 5

        Text {
            id: thex
            x: 10
            y: 5
            color: "white"
            text: "x"
            visible: variables.faceTaggingActive
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: "Click to exit face tagging mode"
                onClicked:
                    loader.passOn("facetagger", "stop", undefined)
            }
        }

        Text {

            x: variables.faceTaggingActive ? (thex.x+thex.width+5) : 10
            y: 5
            color: "white"

            text: variables.faceTaggingActive ? "Click to tag faces, changes are saved automatically" : "Open a file to start"

        }

    }

}
