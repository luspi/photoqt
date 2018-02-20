/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

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
        checked: settings.openDefaultView!=="icons"

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
        checked: settings.openDefaultView==="icons"

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
