/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: ele_top

    property alias content: cont.children

    property bool popout
    property rect geometry
    property bool toBeShown
    property string itemname

    property bool darkBackgroundManageIcons: false

    property alias thisIsBlur: blur.thisis
    property alias tooltip: dragArea.tooltip
    property alias radius: blur.radius

    property alias additionalAction: additionalActionItem.children

    signal updateElement()
    signal clickedRight()
    signal wheelEvent(var delta)
    signal resized()

    PQBlurBackground {
        id: blur
        radius: popout ? 0 : 10
        isPoppedOut: ele_top.popout
    }

    x: popout ? 0 : geometry.x
    y: popout ? 0 : geometry.y
    width: popout ? parentWidth : geometry.width
    height: popout ? parentHeight : geometry.height

    property int parentWidth: 0
    property int parentHeight: 0

    // at startup toplevel width/height is zero causing the x/y of the element to be set to 0
    property bool startupDelay: true

    onXChanged:
        saveGeometryTimer.restart()
    onYChanged:
        saveGeometryTimer.restart()
    onWidthChanged:
        saveGeometryTimer.restart()
    onHeightChanged:
        saveGeometryTimer.restart()

    opacity: (popout||toBeShown) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    onVisibleChanged:
        updateElement()

    Component.onCompleted:
        if(filefoldermodel.current != -1)
            updateElement()

    Timer {
        // at startup toplevel width/height is zero causing the x/y of the element to be set to 0
        running: true
        repeat: false
        interval: 250
        onTriggered:
            startupDelay = false
    }

    Timer {
        id: saveGeometryTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: {
            if(!popout && !startupDelay) {
                geometry = Qt.rect(Math.max(0, Math.min(ele_top.x, toplevel.width-ele_top.width)),
                                   Math.max(0, Math.min(ele_top.y, toplevel.height-ele_top.height)),
                                   ele_top.width,
                                   ele_top.height)
            }
        }
    }

    Item {
        id: cont
        anchors.fill: parent

        // CONTENT GOES HERE

    }

    PinchArea {

        anchors.fill: parent

        pinch.target: popout ? undefined : ele_top
        pinch.minimumRotation: 0
        pinch.maximumRotation: 0
        pinch.minimumScale: 1
        pinch.maximumScale: 1
        pinch.dragAxis: Pinch.XAndYAxis

        onSmartZoom: {
            ele_top.x = pinch.previousCenter.x - ele_top.width / 2
            ele_top.y = pinch.previousCenter.y - ele_top.height / 2
        }

        // This mouse area does the same as the pinch area but for the mouse
        PQMouseArea {
            id: dragArea
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            drag.target: popout ? undefined : ele_top
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: toplevel.width-ele_top.width
            drag.maximumY: toplevel.height-ele_top.height

            onPressed:
                if(mouse.button == Qt.RightButton)
                    clickedRight()

            onWheel:
                wheelEvent(wheel.angleDelta)

        }
    }


    Row {

        x: parent.width-width+5
        y: -5

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

            source: "/other/close.svg"
            sourceSize: Qt.size(width, height)

            opacity: closemouse.containsMouse ? 0.8 : 0.1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQMouseArea {
                id: closemouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:
                    toBeShown = !toBeShown
            }

            Rectangle {
                anchors.fill: closeimage
                radius: width/2
                z: -1
                visible: darkBackgroundManageIcons
                color: "#88000000"
                opacity: closeimage.opacity
            }

        }

    }

    PQMouseArea {

        id: resizeBotRight

        enabled: !popout

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: Qt.SizeFDiagCursor

        onPositionChanged: {
            if(pressed) {
                ele_top.width += (mouse.x-resizeBotRight.width)
                ele_top.height += (mouse.y-resizeBotRight.height)
                if(ele_top.width < 100)
                    ele_top.width = 100
                if(ele_top.height < 100)
                    ele_top.height = 100
            }
        }

        onReleased:
            signalSizeChange.restart()

    }

    PQMouseArea {

        id: resizeBotLeft

        enabled: !popout

        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: Qt.SizeBDiagCursor

        onPositionChanged: {

            if(pressed) {

                ele_top.width -= mouse.x
                ele_top.height += (mouse.y-resizeBotRight.height)

                if(ele_top.width < 100)
                    ele_top.width = 100
                else
                    ele_top.x += mouse.x

                if(ele_top.height < 100)
                    ele_top.height = 100

            }

        }

        onReleased:
            signalSizeChange.restart()

    }

    Timer {
        id: signalSizeChange
        interval: 500
        onTriggered: {
            ele_top.resized()
        }
    }

    Rectangle {
        anchors.fill: popinout
        anchors.margins: -2
        visible: darkBackgroundManageIcons
        radius: 2
        color: "#88000000"
        opacity: popinout.opacity
    }

    Image {
        id: popinout
        x: (popout ? 5 : 0)
        y: popout ? 5 : 0
        width: 15
        height: 15
        source: "/popin.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.1
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: popout ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(popout)
                    ele_window.storeGeometry()
                popout = !popout
                loader.ensureItIsReady(itemname)
            }
        }
    }

    // this makes sure that a change in the window geometry does not leeds to the element being outside the visible area
    Connections {
        target: toplevel
        onWidthChanged: {
            if(ele_top.x < 0)
                ele_top.x = 0
            else if(ele_top.x > toplevel.width-ele_top.width)
                ele_top.x = toplevel.width-ele_top.width
        }
        onHeightChanged: {
            if(ele_top.y < 0)
                ele_top.y = 0
            else if(ele_top.y > toplevel.height-ele_top.height)
                ele_top.y = toplevel.height-ele_top.height
        }
    }

}
