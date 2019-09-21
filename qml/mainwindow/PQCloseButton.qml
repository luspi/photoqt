import QtQuick 2.9
import "../elements"

Item {

    x: parent.width-width
    y: 0

    width: 3*PQSettings.quickInfoCloseXSize
    height: 3*PQSettings.quickInfoCloseXSize

    visible: !(variables.slideShowActive&&PQSettings.slideShowHideQuickInfo) && !PQSettings.quickInfoHideX

    Image {
        anchors.fill: parent
        anchors.margins: 5
        source: "/mainwindow/close.png"
    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: em.pty+qsTranslate("quickinfo", "Click here to close PhotoQt")
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.LeftButton)
                toplevel.close()
            else
                rightclickmenu.popup()
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
