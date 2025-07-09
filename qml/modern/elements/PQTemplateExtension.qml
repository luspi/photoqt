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

Rectangle {

    id: floating_top

    ///////////////////
    // SOME REQUIRED ENTRIES

    property string extensionId: ""

    ///////////////////

    ///////////////////
    // these are user facing options

    property bool setHideDuringSlideshow: false
    property bool setAllowResizing: true
    property bool setCanBePoppedOut: true
    property string setTooltip: ""

    ///////////////////

    property string getExtensionBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)
    property bool getIsPoppedOut: PQCSettings.extensions[extensionId+"Popout"]
    property bool getDragActive: mousearea.drag.active || mouseareaBG.drag.active
    property bool getResizeActive: resizearea.pressed

    ///////////////////
    // user facing accessors

    property alias content: contentItem.children
    property alias additionalAction: additionalActionItem.children

    ///////////////////
    // some user facing signals

    signal leftClicked(var mouse)
    signal rightClicked(var mouse)
    signal showing()
    signal hiding()

    ///////////////////

    color: PQCLook.baseColor

    property bool _popoutOpen: false

    property int _cacheWidth: 300
    property int _cacheHeight: 200

    property size _minReqSize: PQCExtensionsHandler.getMinimumRequiredWindowSize(extensionId)
    property bool _forcedPopout: PQCConstants.windowWidth < _minReqSize.width || PQCConstants.windowHeight < _minReqSize.height

    on_PopoutOpenChanged: {
        if(_popoutOpen)
            floating_top.show()
    }

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: floating_top.getIsPoppedOut ? 0 : 200 } }
    visible: opacity>0 && (!floating_top.setHideDuringSlideshow || !PQCConstants.slideshowRunning)
    enabled: visible

    states: [
        State {
            name: "normal"
            PropertyChanges {
                width: floating_top._cacheWidth
                height: floating_top._cacheHeight
            }
        }
    ]

    onXChanged: {
        if(getDragActive)
            storeSize.restart()
    }
    onYChanged: {
        if(getDragActive)
            storeSize.restart()
    }
    onWidthChanged: {
        if(getResizeActive)
            storeSize.restart()
    }
    onHeightChanged: {
        if(getResizeActive)
            storeSize.restart()
    }

    Timer {
        id: storeSize
        interval: 200
        onTriggered: {
            PQCSettings.extensions[floating_top.extensionId+"Position"] = Qt.point(floating_top.x, floating_top.y)
            PQCSettings.extensions[floating_top.extensionId+"Size"] = Qt.size(floating_top.width, floating_top.height)
        }
    }

    PQShadowEffect { masterItem: floating_top }

    PQMouseArea {
        id: mouseareaBG
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: floating_top.getIsPoppedOut ? undefined : parent
        text: floating_top.setTooltip
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                floating_top.rightClicked(mouse)
            else
                floating_top.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    Item {

        id: contentItem

        anchors.fill: parent
        anchors.margins: 2

        clip: true

        // CONTENT WILL GO HERE

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: floating_top.getIsPoppedOut ? undefined : parent
        text: floating_top.setTooltip
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                floating_top.rightClicked(mouse)
            else
                floating_top.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    PQMouseArea {

        id: resizearea

        enabled: !floating_top.getIsPoppedOut && floating_top.setAllowResizing

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: floating_top.setAllowResizing ? Qt.SizeFDiagCursor : Qt.ArrowCursor

        onPositionChanged: (mouse) => {
            if(pressed) {
                floating_top.width += (mouse.x-resizearea.width)
                floating_top.height += (mouse.y-resizearea.height)
                if(floating_top.width < 100)
                    floating_top.width = 100
                if(floating_top.height < 100)
                    floating_top.height = 100
            }
        }

    }

    Image {
        x: 5-(floating_top._popoutOpen ? 0 : width)
        y: 5-(floating_top._popoutOpen ? 0 : height)
        width: 15
        height: 15
        visible: floating_top.setCanBePoppedOut && !floating_top._forcedPopout
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
            text: floating_top.getIsPoppedOut ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(!floating_top.setCanBePoppedOut)
                    return
                floating_top.hide()
                var v = !floating_top.getIsPoppedOut
                PQCSettings.extensions[extensionId+"Popout"] = v
                PQCSettings.extensionValueChanged(extensionId+"Popout", v)
                PQCNotify.loaderShowExtension(extensionId)
            }
        }

        Rectangle {
            visible: floating_top._popoutOpen
            anchors.fill: parent
            anchors.margins: -2
            radius: 2
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

            visible: !floating_top.getIsPoppedOut

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
                    floating_top.hide()
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

        if(!floating_top.getIsPoppedOut) {

            var pos = PQCSettings.extensions[extensionId+"Position"]
            x = pos.x
            y = pos.y

            var sze = PQCSettings.extensions[extensionId+"Size"]
            width = sze.width
            height = sze.height

            floating_top.state = ""

            if(PQCSettings.extensions[extensionId])
                show()

        } else {

            x = 0
            y = 0

            floating_top.state = "popout"

        }

    }

    Connections {

        target: PQCNotify // qmllint disable unqualified

        enabled: !floating_top.getIsPoppedOut

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === floating_top.extensionId) {
                if(floating_top.visible) {
                    floating_top.hide()
                } else {
                    floating_top.show()
                }
            }
        }
    }

    function show() {
        opacity = 1
        PQCSettings.extensions[extensionId] = true
        showing()
    }

    function hide() {
        opacity = 0
        PQCSettings.extensions[extensionId] = false
        hiding()
    }

    // /////////

    // property bool allowWheel: false
    // property bool showMainMouseArea: true
    // property bool showBGMouseArea: false
    // property int contentPadding: 0
    // property bool allowResize: true
    // property alias closeMouseArea: closemouse
    // property alias popinMouseArea: popinmouse

}
