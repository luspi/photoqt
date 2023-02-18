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
import QtQuick.Window 2.2
import "../elements"

Item {

    id: windowbuttons_top

    property bool makeVisible: !PQSettings.interfaceWindowButtonsAutoHide && PQSettings.interfaceWindowButtonsShow

    x: parent.width-width-distanceFromEdge
    y: (PQSettings.thumbnailsEdge == "Top") ?
           (makeVisible ? (distanceFromEdge + thumbnails.height+thumbnails.y) : -height) :
           (makeVisible ? distanceFromEdge : -height)

    Behavior on y { NumberAnimation { duration: (PQSettings.interfaceWindowButtonsAutoHide || movedByMouse) ? (PQSettings.imageviewAnimationDuration*100) : 0 } }
    Behavior on x { NumberAnimation { duration: (movedByMouse) ? (PQSettings.imageviewAnimationDuration*100) : 0 } }

    property bool movedByMouse: false

    property int distanceFromEdge: 5

    width: row.width
    height: row.height

    visible: (!(variables.slideShowActive&&PQSettings.slideshowHideWindowButtons) && PQSettings.interfaceWindowButtonsShow && opacity==1)

    property bool visibleAlways: false

    z: (visibleAlways&&variables.visibleItem!="filedialog") ? 999 : 0

    // clicks between buttons has no effect anywhere
    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Row {

        id: row

        spacing: 0

        Image {
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/leftarrow.svg"
            enabled: filefoldermodel.countMainView>0
            opacity: visibleAlways ? 0 : (enabled ? (left_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
            visible: PQSettings.interfaceNavigationTopRight && opacity > 0 && !variables.slideShowActive
            mipmap: true
            PQMouseArea {
                id: left_mouse
                anchors.fill: parent
                enabled: parent.enabled&&parent.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                tooltip: em.pty+qsTranslate("navigate", "Navigate to previous image in folder")
                onClicked:
                    imageitem.loadPrevImage()
            }
        }

        Image {
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/rightarrow.svg"
            enabled: filefoldermodel.countMainView>0
            opacity: visibleAlways||variables.slideShowActive ? 0 : (enabled ? (right_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
            visible: PQSettings.interfaceNavigationTopRight && opacity > 0
            mipmap: true
            PQMouseArea {
                id: right_mouse
                anchors.fill: parent
                enabled: parent.enabled&&parent.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
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
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/menu.svg"

            opacity: (visibleAlways && !variables.mainMenuVisible)||variables.slideShowActive ? 0 : (mainmenu_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            mipmap: true

            visible: PQSettings.interfaceNavigationTopRight && opacity > 0

            PQMouseArea {
                id: mainmenu_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Click here to show main menu")
                onClicked:
                    loader.passOn("mainmenu", "toggle", undefined)
            }
        }

        Image {
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/keepforeground.svg"

            opacity: !visibleAlways ? 0 : (fore_mouse.containsMouse ? 0.8 : 0.5)*(PQSettings.interfaceKeepWindowOnTop ? 1 : 0.3)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            visible: PQSettings.interfaceWindowMode

            mipmap: true

            PQMouseArea {
                id: fore_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: PQSettings.interfaceKeepWindowOnTop ? em.pty+qsTranslate("quickinfo", "Click here to not keep window in foreground") : em.pty+qsTranslate("quickinfo", "Click here to keep window in foreground")
                onClicked:
                    PQSettings.interfaceKeepWindowOnTop = !PQSettings.interfaceKeepWindowOnTop
            }
        }

        Item {
            width: 1
            height: 1
            visible: PQSettings.interfaceWindowMode && ((!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons)
        }

        Image {
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: "/mainwindow/minimize.svg"

            opacity: !visibleAlways ? 0 : (mini_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            visible: PQSettings.interfaceWindowMode && ((!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons)

            mipmap: true

            PQMouseArea {
                id: mini_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Click here to minimize window")
                onClicked:
                    toplevel.showMinimized()
            }
        }

        Item {
            width: 1
            height: 1
            visible: PQSettings.interfaceWindowMode && ((!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons)
        }

        Image {
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: toplevel.visibility==Window.Windowed ? "/mainwindow/maximize.svg" : "/mainwindow/restore.svg"

            opacity: !visibleAlways ? 0 : (minimaxi_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            visible: PQSettings.interfaceWindowMode && ((!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons)

            mipmap: true

            PQMouseArea {
                id: minimaxi_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: (toplevel.visibility==Window.Maximized ? em.pty+qsTranslate("quickinfo", "Click here to restore window")
                                                : em.pty+qsTranslate("quickinfo", "Click here to maximize window"))
                onClicked: {
                    if(toplevel.visibility == Window.Windowed)
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
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            sourceSize: Qt.size(width, height)
            source: PQSettings.interfaceWindowMode ? "/mainwindow/fullscreen_on.svg" : "/mainwindow/fullscreen_off.svg"

            opacity: !visibleAlways ? 0 : (fullscreen_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            mipmap: true

            PQMouseArea {
                id: fullscreen_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: (PQSettings.interfaceWindowMode ? em.pty+qsTranslate("quickinfo", "Click here to enter fullscreen mode")
                                                : em.pty+qsTranslate("quickinfo", "Click here to exit fullscreen mode"))
                onClicked:
                    PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
            }
        }

        Item {
            visible: (toplevel.visibility==Window.FullScreen) || (!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons
            width: 1
            height: 1
        }

        Image {
            width: 3*PQSettings.interfaceWindowButtonsSize
            height: 3*PQSettings.interfaceWindowButtonsSize
            source: "/other/close.svg"
            sourceSize: Qt.size(width, height)

            opacity: !visibleAlways ? 0 : (closemouse.containsMouse ? 1 : 0.8)
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

            mipmap: true

            visible: (toplevel.visibility==Window.FullScreen) || (!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceWindowButtonsDuplicateDecorationButtons

            PQMouseArea {
                id: closemouse
                anchors.fill: parent
                anchors.topMargin: -distanceFromEdge
                anchors.rightMargin: -distanceFromEdge
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Click here to close PhotoQt")
                onClicked:
                    toplevel.close()
            }

        }

    }


    Connections {

        target: variables

        onMousePosChanged: {

            if(!PQSettings.interfaceWindowButtonsAutoHide || variables.visibleItem != "") {
                makeVisible = true
                return
            }

            var trigger = 30
            if(PQSettings.thumbnailsEdge == "Top")
                trigger = 60

            if((variables.mousePos.y < trigger && PQSettings.interfaceWindowButtonsAutoHideTopEdge) || !PQSettings.interfaceWindowButtonsAutoHideTopEdge)
                makeVisible = true

            resetAutoHide.restart()

        }

        onVisibleItemChanged: {
            if(variables.visibleItem != "")
                makeVisible = true
        }

    }

    Timer {
        id: resetAutoHide
        interval:  500 + PQSettings.interfaceWindowButtonsAutoHideTimeout
        repeat: false
        running: false
        onTriggered: {
            if(variables.mousePos.y > windowbuttons_top.y+windowbuttons_top.height+20)
                makeVisible = false
        }
    }

}
