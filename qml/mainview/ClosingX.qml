import QtQuick 2.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4
import PContextMenu 1.0

import "../elements"

Item {

    id: top

    visible: (!variables.slideshowRunning && !settings.quickInfoHideX) || (variables.slideshowRunning && !settings.slideShowHideQuickInfo)

    // Position it
    anchors.right: parent.right
    anchors.top: parent.top

    // Width depends on type of 'x'
    width: 3*settingsQuickInfoCloseXSize
    height: 3*settingsQuickInfoCloseXSize

    // make sure settings values are valid
    property int settingsQuickInfoCloseXSize: Math.max(5, Math.min(25, settings.quickInfoCloseXSize))

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
    PContextMenu {

        id: context

        Component.onCompleted: {

            //: The counter shows the position of the currently loaded image in the folder
            addItem(em.pty+qsTr("Show counter"))
            setCheckable(0, true)
            setChecked(0, !settings.quickInfoHideCounter)

            addItem(em.pty+qsTr("Show filepath"))
            setCheckable(1, true)
            setChecked(1, !settings.quickInfoHideFilepath)

            addItem(em.pty+qsTr("Show filename"))
            setCheckable(2, true)
            setChecked(2, !settings.quickInfoHideFilename)

            //: The clsoing 'x' is the button in the top right corner of the screen for closing PhotoQt
            addItem(em.pty+qsTr("Show closing 'x'"))
            setCheckable(3, true)
            setChecked(3, !settings.quickInfoHideX)

        }

        onCheckedChanged: {
            if(index == 0)
                settings.quickInfoHideCounter = !checked
            else if(index == 1)
                settings.quickInfoHideFilepath = !checked
            else if(index == 2)
                settings.quickInfoHideFilename = !checked
            else if(index == 3)
                settings.quickInfoHideX = !checked
        }

    }

}
