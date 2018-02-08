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
