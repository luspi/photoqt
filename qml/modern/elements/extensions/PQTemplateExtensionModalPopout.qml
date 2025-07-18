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

    property size defaultPopoutPosition: Qt.point(150,150)
    property size defaultPopoutSize: Qt.size(500,300)

    ///////////////////

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

        element_top.setWidth(sze.width)
        element_top.setHeight(sze.height)

        if(settings["ExtShow"]) {
            element_top._show()
        }

        setupCompleted.restart()

    }

    onClosing: {
        element_top.hide()
    }

    property bool setupHasBeenCompleted: false
    Timer {
        id: setupCompleted
        interval: 300
        onTriggered:
            element_top.setupHasBeenCompleted = true
    }

    minimumWidth: 300
    minimumHeight: 500

    modality: PQCExtensionsHandler.getExtensionModalMake(extensionId) ? Qt.ApplicationModal : Qt.NonModal

    visible: false
    flags: Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint

    color: PQCLook.transColor

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

    Rectangle {

        id: toprow

        width: parent.width
        height: parent.height>500 ? 75 : Math.max(75-(500-parent.height), 50)
        color: PQCLook.baseColor

        PQTextXL {
            anchors.centerIn: parent
            text: PQCExtensionsHandler.getExtensionName(element_top.extensionId)
            font.weight: PQCLook.fontWeightBold
        }

        Rectangle {
            x: 0
            y: parent.height-1
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive
        }

    }

    Item {

        y: toprow.height
        width: parent.width
        height: parent.height-toprow.height-bottomrow.height

        Loader {
            id: popout_loader
            source: "file:/" + PQCExtensionsHandler.getExtensionLocation(element_top.extensionId) + "/qml/PQ" + element_top.extensionId + ".qml"
        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: PQCLook.baseColor

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive
        }

        Item {
            id: bottomleftelement
            x: 0
            y: 0
            height: parent.height
        }

        Row {

            x: (parent.width-width)/2

            height: parent.height

            spacing: 0            

            PQButtonElement {
                id: firstbutton
                text: popout_loader.status===Loader.Ready ? popout_loader.item.modalButton1Text : genericStringClose
                font.weight: PQCLook.fontWeightBold
                y: 1
                height: parent.height-1
                onClicked: {
                    if(popout_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        popout_loader.item.modalButton1Action()
                }
            }

            PQButtonElement {
                id: secondbutton
                text: popout_loader.status===Loader.Ready ? popout_loader.item.modalButton2Text : ""
                visible: text!==""
                y: 1
                height: parent.height-1
                onClicked: {
                    if(popout_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        popout_loader.item.modalButton2Action()
                }
            }

            PQButtonElement {
                id: thirdbutton
                text: popout_loader.status===Loader.Ready ? popout_loader.item.modalButton3Text : ""
                visible: text!==""
                y: 1
                height: parent.height-1
                onClicked: {
                    if(popout_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        popout_loader.item.modalButton3Action()
                }
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
        visible: !element_top.settings["ExtForcePopout"] && PQCExtensionsHandler.getExtensionIntegratedAllow(element_top.extensionId)
        enabled: visible
        z: 1
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 0.8 : 0.2
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
                PQCNotifyQML.loaderRegisterClose(element_top.extensionId)
                PQCNotifyQML.loaderShowExtension(element_top.extensionId)
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 2
            z: -1
            color: PQCLook.transColor
            opacity: parent.opacity
        }
    }

    Connections {

        target: element_top.settings

        enabled: element_top.setupHasBeenCompleted

        function onValueChanged(key, value) {
            if(key.toLowerCase() === extensionId) {
                if(1*value) {
                    element_top._show()
                } else {
                    element_top.hide()
                }
            }
        }

    }

    Connections {

        target: PQCNotifyQML

        enabled: element_top.setupHasBeenCompleted

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === element_top.extensionId) {
                if(element_top.visible) {
                    element_top.hide()
                } else {
                    element_top._show()
                }
            } else if(element_top.visible) {
                if(what === "keyEvent") {
                    if(args[0] === Qt.Key_Escape) {
                        element_top.hide()
                    }
                }
            }
        }
    }

    function _show() {

        settings["ExtShow"] = true

        if(settings["ExtForcePopout"]) {
            var minsize = PQCExtensionsHandler.getExtensionIntegratedMinimumRequiredWindowSize(extensionId)
            if(PQCConstants.windowWidth > minsize.width && PQCConstants.windowHeight > minsize.height) {
                PQCNotifyQML.loaderRegisterClose(extensionId)
                settings["ExtForcePopout"] = false
                settings["ExtPopout"] = false
                PQCNotifyQML.loaderShowExtension(extensionId)
                return
            }
        }

        PQCNotifyQML.loaderRegisterOpen(element_top.extensionId)
        show()
        popout_loader.item.showing()
    }

    function hide() {
        PQCNotifyQML.loaderRegisterClose(element_top.extensionId)
        settings["ExtShow"] = false
        element_top.close()
        popout_loader.item.hiding()
    }

    function handleChangesBottomRowWidth(w) {
        element_top.minimumWidth = Math.max(element_top.minimumWidth, w)
    }

}
