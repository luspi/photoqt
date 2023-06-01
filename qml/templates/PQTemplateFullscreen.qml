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
import QtQuick.Controls 2.2

import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Rectangle {

    id: ele_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    // THESE ARE REQUIRED
    property bool popout
    property string shortcut

    /////////

    property alias content: insidecont.children

    /////////

    property string title: ""

    /////////

    property bool buttonFirstShow: true
    property bool buttonSecondShow: false

    property alias buttonFirstText: firstbutton.text
    property alias buttonSecondText: secondbutton.text

    property alias buttonFirstFont: firstbutton.font
    property alias buttonSecondFont: secondbutton.font

    property alias genericStringCancel: firstbutton.genericStringCancel
    property alias genericStringClose: firstbutton.genericStringClose
    property alias genericStringOk: firstbutton.genericStringOk
    property alias genericStringSave: firstbutton.genericStringSave

    property alias spacing: insidecont.spacing
    property int maxWidth: 0

    /////////

    signal buttonFirstClicked()
    signal buttonSecondClicked()

    /////////

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity!=0
    enabled: visible

    color: "#f41f1f1f"

    signal close()

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }


    Rectangle {

        id: toprow

        width: parent.width
        height: 50
        color: "#333333"

        PQTextXL {
            anchors.centerIn: parent
            text: ele_top.title
            font.weight: baselook.boldweight
        }

        Rectangle {
            x: 0
            y: parent.height-1
            width: parent.width
            height: 1
            color: "#888888"
        }

    }

    Flickable {

        id: flickable

        y: toprow.height + ((parent.height-bottomrow.height-toprow.height-height)/2)

        width: parent.width
        height: Math.min(parent.height-bottomrow.height-toprow.height, contentHeight)

        clip: true

        contentHeight: insidecont.height+20

        ScrollBar.vertical: PQScrollBar { id: scroll }

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
        color: "#333333"

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: "#888888"
        }

        Row {

            x: (parent.width-width)/2

            height: parent.height

            PQButton {
                id: firstbutton
                text: genericStringClose
                font.weight: baselook.boldweight
                font.pointSize: baselook.fontsize_l
                visible: buttonFirstShow
                x: (parent.width-width)/2
                y: 1
                height: parent.height-1
                leftRightTextSpacing: 40
                onClicked:
                    buttonFirstClicked()

                Rectangle {
                    x: 0
                    width: 1
                    height: parent.height
                    color: "#888888"
                }

                Rectangle {
                    x: parent.width-1
                    width: 1
                    height: parent.height
                    color: "#888888"
                }
            }

            PQButton {
                id: secondbutton
                text: genericStringClose
                font.weight: baselook.normalweight
                visible: buttonSecondShow
                x: (parent.width-width)/2
                y: 1
                height: parent.height-1
                leftRightTextSpacing: 20
                onClicked:
                    buttonSecondClicked()

                Rectangle {
                    x: 0
                    width: 1
                    height: parent.height
                    color: "#888888"
                }

                Rectangle {
                    x: parent.width-1
                    width: 1
                    height: parent.height
                    color: "#888888"
                }
            }

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        source: "/popin.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: ele_top.popout ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(ele_top.popout)
                    ele_window.storeGeometry()
                close()
                ele_top.popout = !ele_top.popout
                HandleShortcuts.executeInternalFunction(ele_top.shortcut)
            }
        }
    }

}