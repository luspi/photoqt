import QtQuick 2.9
import "../elements"

Item {

    x: 10
    y: 10

    width: cont.width
    height: cont.height

    visible: variables.indexOfCurrentImage>-1&&variables.allImageFilesInOrder.length>0

    Rectangle {

        id: cont
        width: childrenRect.width+20
        height: childrenRect.height+10

        clip: true

        Behavior on width { NumberAnimation { duration: 200 } }

        color: "#88000000"
        radius: 5

        Text {

            id: counter

            x: settings.quickInfoHideCounter ? 0 : 10
            y: 5
            color: "white"

            visible: !settings.quickInfoHideCounter

            text: settings.quickInfoHideCounter ? "" : ((variables.indexOfCurrentImage+1) + "/" + variables.allImageFilesInOrder.length)

        }

        // filename
        Text {

            id: filename

            x: text=="" ? 0 : counter.x+counter.width+10

            visible: text!=""

            y: 5
            color: "white"
            text: ((settings.quickInfoHideFilename&&settings.quickInfoHideFilepath) || variables.indexOfCurrentImage==-1) ?
                      "" :
                      (settings.quickInfoHideFilepath ?
                           handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]) :
                           (settings.quickInfoHideFilename ?
                                handlingGeneral.getFilePathFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]) :
                                variables.allImageFilesInOrder[variables.indexOfCurrentImage]))
        }

        Rectangle {

            id: seperator

            color: "#cccccc"

            x: filename.x+filename.width+10
            y: 5

            visible: (filename.visible||counter.visible) && zoomlevel.visible

            width: 1
            height: filename.height

        }

        // zoom level
        Text {
            id: zoomlevel
            x: settings.quickInfoHideZoomLevel ? 0 : seperator.x+seperator.width+10
            y: 5
            color: "white"
            visible: !settings.quickInfoHideZoomLevel
            text: settings.quickInfoHideZoomLevel ? "" : (Math.round(variables.currentZoomLevel)+"%")
        }

        PQMenu {

            id: rightclickmenu

            PQMenuItem {
                text: settings.quickInfoHideCounter ? "Show counter" : "Hide counter"
                onTriggered: {
                    var old = settings.quickInfoHideCounter
                    settings.quickInfoHideCounter = !old
                }
            }

            PQMenuItem {
                text: settings.quickInfoHideFilepath ? "Show file path" : "Hide file path"
                onTriggered: {
                    var old = settings.quickInfoHideFilepath
                    settings.quickInfoHideFilepath = !old
                }
            }

            PQMenuItem {
                text: settings.quickInfoHideFilename ? "Show file name" : "Hide file name"
                onTriggered: {
                    var old = settings.quickInfoHideFilename
                    settings.quickInfoHideFilename = !old
                }
            }

            PQMenuItem {
                text: settings.quickInfoHideZoomLevel ? "Show zoom level" : "Hide zoom level"
                onTriggered: {
                    var old = settings.quickInfoHideZoomLevel
                    settings.quickInfoHideZoomLevel = !old
                }
            }

            PQMenuItem {
                text: settings.quickInfoHideX ? "Show button for closing PhotoQt" : "Hide button for closing PhotoQt"
                onTriggered: {
                    var old = settings.quickInfoHideX
                    settings.quickInfoHideX = !old
                }
            }

        }

    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        drag.target: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.RightButton)
                rightclickmenu.popup()
        }
    }

}
