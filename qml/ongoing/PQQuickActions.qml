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
import PQCNotify
import PQCFileFolderModel
import PQCScriptsConfig
import PQCWindowGeometry

import "../elements"
import "../"

PQTemplateFloating {

    id: quickactions_top

    width: contentitem.width
    height: contentitem.height

    opacity: mouseOver||dragActive||closeMouseArea.containsMouse||popinMouseArea.containsMouse ? 1 : 0.2
    Behavior on opacity { NumberAnimation { duration: 200 } }

    color: PQCLook.baseColor

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

    onXChanged: {
        if(!toplevel.startup && finishedSetup)
            storePos.restart()
    }
    onYChanged: {
        if(!toplevel.startup && finishedSetup)
            storePos.restart()
    }

    Timer {
        id: storePos
        interval: 200
        onTriggered: {
            PQCSettings.interfaceQuickActionsPosition.x = quickactions_top.x // qmllint disable unqualified
            PQCSettings.interfaceQuickActionsPosition.y = quickactions_top.y
        }
    }

    // states: [
    //     State {
    //         name: "popout"
    //         PropertyChanges {
    //             quickactions_top.x: 0
    //             quickactions_top.y: 0
    //             quickactions_top.width: quickactions_top.parentWidth
    //             quickactions_top.height: quickactions_top.parentHeight
    //         }
    //     }
    // ]

    PQShadowEffect { masterItem: quickactions_top }

    popout: PQCSettings.interfacePopoutQuickActions // qmllint disable unqualified
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
        if(popout !== PQCSettings.interfacePopoutQuickActions) // qmllint disable unqualified
            PQCSettings.interfacePopoutQuickActions = popout
    }

    property list<string> buttons: PQCSettings.interfaceQuickActionsItems

    // 4 values: tooltip, icon name, shortcut action, enabled with no file loaded
    property var mappings: {
        "|" : ["|", "|", "|", "|"],
        "rename" :      [qsTranslate("quickactions", "Rename file"),                "rename",         "__rename",         false],
        "copy"   :      [qsTranslate("quickactions", "Copy file"),                  "copy",           "__copy",           false],
        "move"   :      [qsTranslate("quickactions", "Move file"),                  "move",           "__move",           false],
        "delete" :      [qsTranslate("quickactions", "Delete file"),                "delete",         "__deleteTrash",    false],
        "rotateleft" :  [qsTranslate("quickactions", "Rotate left"),                "rotateleft",     "__rotateL",        false],
        "rotateright" : [qsTranslate("quickactions", "Rotate right"),               "rotateright",    "__rotateR",        false],
        "mirrorhor" :   [qsTranslate("quickactions", "Mirror horizontally"),        "leftrightarrow", "__flipH",          false],
        "mirrorver" :   [qsTranslate("quickactions", "Mirror vertically"),          "updownarrow",    "__flipV",          false],
        "crop" :        [qsTranslate("quickactions", "Crop image"),                 "crop",           "__crop",           false],
        "scale" :       [qsTranslate("quickactions", "Scale image"),                "scale",          "__scale",          false],
        "tagfaces" :    [qsTranslate("quickactions", "Tag faces"),                  "faces",          "__tagFaces",       false],
        "clipboard" :   [qsTranslate("quickactions", "Copy to clipboard"),          "clipboard",      "__clipboard",      false],
        "export" :      [qsTranslate("quickactions", "Export to different format"), "convert",        "__export",         false],
        "wallpaper" :   [qsTranslate("quickactions", "Set as wallpaper"),           "wallpaper",      "__wallpaper",      false],
        "qr" :          [(PQCNotify.barcodeDisplayed ?
                              qsTranslate("quickactions", "Hide QR/barcodes") :
                              qsTranslate("quickactions", "Detect QR/barcodes")),   "qrcode",         "__detectBarCodes", false],
        "close" :       [qsTranslate("quickactions", "Close window"),               "quit",           "__close",          true],
        "quit" :        [qsTranslate("quickactions", "Quit"),                       "quit",           "__quit",           true],
    }

    property list<string> mapkeys: ["|", "rename", "copy", "move", "delete", "rotateleft",
                                     "rotateright", "mirrorhor", "mirrorver", "crop", "scale",
                                     "tagfaces", "clipboard", "export", "wallpaper", "qr", "close", "quit"]

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
                            width: 40
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
                            width: 40
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
                            width: visible ? 40 : 0
                            height: visible ? 40 : 0
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
                            width: sepver.visible ? 0 : 40
                            height: sepver.visible ? 0 : 40
                            visible: !sepver.visible && !unknownver.visible
                            enabled: visible && (delegver.props[3] || PQCFileFolderModel.countMainView>0)
                            tooltip: enabled ? delegver.props[0] : qsTranslate("quickactions", "No file loaded")
                            dragTarget: quickactions_top
                            source: visible ? ("image://svg/:/" + PQCLook.iconShade + "/" + delegver.props[1] + ".svg") : ""
                            onClicked: {
                                PQCNotify.executeInternalCommand(delegver.props[2])
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
                            width: 40
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
                            height: 40
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
                            height: 40
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
                            width: visible ? 40 : 0
                            height: visible ? 40 : 0
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
                            width: sephor.visible ? 0 : 40
                            height: sephor.visible ? 0 : 40
                            visible: !sephor.visible && !unknownhor.visible
                            enabled: visible && (deleghor.props[3] || PQCFileFolderModel.countMainView>0)
                            tooltip: enabled ? deleghor.props[0] : qsTranslate("quickactions", "No file loaded")
                            dragTarget: quickactions_top
                            source: visible ? ("image://svg/:/" + PQCLook.iconShade + "/" + deleghor.props[1] + ".svg") : ""
                            onClicked: {
                                PQCNotify.executeInternalCommand(deleghor.props[2])
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
                            height: 40
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
                checked: PQCSettings.interfaceQuickActions // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.interfaceQuickActions = checked // qmllint disable unqualified
                    if(!checked)
                        themenu.dismiss()
                }
            }

            PQMenuItem {
                text: qsTranslate("MainMenu", "Reset position to default")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg" // qmllint disable unqualified
                onTriggered: {
                    PQCScriptsConfig.setDefaultSettingValueFor("interfaceQuickActionsPosition") // qmllint disable unqualified
                    quickactions_top.reposition()
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                text: qsTranslate("settingsmanager", "Manage in settings manager")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg" // qmllint disable unqualified
                onTriggered: {
                    loader.ensureItIsReady("settingsmanager", loader.loadermapping["settingsmanager"]) // qmllint disable unqualified
                    loader.passOn("showSettings", "quickactions")
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

        if(PQCSettings.interfaceQuickActions)
            show()

        recordFinishedSetup.restart()
    }

    Timer {
        id: recordFinishedSetup
        interval: 500
        onTriggered:
            quickactions_top.finishedSetup = true
    }

    onRightClicked: (mouse) => {
        menu.item.popup() // qmllint disable missing-property
    }

    Connections {
        target: loader // qmllint disable unqualified

        function onPassOn(what : string, param : string) {

            if(what === "show") {
                if(param === "quickactions") {
                    quickactions_top.show()
                }
            }

        }

    }

    Connections {

        target: PQCSettings // qmllint disable unqualified

        function onInterfaceQuickActionsChanged() {
            if(PQCSettings.interfaceQuickActions) // qmllint disable unqualified
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

    }

    function reposition() {
        finishedSetup = false
        var tmppos = PQCSettings.interfaceQuickActionsPosition // qmllint disable unqualified
        if(tmppos.x === -1)
            x = Qt.binding(function() { return (toplevel.width-quickactions_top.width)/2 })
        else
            x = tmppos.x
        if(tmppos.y === -1) {
            if(PQCSettings.interfaceEdgeTopAction === "thumbnails")
                y = Qt.binding(function() { return toplevel.height-quickactions_top.height-20 })
            else
                y = Qt.binding(function() { return 20 })
        } else
            y = tmppos.y
        recordFinishedSetup.restart()
    }

    function show() {
        PQCSettings.interfaceQuickActions = true // qmllint disable unqualified
        opacity = Qt.binding(function() { return (mouseOver||dragActive||closeMouseArea.containsMouse||popinMouseArea.containsMouse ? 1 : 0.2) })
        // if(popoutWindowUsed)
            // histogram_popout.visible = true
    }

    function hide() {
        opacity = 0
        // if(popoutWindowUsed)
            // histogram_popout.visible = false // qmllint disable unqualified
        PQCSettings.interfaceQuickActions = false
    }

}
