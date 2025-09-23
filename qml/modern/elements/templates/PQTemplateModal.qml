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
import PhotoQt.CPlusPlus
import PhotoQt.Modern

Rectangle {

    id: element_top

    property string title: ""
    property string elementId: ""
    property alias content: cont.sourceComponent

    property bool letElementHandleClosing: false

    property alias button1: firstbutton
    property alias button2: secondbutton
    property alias button3: thirdbutton
    property alias bottomLeft: bottomleftelement
    property alias bottomLeftContent: bottomleftelement.children
    property alias popInOutButton: popinoutimage

    property bool showTopBottom: true
    property int toprowHeight: toprow.height
    property int bottomrowHeight: bottomrow.height
    property int contentHeight: element_top.height-(showTopBottom ? (toprowHeight+bottomrowHeight) : 0)
    property int contentWidth: cont.width

    signal button1Clicked()
    signal button2Clicked()
    signal button3Clicked()

    signal showing()
    signal hiding()

    /********************/

    SystemPalette { id: pqtPalette }

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0
    enabled: visible

    width: PQCConstants.availableWidth
    height: PQCConstants.availableHeight
    color: pqtPalette.alternateBase

    onWidthChanged: {
        width = Qt.binding(function() { return PQCConstants.availableWidth })
    }
    onHeightChanged: {
        height = Qt.binding(function() { return PQCConstants.availableHeight })
    }

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
        height: parent.height-(element_top.showTopBottom ? (toprow.height-bottomrow.height) : 0)

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
                y: 1
                height: parent.height-1
                onClicked:
                    element_top.button1Clicked()
            }

            PQButtonElement {
                id: secondbutton
                visible: text!==""
                y: 1
                height: parent.height-1
                onClicked:
                    element_top.button2Clicked()
            }

            PQButtonElement {
                id: thirdbutton
                visible: text!==""
                y: 1
                height: parent.height-1
                onClicked:
                    element_top.button3Clicked()
            }

        }

    }

    Image {
        id: popinoutimage
        x: 5
        y: 5
        width: 15
        height: 15
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
            onClicked:
                PQCSettings["interfacePopout"+element_top.elementId] = true
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
        // in this case the user switched the popped out state
        if(PQCConstants.idOfVisibleItem === elementId)
            _show()
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
        PQCNotify.loaderRegisterOpen(element_top.elementId)
        opacity = 1
        cont.item.showing()
    }

    function _hide() {
        if(!letElementHandleClosing) {
            _hideNoCheck()
        }
        cont.item.hiding()
    }

    function _hideNoCheck() {
        PQCNotify.loaderRegisterClose(element_top.elementId)
        opacity = 0
        PQCNotify.resetActiveFocus()
    }

}
