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
import PQCScriptsConfig

Item {

    id: element_top

    // set in extension container
    property string extensionId
    property ExtensionSettings settings

    /********************/

    property bool _dragActive: mousearea.drag.active || mouseareaBG.drag.active
    property bool _finishedSetup: false
    property bool _containsMouse: mousearea.containsMouse || mouseareaBG.containsMouse

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0 && !PQCConstants.slideshowRunning
    enabled: visible

    onXChanged: {
        if(PQCConstants.mainWindowBeingResized)
            return
        if(_dragActive)
            storeSize.restart()
        if(_finishedSetup) {
            element_top.x = element_top.x
            element_top.y = element_top.y
        }
    }
    onYChanged: {
        if(PQCConstants.mainWindowBeingResized)
            return
        if(_dragActive)
            storeSize.restart()
        if(_finishedSetup) {
            element_top.x = element_top.x
            element_top.y = element_top.y
        }
    }
    onWidthChanged: {
        if(PQCConstants.mainWindowBeingResized)
            return
        if(_dragActive)
            storeSize.restart()
    }
    onHeightChanged: {
        if(PQCConstants.mainWindowBeingResized)
            return
        if(_dragActive)
            storeSize.restart()
    }

    Timer {
        id: storeSize
        interval: 200
        onTriggered: {
            if(PQCExtensionsHandler.getExtensionRememberGeometry(element_top.extensionId)) {
                settings["ExtPosition"] = Qt.point(element_top.x, element_top.y)
                settings["ExtSize"] = Qt.size(element_top.width, element_top.height)
            }
        }
    }

    PQShadowEffect { masterItem: element_top }

    PQMouseArea {
        id: mouseareaBG
        anchors.fill: parent
        hoverEnabled: true
        enabled: !PQCExtensionsHandler.getExtensionLetMeHandleMouseEvents(element_top.extensionId)
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: parent
        text: qsTr("Click-and-drag to move.")
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                floating_loader.item.rightClicked(mouse)
            else
                floating_loader.item.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    Loader {
        id: floating_loader
        source: "file:/" +  PQCExtensionsHandler.getExtensionLocation(element_top.extensionId) + "/qml/PQ" + element_top.extensionId + ".qml"
    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !PQCExtensionsHandler.getExtensionLetMeHandleMouseEvents(element_top.extensionId)
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: parent
        text: qsTr("Click-and-drag to move.")
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                floating_loader.item.rightClicked(mouse)
            else
                floating_loader.item.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    PQMouseArea {

        id: resizearea

        enabled: !PQCExtensionsHandler.getExtensionIntegratedFixSizeToContent(element_top.extensionId)

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: enabled ? Qt.SizeFDiagCursor : Qt.ArrowCursor

        onPositionChanged: (mouse) => {
            if(pressed) {
                element_top.width += (mouse.x-resizearea.width)
                element_top.height += (mouse.y-resizearea.height)
                if(element_top.width < 100)
                    element_top.width = 100
                if(element_top.height < 100)
                    element_top.height = 100
            }
        }

    }

    Image {
        x: 5-width
        y: 5-height
        width: 15
        height: 15
        visible: PQCExtensionsHandler.getExtensionPopoutAllow(element_top.extensionId)
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
                  //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
            text: qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                settings["ExtPopout"] = true
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 4
            z: -1
            color: PQCLook.transColor
            opacity: parent.opacity
        }
    }

    Row {

        x: parent.width-additionalActionItem.width-10
        y: 10-height

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
                onClicked:
                    element_top.hide()
            }

            Rectangle {
                anchors.fill: closeimage
                radius: width/2
                z: -1
                color: PQCLook.transColor
                opacity: closeimage.opacity
            }

        }

    }

    Component.onCompleted: {

        if(extensionId == "") {
            PQCScriptsConfig.inform("Faulty extension!", "An extension was added that is missing its extension id! This is bad and needs to be fixed!")
            return
        }

        resetPositionAndSize()

        if(PQCExtensionsHandler.getExtensionRememberGeometry(extensionId)) {

            var pos = settings["ExtPosition"]
            if(pos !== undefined && pos.x !== -1) {
                x = pos.x
                y = pos.y
            }

            var sze = settings["ExtSize"]
            if(sze !== undefined && sze.width !== -1) {
                width = sze.width
                height = sze.height
            }

        }

        if(settings["ExtShow"])
            show()

        _recordFinishedSetup.restart()

    }

    Timer {
        id: _recordFinishedSetup
        interval: 500
        onTriggered:
            element_top._finishedSetup = true
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

    Connections {

        target: PQCExtensionsHandler

        function onRequestResetGeometry(id : string) {
            if(id === element_top.extensionId) {
                element_top.resetPositionAndSize()
            }
        }

    }

    Connections {

        target: PQCConstants

        function onWindowWidthChanged() {
            if(element_top.x+element_top.width > PQCConstants.windowWidth && element_top.width+50 < PQCConstants.windowWidth)
                element_top.x = PQCConstants.windowWidth-element_top.width
        }

        function onWindowHeightChanged() {
            if(element_top.y+element_top.height> PQCConstants.windowHeight && element_top.height+50 < PQCConstants.windowHeight)
                element_top.y = PQCConstants.windowHeight-element_top.height
        }

    }

    function show() {
        opacity = 1
        settings["ExtShow"] = true
        floating_loader.item.showing()
    }

    function hide() {
        opacity = 0
        settings["ExtShow"] = false
        floating_loader.item.hiding()
    }

    function resetPositionAndSize() {

        _finishedSetup = false;

        var topos = PQCExtensionsHandler.getExtensionIntegratedDefaultPosition(extensionId)
        var dist  = PQCExtensionsHandler.getExtensionIntegratedDefaultDistanceFromEdge(extensionId)

        // top left
        if(topos === 0) {

            x = dist
            y = dist

        // top middle
        } else if(topos === 1) {

            x = Qt.binding(function() { return (PQCConstants.windowWidth-width)/2 })
            y = dist

        // top right
        } else if(topos === 2) {

            x = Qt.binding(function() { return PQCConstants.windowWidth-width-dist })
            y = dist

        // left
        } else if(topos === 3) {

            x = dist
            y = Qt.binding(function() { return (PQCConstants.windowHeight-height)/2 })

        // center
        } else if(topos === 4) {

            x = Qt.binding(function() { return (PQCConstants.windowWidth-width)/2 })
            y = Qt.binding(function() { return (PQCConstants.windowHeight-height)/2 })

        // right
        } else if(topos === 5) {

            x = Qt.binding(function() { return PQCConstants.windowWidth-width-dist })
            y = Qt.binding(function() { return (PQCConstants.windowHeight-height)/2 })

        // bottom left
        } else if(topos === 6) {

            x = dist
            y = Qt.binding(function() { return PQCConstants.windowHeight-height-dist })

        // bottom
        } else if(topos === 7) {

            x = Qt.binding(function() { return (PQCConstants.windowWidth-width)/2 })
            y = Qt.binding(function() { return PQCConstants.windowHeight-height-dist })

        // bottom right
        } else if(topos === 8) {

            x = Qt.binding(function() { return PQCConstants.windowWidth-width-dist })
            y = Qt.binding(function() { return PQCConstants.windowHeight-height-dist })

        }

        if(PQCExtensionsHandler.getExtensionIntegratedFixSizeToContent(extensionId)) {
            width = Qt.binding(function() { return floating_loader.item.width } )
            height = Qt.binding(function() { return floating_loader.item.height } )
        } else {
            var sze = PQCExtensionsHandler.getExtensionIntegratedDefaultSize(extensionId)
            if(sze.width !== -1) {
                width = sze.width
                height = sze.height
            } else {
                width = 300
                height = 200
            }
        }

        _recordFinishedSetup.restart()

    }

}
