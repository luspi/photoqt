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

import QtQuick
import QtQuick.Controls

import "../elements"

Rectangle {

    id: ele_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    /////////

    property alias content: insidecont.children

    /////////

    property string title: ""

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

    /////////

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0
    enabled: visible

    color: PQCLook.baseColor

    signal close()

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {

        id: toprow

        width: parent.width
        height: parent.height>500 ? 75 : Math.max(75-(500-parent.height), 50)
        color: PQCLook.baseColorHighlight

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

        contentHeight: insidecont.height+20

//        ScrollBar.vertical: PQScrollBar { id: scroll }

        Column {

            id: insidecont

            x: ((parent.width-width)/2)
            y: 10

            width: (ele_top.maxWidth==0 ? parent.width-10 : Math.min(parent.width-10, ele_top.maxWidth))

            spacing: 10

            // FILL IN CONTENT HERE

        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: PQCLook.baseColorAccent

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive
        }

        Row {

            x: (parent.width-width)/2

            height: parent.height

            spacing: 0

            PQButtonElement {
                id: firstbutton
                text: genericStringClose
//                font.weight: baselook.boldweight
//                font.pointSize: baselook.fontsize_l
                y: 1
                height: parent.height-1
//                leftRightTextSpacing: 40
//                showLeftRightBorder: true
            }

            PQButtonElement {
                id: secondbutton
                text: genericStringClose
//                font.weight: baselook.normalweight
                visible: false
                y: 1
                height: parent.height-1
//                leftRightTextSpacing: 20
//                showLeftRightBorder: true
            }

            PQButtonElement {
                id: thirdbutton
                text: genericStringClose
//                font.weight: baselook.normalweight
//                font.pointSize: baselook.fontsize_s
                visible: false
                y: 1
                height: parent.height-1
//                leftRightTextSpacing: 20
//                showLeftRightBorder: true
            }

        }

    }

    function show() {
        opacity = 1
    }

    function hide() {
        opacity = 0
        close()
    }

}
