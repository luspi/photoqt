pragma ComponentBehavior: Bound
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
import QtQuick.Controls
import QtQuick.Window

import PQCFileFolderModel
import PQCScriptsConfig

import "../elements"
import "../"

Item {

    id: windowbuttons_top

    x: PQCConstants.windowWidth-width-distanceFromEdge // qmllint disable unqualified

    Behavior on y { NumberAnimation { duration: (PQCSettings.interfaceWindowButtonsAutoHide || PQCSettings.interfaceWindowButtonsAutoHideTopEdge || windowbuttons_top.movedByMouse) ? 200 : 0 } } // qmllint disable unqualified
    Behavior on x { NumberAnimation { duration: (windowbuttons_top.movedByMouse) ? 200 : 0 } }

    property bool movedByMouse: false

    property int distanceFromEdge: 5

    width: row.width
    height: row.height

    visible: (!(PQCNotify.slideshowRunning && PQCSettings.slideshowHideWindowButtons) && PQCSettings.interfaceWindowButtonsShow && opacity>0) && !PQCConstants.faceTaggingMode // qmllint disable unqualified

    property bool visibleAlways: false

    state: (!PQCSettings.interfaceWindowButtonsAutoHide && PQCSettings.interfaceWindowButtonsShow) ? // qmllint disable unqualified
               "visible" :
               "hidden"

    onStateChanged: {
        if(state === "hidden" && menu.item !== null)
            menu.item.dismiss() // qmllint disable missing-property
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                windowbuttons_top.y: windowbuttons_top.distanceFromEdge
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                windowbuttons_top.y: -windowbuttons_top.height
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
                menu.item.popup() // qmllint disable missing-property
        }
    }

    Component {
        id: navigationbuttons

        Row {

            Image {
                width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
                height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/leftarrow.svg" // qmllint disable unqualified
                enabled: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
                opacity: PQCConstants.modalWindowOpen||PQCNotify.slideshowRunning ? 0 : (enabled ? (left_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
                visible: PQCSettings.interfaceNavigationTopRight && (PQCSettings.interfaceNavigationTopRightAlways || PQCConstants.windowFullScreen) && opacity > 0 && !PQCNotify.slideshowRunning // qmllint disable unqualified
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
                            PQCNotify.executeInternalCommand("__prev") // qmllint disable unqualified
                        else if(mouse.button === Qt.RightButton)
                            menu.item.popup()
                    }
                }
            }

            Image {
                width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
                height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/rightarrow.svg" // qmllint disable unqualified
                enabled: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
                opacity: PQCConstants.modalWindowOpen||PQCNotify.slideshowRunning ? 0 : (enabled ? (right_mouse.containsMouse ? 0.8 : 0.5) : 0.2) // qmllint disable unqualified
                visible: PQCSettings.interfaceNavigationTopRight && (PQCSettings.interfaceNavigationTopRightAlways || PQCConstants.windowFullScreen) && opacity > 0 // qmllint disable unqualified
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
                            PQCNotify.executeInternalCommand("__next") // qmllint disable unqualified
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
                width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
                height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/menu.svg" // qmllint disable unqualified

                opacity: (PQCConstants.modalWindowOpen||PQCNotify.slideshowRunning) ? 0 : (mainmenu_mouse.containsMouse ? 0.8 : 0.5) // qmllint disable unqualified

                mipmap: true

                visible: PQCSettings.interfaceNavigationTopRight && (PQCSettings.interfaceNavigationTopRightAlways || PQCConstants.windowFullScreen) && opacity > 0 // qmllint disable unqualified

                PQMouseArea {
                    id: mainmenu_mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("quickinfo", "Click here to show main menu")
                    acceptedButtons: Qt.AllButtons
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton)
                            PQCNotify.executeInternalCommand("__toggleMainMenu") // qmllint disable unqualified
                        else if(mouse.button === Qt.RightButton)
                            menu.item.popup()
                    }
                }
            }

        }
    }

    Row {

        id: row

        spacing: 0

        Loader {
            active: PQCSettings.interfaceNavigationTopRight&&PQCSettings.interfaceNavigationTopRightLeftRight==="left"
            sourceComponent: navigationbuttons
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/keepforeground.svg" // qmllint disable unqualified

            opacity: !windowbuttons_top.visibleAlways ? 0 : (fore_mouse.containsMouse ? 0.8 : 0.5)*(PQCSettings.interfaceKeepWindowOnTop ? 1 : 0.3) // qmllint disable unqualified
            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: PQCSettings.interfaceWindowMode // qmllint disable unqualified

            mipmap: true

            PQMouseArea {
                id: fore_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: PQCSettings.interfaceKeepWindowOnTop ? qsTranslate("quickinfo", "Click here to not keep window in foreground") : qsTranslate("quickinfo", "Click here to keep window in foreground") // qmllint disable unqualified
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCSettings.interfaceKeepWindowOnTop = !PQCSettings.interfaceKeepWindowOnTop // qmllint disable unqualified
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
            }
        }

        Item {
            width: 1
            height: 1
            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons) // qmllint disable unqualified
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: PQCScriptsConfig.amIOnWindows() ? ("image://svg/:/" + PQCLook.iconShade + "/windows-minimize.svg") : ("image://svg/:/" + PQCLook.iconShade + "/minimize.svg") // qmllint disable unqualified

            opacity: !windowbuttons_top.visibleAlways ? 0 : (mini_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons) // qmllint disable unqualified

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
                        PQCNotify.setWindowState(Window.Minimized)
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup() // qmllint disable missing-property
                }
            }
        }

        Item {
            width: 1
            height: 1
            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons) // qmllint disable unqualified
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: PQCScriptsConfig.amIOnWindows() ? // qmllint disable unqualified
                        (PQCConstants.windowState===Window.Windowed ? ("image://svg/:/" + PQCLook.iconShade + "/windows-maximize.svg") : ("image://svg/:/" + PQCLook.iconShade + "/windows-restore.svg")) :
                        (PQCConstants.windowState===Window.Windowed ? ("image://svg/:/" + PQCLook.iconShade + "/maximize.svg") : ("image://svg/:/" + PQCLook.iconShade + "/restore.svg"))

            opacity: !windowbuttons_top.visibleAlways ? 0 : (minimaxi_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: PQCSettings.interfaceWindowMode && ((!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons) // qmllint disable unqualified

            mipmap: true

            PQMouseArea {
                id: minimaxi_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: (PQCConstants.windowState===Window.Maximized ? // qmllint disable unqualified
                           qsTranslate("quickinfo", "Click here to restore window") :
                           qsTranslate("quickinfo", "Click here to maximize window"))
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton) {
                        if(PQCConstants.windowState === Window.Windowed) // qmllint disable unqualified
                            PQCNotify.setWindowState(Window.Maximized)
                        else
                            PQCNotify.setWindowState(Window.Windowed)
                    } else if(mouse.button === Qt.RightButton)
                        menu.item.popup() // qmllint disable missing-property
                }
            }
        }

        Item {
            width: 1
            height: 1
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: PQCSettings.interfaceWindowMode ? ("image://svg/:/" + PQCLook.iconShade + "/fullscreen_on.svg") : ("image://svg/:/" + PQCLook.iconShade + "/fullscreen_off.svg") // qmllint disable unqualified

            opacity: !windowbuttons_top.visibleAlways ? 0 : (fullscreen_mouse.containsMouse ? 0.8 : 0.5)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            PQMouseArea {
                id: fullscreen_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: (PQCSettings.interfaceWindowMode ? // qmllint disable unqualified
                           qsTranslate("quickinfo", "Click here to enter fullscreen mode") :
                           qsTranslate("quickinfo", "Click here to exit fullscreen mode"))
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode // qmllint disable unqualified
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup()
                }
            }
        }

        Item {
            visible: (PQCConstants.windowState===Window.FullScreen) || (!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons // qmllint disable unqualified
            width: 1
            height: 1
        }

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)

            opacity: !windowbuttons_top.visibleAlways ? 0 : (closemouse.containsMouse ? 1 : 0.8)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            visible: (PQCConstants.windowState===Window.FullScreen) || (!PQCSettings.interfaceWindowDecoration) || PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons // qmllint disable unqualified

            PQMouseArea {
                id: closemouse
                anchors.fill: parent
                anchors.topMargin: -windowbuttons_top.distanceFromEdge
                anchors.rightMargin: -windowbuttons_top.distanceFromEdge
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to close PhotoQt")
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCNotify.windowClose()
                    else if(mouse.button === Qt.RightButton)
                        menu.item.popup() // qmllint disable missing-property
                }
            }

        }

        Loader {
            active: PQCSettings.interfaceNavigationTopRight&&PQCSettings.interfaceNavigationTopRightLeftRight==="right"
            sourceComponent: navigationbuttons
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
                    enabled: false
                    font.italic: true
                    moveToRightABit: true
                    text: qsTranslate("metadata", "Window buttons")
                }

                PQMenuSeparator {}

                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "show")
                    checked: PQCSettings.interfaceWindowButtonsShow // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked !== PQCSettings.interfaceWindowButtonsShow) { // qmllint disable unqualified
                            PQCSettings.interfaceWindowButtonsShow = checked
                            checked = Qt.binding(function() {  return PQCSettings.interfaceWindowButtonsShow })
                        }
                        if(!checked)
                            menucomponent.dismiss()
                    }
                }
                PQMenuItem {
                    checkable: true
                    text: qsTranslate("settingsmanager", "duplicate buttons")
                    checked: PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked !== PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons) { // qmllint disable unqualified
                            PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons = checked
                            checked = Qt.binding(function() {  return PQCSettings.interfaceWindowButtonsDuplicateDecorationButtons })
                        }
                    }
                }
                PQMenu {
                    title: qsTranslate("settingsmanager", "navigation icons")
                    PQMenuItem {
                        checkable: true
                        text: qsTranslate("settingsmanager", "show icons")
                        checked: PQCSettings.interfaceNavigationTopRight // qmllint disable unqualified
                        onCheckedChanged: {
                            if(PQCSettings.interfaceNavigationTopRight !== checked) { // qmllint disable unqualified
                                PQCSettings.interfaceNavigationTopRight = checked
                                checked = Qt.binding(function() {  return PQCSettings.interfaceNavigationTopRight })
                            }
                        }
                    }
                    PQMenuItem {
                        checkable: true
                        text: qsTranslate("settingsmanager", "only in fullscreen")
                        checked: !PQCSettings.interfaceNavigationTopRightAlways // qmllint disable unqualified
                        onCheckedChanged: {
                            if(PQCSettings.interfaceNavigationTopRightAlways === checked) { // qmllint disable unqualified
                                PQCSettings.interfaceNavigationTopRightAlways = !checked
                                checked = Qt.binding(function() {  return !PQCSettings.interfaceNavigationTopRightAlways })
                            }
                        }
                    }
                }

                PQMenuSeparator {}

                PQMenu {

                    title: qsTranslate("settingsmanager", "visibility")

                    PQMenuItem {
                        checkable: true
                        checkableLikeRadioButton: true
                        text: qsTranslate("settingsmanager", "always")
                        ButtonGroup.group: grp
                        checked: !PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge // qmllint disable unqualified
                        onCheckedChanged: {
                            if(checked) {
                                PQCSettings.interfaceWindowButtonsAutoHide = false // qmllint disable unqualified
                                PQCSettings.interfaceWindowButtonsAutoHideTopEdge = false
                            }
                        }
                    }
                    PQMenuItem {
                        checkable: true
                        checkableLikeRadioButton: true
                        text: qsTranslate("settingsmanager", "cursor move")
                        ButtonGroup.group: grp
                        checked: PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge // qmllint disable unqualified
                        onCheckedChanged: {
                            if(checked) {
                                PQCSettings.interfaceWindowButtonsAutoHide = true // qmllint disable unqualified
                                PQCSettings.interfaceWindowButtonsAutoHideTopEdge = false
                            }
                        }
                    }
                    PQMenuItem {
                        checkable: true
                        checkableLikeRadioButton: true
                        text: qsTranslate("settingsmanager", "cursor near top edge")
                        ButtonGroup.group: grp
                        checked: PQCSettings.interfaceWindowButtonsAutoHideTopEdge // qmllint disable unqualified
                        onCheckedChanged: {
                            if(checked) {
                                PQCSettings.interfaceWindowButtonsAutoHide = false // qmllint disable unqualified
                                PQCSettings.interfaceWindowButtonsAutoHideTopEdge = true
                            }
                        }
                    }

                }

                PQMenuSeparator {}

                PQMenuItem {
                    text: qsTranslate("settingsmanager", "Manage in settings manager")
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg" // qmllint disable unqualified
                    onTriggered: {
                        PQCNotify.onOpenSettingsManagerAt("showSettings", "windowbuttons")
                    }
                }

                onAboutToHide:
                    recordAsClosed.restart()
                onAboutToShow:
                    PQCNotify.addToWhichContextMenusOpen("windowbuttons") // qmllint disable unqualified

                Timer {
                    id: recordAsClosed
                    interval: 200
                    onTriggered: {
                        if(!menucomponent.visible)
                            PQCNotify.removeFromWhichContextMenusOpen("windowbuttons") // qmllint disable unqualified
                    }
                }
            }
    }

    property bool nearTopEdge: false

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onMouseMove(posx, posy) {

            if((!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || PQCConstants.modalWindowOpen) { // qmllint disable unqualified
                resetAutoHide.stop()
                windowbuttons_top.state = "visible"
                windowbuttons_top.nearTopEdge = true
                return
            }

            var trigger = PQCSettings.interfaceHotEdgeSize*5
            if(PQCSettings.interfaceEdgeTopAction !== "")
                trigger *= 2

            if((posy < trigger && PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                windowbuttons_top.state = "visible"

            windowbuttons_top.nearTopEdge = (posy < trigger)

            if(!windowbuttons_top.nearTopEdge && (!resetAutoHide.running || PQCSettings.interfaceWindowButtonsAutoHide))
                resetAutoHide.restart()

        }

        function onCloseAllContextMenus() {
            menu.item.dismiss() // qmllint disable missing-property
        }

    }

    Connections {

        target: PQCConstants // qmllint disable unqualified

        function onModalWindowOpenChanged() {
            if(PQCConstants.modalWindowOpen) // qmllint disable unqualified
                windowbuttons_top.state = "visible"
        }

    }

    Timer {
        id: resetAutoHide
        interval:  500 + PQCSettings.interfaceWindowButtonsAutoHideTimeout // qmllint disable unqualified
        repeat: false
        running: false
        onTriggered: {
            if((!windowbuttons_top.nearTopEdge || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) && !menu.item.opened) // qmllint disable unqualified
                windowbuttons_top.state = "hidden"
        }
    }

}
