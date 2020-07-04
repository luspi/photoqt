import QtQuick 2.9
import QtQuick.Controls 2.2
import "../elements"

Item {

    property int xOffset: (view.contentWidth < (toplevel.width-variables.metaDataWidthWhenKeptOpen) ? ((toplevel.width-variables.metaDataWidthWhenKeptOpen)-view.contentWidth)/2 : 0)
    x: variables.metaDataWidthWhenKeptOpen + xOffset
    Behavior on x { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    y:
        PQSettings.thumbnailPosition=="Top" ?

           ((PQSettings.thumbnailKeepVisible ||
           (variables.mousePos.y < PQSettings.hotEdgeWidth*5 && !visible) ||
           (variables.mousePos.y < height && visible) ||
           (PQSettings.thumbnailKeepVisibleWhenNotZoomedIn && variables.currentPaintedZoomLevel<=1)) ? 0 : -height) :

           ((PQSettings.thumbnailKeepVisible ||
           (variables.mousePos.y > toplevel.height-PQSettings.hotEdgeWidth*5 && !visible) ||
           (variables.mousePos.y > toplevel.height-height && visible) ||
           (PQSettings.thumbnailKeepVisibleWhenNotZoomedIn && variables.currentPaintedZoomLevel<=1)) ? (toplevel.height-height-(variables.videoControlsVisible ? 50 : 0)) : toplevel.height)

    Behavior on y { NumberAnimation { duration: 200 } }

    visible: !variables.slideShowActive && !variables.faceTaggingActive && (PQSettings.thumbnailPosition=="Top" ? (y > -height) : (y < toplevel.height))

    width: toplevel.width-(variables.metaDataWidthWhenKeptOpen + xOffset*2)

    clip: true

    height: PQSettings.thumbnailSize+PQSettings.thumbnailLiftUp+scroll.height

    ListView {

        id: view

        anchors.fill: parent

        spacing: PQSettings.thumbnailSpacingBetween

        orientation: ListView.Horizontal

        model: PQSettings.thumbnailDisable ? 0 : variables.allImageFilesInOrder.length

        ScrollBar.horizontal: PQScrollBar { id: scroll }

        property int mouseOverItem: -1

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 200
        preferredHighlightBegin: currentItem==null ? 0 : (PQSettings.thumbnailCenterActive ? (view.width-currentItem.width)/2 : PQSettings.thumbnailSize/2)
        preferredHighlightEnd: currentItem==null ? width : (PQSettings.thumbnailCenterActive ? (view.width-currentItem.width)/2+currentItem.width : (width-PQSettings.thumbnailSize/2))
        highlightRangeMode: ListView.ApplyRange

        Behavior on contentItem.x { NumberAnimation { duration: 200 } }

        delegate: Rectangle {

            x: 0
            y: (view.currentIndex==index||view.mouseOverItem==index) ? 0 : PQSettings.thumbnailLiftUp
            Behavior on y { NumberAnimation { duration: 100 } }

            width: PQSettings.thumbnailSize
            height: PQSettings.thumbnailSize

            color: "#88000000"

            Text {

                anchors.fill: parent
                anchors.margins: 5

                visible: PQSettings.thumbnailFilenameInstead
                color: "white"

                text: handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[index])
                font.pointSize: PQSettings.thumbnailFilenameInsteadFontSize
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            }

            Image {
                anchors.fill: parent
                fillMode: Image.Image.PreserveAspectFit
                source: (PQSettings.thumbnailFilenameInstead||PQSettings.thumbnailDisable) ? "" : "image://thumb/" + variables.allImageFilesInOrder[index]

                visible: !PQSettings.thumbnailFilenameInstead

                Rectangle {
                    visible: PQSettings.thumbnailWriteFilename
                    color: "#88000000"
                    width: parent.width
                    height: parent.height/3
                    x: 0
                    y: 2*parent.height/3
                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.rightMargin: 2
                        color: "white"
                        elide: Text.ElideMiddle
                        font.pointSize: PQSettings.thumbnailFontSize
                        font.bold: true
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[index], true)
                    }
                }
            }

            PQMouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                tooltip: "<b><span style=\"font-size: x-large\">" + handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[index], true) + "</span></b><br><br>" +
                         "File size: " + handlingFileDialog.convertBytesToHumanReadable(1024*handlingGeneral.getFileSize(variables.allImageFilesInOrder[index]).split(" ")[0]) + "<br>" +
                         "File type: " + handlingFileDialog.getFileType(variables.allImageFilesInOrder[index])
                onEntered:
                    view.mouseOverItem = index
                onClicked: {
                    variables.indexOfCurrentImage = index
                    variables.newFileLoaded()
                }
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

    function reloadThumbnails() {
        view.model = 0
        view.model = Qt.binding(function() { return (PQSettings.thumbnailDisable ? 0 : variables.allImageFilesInOrder.length) })
        view.currentIndex = variables.indexOfCurrentImage
    }

}
