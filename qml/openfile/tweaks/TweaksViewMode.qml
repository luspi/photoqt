import QtQuick 2.5
import QtQuick.Controls.Styles 1.4

import "../../elements"

Item {

    id: iconlist
    anchors.right: parent.right
    anchors.rightMargin: 10
    y: 10
    height: parent.height-20
    width: showaslist.width+showasicon.width

    CustomButton {

        id: showaslist
        x: 0
        width: height
        height: parent.height
        checkable: true
        checked: settings.openDefaultView!="icons"

        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: iconlist.height
                implicitHeight: iconlist.height
                anchors.fill: parent
                radius: 5
                color: control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.checked ? 1: 0.2
                    width: parent.width
                    height: parent.height
                    source: Qt.resolvedUrl("qrc:/img/openfile/listview.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            text: em.pty+qsTr("Show files as list")
            onClicked:
                settings.openDefaultView = "list"
        }

    }

    CustomButton {

        id: showasicon
        x: showaslist.width
        width: height
        height: parent.height
        checkable: true
        checked: settings.openDefaultView=="icons"

        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: iconlist.height
                implicitHeight: iconlist.height
                anchors.fill: parent
                radius: 5
                color: control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.checked ? 1: 0.2
                    width: parent.width
                    height: parent.height
                    source: Qt.resolvedUrl("qrc:/img/openfile/iconview.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            text: em.pty+qsTr("Show files as grid")
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            onClicked:
                settings.openDefaultView = "icons"
        }

    }

}
