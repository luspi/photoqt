import QtQuick 2.9
import QtQuick.Window 2.2
import "../elements"

Item {

    x: variables.metaDataWidthWhenKeptOpen + 10
    Behavior on x { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    y: 10

    width: cont.width
    height: cont.height

    visible: !(variables.slideShowActive&&PQSettings.slideShowHideQuickInfo) &&
             (variables.indexOfCurrentImage>-1 || variables.filterSet) &&
             (variables.allImageFilesInOrder.length>0 || variables.filterSet) &&
             !variables.faceTaggingActive

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

            x: PQSettings.quickInfoHideCounter ? 0 : 10
            y: 5
            color: "white"

            visible: !PQSettings.quickInfoHideCounter && (variables.indexOfCurrentImage > -1)

            text: PQSettings.quickInfoHideCounter ? "" : ((variables.indexOfCurrentImage+1) + "/" + variables.allImageFilesInOrder.length)

        }

        // filename
        Text {

            id: filename

            x: text=="" ? 0 : counter.x+counter.width+10

            visible: text!="" && (variables.indexOfCurrentImage > -1)

            y: 5
            color: "white"
            text: ((PQSettings.quickInfoHideFilename&&PQSettings.quickInfoHideFilepath) || variables.indexOfCurrentImage==-1) ?
                      "" :
                      (PQSettings.quickInfoHideFilepath ?
                           handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]) :
                           (PQSettings.quickInfoHideFilename ?
                                handlingGeneral.getFilePathFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]) :
                                variables.allImageFilesInOrder[variables.indexOfCurrentImage]))
        }

        Rectangle {

            id: seperator1

            color: "#cccccc"

            x: filename.x+filename.width+(visible ? 10 : 0)
            y: 5

            visible: (filename.visible||counter.visible) && (pageInfo.visible) && (variables.indexOfCurrentImage > -1)

            width: 1
            height: filename.height

        }

        Text {

            id: pageInfo

            anchors.left: seperator1.right
            anchors.leftMargin: visible ? 10 : 0
            y: 5

            text: (variables.indexOfCurrentImage>-1 && variables.indexOfCurrentImage < variables.allImageFilesInOrder.length && variables.allImageFilesInOrder[variables.indexOfCurrentImage].indexOf("::PQT::")>-1) ?
                      ("Page " + (variables.allImageFilesInOrder[variables.indexOfCurrentImage].split("::PQT::")[0]*1+1) + " of " + variables.allImageFilesInOrder.length) :
                      ""
            visible: text != "" && (variables.indexOfCurrentImage > -1)

            color: "white"

        }

        Rectangle {

            id: seperator2

            color: "#cccccc"

            x: pageInfo.x+pageInfo.width+10
            y: 5

            visible: (filename.visible||counter.visible||pageInfo.visible) && zoomlevel.visible && (variables.indexOfCurrentImage > -1)

            width: 1
            height: filename.height

        }

        // zoom level
        Text {
            id: zoomlevel
            x: PQSettings.quickInfoHideZoomLevel ? 0 : seperator2.x+seperator2.width+10
            y: 5
            color: "white"
            visible: !PQSettings.quickInfoHideZoomLevel && (variables.indexOfCurrentImage > -1)
            text: PQSettings.quickInfoHideZoomLevel ? "" : (Math.round(variables.currentZoomLevel)+"%")
        }

        // filter string
        Item {
            id: filterremove_cont
            x: counter.x
            y: (variables.filterSet&&variables.indexOfCurrentImage==-1) ? 5 : (counter.y+counter.height + (visible ? 10 : 0))
            visible: variables.filterSet
            width: visible ? filtertext.width : 0
            height: visible ? filtertext.height : 0
            Row {
                height: childrenRect.height
                spacing: 5
                Text {
                    id: filterremove
                    color: "#999999"
                    text: "x"
                }
                Text {
                    id: filtertext
                    color: "white"
                    text: "Filter: " + variables.filterStringConcat
                }
            }

        }

        PQMenu {

            id: rightclickmenu

            PQMenuItem {
                text: PQSettings.quickInfoHideCounter ? "Show counter" : "Hide counter"
                onTriggered: {
                    var old = PQSettings.quickInfoHideCounter
                    PQSettings.quickInfoHideCounter = !old
                }
            }

            PQMenuItem {
                text: PQSettings.quickInfoHideFilepath ? "Show file path" : "Hide file path"
                onTriggered: {
                    var old = PQSettings.quickInfoHideFilepath
                    PQSettings.quickInfoHideFilepath = !old
                }
            }

            PQMenuItem {
                text: PQSettings.quickInfoHideFilename ? "Show file name" : "Hide file name"
                onTriggered: {
                    var old = PQSettings.quickInfoHideFilename
                    PQSettings.quickInfoHideFilename = !old
                }
            }

            PQMenuItem {
                text: PQSettings.quickInfoHideZoomLevel ? "Show zoom level" : "Hide zoom level"
                onTriggered: {
                    var old = PQSettings.quickInfoHideZoomLevel
                    PQSettings.quickInfoHideZoomLevel = !old
                }
            }

            PQMenuItem {
                text: PQSettings.quickInfoHideX ? "Show button for closing PhotoQt" : "Hide button for closing PhotoQt"
                onTriggered: {
                    var old = PQSettings.quickInfoHideX
                    PQSettings.quickInfoHideX = !old
                }
            }

        }

    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        drag.target: PQSettings.quickInfoManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : parent
        tooltip: em.pty+qsTranslate("quickinfo", "Some info about the current image and directory")
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.RightButton)
                rightclickmenu.popup()
        }
        property point clickPos: Qt.point(0,0)
        property bool isPressed: false
        onPressed: {
            if(toplevel.visibility != Window.Maximized) {
                isPressed = true
                clickPos = Qt.point(mouse.x, mouse.y)
            }
        }
        onPositionChanged: {
            if(PQSettings.quickInfoManageWindow && isPressed) {
                if(toplevel.visibility == Window.Maximized)
                    toplevel.visibility = Window.Windowed
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                toplevel.x += delta.x;
                toplevel.y += delta.y;
            }
        }
        onReleased: {
            isPressed = false
        }
        onDoubleClicked: {
            if(toplevel.visibility == Window.Maximized)
                toplevel.visibility = Window.Windowed
            else if(toplevel.visibility == Window.Windowed)
                toplevel.visibility = Window.Maximized
            else if(toplevel.visibility == Window.FullScreen)
                toplevel.visibility = Window.Maximized
        }
    }



    PQMouseArea {
        x: filterremove_cont.x
        y: filterremove_cont.y
        width: filterremove.width+5
        height: filterremove_cont.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: "Click to remove filter"
        onPressed:
            loader.passOn("filter", "removeFilter", undefined)
    }

}
