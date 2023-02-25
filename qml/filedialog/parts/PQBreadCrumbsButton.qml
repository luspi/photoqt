/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import "../../elements"

Rectangle {

    id: control

    // position and size
    y: 1
    width: txt.width+iconview.width
    height: bread_top.height-2

    // we need this value inside a Repeater below
    property int topindex: index

    // some styling
    border.width: 0
    border.color: "#00000000"
    radius: 2

    // if it's a dropdown button and there are no subfolders, show partially transparent
    opacity: (index%2==0||listMenuItems.length) ? 1 : 0.5

    // the complete folder path of this item
    property string completePath: ""

    // style the background
    color: menu.isOpen ? control.backgroundColorMenuOpen : ((control.down&&listMenuItems.length>0) ? control.backgroundColorActive : (control.mouseOver ? control.backgroundColorHover : control.backgroundColor))
    Behavior on color { ColorAnimation { duration: 150 } }

    // some easy stylings
    property string backgroundColor: "#333333"
    property string backgroundColorHover: "#3a3a3a"
    property string backgroundColorActive: "#444444"
    property string backgroundColorMenuOpen: "#666666"
    property string textColor: "#ffffff"
    property string textColorHover: "#ffffff"
    property string textColorActive: "#ffffff"

    // this holds the subfolders
    property var listMenuItems: []

    // some button properties
    property bool mouseOver: false
    property bool down: false

    // a click while some menu item is hovered does not close the menu below
    property bool someMenuItemHovered: false

    // if this is a folder in the actual path, show that folder
    // otherwise hide it
    Text {

        id: txt

        x: (parent.width-width)/2
        height: parent.height

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        leftPadding: 10
        rightPadding: 10
        font.bold: true

        font.pointSize: baselook.fontsize

        visible: text != ""

        text: index%2 == 0 ?
                  (bread_top.pathParts[index/2]=="" ?
                       "/" :
                       // This is needed to not show a trailing slash when top level folder is loaded in Windows
                       ((handlingGeneral.amIOnWindows()&&index==0) ?
                             bread_top.pathParts[index/2].substr(0,2) :
                             bread_top.pathParts[index/2])) :
                  ""

        color: control.down ? control.textColorActive : (control.mouseOver ? control.textColorHover : control.textColor)
        Behavior on color { ColorAnimation { duration: 100 } }

    }

    // a downwards icon to open a menu to show all subfolders
    Image {

        id: iconview

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        visible: source != ""

        source: index%2 == 1 ? "/filedialog/breadcrumb.svg" : ""
        sourceSize: Qt.size(control.height*0.25,control.height*0.25)

    }

    // a click on the button
    PQMouseArea {

        id: mousearea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        tooltip: index%2==1 ? (listMenuItems.length ? (em.pty+qsTranslate("filedialog", "List subfolders")) : (em.pty+qsTranslate("filedialog", "No subfolders found"))) : handlingFileDir.pathWithNativeSeparators(completePath)
        tooltipFollowsMouse: false

        onEntered:
            control.mouseOver = true
        onExited:
            control.mouseOver = false
        onPressed:
            control.down = true
        onReleased:
            control.down = false

        // click on folder opens folder
        // click on down arrow opens menu with subfolders
        onClicked: {
            if(index%2==1) {
                if(listMenuItems.length > 0) {
                    if(menu.isOpen)
                        menu.close()
                    else
                        menu.show()
                }
            } else
                filedialog_top.setCurrentDirectory(completePath)
        }
    }

    // the menu that opens downwards
    Rectangle {

        id: menu

        // we reparent it so that it is shown above all other elements here
        parent: filedialog_top

        // align the top of the menu with the divider at the bottom of the breadcrumbs area
        y: control.height+1

        // same color scheme as PQMenu
        color: "#88000000"
        border.width: 1
        border.color: "gray"

        // sane choice for width (I think)
        width: 300

        // the plus 2 allows us to show the border as well
        height: outercol.height+2

        // hidden by default
        visible: false
        property bool isOpen: visible

        // show menu
        function show() {
            x = Math.min(filedialog_top.width-width, toplevel.x-path.contentX+filedialog_top.mapFromItem(path, path.itemAtIndex(index).x, path.itemAtIndex(index).y).x-toplevel.x)
            visible = true
        }
        // hide menu
        function close() {
            visible = false
        }

        Column {

            id: outercol

            // show column below border around rectangle
            y: 1

            // If too many folders we show scrollbars and buttons to go up (this oen) and down (below)
            Rectangle {

                id: goup

                // same color scheme as PQMenu
                color: (upmouse.containsMouse && flick.contentY > 1) ? "#454545" : "#202020"
                border.width: 1
                border.color: "grey"

                width: menu.width
                height: visible ? 30 : 0

                // only show if too many folders
                visible: flick.contentHeight>fileview.height

                // the arrow image
                Image {
                    anchors.fill: parent
                    source: "/filedialog/upwards.svg"
                    opacity: (flick.contentY > 1) ? 1 : 0.4
                    sourceSize: Qt.size(goup.height,goup.height)
                    fillMode: Image.PreserveAspectFit
                }

                // mouse handling
                PQMouseArea {
                    id: upmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered:
                        control.someMenuItemHovered = true
                    onExited:
                        control.someMenuItemHovered = false

                    // press and hold keeps scrolling up
                    onPressed: {
                        doGoUp()
                        timerGoUp.restart()
                    }
                    onReleased:
                        timerGoUp.stop()
                    Timer {
                        id: timerGoUp
                        interval: 200
                        repeat: true
                        running: false
                        onTriggered:
                            parent.doGoUp()
                    }
                    function doGoUp() {
                        flick.contentY = Math.max(flick.contentY-40, 0)
                    }
                }
            }

            // the actual items
            Flickable {

                id: flick

                // sizing
                width: col.width
                height: Math.min(fileview.height-goup.height-godown.height, flick.contentHeight)
                contentHeight: col.height

                clip: true

                ScrollBar.vertical: PQScrollBar { id: scroll }

                // the content item
                Column {

                    id: col

                    Repeater {

                        // all entries
                        model: listMenuItems.length

                        Rectangle {

                            x: 1
                            width: menu.width-2
                            height: 40

                            color: delegmouse.containsMouse ? "#454545" : "#202020"

                            property bool hovered: false

                            Text {

                                anchors.fill: parent

                                leftPadding: 10
                                rightPadding: 10
                                topPadding: 5
                                bottomPadding: 5

                                font.pointSize: baselook.fontsize

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideMiddle

                                color: "white"
                                text: listMenuItems[index]

                            }

                            PQMouseArea {

                                id: delegmouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered:
                                    control.someMenuItemHovered = true
                                onExited:
                                    control.someMenuItemHovered = false
                                onClicked: {
                                    menu.close()
                                    if(handlingGeneral.amIOnWindows()) {
                                        var newpath = ""
                                        for(var i = 0; i <= topindex/2; ++i)
                                            newpath += pathParts[i] + "/"
                                    } else {
                                        newpath = "/"
                                        for(var i = 1; i <= topindex/2; ++i)
                                            newpath += pathParts[i] + "/"
                                    }
                                    filedialog_top.setCurrentDirectory(newpath + listMenuItems[index])
                                }
                            }
                        }
                    }

                }

            }

            // If too many folders we show scrollbars and buttons to go down (this oen) and up (above)
            Rectangle {

                id: godown

                // same color scheme as PQMenu
                color: (downmouse.containsMouse && (flick.contentY < flick.contentHeight-flick.height-1)) ? "#454545" : "#202020"
                border.width: 1
                border.color: "grey"

                width: menu.width
                height: visible ? 30 : 0

                // only show if too many folders
                visible: flick.contentHeight>fileview.height

                // the arrow image
                Image {
                    anchors.fill: parent
                    source: "/filedialog/downwards.svg"
                    opacity: (flick.contentY < flick.contentHeight-flick.height-1) ? 1 : 0.4
                    sourceSize: Qt.size(goup.height,goup.height)
                    fillMode: Image.PreserveAspectFit
                }

                // mouse handling
                PQMouseArea {
                    id: downmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered:
                        control.someMenuItemHovered = true
                    onExited:
                        control.someMenuItemHovered = false

                    // press and hold keeps scrolling down
                    onPressed: {
                        doGoDown()
                        timerGoDown.restart()
                    }
                    onReleased:
                        timerGoDown.stop()
                    Timer {
                        id: timerGoDown
                        interval: 200
                        repeat: true
                        running: false
                        onTriggered:
                            parent.doGoDown()
                    }
                    function doGoDown() {
                        flick.contentY = Math.min(flick.contentY+40, flick.contentHeight-flick.height)
                    }
                }
            }

        }
    }

    Connections {
        target: PQKeyPressMouseChecker
        // mouse clicks anywhere outside of the menu close the menu
        onReceivedMouseButtonPress: {
            if(!control.someMenuItemHovered && !scroll.active && !control.mouseOver)
                menu.close()
        }
        // pressing the escape button closes the menu
        onReceivedKeyPress: {
            if(key == Qt.Key_Escape)
                menu.close()
        }
    }

    Component.onCompleted: {
        // set the complete path
        if(bread_top.pathParts.length == 1)
            completePath = bread_top.pathParts[0]
        else {
            if(handlingGeneral.amIOnWindows()) {
                completePath = ""
                for(var i = 0; i <= index/2; ++i)
                    completePath += bread_top.pathParts[i] + "/"
            } else {
                completePath = "/"
                for(var i = 1; i <= index/2; ++i)
                    completePath += bread_top.pathParts[i] + "/"
            }
        }
        listMenuItems = handlingFileDialog.getFoldersIn(completePath)
    }

}
