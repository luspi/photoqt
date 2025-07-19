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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

Rectangle {

    id: ele_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: PQCConstants.windowWidth // qmllint disable unqualified
    property int parentHeight: PQCConstants.windowHeight // qmllint disable unqualified

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
    property alias botLeftContent: bottomleftelement.children

    property bool noGapsAnywhere: false

    property bool contextMenuOpen: firstbutton.contextmenu.visible || secondbutton.contextmenu.visible || thirdbutton.contextmenu.visible

    /////////

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    /////////

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: ele_top.popout ? 0 : 200 } }
    visible: opacity>0
    enabled: visible

    onOpacityChanged: {
        if(opacity > 0 && !popout)
            PQCNotify.windowTitleOverride(title) // qmllint disable unqualified
        else if(opacity === 0)
            PQCNotify.windowTitleOverride("")
    }

    color: PQCLook.baseColorAccent

    signal close()

    // this signal is only ever emitted IF this element is popped out AND if the window was closed through the window manager
    signal popoutClosed()

    Loader {
        active: ele_top.popoutWindowUsed
        sourceComponent:
        Item {
            Connections {
                target: ele_window // qmllint disable unqualified
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
        color: PQCLook.baseColor // qmllint disable unqualified

        PQTextXL {
            anchors.centerIn: parent
            text: ele_top.title
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        }

        Rectangle {
            x: 0
            y: parent.height-1
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive // qmllint disable unqualified
        }

    }

    Flickable {

        id: flickable

        y: toprow.height + ((parent.height-bottomrow.height-toprow.height-height)/2)

        width: parent.width
        height: Math.min(parent.height-bottomrow.height-toprow.height, contentHeight)

        clip: true

        contentHeight: insidecont.height+(ele_top.noGapsAnywhere ? 0 : 20)

        ScrollBar.vertical: PQVerticalScrollBar { }

        Column {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ele_top.noGapsAnywhere ? 0 : 10

            width: (ele_top.maxWidth==0 ? parent.width-(ele_top.noGapsAnywhere ? 0 : 10) : Math.min(parent.width-(ele_top.noGapsAnywhere ? 0 : 10), ele_top.maxWidth))

            spacing: 10

            // FILL IN CONTENT HERE

        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: PQCLook.baseColor // qmllint disable unqualified

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive // qmllint disable unqualified
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
                    ele_window.handleChangesBottomRowWidth(width) // qmllint disable unqualified
            }

            PQButtonElement {
                id: firstbutton
                text: genericStringClose
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
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
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg" // qmllint disable unqualified
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: ele_top.showPopinPopout && (!ele_top.forcePopout || !ele_top.popout)
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
                if(!ele_top.showPopinPopout)
                    return
                ele_top.hide()
                ele_top.popout = !ele_top.popout
                ele_top.opacityChanged()
                PQCScriptsShortcuts.executeInternalCommand(ele_top.shortcut) // qmllint disable unqualified
            }
        }
    }

    function hide() {}

    function closeContextMenus() {
        firstbutton.contextmenu.close()
        secondbutton.contextmenu.close()
        thirdbutton.contextmenu.close()
    }

}
