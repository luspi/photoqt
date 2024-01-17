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

import QtQuick
import QtQuick.Window

import PQCFileFolderModel
import PQCNotify
import PQCScriptsConfig

import "../elements"

Item {

    id: windowbuttons_top

    x: toplevel.width-width-distanceFromEdge

    Behavior on y { NumberAnimation { duration: (PQCSettings.interfaceWindowButtonsAutoHide || movedByMouse) ? 200 : 0 } }
    Behavior on x { NumberAnimation { duration: (movedByMouse) ? 200 : 0 } }

    property bool movedByMouse: false

    property int distanceFromEdge: 5

    width: row.width
    height: row.height

    visible: (!(PQCNotify.slideshowRunning && PQCSettings.slideshowHideWindowButtons) && PQCSettings.interfaceWindowButtonsShow && opacity>0) && !PQCNotify.faceTagging && !PQCNotify.insidePhotoSphere

    property bool visibleAlways: false

    state: (!PQCSettings.interfaceWindowButtonsAutoHide && PQCSettings.interfaceWindowButtonsShow) ?
               "visible" :
               "hidden"

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: windowbuttons_top
                y: distanceFromEdge
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: windowbuttons_top
                y: -height
            }
        }
    ]

    // clicks between buttons has no effect anywhere
    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Row {

        id: row

        spacing: 0

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/white/leftarrow.svg"
            enabled: PQCFileFolderModel.countMainView>0
            opacity: visibleAlways ? 0 : (enabled ? (left_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: PQCSettings.interfaceNavigationTopRight && opacity > 0 && !PQCNotify.slideshowRunning
            mipmap: true
            PQMouseArea {
                id: left_mouse
                anchors.fill: parent
                enabled: parent.enabled&&parent.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                text: qsTranslate("navigate", "Navigate to previous image in folder")
                onClicked:
                    PQCNotify.executeInternalCommand("__prev")
            }
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/white/rightarrow.svg"
            enabled: PQCFileFolderModel.countMainView>0
            opacity: visibleAlways||PQCNotify.slideshowRunning ? 0 : (enabled ? (right_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: PQCSettings.interfaceNavigationTopRight && opacity > 0
            mipmap: true
            PQMouseArea {
                id: right_mouse
                anchors.fill: parent
                enabled: parent.enabled&&parent.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                text: qsTranslate("navigate", "Navigate to next image in folder")
                onClicked:
                    PQCNotify.executeInternalCommand("__next")
            }
        }

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/white/menu.svg"

            opacity: (visibleAlways||PQCNotify.slideshowRunning) ? 0 : (mainmenu_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            visible: PQCSettings.interfaceNavigationTopRight && opacity > 0

            PQMouseArea {
                id: mainmenu_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to show main menu")
                onClicked:
                    PQCNotify.executeInternalCommand("__toggleMainMenu")
            }
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/white/keepforeground.svg"

            opacity: !visibleAlways ? 0 : (fore_mouse.containsMouse ? 0.8 : 0.5)*(PQCSettings.interfaceKeepWindowOnTop ? 1 : 0.3)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: PQCSettings.interfaceWindowMode

            mipmap: true

            PQMouseArea {
                id: fore_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: PQCSettings.interfaceKeepWindowOnTop ? qsTranslate("quickinfo", "Click here to not keep window in foreground") : qsTranslate("quickinfo", "Click here to keep window in foreground")
                onClicked:
                    PQCSettings.interfaceKeepWindowOnTop = !PQCSettings.interfaceKeepWindowOnTop
            }
        }

        Item {
            width: 1
            height: 1
            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons)
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: PQCScriptsConfig.amIOnWindows() ? "image://svg/:/white/windows-minimize.svg" : "image://svg/:/white/minimize.svg"

            opacity: !visibleAlways ? 0 : (mini_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons)

            mipmap: true

            PQMouseArea {
                id: mini_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to minimize window")
                onClicked:
                    toplevel.showMinimized()
            }
        }

        Item {
            width: 1
            height: 1
            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons)
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: PQCScriptsConfig.amIOnWindows() ?
                        (toplevel.visibility===Window.Windowed ? "image://svg/:/white/windows-maximize.svg" : "image://svg/:/white/windows-restore.svg") :
                        (toplevel.visibility===Window.Windowed ? "image://svg/:/white/maximize.svg" : "image://svg/:/white/restore.svg")

            opacity: !visibleAlways ? 0 : (minimaxi_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons)

            mipmap: true

            PQMouseArea {
                id: minimaxi_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: (toplevel.visibility===Window.Maximized ?
                           qsTranslate("quickinfo", "Click here to restore window") :
                           qsTranslate("quickinfo", "Click here to maximize window"))
                onClicked: {
                    if(toplevel.visibility === Window.Windowed)
                        toplevel.visibility = Window.Maximized
                    else
                        toplevel.visibility = Window.Windowed
                }
            }
        }

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: PQCSettings.interfaceWindowMode ? "image://svg/:/white/fullscreen_on.svg" : "image://svg/:/white/fullscreen_off.svg"

            opacity: !visibleAlways ? 0 : (fullscreen_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            PQMouseArea {
                id: fullscreen_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: (PQCSettings.interfaceWindowMode ?
                           qsTranslate("quickinfo", "Click here to enter fullscreen mode") :
                           qsTranslate("quickinfo", "Click here to exit fullscreen mode"))
                onClicked:
                    PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode
            }
        }

        Item {
            visible: (toplevel.visibility===Window.FullScreen) || (!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons
            width: 1
            height: 1
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            source: "image://svg/:/white/close.svg"
            sourceSize: Qt.size(width, height)

            opacity: !visibleAlways ? 0 : (closemouse.containsMouse ? 1 : 0.8)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            visible: (toplevel.visibility===Window.FullScreen) || (!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons

            PQMouseArea {
                id: closemouse
                anchors.fill: parent
                anchors.topMargin: -distanceFromEdge
                anchors.rightMargin: -distanceFromEdge
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to close PhotoQt")
                onClicked:
                    toplevel.close()
            }

        }

    }

    property bool nearTopEdge: false

    Connections {

        target: PQCNotify

        function onMouseMove(posx, posy) {

            if(!PQCSettings.interfaceWindowButtonsAutoHide || loader.visibleItem !== "") {
                resetAutoHide.stop()
                windowbuttons_top.state = "visible"
                nearTopEdge = true
                return
            }

            var trigger = PQCSettings.interfaceHotEdgeSize*5
            if(PQCSettings.interfaceEdgeTopAction !== "")
                trigger *= 2

            if((posy < trigger && PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) {
                windowbuttons_top.state = "visible"
                nearTopEdge = true
            } else
                nearTopEdge = false

            resetAutoHide.restart()

        }

    }

    Connections {

        target: loader

        function onVisibleItemChanged() {
            if(loader.visibleItem !== "")
                windowbuttons_top.state = "visible"
        }

    }

    Timer {
        id: resetAutoHide
        interval:  500 + PQCSettings.interfaceWindowButtonsAutoHideTimeout
        repeat: false
        running: false
        onTriggered: {
            if(!nearTopEdge || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                windowbuttons_top.state = "hidden"
        }
    }

}
