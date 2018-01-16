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
    width: (settings.quickInfoFullX ? 3 : 1.5)*settings.quickInfoCloseXSize
    height: (settings.quickInfoFullX ? 3 : 1.5)*settings.quickInfoCloseXSize

    // Normal 'x'
    Text {

        id: txt_x

        visible: !settings.quickInfoFullX
        anchors.fill: parent

        horizontalAlignment: Qt.AlignRight
        verticalAlignment: Qt.AlignTop

        font.pointSize: settings.quickInfoCloseXSize*1.5
        font.bold: true
        color: colour.quickinfo_text
        text: "x"

    }

    // Fancy 'x'
    Image {

        id: img_x

        visible: settings.quickInfoFullX
        anchors.right: parent.right
        anchors.top: parent.top

        source: "qrc:/img/closingx.png"
        sourceSize: Qt.size(3*settings.quickInfoCloseXSize,3*settings.quickInfoCloseXSize)

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
            text: qsTr("Show counter")
            checkable: true
            checked: !settings.quickInfoHideCounter
            onTriggered:
                settings.quickInfoHideCounter = !checked
        }

        MenuItem {
            text: qsTr("Show filepath")
            checkable: true
            checked: !settings.quickInfoHideFilepath
            onTriggered:
                settings.quickInfoHideFilepath = !checked
        }

        MenuItem {
            text: qsTr("Show filename")
            checkable: true
            checked: !settings.quickInfoHideFilename
            onTriggered:
                settings.quickInfoHideFilename = !checked
        }

        MenuItem {
            //: The clsoing 'x' is the button in the top right corner of the screen for closing PhotoQt
            text: qsTr("Show closing 'x'")
            checkable: true
            checked: !settings.quickInfoHideX
            onTriggered:
                settings.quickInfoHideX = !checked
        }

    }

}
