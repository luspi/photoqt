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
import QtQuick.Controls

import PQCNotify

Rectangle {

    id: ele_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    // THESE ARE REQUIRED
    property string thisis
    property bool popout
    property string shortcut
    property bool forcePopout

    // similarly a hide() and show() function is required

    /////////

    property alias content: insidecont.children

    /////////

    property string title: ""
    property bool showPopinPopout: true

    /////////

    property alias button1: firstbutton
    property alias button2: secondbutton
    property alias button3: thirdbutton

    property alias genericStringCancel: firstbutton.genericStringCancel
    property alias genericStringClose: firstbutton.genericStringClose
    property alias genericStringOk: firstbutton.genericStringOk
    property alias genericStringSave: firstbutton.genericStringSave

    property alias spacing: insidecont.spacing
    property int maxWidth: 0

    property int toprowHeight: toprow.height
    property int bottomrowHeight: bottomrow.height
    property int contentHeight: ele_top.height-toprowHeight-bottomrowHeight-(noGapsAnywhere ? 0 : 20)
    property int contentWidth: flickable.width

    property alias botLeft: bottomleftelement

    property bool noGapsAnywhere: false

    /////////

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    /////////

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: popout ? 0 : 200 } }
    visible: opacity>0
    enabled: visible

    onOpacityChanged: {
        if(opacity > 0 && !popout)
            toplevel.titleOverride = title
        else if(opacity == 0)
            toplevel.titleOverride = ""
    }

    color: PQCLook.baseColorAccent

    signal close()

    // this signal is only ever emitted IF this element is popped out AND if the window was closed through the window manager
    signal popoutClosed()

    Loader {
        active: popoutWindowUsed
        sourceComponent:
        Item {
            Connections {
                target: ele_window
                function onPopoutClosed() {
                    ele_top.popoutClosed()
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            mouse.accepted = true
        }
    }


    Rectangle {

        id: toprow

        width: parent.width
        height: parent.height>500 ? 75 : Math.max(75-(500-parent.height), 50)
        color: PQCLook.baseColor

        PQTextXL {
            anchors.centerIn: parent
            text: ele_top.title
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

    Flickable {

        id: flickable

        y: toprow.height + ((parent.height-bottomrow.height-toprow.height-height)/2)

        width: parent.width
        height: Math.min(parent.height-bottomrow.height-toprow.height, contentHeight)

        clip: true

        contentHeight: insidecont.height+(noGapsAnywhere ? 0 : 20)

        ScrollBar.vertical: PQVerticalScrollBar { }

        Column {

            id: insidecont

            x: ((parent.width-width)/2)
            y: noGapsAnywhere ? 0 : 10

            width: (ele_top.maxWidth==0 ? parent.width-(noGapsAnywhere ? 0 : 10) : Math.min(parent.width-(noGapsAnywhere ? 0 : 10), ele_top.maxWidth))

            spacing: 10

            // FILL IN CONTENT HERE

        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: PQCLook.baseColor

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive
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

            onWidthChanged: {
                if(ele_top.popout)
                    ele_window.handleChangesBottomRowWidth(width)
            }

            PQButtonElement {
                id: firstbutton
                text: genericStringClose
                font.weight: PQCLook.fontWeightBold
                y: 1
                height: parent.height-1
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
        source: "image://svg/:/white/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: showPopinPopout && (!forcePopout || !popout)
        enabled: visible
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
                ele_top.hide()
                ele_top.popout = !ele_top.popout
                ele_top.opacityChanged()
                PQCNotify.executeInternalCommand(ele_top.shortcut)
            }
        }
    }

}
