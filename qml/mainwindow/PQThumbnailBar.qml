import QtQuick 2.9
import QtQuick.Controls 2.2
import "../elements"

Item {

    x: 0
    y: (settings.thumbnailKeepVisible ||
        (variables.mousePos.y > toplevel.height-settings.hotEdgeWidth*5 && !visible) ||
        (variables.mousePos.y > toplevel.height-height && visible)) ? (toplevel.height-height) : toplevel.height
    Behavior on y { NumberAnimation { duration: 200 } }

    visible: y < toplevel.height

    width: toplevel.width

    height: settings.thumbnailSize+settings.thumbnailLiftUp+scroll.height

    ListView {

        id: view

        anchors.fill: parent

        spacing: settings.thumbnailSpacingBetween

        orientation: ListView.Horizontal

        model: variables.allImageFilesInOrder.length

        ScrollBar.horizontal: PQScrollBar { id: scroll }

        property int mouseOverItem: -1

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 200
        preferredHighlightBegin: currentItem==null ? 0 : (settings.thumbnailCenterActive ? (view.width-currentItem.width)/2 : settings.thumbnailSize/2)
        preferredHighlightEnd: currentItem==null ? width : (settings.thumbnailCenterActive ? (view.width-currentItem.width)/2+currentItem.width : (width-settings.thumbnailSize/2))
        highlightRangeMode: ListView.ApplyRange

        Behavior on contentItem.x { NumberAnimation { duration: 200 } }

        delegate: Rectangle {

            x: 0
            y: (view.currentIndex==index||view.mouseOverItem==index) ? 0 : settings.thumbnailLiftUp
            Behavior on y { NumberAnimation { duration: 100 } }

            width: settings.thumbnailSize
            height: settings.thumbnailSize

            color: "#88000000"

            Image {
                anchors.fill: parent
                fillMode: Image.Image.PreserveAspectFit
                source: "image://thumb/" + variables.allImageFilesInOrder[index]
            }

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                tooltip: handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[index])
                onEntered:
                    view.mouseOverItem = index
                onClicked:
                    variables.indexOfCurrentImage = index
                onExited:
                    view.mouseOverItem = -1
            }

        }

    }

    Connections {
        target: variables
        onIndexOfCurrentImageChanged:
            view.currentIndex = variables.indexOfCurrentImage
    }

}
