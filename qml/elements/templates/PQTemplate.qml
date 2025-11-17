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

Rectangle {

    id: action_top

    ///////////////////

    property string elementId: ""
    property string title: ""
    property alias content: contentItem.children
    property bool letMeHandleClosing: false

    property PQButtonElement button1
    property PQButtonElement button2
    property PQButtonElement button3
    property Item bottomLeft
    property list<Item> bottomLeftContent
    property Item popInOutButton

    property int availableHeight

    function showing() { PQCNotify.resetActiveFocus(); return true }
    function hiding() { return true }

    ///////////////////

    function hide() {
        if(letMeHandleClosing)
            PQCNotify.elementSignal(action_top.elementId, "forceHide")
        else
            PQCNotify.elementSignal(action_top.elementId, "hide")
    }

    function show() {
        PQCNotify.elementSignal(action_top.elementId, "show")
    }

    ///////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: {}
        onClicked: {}
    }

    Connections {
        target: button1
        function onClicked() {
            action_top.button1Action()
        }
    }
    Connections {
        target: button2
        function onClicked() {
            action_top.button2Action()
        }
    }
    Connections {
        target: button3
        function onClicked() {
            action_top.button3Action()
        }
    }

    function button1Action() {}
    function button2Action() {}
    function button3Action() {}

    SystemPalette { id: pqtPalette }

    color: pqtPalette.base
    radius: 5

    Item {

        id: contentItem

        width: action_top.width
        height: action_top.height

        clip: true

        // CONTENT WILL GO HERE

    }

    Component.onCompleted: {}

    function modalButton1Action() {
        hide()
    }

    function modalButton2Action() {
    }

    function modalButton3Action() {
    }

}
