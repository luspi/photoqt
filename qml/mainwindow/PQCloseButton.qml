import QtQuick 2.9
import "../elements"

Item {

    x: parent.width-width
    y: 0

    width: 3*settings.quickInfoCloseXSize
    height: 3*settings.quickInfoCloseXSize

    visible: !settings.quickInfoHideX

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
