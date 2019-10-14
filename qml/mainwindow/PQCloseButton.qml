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

        model: {
            var p = []
            p.push(PQSettings.quickInfoHideCounter ?
                       em.pty+qsTranslate("quickinfo", "Show counter") :
                       em.pty+qsTranslate("quickinfo", "Hide counter"))
            p.push(PQSettings.quickInfoHideFilepath ?
                       em.pty+qsTranslate("quickinfo", "Show file path") :
                       em.pty+qsTranslate("quickinfo", "Hide file path"))
            p.push(PQSettings.quickInfoHideFilename ?
                       em.pty+qsTranslate("quickinfo", "Show file name") :
                       em.pty+qsTranslate("quickinfo", "Hide file name"))
            p.push(PQSettings.quickInfoHideZoomLevel ?
                       em.pty+qsTranslate("quickinfo", "Show zoom level") :
                       em.pty+qsTranslate("quickinfo", "Hide zoom level"))
            p.push(PQSettings.quickInfoHideX ?
                       em.pty+qsTranslate("quickinfo", "Show button for closing PhotoQt") :
                       em.pty+qsTranslate("quickinfo", "Hide button for closing PhotoQt"))
        }

        onTriggered: {
            if(index == 0)
                PQSettings.quickInfoHideCounter = !PQSettings.quickInfoHideCounter
            else if(index == 1)
                PQSettings.quickInfoHideFilepath = !PQSettings.quickInfoHideFilepath
            else if(index == 2)
                PQSettings.quickInfoHideFilename = !PQSettings.quickInfoHideFilename
             else if(index == 3)
                PQSettings.quickInfoHideZoomLevel = !PQSettings.quickInfoHideZoomLevel
            else if(index == 4)
                PQSettings.quickInfoHideX = !PQSettings.quickInfoHideX
        }

    }

}
