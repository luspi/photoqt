import QtQuick 2.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4

import "../elements"

Item {

    id: top

    visible: (!variables.slideshowRunning && !settings.quickInfoHideX) || (variables.slideshowRunning && !settings.slideShowHideQuickInfo)

    // Position it
    anchors.right: parent.right
    anchors.top: parent.top

    // Width depends on type of 'x'
    width: 3*settings.quickInfoCloseXSize
    height: 3*settings.quickInfoCloseXSize

    // Plain 'x'
    Image {
        visible: !settings.quickInfoFullX
        anchors.fill: parent
        source: "qrc:/img/closingxplain.png"
    }

    // Full 'x'
    Image {
        visible: settings.quickInfoFullX
        anchors.fill: parent
        source: "qrc:/img/closingx.png"
    }

    // Click on either one of them
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.RightButton)
                context.popup()
            else
                mainwindow.closePhotoQt()
        }
    }

    // The actual context menu
    ContextMenu {

        id: context

        MenuItem {
            //: The counter shows the position of the currently loaded image in the folder
            text: em.pty+qsTr("Show counter")
            checkable: true
            checked: !settings.quickInfoHideCounter
            onTriggered:
                settings.quickInfoHideCounter = !checked
        }

        MenuItem {
            text: em.pty+qsTr("Show filepath")
            checkable: true
            checked: !settings.quickInfoHideFilepath
            onTriggered:
                settings.quickInfoHideFilepath = !checked
        }

        MenuItem {
            text: em.pty+qsTr("Show filename")
            checkable: true
            checked: !settings.quickInfoHideFilename
            onTriggered:
                settings.quickInfoHideFilename = !checked
        }

        MenuItem {
            //: The clsoing 'x' is the button in the top right corner of the screen for closing PhotoQt
            text: em.pty+qsTr("Show closing 'x'")
            checkable: true
            checked: !settings.quickInfoHideX
            onTriggered:
                settings.quickInfoHideX = !checked
        }

    }

}
