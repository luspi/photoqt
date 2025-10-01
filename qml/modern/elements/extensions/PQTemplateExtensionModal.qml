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
import PhotoQt.Shared
import PhotoQt.Modern
import ExtensionSettings
import PQCExtensionsHandler

Rectangle {

    id: element_top

    // set in extension container
    property string extensionId
    property ExtensionSettings settings

    /********************/

    SystemPalette { id: pqtPalette }

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0
    enabled: visible

    width: PQCConstants.windowWidth
    height: PQCConstants.windowHeight
    color: pqtPalette.alternateBase

    PQMouseArea {
        id: mouseareaBG
        anchors.fill: parent
        hoverEnabled: true
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

        y: toprow.height
        width: parent.width
        height: parent.height-toprow.height-bottomrow.height

        Loader {
            id: fullscreen_loader
            source: "file:/" +  PQCExtensionsHandler.getExtensionLocation(element_top.extensionId) + "/qml/PQ" + element_top.extensionId + ".qml"
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

            spacing: 0

            PQButtonElement {
                id: firstbutton
                text: fullscreen_loader.status===Loader.Ready ? fullscreen_loader.item.modalButton1Text : genericStringClose
                font.weight: PQCLook.fontWeightBold
                y: 1
                height: parent.height-1
                onClicked: {
                    if(fullscreen_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        fullscreen_loader.item.modalButton1Action()
                }
            }

            PQButtonElement {
                id: secondbutton
                text: fullscreen_loader.status===Loader.Ready ? fullscreen_loader.item.modalButton2Text : ""
                visible: text!==""
                y: 1
                height: parent.height-1
                onClicked: {
                    if(fullscreen_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        fullscreen_loader.item.modalButton2Action()
                }
            }

            PQButtonElement {
                id: thirdbutton
                text: fullscreen_loader.status===Loader.Ready ? fullscreen_loader.item.modalButton3Text : ""
                visible: text!==""
                y: 1
                height: parent.height-1
                onClicked: {
                    if(fullscreen_loader.status !== Loader.Ready)
                        element_top.hide()
                    else
                        fullscreen_loader.item.modalButton3Action()
                }
            }

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: PQCExtensionsHandler.getExtensionPopoutAllow(element_top.extensionId)
        enabled: visible
        z: 1
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
                  //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
            text: qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                element_top.settings["ExtPopout"] = true
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

    Component.onCompleted: {

        if(extensionId == "") {
            PQCScriptsConfig.inform("Faulty extension!", "An extension was added that is missing its extension id! This is bad and needs to be fixed!")
            return
        }

        if(settings["ExtShow"]) {
            show()
        }

    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === element_top.extensionId) {
                if(element_top.visible) {
                    element_top.hide()
                } else {
                    element_top.show()
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

    function show() {

        settings["ExtShow"] = true

        var minsize = PQCExtensionsHandler.getExtensionIntegratedMinimumRequiredWindowSize(extensionId)
        if(PQCConstants.windowWidth < minsize.width || PQCConstants.windowHeight < minsize.height) {
            PQCNotify.loaderRegisterClose(extensionId)
            settings["ExtForcePopout"] = true
            settings["ExtPopout"] = true
            return
        } else {
            settings["ExtForcePopout"] = false
            settings["ExtPopout"] = false
        }

        PQCNotify.loaderRegisterOpen(element_top.extensionId)
        opacity = 1
        fullscreen_loader.item.showing()
    }

    function hide() {
        PQCNotify.loaderRegisterClose(element_top.extensionId)
        opacity = 0
        settings["ExtShow"] = false
        fullscreen_loader.item.hiding()
    }

}
