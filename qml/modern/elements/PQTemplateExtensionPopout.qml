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
import QtQuick.Window
import PQCScriptsConfig
import PhotoQt
import PQCExtensionsHandler

Window {

    id: ele_window

    title: "Popout"

    ///////////////////
    // SOME REQUIRED ENTRIES

    property string extensionId: ""
    property alias settings: extsettings

    ///////////////////

    property bool setCanBeResized: true
    property bool setIsModal: false

    property size defaultPopoutPosition: Qt.point(150,150)
    property size defaultPopoutSize: Qt.size(500,300)

    ///////////////////

    ExtensionSettings {
        id: extsettings
        extensionId: ele_window.extensionId
    }

    width: 100
    height: 100

    Component.onCompleted: {

        var pos = settings["PopoutPosition"]
        var sze = settings["PopoutSize"]

        if(pos === undefined || pos.x === -1) pos = defaultPopoutPosition
        if(sze === undefined || sze.width < 1) sze = defaultPopoutSize

        ele_window.setX(pos.x)
        ele_window.setY(pos.y)

        if(setCanBeResized) {
            ele_window.setWidth(sze.width)
            ele_window.setHeight(sze.height)
        }

        if(settings["Show"])
            show()

        setupCompleted.restart()

    }

    property bool setupHasBeenCompleted: false
    Timer {
        id: setupCompleted
        interval: 300
        onTriggered:
            ele_window.setupHasBeenCompleted = true
    }

    minimumWidth: 100
    minimumHeight: 100

    modality: setIsModal ? Qt.ApplicationModal : Qt.NonModal

    visible: false
    flags: Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint

    color: PQCLook.transColor

    onXChanged:
        updateGeometry.restart()
    onYChanged:
        updateGeometry.restart()
    onWidthChanged: {
        updateGeometry.restart()
        // if(!setCanBeResized) {
        //     minimumWidth = width
        //     maximumWidth = width
        // }
    }
    onHeightChanged: {
        updateGeometry.restart()
        // if(!setCanBeResized) {
        //     minimumHeight = height
        //     maximumHeight = height
        // }
    }

    Loader {
        id: curloader
        source: "file:/" + PQCExtensionsHandler.getExtensionLocation(ele_window.extensionId) + "/modern/PQ" + ele_window.extensionId + "Floating.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                if(ele_window.setCanBeResized) {
                    item.width = Qt.binding(function() { return ele_window.width })
                    item.height = Qt.binding(function() { return ele_window.height })
                }
                ele_window.visible = true
                item._popoutOpen = true
                item.show()
                if(!ele_window.setCanBeResized) {
                    ele_window.minimumWidth = Qt.binding(function() { return item.width })
                    ele_window.maximumWidth = Qt.binding(function() { return item.width })
                    ele_window.minimumHeight = Qt.binding(function() { return item.height })
                    ele_window.maximumHeight = Qt.binding(function() { return item.height })
                }
            }
        // Connections {
        //     target: curloader.item
        //     // enabled: curloader.status===Loader.Ready
        //     onWidthChanged: {
        //         ele_window.minimumWidth = width
        //         ele_window.maximumWidth = width
        //     }
        //     onHeightChanged: {
        //         ele_window.minimumHeight = height
        //         ele_window.maximumHeight = height
        //     }
        // }
    }

    Timer {
        id: updateGeometry
        interval: 200
        repeat: false
        onTriggered: {
            if(ele_window.visibility !== Window.Maximized) {
                settings["PopoutPosition"] = Qt.point(ele_window.x, ele_window.y)
                settings["PopoutSize"] = Qt.size(ele_window.width, ele_window.height)
            }
        }
    }

    onVisibleChanged: {
        curloader.item._popoutOpen = visible
    }

    Connections {

        target: settings

        enabled: ele_window.setupHasBeenCompleted

        function onValueChanged(key, value) {
            if(key.toLowerCase() === extensionId) {
                if(1*value) {
                    ele_window.show()
                    curloader.item.show()
                } else {
                    ele_window.close()
                    curloader.item.hide()
                }
            }
        }

    }

    Connections {

        target: PQCNotify // qmllint disable unqualified

        enabled: ele_window.setupHasBeenCompleted

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === ele_window.extensionId) {
                if(ele_window.visible) {
                    ele_window.hide()
                    curloader.item.hide()
                } else {
                    ele_window.show()
                    curloader.item.show()
                }
            }
        }
    }

    function handleChangesBottomRowWidth(w) {
        ele_window.minimumWidth = Math.max(ele_window.minimumWidth, w)
    }

}
