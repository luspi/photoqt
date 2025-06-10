/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick

import PQCFileFolderModel

import org.photoqt.qml

Item {

    id: nav_top

    x: ((parentWidth-width)/2)
    y: parentHeight*0.8
    width: row.width
    height: 80

    property int parentWidth: PQCConstants.windowWidth
    property int parentHeight: PQCConstants.windowHeight

    opacity: (!PQCSettingsExtensions.FloatingNavigation || PQCNotify.slideshowRunning) ? 0 : (mouseOver ? opacityMouseOver : opacityBackground) // qmllint disable unqualified
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: (opacity > 0)
    enabled: visible

    property real opacityMouseOver: 1
    property real opacityBackground: 0.5
    property bool mouseOver: false
    property int mouseOverId: 0

    property bool atStartup: true

    function disconnectPos() {
        if(!atStartup) return
        nav_top.x = nav_top.x
        nav_top.y = nav_top.y
        atStartup = false
    }

    Timer {
        id: resetMouseOver
        interval: 100
        property int oldId
        onTriggered: {
            if(oldId == nav_top.mouseOverId)
                nav_top.mouseOver = false
        }
    }

    PQMouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.minimumX: 0
        drag.maximumX: PQCConstants.windowWidth-nav_top.width
        drag.minimumY: 0
        drag.maximumY: PQCConstants.windowHeight-nav_top.height
        property bool dragActive: drag.active
        onDragActiveChanged: nav_top.disconnectPos()
        hoverEnabled: true
        text: qsTranslate("navigate", "Click and drag to move")
        onEntered: {
            resetMouseOver.stop()
            nav_top.mouseOverId = 0
            nav_top.mouseOver = true
        }
        onExited: {
            resetMouseOver.oldId = 0
            resetMouseOver.restart()
        }
    }

    Row {

        id: row
        spacing: 5

        y: (parent.height-height)/2

        Image {
            width: 75
            height: width
            source: "image://svg/:/" + PQCLook.iconShade + "/leftarrow.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            enabled: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: PQCConstants.windowWidth-nav_top.width
                drag.minimumY: 0
                drag.maximumY: PQCConstants.windowHeight-nav_top.height
                property bool dragActive: drag.active
                onDragActiveChanged: nav_top.disconnectPos()
                text: qsTranslate("navigate", "Navigate to previous image in folder")
                onClicked:
                    PQCNotify.executeInternalCommand("__prev") // qmllint disable unqualified
                onEntered: {
                    resetMouseOver.stop()
                    nav_top.mouseOverId = 1
                    nav_top.mouseOver = true
                }
                onExited: {
                    resetMouseOver.oldId = 1
                    resetMouseOver.restart()
                }
            }
        }

        Image {
            width: 75
            height: width
            source: "image://svg/:/" + PQCLook.iconShade + "/rightarrow.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            enabled: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: PQCConstants.windowWidth-nav_top.width
                drag.minimumY: 0
                drag.maximumY: PQCConstants.windowHeight-nav_top.height
                property bool dragActive: drag.active
                onDragActiveChanged: nav_top.disconnectPos()
                text: qsTranslate("navigate", "Navigate to next image in folder")
                onClicked:
                    PQCNotify.executeInternalCommand("__next") // qmllint disable unqualified
                onEntered: {
                    resetMouseOver.stop()
                    nav_top.mouseOverId = 2
                    nav_top.mouseOver = true
                }
                onExited: {
                    resetMouseOver.oldId = 2
                    resetMouseOver.restart()
                }
            }
        }

        Image {
            width: 75
            height: width
            source: "image://svg/:/" + PQCLook.iconShade + "/menu.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top
                drag.minimumX: 0
                drag.maximumX: PQCConstants.windowWidth-nav_top.width
                drag.minimumY: 0
                drag.maximumY: PQCConstants.windowHeight-nav_top.height
                property bool dragActive: drag.active
                onDragActiveChanged: nav_top.disconnectPos()
                text: qsTranslate("navigate", "Show main menu")
                onClicked:
                    PQCNotify.executeInternalCommand("__toggleMainMenu") // qmllint disable unqualified
                onEntered: {
                    resetMouseOver.stop()
                    nav_top.mouseOverId = 3
                    nav_top.mouseOver = true
                }
                onExited: {
                    resetMouseOver.oldId = 3
                    resetMouseOver.restart()
                }
            }
        }

    }

    Connections {
        target: PQCNotify // qmllint disable unqualified

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === "floatingnavigation") {
                PQCSettingsExtensions.FloatingNavigation = !PQCSettingsExtensions.FloatingNavigation
            }
        }
    }

}
