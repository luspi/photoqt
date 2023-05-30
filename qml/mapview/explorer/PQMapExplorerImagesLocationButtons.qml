/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

import QtQuick 2.9
import QtQuick.Window 2.2
import "../../elements"

Rectangle {

    id: toprow

    color: "#333333"

    PQTextL {

        x: 10
        y: (parent.height-height)/2
        width: (butrow.x-10)
        elide: Text.ElideMiddle

        text: "Current folder:" + " <b>" + handlingFileDir.getDirectoryBaseName(folderLoaded[0]) + "</b>"

    }

    Row {

        id: butrow

        x: (parent.width-width-10)
        y: (parent.height-height)/2

        PQButton {

            id: cancelbut
            y: (parent.height-height)/2

            backgroundColor: "#444444"
            backgroundColorHover: "#5a5a5a"
            backgroundColorActive: "#555555"

            text: genericStringCancel

            onClicked:
                mapexplorer_top.hideExplorer()

        }

        Item {
            width: 10
            height: 1
        }

        Item {
            id: fullscreenwindow
            height: parent.height
            width: height

            Image {

                anchors.fill: parent

                sourceSize: Qt.size(width, height)

                mipmap: true

                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                source: PQSettings.interfaceWindowMode ? "/mainwindow/fullscreen_on.svg" : "/mainwindow/fullscreen_off.svg"

            }

            PQMouseArea {
                anchors.fill: parent
                tooltip: PQSettings.interfaceWindowMode ? em.pty+qsTranslate("filedialog", "Enter fullscreen")
                                               : em.pty+qsTranslate("filedialog", "Exit fullscreen")
                tooltipFollowsMouse: false
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
            }

        }

        Item {
            id: closefileview
            height: parent.height
            width: height

            visible: (toplevel.visibility==Window.FullScreen) || (!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons

            Image {

                anchors.fill: parent

                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                source: "/other/close.svg"
                sourceSize: Qt.size(width, height)

            }

            PQMouseArea {
                anchors.fill: parent
                tooltip: em.pty+qsTranslate("filedialog", "Close")
                tooltipFollowsMouse: false
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: toplevel.close()
            }

        }

    }

    Rectangle {

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: "#aaaaaa"
    }

}
