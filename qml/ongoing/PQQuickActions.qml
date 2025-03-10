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

import "../elements"
import "../"

PQTemplateFloating {

    id: quickactions_top

    width: contentitem.width
    height: contentitem.height

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

    // popout: PQCSettings.interfacePopoutHistogram // qmllint disable unqualified
    // forcePopout: PQCWindowGeometry.histogramForcePopout // qmllint disable unqualified
    shortcut: "__quickActions"
    tooltip: qsTranslate("quickactions", "Click-and-drag to move.")
    blur_thisis: "quickactions"
    showMainMouseArea: false
    showBGMouseArea: true
    contentPadding: 5
    allowResize: false
    moveButtonsOutside: true

    onPopoutChanged: {
        // if(popout !== PQCSettings.interfacePopoutHistogram) // qmllint disable unqualified
            // PQCSettings.interfacePopoutHistogram = popout
    }

    property list<string> buttons: [
        "rename",
        "copy",
        "move",
        "delete",
        "|",
        "rotateleft",
        "rotateright",
        "mirrorhor",
        "mirrorver",
        "|",
        "crop",
        "scale",
        "tagfaces",
        "|",
        "clipboard",
        "export",
        "wallpaper",
        "qr",
        "|",
        "close",
        "quitt"
    ]

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
    onMapkeysChanged:
    console.warn()

    content: [

        Item {

            id: contentitem

            property string orientation: "vertical"
            width: (orientation=="horizontal" ? contentrow.width : contentcol.width)+10
            height: (orientation=="horizontal" ? contentrow.height : contentcol.height)+10

            Column {

                id: contentcol

                width: childrenRect.width
                spacing: 5

                Repeater {

                    model: contentitem.orientation=="vertical" ? quickactions_top.buttons.length : 0

                    Item {

                        id: delegver

                        required property int modelData
                        property string cat: quickactions_top.buttons[modelData]

                        property list<var> props: (delegver.cat in quickactions_top.mappings ?
                                                       quickactions_top.mappings[delegver.cat] :
                                                       ["?", "?", "?", "?"])

                        width: childrenRect.width
                        height: childrenRect.height

                        Rectangle {
                            id: sepver
                            visible: delegver.props[0]==="|"
                            width: 40
                            height: 4
                            color: PQCLook.baseColorHighlight
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
                        }

                        PQButtonIcon {
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
                        }

                    }

                }

            }

            Row {

                id: contentrow

                height: childrenRect.height
                spacing: 5

                Repeater {

                    model: contentitem.orientation=="horizontal" ? quickactions_top.buttons.length : 0

                    Item {

                        id: deleghor

                        required property int modelData
                        property string cat: quickactions_top.buttons[modelData]

                        property list<var> props: (deleghor.cat in quickactions_top.mappings ?
                                                       quickactions_top.mappings[deleghor.cat] :
                                                       ["?", "?", "?", "?"])

                        width: childrenRect.width
                        height: childrenRect.height

                        Rectangle {
                            id: sephor
                            visible: deleghor.props[0]==="|"
                            width: 4
                            height: 40
                            color: PQCLook.baseColorHighlight
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
                        }

                        PQButtonIcon {
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
                        }

                    }

                }

            }

        }

    ]

    Component.onCompleted: {
        if(popout || forcePopout) {
            quickactions_top.state = "popout"
        } else {
            quickactions_top.state = ""
            // x = PQCSettings.histogramPosition.x // qmllint disable unqualified
            // y = PQCSettings.histogramPosition.y
            // width = PQCSettings.histogramSize.width
            // height = PQCSettings.histogramSize.height
            x = 200
            y = 200
        }

        // if(PQCSettings.histogramVisible)
        show()
    }

    onRightClicked: (mouse) => {
        // menu.item.popup() // qmllint disable missing-property
    }

    Connections {
        target: loader // qmllint disable unqualified

        function onPassOn(what : string, param : string) {

            if(what === "show") {
                if(param === "quickactions") {
                    if(quickactions_top.visible) {
                        quickactions_top.hide()
                    } else {
                        quickactions_top.show()
                    }
                }
            }

        }

    }

    // Connections {

    //     target: PQCSettings // qmllint disable unqualified

    //     function onHistogramVisibleChanged() {
    //         if(PQCSettings.histogramVisible) // qmllint disable unqualified
    //             quickactions_top.show()
    //         else
    //             quickactions_top.hide()
    //     }

    // }

    // Connections {
    //     target: PQCNotify // qmllint disable unqualified

    //     function onCloseAllContextMenus() {
    //         menu.item.dismiss() // qmllint disable missing-property
    //     }

    // }

    function show() {
        opacity = 1
        // PQCSettings.histogramVisible = true // qmllint disable unqualified
        // if(popoutWindowUsed)
            // histogram_popout.visible = true
    }

    function hide() {
        opacity = 0
        // if(popoutWindowUsed)
            // histogram_popout.visible = false // qmllint disable unqualified
        // PQCSettings.histogramVisible = false
    }

}
