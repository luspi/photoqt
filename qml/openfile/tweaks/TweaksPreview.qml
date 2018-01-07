import QtQuick 2.6
import QtQuick.Controls.Styles 1.3

import "../../elements"

Item {

    id: prev
    anchors.right: thumb.left
    anchors.rightMargin: 10
    y: 10
    height: parent.height-20
    width: but1.width+but2.width

    CustomButton {

        id: but1
        x: 0
        width: height
        height: parent.height
        checkable: true
        checked: settings.openPreview

        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: prev.height
                implicitHeight: prev.height
                anchors.fill: parent
                radius: 5
                color: control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.checked ? 1: 0.2
                    x: 3
                    y: 3
                    width: parent.width-6
                    height: parent.height-6
                    source: Qt.resolvedUrl("qrc:/img/openfile/hoverpreview.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            text: qsTr("En-/Disable hover preview")
            onClicked:
                settings.openPreview = !settings.openPreview
        }

    }

    CustomButton {

        id: but2
        x: but1.width
        width: height
        height: parent.height
        checkable: true
        checked: settings.openPreviewHighQuality
        enabled: settings.openPreview

        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: prev.height
                implicitHeight: prev.height
                anchors.fill: parent
                radius: 5
                color: control.enabled&&control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.enabled&&control.checked ? 1: 0.2
                    x: 3
                    y: 3
                    width: parent.width-6
                    height: parent.height-6
                    source: Qt.resolvedUrl("qrc:/img/openfile/hoverpreviewhq.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            text: qsTr("Use HIGH QUALITY preview")
            onClicked:
                settings.openPreviewHighQuality = !settings.openPreviewHighQuality
        }

    }

}
