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
import PhotoQt.CPlusPlus
import PhotoQt.Modern

Rectangle {

    id: ele_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: 300
    property int parentHeight: 200

    // THESE ARE REQUIRED
    property bool popout
    property string shortcut
    property bool forcePopout

    // similarly a hide() and show() function is required

    /////////

    property string blur_thisis: "blurbg.thisis"
    property bool showPopinPopout: true
    property bool darkBackgroundManageIcons: false
    property string tooltip: ""
    property bool allowWheel: false
    property bool showMainMouseArea: true
    property bool showBGMouseArea: false
    property int contentPadding: 0
    property bool allowResize: true
    property bool moveButtonsOutside: false
    property alias closeMouseArea: closemouse
    property alias popinMouseArea: popinmouse

    /////////

    property alias content: content.children
    property alias additionalAction: additionalActionItem.children

    /////////

    property bool dragActive: mousearea.drag.active || mouseareaBG.drag.active
    property bool resizeActive: resizearea.pressed

    /////////

    signal leftClicked(var mouse)
    signal rightClicked(var mouse)

    /////////

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    /////////

    SystemPalette { id: pqtPalette }

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: ele_top.popout ? 0 : 200 } }
    visible: opacity>0
    enabled: visible

    color: pqtPalette.base

    PQMouseArea {
        id: mouseareaBG
        enabled: ele_top.showBGMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: ele_top.popout ? undefined : parent
        text: ele_top.tooltip
        onWheel: (wheel) => {
            wheel.accepted = !ele_top.allowWheel
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                ele_top.rightClicked(mouse)
            else
                ele_top.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    Item {

        id: content

        anchors.fill: parent
        anchors.margins: ele_top.contentPadding

        clip: true

        // FILL IN CONTENT HERE

    }

    PQMouseArea {
        id: mousearea
        enabled: ele_top.showMainMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: ele_top.popout ? undefined : parent
        text: ele_top.tooltip
        onWheel: (wheel) => {
            wheel.accepted = !ele_top.allowWheel
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                ele_top.rightClicked(mouse)
            else
                ele_top.leftClicked(mouse)
            mouse.accepted = true
        }
    }

    PQMouseArea {

        id: resizearea

        enabled: !ele_top.popout && ele_top.allowResize

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: ele_top.allowResize ? Qt.SizeFDiagCursor : Qt.ArrowCursor

        onPositionChanged: (mouse) => {
            if(pressed) {
                ele_top.width += (mouse.x-resizearea.width)
                ele_top.height += (mouse.y-resizearea.height)
                if(ele_top.width < 100)
                    ele_top.width = 100
                if(ele_top.height < 100)
                    ele_top.height = 100
            }
        }

    }

    Image {
        x: moveButtonsOutside ? (5-width) : 4
        y: moveButtonsOutside ? (5-height) : 4
        width: 15
        height: 15
        visible: ele_top.showPopinPopout && !ele_top.forcePopout
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
            text: ele_top.popout ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(!ele_top.showPopinPopout)
                    return
                ele_top.hide()
                if(!ele_top.popout)
                    ele_top.popout = true
                else
                    ele_window.close()
                PQCScriptsShortcuts.executeInternalCommand(ele_top.shortcut)
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 2
            z: -1
            visible: ele_top.darkBackgroundManageIcons
            color: pqtPalette.base
            opacity: parent.opacity*0.8
        }
    }

    Row {

        x: moveButtonsOutside ? (parent.width-additionalActionItem.width-10) : (parent.width-width+2)
        y: moveButtonsOutside ? (10-height) : 2

        Item {
            id: additionalActionItem
            width: 25
            height: 25
        }

        Image {

            id: closeimage
            width: 25
            height: 25

            visible: !ele_top.popout

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
                    ele_top.hide()
            }

            Rectangle {
                anchors.fill: closeimage
                radius: width/2
                z: -1
                visible: ele_top.darkBackgroundManageIcons
                color: pqtPalette.base
                opacity: closeimage.opacity*0.8
            }

        }

    }

    // will be overwritten
    function hide() {}

}
