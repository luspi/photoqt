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
import PhotoQt
import ExtensionSettings
import PQCExtensionsHandler

Window {

    id: element_top

    title: "Popout"

    ///////////////////

    // set in extension container
    property string extensionId
    property ExtensionSettings settings

    ///////////////////

    property bool _fixSizeToContent: PQCExtensionsHandler.getExtensionPopoutFixSizeToContent(extensionId)

    property point defaultPopoutPosition: Qt.point(150,150)
    property size defaultPopoutSize: Qt.size(500,300)

    ///////////////////

    SystemPalette { id: pqtPalette }

    width: 100
    height: 100

    Component.onCompleted: {

        var pos = settings["ExtPopoutPosition"]
        var sze = settings["ExtPopoutSize"]

        if(pos === undefined || pos.x === -1) pos = defaultPopoutPosition

        if(sze === undefined || sze.width < 1)
            sze = PQCExtensionsHandler.getExtensionPopoutDefaultSize(element_top.extensionId)

        element_top.setX(pos.x)
        element_top.setY(pos.y)

        if(!_fixSizeToContent) {
            element_top.setWidth(sze.width)
            element_top.setHeight(sze.height)
        }

        if(settings["ExtShow"]) {
            show()
            popout_loader.item.showing()
        }

        setupCompleted.restart()

    }

    property bool setupHasBeenCompleted: false
    Timer {
        id: setupCompleted
        interval: 300
        onTriggered:
            element_top.setupHasBeenCompleted = true
    }

    minimumWidth: 100
    minimumHeight: 100

    modality: PQCExtensionsHandler.getExtensionModalMake(extensionId) ? Qt.ApplicationModal : Qt.NonModal

    visible: false
    flags: Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint

    color: "transparent"

    Rectangle {
        width: parent.width
        height: parent.height
        color: pqtPalette.base
        opacity: 0.8
    }

    onXChanged:
        updateGeometry.restart()
    onYChanged:
        updateGeometry.restart()
    onWidthChanged: {
        updateGeometry.restart()
    }
    onHeightChanged: {
        updateGeometry.restart()
    }

    Loader {
        id: popout_loader
        source: "file:/" + PQCExtensionsHandler.getExtensionLocation(element_top.extensionId) + "/qml/PQ" + element_top.extensionId + ".qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                if(!element_top._fixSizeToContent) {
                    item.width = Qt.binding(function() { return element_top.width })
                    item.height = Qt.binding(function() { return element_top.height })
                }
                element_top.visible = true
                if(element_top._fixSizeToContent) {
                    element_top.minimumWidth = Qt.binding(function() { return item.width })
                    element_top.maximumWidth = Qt.binding(function() { return item.width })
                    element_top.minimumHeight = Qt.binding(function() { return item.height })
                    element_top.maximumHeight = Qt.binding(function() { return item.height })
                }
            }
    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        enabled: !PQCExtensionsHandler.getExtensionLetMeHandleMouseEvents(element_top.extensionId)
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                popout_loader.item.rightClicked(mouse)
            else
                popout_loader.item.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    Timer {
        id: updateGeometry
        interval: 200
        repeat: false
        onTriggered: {
            if(element_top.visibility !== Window.Maximized) {
                element_top.settings["ExtPopoutPosition"] = Qt.point(element_top.x, element_top.y)
                element_top.settings["ExtPopoutSize"] = Qt.size(element_top.width, element_top.height)
            }
        }
    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        // visible: ele_window.setCanBePoppedOut
        enabled: visible
        z: 1
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 0.8 : 0.1
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
                  //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
            text: qsTranslate("popinpopout", "Merge into main interface")
            onClicked: {
                element_top.settings["ExtPopout"] = false
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 2
            z: -1
            color: pqtPalette.base
            opacity: parent.opacity*0.8
        }
    }

    Row {

        x: parent.width-additionalActionItem.width-closeimage.width-5
        y: 5

        visible: !PQCExtensionsHandler.getExtensionModalMake(element_top.extensionId)

        Item {
            id: additionalActionItem
            width: 25
            height: 25
        }

        Image {

            id: closeimage
            width: 25
            height: 25

            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
            sourceSize: Qt.size(width, height)

            opacity: closemouse.containsMouse ? 0.8 : 0.1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQMouseArea {
                id: closemouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    element_top.close()
                    popout_loader.item.hiding()
                }
            }

            Rectangle {
                anchors.fill: closeimage
                radius: width/2
                z: -1
                color: pqtPalette.base
                opacity: closeimage.opacity*0.8
            }

        }

    }

    Connections {

        target: element_top.settings

        enabled: element_top.setupHasBeenCompleted

        function onValueChanged(key : string, value : var) {
            if(key.toLowerCase() === element_top.extensionId) {
                if(1*value) {
                    element_top.show()
                    popout_loader.item.showing()
                } else {
                    element_top.close()
                    popout_loader.item.hiding()
                }
            }
        }

    }

    Connections {

        target: PQCNotify

        enabled: element_top.setupHasBeenCompleted

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === element_top.extensionId) {
                if(element_top.visible) {
                    element_top.hide()
                } else {
                    element_top.show()
                }
            }
        }
    }

    onVisibleChanged: {
        if(!visible) {
            if(!popout_loader.item.hiding()) {
                visible = true
                return
            }
            settings["ExtShow"] = false
            PQCSettings.generalSetupFloatingExtensionsAtStartup = PQCSettings.generalSetupFloatingExtensionsAtStartup.filter(function(entry) { return entry !== extensionId; });

        } else {
            if(!popout_loader.item.showing()) {
                visible = false
                return
            }
            settings["ExtShow"] = true
            if(!PQCSettings.generalSetupFloatingExtensionsAtStartup.includes(extensionId))
                PQCSettings.generalSetupFloatingExtensionsAtStartup.push(extensionId)
        }

    }

    onClosing: {
        hide()
    }

    function hide() {
        element_top.close()
    }

    function handleChangesBottomRowWidth(w : int) {
        element_top.minimumWidth = Math.max(element_top.minimumWidth, w)
    }

}
