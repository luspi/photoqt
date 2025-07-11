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
    property alias settings: extsettings

    ///////////////////

    ///////////////////
    // these are user facing options

    property bool setHideDuringSlideshow: true
    property bool setAllowResizing: true
    property bool setCanBePoppedOut: true
    property bool setHandleForegroundMouseEvent: true
    property bool setAnchorInTopMiddle: false
    property string setTooltip: ""

    ExtensionSettings {
        id: extsettings
        extensionId: floating_top.extensionId
    }

    ///////////////////

    property string getExtensionBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)
    property bool getDragActive: mousearea.drag.active || mouseareaBG.drag.active
    property bool getResizeActive: resizearea.pressed
    property bool getIsMovedManually: false

    ///////////////////

    function requestRepositioning() {
        _reposition()
    }

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

    onGetDragActiveChanged: {
        if(getDragActive)
            getIsMovedManually = true
    }

    color: PQCLook.baseColor

    property bool _popoutOpen: false

    property int _cacheWidth: 300
    property int _cacheHeight: 200

    property size _minReqSize: PQCExtensionsHandler.getMinimumRequiredWindowSize(extensionId)
    property bool _forcedPopout: PQCConstants.windowWidth < _minReqSize.width || PQCConstants.windowHeight < _minReqSize.height

    property bool _finishedSetup: false

    on_PopoutOpenChanged: {
        if(_popoutOpen)
            floating_top.show()
    }

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: settings["Popout"] ? 0 : 200 } }
    visible: opacity>0 && (!floating_top.setHideDuringSlideshow || !PQCConstants.slideshowRunning)
    enabled: visible

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
            settings["Position"] = Qt.point(floating_top.x, floating_top.y)
            settings["Size"] = Qt.size(floating_top.width, floating_top.height)
        }
    }

    PQShadowEffect { masterItem: floating_top }

    PQMouseArea {
        id: mouseareaBG
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: settings["Popout"] ? undefined : parent
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

        width: floating_top.setAllowResizing ? parent.width : childrenRect.width
        height: floating_top.setAllowResizing ? parent.height : childrenRect.height

        onWidthChanged: {
            if(!floating_top.setAllowResizing)
                parent.width = width
        }
        onHeightChanged: {
            if(!floating_top.setAllowResizing)
                parent.height = height
        }

        clip: true

        // CONTENT WILL GO HERE

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        enabled: floating_top.setHandleForegroundMouseEvent
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: settings["Popout"] ? undefined : parent
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

        enabled: !settings["Popout"] && floating_top.setAllowResizing

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
            text: settings["Popout"] ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(!floating_top.setCanBePoppedOut)
                    return
                floating_top.hide()
                var v = !settings["Popout"]
                settings["Popout"] = v
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

            visible: !settings["Popout"]

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

        if(!settings["Popout"]) {

            var pos = settings["Position"]
            if(pos !== undefined) {
                x = pos.x
                y = pos.y
            } else {
                x = (PQCConstants.windowWidth-floating_top.width)/2
                y: 100
            }

            if(floating_top.setAllowResizing) {

                var sze = settings["Size"]
                if(sze !== undefined) {
                    width = sze.width
                    height = sze.height
                } else {
                    width = 300
                    height = 200
                }

            } else {
                width = Qt.binding(function() { return contentItem.childrenRect.width })
                height = Qt.binding(function() { return contentItem.childrenRect.height })
            }

            floating_top.state = ""

            if(settings["Show"])
                show()

        } else {

            x = 0
            y = 0

            floating_top.state = "popout"

            if(settings["Show"])
                show()

        }

        _recordFinishedSetup.restart()

    }

    Timer {
        id: _recordFinishedSetup
        interval: 500
        onTriggered:
            floating_top._finishedSetup = true
    }


    Connections {

        target: PQCNotify // qmllint disable unqualified

        enabled: !settings["Popout"]

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
        settings["Show"] = true
        showing()
        if(!_popoutOpen && setAnchorInTopMiddle) {
            if(!getIsMovedManually)
                _reposition()
        }
    }

    function hide() {
        opacity = 0
        settings["Show"] = false
        hiding()
    }

    // /////////

    /**************************************************************************************************/
    /**************************************************************************************************/
    // the following is used when this element is to be anchored in the top middle

    Connections {

        target: PQCSettings

        function onInterfaceEdgeTopActionChanged() {
            floating_top._reposition()
        }

        function onInterfaceStatusInfoPositionChanged() {
            if(!floating_top.getIsMovedManually)
                floating_top._reposition()
        }

        function onInterfaceStatusInfoShowChanged() {
            if(!floating_top.getIsMovedManually)
                floating_top._reposition()
        }

    }

    Connections {

        target: PQCConstants
        enabled: floating_top.setAnchorInTopMiddle

        function onWindowWidthChanged() {
            if(!floating_top._finishedSetup) return
            if(!floating_top.getIsMovedManually) {
                floating_top._reposition()
                return
            }
            floating_top.x = Math.min(PQCConstants.windowWidth-floating_top.width, Math.max(0, floating_top.x))
        }

        function onWindowHeightChanged() {
            if(!floating_top._finishedSetup || !floating_top.getIsMovedManually) return
            floating_top.y = Math.min(PQCConstants.windowHeight-floating_top.height, Math.max(0, floating_top.y))
        }

        function onStatusInfoMovedDownChanged() {
            if(!floating_top._finishedSetup) return
            if(!floating_top.getIsMovedManually) {
                floating_top._reposition()
                return
            }
        }

        function onStatusInfoCurrentRectChanged() {
            if(!floating_top.getIsMovedManually)
                floating_top._reposition()
        }

    }

    function _reposition() {
        getIsMovedManually = false
        _finishedSetup = false
        if(!settings["Popout"]) {
            x = Qt.binding(function() { return (PQCConstants.windowWidth-width)/2 })
            if(PQCSettings.interfaceEdgeTopAction === "thumbnails")
                y = Qt.binding(function() { return PQCConstants.windowHeight-height-20-_computeYOffset() })
            else
                y = 20 + _computeYOffset()
        }
        _recordFinishedSetup.restart()
    }

    function _computeYOffset() {

        var dist = 20
        var offset = 0

        // if floating actions has not been manually moved yet
        if(!getIsMovedManually) {

            // if the quick actions fill (at least) the full width
            if(x <= 0 && x+width >= PQCConstants.windowWidth) {

                if(PQCSettings.interfaceStatusInfoShow && !PQCConstants.statusInfoMovedManually)
                    offset += PQCConstants.statusInfoCurrentRect.height+20
                if(PQCSettings.interfaceWindowButtonsShow && (PQCConstants.statusInfoMovedDown || !PQCSettings.interfaceStatusInfoShow))
                    offset += PQCConstants.windowButtonsCurrentRect.height+20

            // if the status info is visible and overlaps quick actions
            } else if(PQCSettings.interfaceStatusInfoShow && !PQCConstants.statusInfoMovedManually) {
                if((x <= PQCConstants.statusInfoCurrentRect.x+PQCConstants.statusInfoCurrentRect.width+dist &&
                    x+width >= PQCConstants.statusInfoCurrentRect.x) ||
                        (x+width >= PQCConstants.statusInfoCurrentRect.x &&
                         x <= PQCConstants.statusInfoCurrentRect.x+PQCConstants.statusInfoCurrentRect.width+dist)) {
                    offset += PQCConstants.statusInfoCurrentRect.height+20
                    if(PQCConstants.statusInfoMovedDown)
                        offset += PQCConstants.windowButtonsCurrentRect.height+20
                }
            // if window buttons are visible and overlap quick actions and if either (1) the status info is not shown, or (2) the status info and window buttons also overlap
            } else if(PQCSettings.interfaceWindowButtonsShow && ((PQCConstants.windowButtonsCurrentRect.x <= PQCConstants.statusInfoCurrentRect.x+PQCConstants.statusInfoCurrentRect.width+dist) ||
                                                          !(PQCSettings.interfaceStatusInfoShow && !PQCConstants.statusInfoMovedManually))) {
                if((x <= PQCConstants.windowButtonsCurrentRect.x+PQCConstants.windowButtonsCurrentRect.width+dist &&
                    x+width >= PQCConstants.windowButtonsCurrentRect.x) ||
                        (x+width >= PQCConstants.windowButtonsCurrentRect.x &&
                         x <= PQCConstants.windowButtonsCurrentRect.x+PQCConstants.windowButtonsCurrentRect.width+dist)) {
                    if(PQCConstants.statusInfoMovedDown && PQCSettings.interfaceStatusInfoShow)
                        offset += PQCConstants.statusInfoCurrentRect.height+20
                    offset += PQCConstants.windowButtonsCurrentRect.height+20
                }
            }
        }
        return offset
    }

    /**************************************************************************************************/
    /**************************************************************************************************/

    // property bool allowWheel: false
    // property bool showBGMouseArea: false
    // property alias closeMouseArea: closemouse
    // property alias popinMouseArea: popinmouse

}
