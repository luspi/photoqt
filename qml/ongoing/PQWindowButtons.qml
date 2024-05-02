/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import QtQuick.Controls
import QtQuick.Window

import PQCFileFolderModel
import PQCNotify
import PQCScriptsConfig

import "../elements"

Item {

    id: windowbuttons_top

    x: toplevel.width-width-distanceFromEdge

    Behavior on y { NumberAnimation { duration: (PQCSettings.interfaceWindowButtonsAutoHide || PQCSettings.interfaceWindowButtonsAutoHideTopEdge || movedByMouse) ? 200 : 0 } }
    Behavior on x { NumberAnimation { duration: (movedByMouse) ? 200 : 0 } }

    property bool movedByMouse: false

    property int distanceFromEdge: 5

    width: row.width
    height: row.height

    visible: (!(PQCNotify.slideshowRunning && PQCSettings.slideshowHideWindowButtons) && PQCSettings.interfaceWindowButtonsShow && opacity>0) && !PQCNotify.faceTagging

    property bool visibleAlways: false

    state: (!PQCSettings.interfaceWindowButtonsAutoHide && PQCSettings.interfaceWindowButtonsShow) ?
               "visible" :
               "hidden"

    onStateChanged: {
        if(state === "hidden" && menu.item !== null)
            menu.item.dismiss()
    }

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
        acceptedButtons: Qt.AllButtons
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.item.popup()
        }
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCNotify.executeInternalCommand("__prev")
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCNotify.executeInternalCommand("__next")
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCNotify.executeInternalCommand("__toggleMainMenu")
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCSettings.interfaceKeepWindowOnTop = !PQCSettings.interfaceKeepWindowOnTop
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        toplevel.showMinimized()
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton) {
                        if(toplevel.visibility === Window.Windowed)
                            toplevel.visibility = Window.Maximized
                        else
                            toplevel.visibility = Window.Windowed
                    } else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
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
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        toplevel.close()
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
            }

        }

    }

    ButtonGroup { id: grp }

    Loader {
        id: menu
        asynchronous: true
        sourceComponent:
            PQMenu {
                id: menucomponent

                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "show")
                    checked: PQCSettings.interfaceWindowButtonsShow
                    onCheckedChanged: {
                        PQCSettings.interfaceWindowButtonsShow = checked
                        if(!checked)
                            menucomponent.dismiss()
                    }
                }
                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "duplicate buttons")
                    checked: PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons
                    onCheckedChanged:
                        PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons = checked
                }
                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "navigation icons")
                    checked: PQCSettings.interfaceNavigationTopRight
                    onCheckedChanged:
                        PQCSettings.interfaceNavigationTopRight = checked
                }
                PQMenuSeparator {}
                PQMenuItem {
                    enabled: false
                    moveToRightABit: true
                    text: "visibility:"
                }

                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "always")
                    ButtonGroup.group: grp
                    checked: !PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceWindowButtonsAutoHide = false
                            PQCSettings.interfaceWindowButtonsAutoHideTopEdge = false
                        }
                    }
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "cursor move")
                    ButtonGroup.group: grp
                    checked: PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceWindowButtonsAutoHide = true
                            PQCSettings.interfaceWindowButtonsAutoHideTopEdge = false
                        }
                    }
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: qsTranslate("settingsmanager", "cursor near top edge")
                    ButtonGroup.group: grp
                    checked: PQCSettings.interfaceWindowButtonsAutoHideTopEdge
                    onCheckedChanged: {
                        if(checked) {
                            PQCSettings.interfaceWindowButtonsAutoHide = false
                            PQCSettings.interfaceWindowButtonsAutoHideTopEdge = true
                        }
                    }
                }

                onAboutToHide:
                    recordAsClosed.restart()
                onAboutToShow:
                    PQCNotify.addToWhichContextMenusOpen("windowbuttons")

                Timer {
                    id: recordAsClosed
                    interval: 200
                    onTriggered:
                        PQCNotify.removeFromWhichContextMenusOpen("windowbuttons")
                }
            }
    }

    property bool nearTopEdge: false

    Connections {

        target: PQCNotify

        function onMouseMove(posx, posy) {

            if((!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || loader.visibleItem !== "") {
                resetAutoHide.stop()
                windowbuttons_top.state = "visible"
                nearTopEdge = true
                return
            }

            var trigger = PQCSettings.interfaceHotEdgeSize*5
            if(PQCSettings.interfaceEdgeTopAction !== "")
                trigger *= 2

            if((posy < trigger && PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                windowbuttons_top.state = "visible"

            nearTopEdge = (posy < trigger)

            if(!nearTopEdge && (!resetAutoHide.running || PQCSettings.interfaceWindowButtonsAutoHideTopEdge))
                resetAutoHide.restart()

        }

        function onCloseAllContextMenus() {
            menu.item.dismiss()
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
            if((!nearTopEdge || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) && !menu.item.opened)
                windowbuttons_top.state = "hidden"
        }
    }

}
