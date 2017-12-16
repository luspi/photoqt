import QtQuick 2.6
import QtQuick.Controls.Styles 1.3
import QtQuick.Controls 1.3

import "../elements"

Item {

    id: top

//    visible: (!slideshowRunning && !settings.hidex) || (slideshowRunning && !settings.slideShowHideQuickinfo)
    visible: !settings.hidex

    // Position it
    anchors.right: parent.right
    anchors.top: parent.top

    // Width depends on type of 'x'
    width: (settings.fancyX ? 3 : 1.5)*settings.closeXsize
    height: (settings.fancyX ? 3 : 1.5)*settings.closeXsize

    // Normal 'x'
    Text {

        id: txt_x

        visible: !settings.fancyX
        anchors.fill: parent

        horizontalAlignment: Qt.AlignRight
        verticalAlignment: Qt.AlignTop

        font.pointSize: settings.closeXsize*1.5
        font.bold: true
        color: colour.quickinfo_text
        text: "x"

    }

    // Fancy 'x'
    Image {

        id: img_x

        visible: settings.fancyX
        anchors.right: parent.right
        anchors.top: parent.top

        source: "qrc:/img/closingx.png"
        sourceSize: Qt.size(3*settings.closeXsize,3*settings.closeXsize)

    }

    // Click on either one of them
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.RightButton)
                contextmenuClosingX.popup()
            else {
//                if(settings.trayicon)
//                    hideToSystemTray()
//                else
                    mainwindow.quitPhotoQt()
            }
        }
    }

    // The actual context menu
    ContextMenu {

        id: contextmenuClosingX

        MenuItem {
            text: qsTr("Hide 'x'")
            onTriggered: {
                settings.hidex = true;
                top.visible = false;
            }
        }
    }

}
