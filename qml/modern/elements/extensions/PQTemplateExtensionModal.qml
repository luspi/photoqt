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
import PhotoQt
import ExtensionSettings
import PQCExtensionsHandler
import PQCScriptsConfig

Rectangle {

    id: element_top

    // set in extension container
    property string extensionId
    property ExtensionSettings settings

    /********************/

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0
    enabled: visible

    width: PQCConstants.windowWidth
    height: PQCConstants.windowHeight
    color: PQCLook.baseColorAccent

    PQMouseArea {
        id: mouseareaBG
        anchors.fill: parent
        hoverEnabled: true
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
            id: fullscreen_loader
            source: "file:/" +  PQCExtensionsHandler.getExtensionLocation(element_top.extensionId) + "/qml/PQ" + element_top.extensionId + ".qml"
        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: PQCLook.baseColor // qmllint disable unqualified

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive // qmllint disable unqualified
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
                text: genericStringClose
                font.weight: PQCLook.fontWeightBold
                y: 1
                height: parent.height-1
                onClicked: element_top.hide()
            }

            PQButtonElement {
                id: secondbutton
                text: genericStringClose
                visible: false
                y: 1
                height: parent.height-1
            }

            PQButtonElement {
                id: thirdbutton
                text: genericStringClose
                visible: false
                y: 1
                height: parent.height-1
            }

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: PQCExtensionsHandler.getExtensionAllowPopout(element_top.extensionId)
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
                settings["ExtPopout"] = true
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

        target: PQCNotify // qmllint disable unqualified

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

    function show() {
        PQCNotify.loaderRegisterOpen(element_top.extensionId)
        opacity = 1
        settings["ExtShow"] = true
        fullscreen_loader.item.showing()
    }

    function hide() {
        PQCNotify.loaderRegisterClose(element_top.extensionId)
        opacity = 0
        settings["ExtShow"] = false
        fullscreen_loader.item.hiding()
    }

}
