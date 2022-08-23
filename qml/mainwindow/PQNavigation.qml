/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import "../elements"

Item {

    id: nav_top

    x: ((parentWidth-width)/2)
    y: (parentHeight-height-thumbnails.height)
    width: row.width
    height: 80

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: !PQSettings.interfaceNavigationFloating ? 0 : (mouseOver ? opacityMouseOver : opacityBackground)
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: (opacity != 0)
    enabled: visible

    property real opacityMouseOver: 1
    property real opacityBackground: 0.5
    property bool mouseOver: false

    property bool atStartup: true

    function disconnectPos() {
        if(!atStartup) return
        nav_top.x = nav_top.x
        nav_top.y = nav_top.y
        atStartup = false
    }

    PQMouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.minimumX: 0
        drag.maximumX: toplevel.width-nav_top.width
        drag.minimumY: 0
        drag.maximumY: toplevel.height-nav_top.height
        property bool dragActive: drag.active
        onDragActiveChanged: disconnectPos()
        hoverEnabled: true
        tooltip: em.pty+qsTranslate("navigate", "Click and drag to move")
        onEntered:
            nav_top.mouseOver = true
        onExited:
            nav_top.mouseOver = false
    }

    Row {

        id: row
        spacing: 5

        y: (parent.height-height)/2

        Image {
            width: 75
            height: width
            source: "/mainwindow/leftarrow.svg"
            sourceSize: Qt.size(width, height)
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
                property bool dragActive: drag.active
                onDragActiveChanged: disconnectPos()
                tooltip: em.pty+qsTranslate("navigate", "Navigate to previous image in folder")
                onClicked:
                    imageitem.loadPrevImage()
                onEntered:
                    nav_top.mouseOver = true
                onExited:
                    nav_top.mouseOver = false
            }
        }

        Image {
            width: 75
            height: width
            source: "/mainwindow/rightarrow.svg"
            sourceSize: Qt.size(width, height)
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
                property bool dragActive: drag.active
                onDragActiveChanged: disconnectPos()
                tooltip: em.pty+qsTranslate("navigate", "Navigate to next image in folder")
                onClicked:
                    imageitem.loadNextImage()
                onEntered:
                    nav_top.mouseOver = true
                onExited:
                    nav_top.mouseOver = false
            }
        }

        Image {
            width: 75
            height: width
            source: "/mainwindow/menu.svg"
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: toplevel.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: toplevel.height-nav_top.height
                property bool dragActive: drag.active
                onDragActiveChanged: disconnectPos()
                tooltip: em.pty+qsTranslate("navigate", "Show main menu")
                onClicked:
                    loader.passOn("mainmenu", "toggle", undefined)
                onEntered:
                    nav_top.mouseOver = true
                onExited:
                    nav_top.mouseOver = false
            }
        }

    }

    Connections {
        target: loader
        onNavigationFloatingPassOn: {
            if(what == "toggle")
                toggle()
        }
    }

}
