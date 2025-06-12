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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Window
import PQCFileFolderModel
import PQCScriptsConfig
import PhotoQt

Item {

    id: wb_top

    x: PQCConstants.windowWidth-width-distanceFromEdge

    Behavior on y { NumberAnimation { duration: (PQCSettings.interfaceWindowButtonsAutoHide || PQCSettings.interfaceWindowButtonsAutoHideTopEdge || wb_top.movedByMouse) ? 200 : 0 } }
    Behavior on x { NumberAnimation { duration: (wb_top.movedByMouse) ? 200 : 0 } }

    property bool movedByMouse: false
    property int distanceFromEdge: 5
    property bool nearTopEdge: false

    // this is set to false in a timer at the end to blend in the status info once properly positioned
    property bool hideAtStartup: true
    opacity: hideAtStartup ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: 200 } }

    width: row.width
    height: row.height

    onXChanged: {
        if(!visibleAlways)
            PQCConstants.windowButtonsCurrentRect.x = x
    }
    onYChanged: {
        if(!visibleAlways)
            PQCConstants.windowButtonsCurrentRect.y = y
    }
    onWidthChanged: {
        if(!visibleAlways)
            PQCConstants.windowButtonsCurrentRect.width = width
    }
    onHeightChanged: {
        if(!visibleAlways)
            PQCConstants.windowButtonsCurrentRect.height = height
    }

    visible: (!(PQCConstants.slideshowRunning && PQCSettings.slideshowHideWindowButtons) && PQCSettings.interfaceWindowButtonsShow && opacity>0) && !PQCConstants.faceTaggingMode // qmllint disable unqualified

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
                wb_top.y: wb_top.distanceFromEdge
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                wb_top.y: -wb_top.height
            }
        }
    ]

    Component.onCompleted: {
        fadeIn.start()
    }
    Timer {
        id: fadeIn
        interval: 200
        onTriggered:
            wb_top.hideAtStartup = false
    }

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


    Row {

        id: row

        spacing: 2

        property list<string> entries: PQCSettings.interfaceWindowButtonsItems

        Repeater {

            model: row.entries.length

            Item {

                id: deleg

                width: ldr.active ? ldr.width : 0
                height: ldr.active ? ldr.height : 0

                required property int modelData
                property string entry: row.entries[modelData]
                property string comp: entry.split("_")[0]
                property bool fullscreenonly: (entry.split("_")[1].split("|")[0] === "1")
                property bool windowedonly: (entry.split("_")[1].split("|")[1] === "1")
                property bool alwaysontop: (entry.split("_")[1].split("|")[2] === "1")

                Loader {
                    id: ldr

                    active: (!deleg.fullscreenonly || PQCConstants.windowFullScreen) &&
                            (!deleg.windowedonly || !PQCConstants.windowFullScreen) &&
                            (deleg.alwaysontop || !wb_top.visibleAlways)

                    sourceComponent: deleg.comp == "left" ?
                                         comp_left :
                                         (deleg.comp == "right" ?
                                              comp_right :
                                              (deleg.comp == "menu" ?
                                                   comp_menu :
                                                   (deleg.comp == "ontop" ?
                                                        comp_ontop :
                                                        (deleg.comp == "fullscreen" ?
                                                             comp_fullscreen :
                                                             (deleg.comp == "minimize" ?
                                                                  comp_min :
                                                                  (deleg.comp == "maximize" ?
                                                                       comp_max :
                                                                       (deleg.comp == "close" ?
                                                                            comp_close :
                                                                            comp_unknown)))))))

                }

            }

        }

    }

    Component {
        id: comp_unknown

        Rectangle {
            width: 3*PQCSettings.interfaceWindowButtonsSize
            height: 3*PQCSettings.interfaceWindowButtonsSize
            color: "red"
            PQText {
                anchors.centerIn: parent
                color: "white"
                text: "?"
            }
        }
    }

    Component {
        id: comp_left

        Image {
            id: leftarrow
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/leftarrow.svg" // qmllint disable unqualified
            enabled: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
            opacity: PQCConstants.modalWindowOpen||PQCConstants.slideshowRunning ? 0 : (enabled ? (left_mouse.containsMouse ? 0.8 : 0.5) : 0.2)
            visible: opacity > 0 && !PQCConstants.slideshowRunning // qmllint disable unqualified
            mipmap: true
            PQMouseArea {
                id: left_mouse
                anchors.fill: leftarrow
                enabled: leftarrow.enabled&&leftarrow.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                text: qsTranslate("navigate", "Navigate to previous image in folder")
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCNotify.executeInternalCommand("__prev") // qmllint disable unqualified
                    else if(button === Qt.RightButton)
                        menu.item.popup()
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        left_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_right

        Image {
            id: rightarrow
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/rightarrow.svg" // qmllint disable unqualified
            enabled: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified
            opacity: PQCConstants.modalWindowOpen||PQCConstants.slideshowRunning ? 0 : (enabled ? (right_mouse.containsMouse ? 0.8 : 0.5) : 0.2) // qmllint disable unqualified
            visible: opacity > 0
            mipmap: true
            PQMouseArea {
                id: right_mouse
                anchors.fill: rightarrow
                enabled: rightarrow.enabled&&rightarrow.opacity>0
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                text: qsTranslate("navigate", "Navigate to next image in folder")
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCNotify.executeInternalCommand("__next") // qmllint disable unqualified
                    else if(button === Qt.RightButton)
                        menu.item.popup()
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        right_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_menu

        Image {
            id: mainmenu
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/menu.svg" // qmllint disable unqualified

            opacity: (PQCConstants.modalWindowOpen||PQCConstants.slideshowRunning) ? 0 : (mainmenu_mouse.containsMouse ? 0.8 : 0.5) // qmllint disable unqualified

            mipmap: true

            visible: opacity > 0

            PQMouseArea {
                id: mainmenu_mouse
                anchors.fill: mainmenu
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to show main menu")
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCNotify.executeInternalCommand("__toggleMainMenu") // qmllint disable unqualified
                    else if(button === Qt.RightButton)
                        menu.item.popup()
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        mainmenu_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_ontop

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: "image://svg/:/" + PQCLook.iconShade + "/keepforeground.svg" // qmllint disable unqualified

            opacity: (fore_mouse.containsMouse ? 0.8 : 0.5)*(PQCSettings.interfaceKeepWindowOnTop ? 1 : 0.3) // qmllint disable unqualified
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            PQMouseArea {
                id: fore_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: PQCSettings.interfaceKeepWindowOnTop ? qsTranslate("quickinfo", "Click here to not keep window in foreground") : qsTranslate("quickinfo", "Click here to keep window in foreground") // qmllint disable unqualified
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCSettings.interfaceKeepWindowOnTop = !PQCSettings.interfaceKeepWindowOnTop // qmllint disable unqualified
                    else if(button === Qt.RightButton)
                        menu.item.popup()
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        fore_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_fullscreen

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: PQCSettings.interfaceWindowMode ? ("image://svg/:/" + PQCLook.iconShade + "/fullscreen_on.svg") : ("image://svg/:/" + PQCLook.iconShade + "/fullscreen_off.svg") // qmllint disable unqualified

            opacity: fullscreen_mouse.containsMouse ? 0.8 : 0.5
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
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode // qmllint disable unqualified
                    else if(button === Qt.RightButton)
                        menu.item.popup()
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        fullscreen_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_min

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: PQCScriptsConfig.amIOnWindows() ? ("image://svg/:/" + PQCLook.iconShade + "/windows-minimize.svg") : ("image://svg/:/" + PQCLook.iconShade + "/minimize.svg") // qmllint disable unqualified

            opacity: mini_mouse.containsMouse ? 0.8 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            PQMouseArea {
                id: mini_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to minimize window")
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCNotify.setWindowState(Window.Minimized)
                    else if(button === Qt.RightButton)
                        menu.item.popup() // qmllint disable missing-property
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        mini_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_max

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            sourceSize: Qt.size(width, height)
            source: PQCScriptsConfig.amIOnWindows() ? // qmllint disable unqualified
                        (PQCConstants.windowState===Window.Windowed ? ("image://svg/:/" + PQCLook.iconShade + "/windows-maximize.svg") : ("image://svg/:/" + PQCLook.iconShade + "/windows-restore.svg")) :
                        (PQCConstants.windowState===Window.Windowed ? ("image://svg/:/" + PQCLook.iconShade + "/maximize.svg") : ("image://svg/:/" + PQCLook.iconShade + "/restore.svg"))

            opacity: minimaxi_mouse.containsMouse ? 0.8 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }

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
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton) {
                        if(PQCConstants.windowState === Window.Windowed) // qmllint disable unqualified
                            PQCNotify.setWindowState(Window.Maximized)
                        else
                            PQCNotify.setWindowState(Window.Windowed)
                    } else if(button === Qt.RightButton)
                        menu.item.popup() // qmllint disable missing-property
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        minimaxi_mouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
                }

            }
        }

    }

    Component {

        id: comp_close

        Image {
            width: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            height: 3*PQCSettings.interfaceWindowButtonsSize // qmllint disable unqualified
            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
            sourceSize: Qt.size(width, height)

            opacity: closemouse.containsMouse ? 1 : 0.8
            Behavior on opacity { NumberAnimation { duration: 200 } }

            mipmap: true

            PQMouseArea {
                id: closemouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("quickinfo", "Click here to close PhotoQt")
                acceptedButtons: Qt.AllButtons
                onClicked: (mouse) => {
                    executeClick(mouse.button)
                }
                function executeClick(button : int) {
                    if(button === Qt.LeftButton)
                        PQCNotify.windowClose()
                    else if(button === Qt.RightButton)
                        menu.item.popup() // qmllint disable missing-property
                }
            }

            MultiPointTouchArea {

                id: toucharea

                anchors.fill: parent
                mouseEnabled: false

                maximumTouchPoints: 1

                property point touchPos

                onPressed: (touchPoints) => {
                    touchPos = touchPoints[0]
                    touchShowMenu.start()
                }

                onUpdated: (touchPoints) => {
                    if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                        touchShowMenu.stop()
                    }
                }

                onReleased: {
                    touchShowMenu.stop()
                    if(!menu.item.opened)
                        closemouse.executeClick(Qt.LeftButton)
                }

                Timer {
                    id: touchShowMenu
                    interval: 1000
                    onTriggered: {
                        menu.item.popup(toucharea.mapToItem(wb_top, toucharea.touchPos))
                    }
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

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onMouseMove(posx, posy) {

            if((!PQCSettings.interfaceWindowButtonsAutoHide && !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || PQCConstants.modalWindowOpen) { // qmllint disable unqualified
                resetAutoHide.stop()
                wb_top.state = "visible"
                wb_top.nearTopEdge = true
                return
            }

            var trigger = PQCSettings.interfaceHotEdgeSize*5
            if(PQCSettings.interfaceEdgeTopAction !== "")
                trigger *= 2

            if((posy < trigger && PQCSettings.interfaceWindowButtonsAutoHideTopEdge) || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge)
                wb_top.state = "visible"

            wb_top.nearTopEdge = (posy < trigger)

            if(!wb_top.nearTopEdge && (!resetAutoHide.running || PQCSettings.interfaceWindowButtonsAutoHide))
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
                wb_top.state = "visible"
        }

    }

    Timer {
        id: resetAutoHide
        interval:  500 + PQCSettings.interfaceWindowButtonsAutoHideTimeout // qmllint disable unqualified
        repeat: false
        running: false
        onTriggered: {
            if((!wb_top.nearTopEdge || !PQCSettings.interfaceWindowButtonsAutoHideTopEdge) && !menu.item.opened) // qmllint disable unqualified
                wb_top.state = "hidden"
        }
    }

}
