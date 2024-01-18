/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCNotify

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

    property bool showPopinPopout: true
    property bool darkBackgroundManageIcons: false
    property string tooltip: ""
    property bool allowWheel: false
    property alias blur_thisis: blurbg.thisis

    /////////

    property alias content: content.children
    property alias additionalAction: additionalActionItem.children

    /////////

    property bool dragActive: mousearea.drag.active
    property bool resizeActive: resizearea.pressed

    /////////

    signal leftClicked(var mouse)
    signal rightClicked(var mouse)

    /////////

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: popout ? 0 : 200 } }
    visible: opacity>0
    enabled: visible

    color: PQCLook.transColor

    radius: 10

    PQBlurBackground { id: blurbg }

    Item {

        id: content

        anchors.fill: parent

        clip: true

        // FILL IN CONTENT HERE

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: popout ? undefined : parent
        text: tooltip
        onWheel: (wheel) => {
            wheel.accepted = !allowWheel
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                rightClicked(mouse)
            else
                leftClicked(mouse)
            mouse.accepted = true
        }
    }

    PQMouseArea {

        id: resizearea

        enabled: !popout

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: Qt.SizeFDiagCursor

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
        x: 4
        y: 4
        width: 15
        height: 15
        visible: showPopinPopout && !forcePopout
        enabled: visible
        z: 1
        source: "image://svg/:/white/popinpopout.svg"
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
                if(!showPopinPopout)
                    return
                if(!ele_top.popout)
                    ele_top.popout = true
                else
                    close()
                ele_top.hide()
                PQCNotify.executeInternalCommand(ele_top.shortcut)
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 2
            z: -1
            visible: darkBackgroundManageIcons
            color: PQCLook.transColor
            opacity: parent.opacity
        }
    }

    Row {

        x: parent.width-width-2
        y: 2

        Item {
            id: additionalActionItem
            width: 25
            height: 25
        }

        Image {

            id: closeimage
            width: 25
            height: 25

            visible: !popout

            source: "image://svg/:/white/close.svg"
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
                visible: darkBackgroundManageIcons
                color: PQCLook.transColor
                opacity: closeimage.opacity
            }

        }

    }

}
