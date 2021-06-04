/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9
import "../elements"

Rectangle {

    id: nav_top

    x: variables.metaDataWidthWhenKeptOpen + 100
    y: PQSettings.thumbnailPosition=="Bottom" ? 100 : parent.height-height-100

    Behavior on x { NumberAnimation { duration: 200 } }

    width: row.width
    height: row.height

    opacity: PQSettings.quickNavigation ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    color: "#bb000000"
    radius: 10

    PQMouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.minimumX: 0
        drag.maximumX: toplevel.width-nav_top.width
        drag.minimumY: 0
        drag.maximumY: toplevel.height-nav_top.height
        hoverEnabled: true
        tooltip: em.pty+qsTranslate("navigate", "Click and drag to move")
    }

    Row {

        id: row
        spacing: 10

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 50
            height: width
            source: "/mainwindow/leftarrow.png"
            enabled: filefoldermodel.countMainView>0
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: toplevel.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: toplevel.height-nav_top.height
                tooltip: em.pty+qsTranslate("navigate", "Navigate to previous image in folder")
                onClicked:
                    imageitem.loadPrevImage()
            }
        }

        Image {
            width: 50
            height: width
            source: "/mainwindow/rightarrow.png"
            enabled: filefoldermodel.countMainView>0
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: toplevel.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: toplevel.height-nav_top.height
                tooltip: em.pty+qsTranslate("navigate", "Navigate to next image in folder")
                onClicked:
                    imageitem.loadNextImage()
            }
        }

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 50
            height: width
            source: "/mainwindow/menu.png"
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: toplevel.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: toplevel.height-nav_top.height
                tooltip: em.pty+qsTranslate("navigate", "Show main menu")
                onClicked:
                    mainmenu.toggle()
            }
        }

        Item {
            width: 1
            height: 1
        }

    }

    // this makes sure that a change in the window geometry does not leeds to the element being outside the visible area
    Connections {
        target: toplevel
        onWidthChanged: {
            if(nav_top.x < 0)
                nav_top.x = 0
            else if(nav_top.x > toplevel.width-nav_top.width)
                nav_top.x = toplevel.width-nav_top.width
        }
        onHeightChanged: {
            if(nav_top.y < 0)
                nav_top.y = 0
            else if(nav_top.y > toplevel.height-nav_top.height)
                nav_top.y = toplevel.height-nav_top.height
        }
    }

}
