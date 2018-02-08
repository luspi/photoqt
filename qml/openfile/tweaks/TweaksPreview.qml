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
            //: The hover preview shows the image behind the files in the element for opening files
            text: em.pty+qsTr("En-/Disable hover preview")
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
            //: The preview shows the image behind the files in the element for opening files, use high quality preview
            text: em.pty+qsTr("Use HIGH QUALITY preview")
            onClicked:
                settings.openPreviewHighQuality = !settings.openPreviewHighQuality
        }

    }

}
