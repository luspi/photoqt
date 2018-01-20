import QtQuick 2.5
import QtQuick.Controls.Styles 1.4

import "../../elements"

Item {

    id: thumb
    anchors.right: viewmode.left
    anchors.rightMargin: 10
    y: 10
    height: parent.height-20
    width: but.width

    CustomButton {

        id: but
        x: 0
        width: height
        height: parent.height
        checkable: true
        checked: settings.openThumbnails

        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: thumb.height
                implicitHeight: thumb.height
                anchors.fill: parent
                radius: 5
                color: control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.checked ? 1: 0.2
                    x: 3
                    y: 3
                    width: parent.width-6
                    height: parent.height-6
                    source: Qt.resolvedUrl("qrc:/img/openfile/thumbnail.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            //: The thumbnails in the element for opening files
            text: em.pty+qsTr("En-/Disable image thumbnails")
            onClicked:
                settings.openThumbnails = !settings.openThumbnails
        }

    }

}
