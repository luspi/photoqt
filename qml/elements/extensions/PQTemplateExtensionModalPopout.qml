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
    property string nameId
    property ExtensionSettings settings

    ///////////////////

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

        element_top.setWidth(sze.width)
        element_top.setHeight(sze.height)

        element_top._show()

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

    modality: PQCExtensionsHandler.getExtensionModal(extensionId) ? Qt.ApplicationModal : Qt.NonModal

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

    Rectangle {

        id: toprow

        width: parent.width
        height: parent.height>500 ? 75 : Math.max(75-(500-parent.height), 50)
        color: pqtPalette.base

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
            color: pqtPalette.alternateBase
        }

    }

    Item {

        id: loader_wrapper
        y: toprow.height
        width: parent.width
        height: parent.height-toprow.height-bottomrow.height

        Loader {
            id: popout_loader
            anchors.fill: loader_wrapper
            source: "file:/" + PQCExtensionsHandler.getExtensionLocation(element_top.extensionId) + "/qml/" + element_top.nameId + ".qml"
        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: pqtPalette.base

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: pqtPalette.alternateBase
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

            spacing: 10

            PQButtonElement {
                id: firstbutton
                text: popout_loader.status===Loader.Ready ? popout_loader.item.modalButton1Text : genericStringClose
                font.weight: PQCLook.fontWeightBold
                y: 8
                height: parent.height-14
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
                y: 8
                height: parent.height-14
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
                y: 8
                height: parent.height-14
                onClicked: {
                    if(popout_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        popout_loader.item.modalButton3Action()
                }
            }

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
        visible: !element_top.settings["ExtForcePopout"] && PQCExtensionsHandler.getExtensionIntegratedAllow(element_top.extensionId) && PQCSettings.generalInterfaceVariant==="modern"
        enabled: visible
        z: 1
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 0.8 : 0.2
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
                  //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
            text: qsTranslate("popinpopout", "Merge into main interface")
            onClicked: {
                element_top.settings["ExtPopout"] = false
                PQCNotify.loaderRegisterClose(element_top.extensionId)
                PQCNotify.loaderShowExtension(element_top.extensionId)
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

    Connections {

        target: element_top.settings

        enabled: element_top.setupHasBeenCompleted

        function onValueChanged(key : string, value : var) {
            if(key === element_top.extensionId) {
                if(1*value) {
                    element_top._show()
                } else {
                    element_top.hide()
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

        var ret = popout_loader.item.showing()
        if(ret !== undefined && !ret) {
            PQCNotify.loaderRegisterClose(element_top.extensionId)
            return
        }

        settings["ExtShow"] = true

        if(settings["ExtForcePopout"]) {
            var minsize = PQCExtensionsHandler.getExtensionIntegratedMinimumRequiredWindowSize(extensionId)
            if(PQCConstants.availableWidth > minsize.width && PQCConstants.availableHeight > minsize.height) {
                PQCNotify.loaderRegisterClose(extensionId)
                settings["ExtForcePopout"] = false
                settings["ExtPopout"] = false
                PQCNotify.loaderShowExtension(extensionId)
                return
            }
        }

        PQCNotify.loaderRegisterOpen(element_top.extensionId)
        show()
    }

    function hide() {
        var ret = popout_loader.item.hiding()
        if(ret !== undefined && !ret)
            return
        PQCNotify.loaderRegisterClose(element_top.extensionId)
        settings["ExtShow"] = false
        element_top.close()
    }

    function handleChangesBottomRowWidth(w : int) {
        element_top.minimumWidth = Math.max(element_top.minimumWidth, w)
    }

}
