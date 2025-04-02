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
import PQCWindowGeometry

import "../../qml/elements"
import "../../qml/"

PQTemplateFloating {

    id: quickactions_top

    width: contentitem.width
    height: contentitem.height

    onXChanged: {
        quickactions_top.x = quickactions_top.x
    }
    onYChanged: {
        quickactions_top.y = quickactions_top.y
    }

    onWidthChanged: {
        if(popoutWindowUsed) {
            ele_window.minimumWidth = width
            ele_window.maximumWidth = width
        }
    }
    onHeightChanged: {
        if(popoutWindowUsed) {
            ele_window.minimumHeight = height
            ele_window.maximumHeight = height
        }
    }

    Behavior on opacity { NumberAnimation { duration: 200 } }

    property int mouseOverIndex: -1
    property bool mouseOver: false
    Timer {
        id: resetMouseOver
        property int leftIndex
        interval: 200
        onTriggered: {
            if(leftIndex === quickactions_top.mouseOverIndex)
                quickactions_top.mouseOver = false
        }
    }

    property bool finishedSetup: false

    states: [
        State {
            name: "popout"
            PropertyChanges {
                quickactions_top.x: 0
                quickactions_top.y: 0
            }
        }
    ]

    PQShadowEffect { masterItem: quickactions_top }

    popout: PQCSettings.extensionsPopoutQuickActions // qmllint disable unqualified
    forcePopout: PQCWindowGeometry.quickactionsForcePopout // qmllint disable unqualified
    shortcut: "__quickActions"
    tooltip: qsTranslate("quickactions", "Click-and-drag to move.")
    blur_thisis: "-"
    showMainMouseArea: false
    showBGMouseArea: true
    contentPadding: 5
    allowResize: false
    moveButtonsOutside: true

    onPopoutChanged: {
        if(popout !== PQCSettings.extensionsPopoutQuickActions) // qmllint disable unqualified
            PQCSettings.extensionsPopoutQuickActions = popout
    }

    property list<string> buttons: PQCSettings.extensionsQuickActionsItems

    // 4 values: tooltip, icon name, shortcut action, enabled with no file loaded
    property var mappings: {
        "|" : ["|", "|", "|", "|"],
        "rename" :      [qsTranslate("quickactions", "Rename file"),                     "rename",         "__rename",      false],
        "copy"   :      [qsTranslate("quickactions", "Copy file"),                       "copy",           "__copy",        false],
        "move"   :      [qsTranslate("quickactions", "Move file"),                       "move",           "__move",        false],
        "delete" :      [qsTranslate("quickactions", "Delete file (with confirmation)"), "delete",         "__delete",      false],
        "deletetrash" : [qsTranslate("quickactions", "Move file directly to trash"),     "delete",         "__deleteTrash", false],
        "rotateleft" :  [qsTranslate("quickactions", "Rotate left"),                     "rotateleft",     "__rotateL",     false],
        "rotateright" : [qsTranslate("quickactions", "Rotate right"),                    "rotateright",    "__rotateR",     false],
        "mirrorhor" :   [qsTranslate("quickactions", "Mirror horizontally"),             "leftrightarrow", "__flipH",       false],
        "mirrorver" :   [qsTranslate("quickactions", "Mirror vertically"),               "updownarrow",    "__flipV",       false],
        "crop" :        [qsTranslate("quickactions", "Crop image"),                      "crop",           "__crop",        false],
        "scale" :       [qsTranslate("quickactions", "Scale image"),                     "scale",          "__scale",       false],
        "tagfaces" :    [qsTranslate("quickactions", "Tag faces"),                       "faces",          "__tagFaces",    false],
        "clipboard" :   [qsTranslate("quickactions", "Copy to clipboard"),               "clipboard",      "__clipboard",   false],
        "export" :      [qsTranslate("quickactions", "Export to different format"),      "convert",        "__export",      false],
        "wallpaper" :   [qsTranslate("quickactions", "Set as wallpaper"),                "wallpaper",      "__wallpaper",   false],
        "qr" :          [(PQCNotify.barcodeDisplayed ?
                              qsTranslate("quickactions", "Hide QR/barcodes") :
                              qsTranslate("quickactions", "Detect QR/barcodes")),   "qrcode",         "__detectBarCodes", false],
        "close" :       [qsTranslate("quickactions", "Close window"),               "quit",           "__close",          true],
        "quit" :        [qsTranslate("quickactions", "Quit"),                       "quit",           "__quit",           true],
    }

    property list<string> mapkeys: ["|", "rename", "copy", "move", "delete", "rotateleft",
                                     "rotateright", "mirrorhor", "mirrorver", "crop", "scale",
                                     "tagfaces", "clipboard", "export", "wallpaper", "qr", "close", "quit"]

    property int sze: popoutWindowUsed ? 50 : 40

    content: [

        Item {

            id: contentitem

            property string orientation: "horizontal"
            width: (orientation=="horizontal" ? contentrow.width : contentcol.width)+10
            height: (orientation=="horizontal" ? contentrow.height : contentcol.height)+10

            Column {

                id: contentcol

                width: childrenRect.width
                spacing: 0

                Repeater {

                    model: contentitem.orientation=="vertical" ? quickactions_top.buttons.length : 0

                    Column {

                        id: delegver

                        required property int modelData
                        property string cat: quickactions_top.buttons[modelData]

                        property list<var> props: (delegver.cat in quickactions_top.mappings ?
                                                       quickactions_top.mappings[delegver.cat] :
                                                       ["?", "?", "?", "?"])

                        width: childrenRect.width

                        Item {
                            width: sze
                            height: 2
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: sepver
                            visible: delegver.props[0]==="|"
                            width: sze
                            height: 4
                            color: PQCLook.baseColorHighlight
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: unknownver
                            visible: delegver.props[0]==="?"
                            width: visible ? sze : 0
                            height: visible ? sze : 0
                            color: "red"
                            PQText {
                                anchors.centerIn: parent
                                color: "white"
                                text: "?"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        PQButtonIcon {
                            id: iconver
                            enableContextMenu: false
                            overrideBaseColor: "transparent"
                            width: sepver.visible ? 0 : sze
                            height: sepver.visible ? 0 : sze
                            visible: !sepver.visible && !unknownver.visible
                            enabled: visible && (delegver.props[3] || PQCConstants.howManyFiles>0)
                            tooltip: quickactions_top.popoutWindowUsed ? "" : (enabled ? delegver.props[0] : qsTranslate("quickactions", "No file loaded"))
                            dragTarget: quickactions_top.popoutWindowUsed ? undefined : quickactions_top
                            source: visible ? ("image://svg/:/" + PQCLook.iconShade + "/" + delegver.props[1] + ".svg") : ""
                            onClicked: {
                                PQCNotify.executeInternalCommand(delegver.props[2])
                            }
                            onRightClicked: {
                                if(!quickactions_top.popoutWindowUsed)
                                    menu.item.popup()
                            }

                            onMouseOverChanged: {
                                if(mouseOver) {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = delegver.modelData
                                    quickactions_top.mouseOver = true
                                } else {
                                    resetMouseOver.leftIndex = delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Item {
                            width: sze
                            height: 2
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                    }

                }

            }

            Row {

                id: contentrow

                height: childrenRect.height
                spacing: 0

                Repeater {

                    model: contentitem.orientation=="horizontal" ? quickactions_top.buttons.length : 0

                    Row {

                        id: deleghor

                        required property int modelData
                        property string cat: quickactions_top.buttons[modelData]

                        property list<var> props: (deleghor.cat in quickactions_top.mappings ?
                                                       quickactions_top.mappings[deleghor.cat] :
                                                       ["?", "?", "?", "?"])

                        height: childrenRect.height

                        Item {
                            width: 2
                            height: sze
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: sephor
                            visible: deleghor.props[0]==="|"
                            width: 4
                            height: sze
                            color: PQCLook.baseColorHighlight
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: unknownhor
                            visible: deleghor.props[0]==="?"
                            width: visible ? sze : 0
                            height: visible ? sze : 0
                            color: "red"
                            PQText {
                                anchors.centerIn: parent
                                color: "white"
                                text: "?"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        PQButtonIcon {
                            id: icnhor
                            enableContextMenu: false
                            overrideBaseColor: "transparent"
                            width: sephor.visible ? 0 : sze
                            height: sephor.visible ? 0 : sze
                            visible: !sephor.visible && !unknownhor.visible
                            enabled: visible && (deleghor.props[3] || PQCConstants.howManyFiles>0)
                            tooltip: quickactions_top.popoutWindowUsed ? "" : (enabled ? deleghor.props[0] : qsTranslate("quickactions", "No file loaded"))
                            dragTarget: quickactions_top.popoutWindowUsed ? undefined : quickactions_top
                            source: visible ? ("image://svg/:/" + PQCLook.iconShade + "/" + deleghor.props[1] + ".svg") : ""
                            onClicked: {
                                PQCNotify.executeInternalCommand(deleghor.props[2])
                            }
                            onRightClicked: {
                                if(!quickactions_top.popoutWindowUsed)
                                    menu.item.popup()
                            }
                            onMouseOverChanged: {
                                if(mouseOver) {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = deleghor.modelData
                                    quickactions_top.mouseOver = true
                                } else {
                                    resetMouseOver.leftIndex = deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Item {
                            width: 2
                            height: sze
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                    }

                }

            }

        }

    ]

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {
            id: themenu
            PQMenuItem {
                checkable: true
                text: qsTranslate("histogram", "show quick actions")
                checked: PQCSettings.extensionsQuickActions // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.extensionsQuickActions = checked // qmllint disable unqualified
                    if(!checked)
                        themenu.dismiss()
                }
            }

            PQMenuItem {
                text: qsTranslate("MainMenu", "Reset position to default")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg" // qmllint disable unqualified
                onTriggered: {
                    quickactions_top.reposition()
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                text: qsTranslate("settingsmanager", "Manage in settings manager")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg" // qmllint disable unqualified
                onTriggered: {
                    PQCNotify.openSettingsManagerAt("settingsmanager", "quickactions")
                }
            }

            onAboutToHide:
                recordAsClosed.restart()
            onAboutToShow:
                PQCNotify.addToWhichContextMenusOpen("quickactions") // qmllint disable unqualified

            Timer {
                id: recordAsClosed
                interval: 200
                onTriggered: {
                    if(!themenu.visible)
                        PQCNotify.removeFromWhichContextMenusOpen("quickactions") // qmllint disable unqualified
                }
            }
        }

    }

    Component.onCompleted: {
        if(popout || forcePopout) {
            quickactions_top.state = "popout"
        } else {
            quickactions_top.state = ""
            quickactions_top.reposition()
        }

        recordFinishedSetup.restart()
    }

    Timer {
        id: recordFinishedSetup
        interval: 500
        onTriggered:
            quickactions_top.finishedSetup = true
    }

    onRightClicked: (mouse) => {
        if(!popoutWindowUsed)
            menu.item.popup() // qmllint disable missing-property
    }

    Connections {

        target: PQCSettings // qmllint disable unqualified

        function onInterfaceQuickActionsChanged() {
            if(PQCSettings.extensionsQuickActions) // qmllint disable unqualified
                quickactions_top.show()
            else
                quickactions_top.hide()
        }

        function onInterfaceEdgeTopActionChanged() {
            quickactions_top.reposition()
        }

    }

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onCloseAllContextMenus() {
            menu.item.dismiss() // qmllint disable missing-property
        }

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(what === "show" && args[0] === "quickactions") {
                if(quickactions_top.visible)
                    quickactions_top.hide()
                else
                    quickactions_top.show()
            }
        }

    }

    Connections {

        target: PQCConstants // qmllint disable unqualified

        function onWindowWidthChanged() {
            if(!quickactions_top.finishedSetup) return
            quickactions_top.x = Math.min(PQCConstants.windowHeight-quickactions_top.width, Math.max(0, quickactions_top.x))
        }

        function onWindowHeightChanged() {
            if(!quickactions_top.finishedSetup) return
            quickactions_top.y = Math.min(PQCConstants.windowWidth-quickactions_top.height, Math.max(0, quickactions_top.y))
        }

    }

    function reposition() {
        finishedSetup = false
        if(popoutWindowUsed) {
            ele_window.minimumWidth = width
            ele_window.minimumHeight = height
            ele_window.maximumWidth = width
            ele_window.maximumHeight = height
        } else {
            x = Qt.binding(function() { return (PQCConstants.windowWidth-quickactions_top.width)/2 })
            if(PQCSettings.interfaceEdgeTopAction === "thumbnails")
                y = Qt.binding(function() { return PQCConstants.windowHeight-quickactions_top.height-20 })
            else
                y = 20
        }
        recordFinishedSetup.restart()
    }

    function show() {
        PQCSettings.extensionsQuickActions = true // qmllint disable unqualified
        opacity = Qt.binding(
                    function() {
                        return popoutWindowUsed ?
                                    1 :
                                    (mouseOver||dragActive||closeMouseArea.containsMouse||
                                     popinMouseArea.containsMouse||menu.item.visible ? 0.8 : 0.2)
                    })
        if(popoutWindowUsed) {
            quickactions_popout.visible = true
            ele_window.minimumWidth = width
            ele_window.minimumHeight = height
            ele_window.maximumWidth = width
            ele_window.maximumHeight = height
        }
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            quickactions_popout.visible = false // qmllint disable unqualified
        PQCSettings.extensionsQuickActions = false
    }

}
