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

Window {

    id: element_top

    ///////////////////

    title: "Popout"

    property string elementId
    property alias content: cont.sourceComponent

    property bool letElementHandleClosing: false

    property alias button1: firstbutton
    property alias button2: secondbutton
    property alias button3: thirdbutton
    property alias bottomLeft: bottomleftelement
    property alias bottomLeftContent: bottomleftelement.children
    property alias popInOutButton: popinoutimage

    property rect defaultPopoutGeometry: Qt.rect(0, 0, 150, 150)
    property bool defaultPopoutMaximized: false

    property bool showTopBottom: true
    property int toprowHeight: toprow.height
    property int bottomrowHeight: bottomrow.height
    property int contentHeight: element_top.height-(showTopBottom ? (toprowHeight+bottomrowHeight) : 0)
    property int contentWidth: cont.width
    property bool forceShow: false

    signal button1Clicked()
    signal button2Clicked()
    signal button3Clicked()

    ///////////////////

    signal rectUpdated(var r)
    signal maximizedUpdated(var m)

    ///////////////////

    property bool _cacheCurrentMaxState: false

    SystemPalette { id: pqtPalette }

    width: 100
    height: 100

    onClosing: {
        _hideNoCheck()
        cont.item.hiding()
    }

    Component.onCompleted: {

        element_top.setX(defaultPopoutGeometry.x)
        element_top.setY(defaultPopoutGeometry.y)

        element_top.setWidth(defaultPopoutGeometry.width)
        element_top.setHeight(defaultPopoutGeometry.height)

        setupCompleted.restart()

        // in this case the user switched the popped out state
        if(PQCConstants.idOfVisibleItem === elementId || forceShow)
            _show()

        forceShow = false

    }

    property bool setupHasBeenCompleted: false
    Timer {
        id: setupCompleted
        interval: 300
        onTriggered: {
            element_top.setupHasBeenCompleted = true
        }
    }

    minimumWidth: 400
    minimumHeight: 400

    modality: Qt.ApplicationModal

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
    onWidthChanged:
        updateGeometry.restart()
    onHeightChanged:
        updateGeometry.restart()
    onVisibilityChanged: {
        if(visibility === Window.Hidden) {
            setupHasBeenCompleted = false
            element_top._hide()
        } else if(!setupHasBeenCompleted)
            setupCompleted.restart()
        updateGeometry.restart()
    }


    Rectangle {

        id: toprow

        width: parent.width
        height: parent.height>500 ? 75 : Math.max(75-(500-parent.height), 50)
        color: pqtPalette.base

        visible: element_top.showTopBottom

        PQTextXL {
            anchors.centerIn: parent
            text: element_top.title
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

    Loader {

        id: cont

        y: element_top.showTopBottom ? toprow.height : 0
        width: parent.width
        height: parent.height-(element_top.showTopBottom ? (toprow.height+bottomrow.height) : 0)

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: pqtPalette.base

        visible: element_top.showTopBottom

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseBorder
        }

        Item {
            id: bottomleftelement
            x: 0
            y: 0
            height: parent.height
            width: childrenRect.width
        }

        Row {

            x: (parent.width-width)/2

            height: parent.height

            spacing: 0

            PQButtonElement {
                id: firstbutton
                text: genericStringClose
                font.weight: PQCLook.fontWeightBold
                y: (parent.height-height)/2
                onClicked:
                    element_top.button1Clicked()
            }

            PQButtonElement {
                id: secondbutton
                visible: text!==""
                y: (parent.height-height)/2
                onClicked:
                    element_top.button2Clicked()
            }

            PQButtonElement {
                id: thirdbutton
                visible: text!==""
                y: (parent.height-height)/2
                onClicked:
                    element_top.button3Clicked()
            }

        }

    }

    Timer {
        id: updateGeometry
        interval: 200
        repeat: false
        onTriggered: {
            if(!element_top.setupHasBeenCompleted) return
            var newm = (element_top.visibility === Window.Maximized)
            if(element_top._cacheCurrentMaxState !== newm) {
                element_top.maximizedUpdated(newm)
                _cacheCurrentMaxState = newm
            }
            if(!newm)
                element_top.rectUpdated(Qt.rect(element_top.x, element_top.y, element_top.width, element_top.height))
        }
    }

    Image {
        id: popinoutimage
        x: 5
        y: 5
        width: 15
        height: 15
        visible: true
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
            onClicked:
                PQCSettings["interfacePopout"+element_top.elementId] = false
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

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === element_top.elementId) {
                if(element_top.visible) {
                    element_top._hide()
                } else {
                    element_top._show()
                }
            }
        }

        function onElementSignal(eId, what) {
            if(eId === element_top.elementId) {
                if(what === "hide")
                    element_top._hide()
                else if(what === "forceHide")
                    element_top._hideNoCheck()
                else if(what === "show")
                    element_top._show()
            }
        }
    }

    function _show() {

        var ret = cont.item.showing()
        if(ret !== undefined && !ret) {
            PQCNotify.loaderRegisterClose(element_top.elementId)
            return false
        }

        PQCNotify.loaderRegisterOpen(element_top.elementId)
        if(defaultPopoutMaximized)
            element_top.showMaximized()
        else
            element_top.show()
        _cacheCurrentMaxState = defaultPopoutMaximized

    }

    function _hide() {

        if(!letElementHandleClosing) {
            _hideNoCheck()
        }
    }

    function _hideNoCheck() {

        var ret = cont.item.hiding()
        if(ret !== undefined && !ret)
            return

        PQCNotify.loaderRegisterClose(element_top.elementId)
        element_top.close()
        PQCNotify.resetActiveFocus()
    }

}
