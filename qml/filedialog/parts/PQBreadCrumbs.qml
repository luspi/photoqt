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
import "../../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: bread_top

    property var pathParts: []

    height: 50

    function goBackwards() {
        backwards.clicked()
    }
    function canGoBackwards() {
        return backwards.enabled
    }

    function goForwards() {
        forwards.clicked()
    }
    function canGoForwards() {
        return forwards.enabled
    }

    PQButton {

        id: backwards

        x: 0
        y: (bread_top.height-height)/2
        width: height

        enabled: filedialog_top.historyListIndex>0

        leftRightTextSpacing: 0
        imageButtonSource: "/filedialog/backwards.svg"

        onClicked: {
            if(filedialog_top.historyListIndex > 0) {
                filedialog_top.historyListIndex -= 1
                filedialog_top.setCurrentDirectory(filedialog_top.historyListDirectory[filedialog_top.historyListIndex], false)
            }
        }

        tooltip: em.pty+qsTranslate("filedialog", "Backwards")
        tooltipFollowsMouse: false

    }

    PQButton {

        id: upwards

        anchors.left: backwards.right
        anchors.leftMargin: 5
        y: (bread_top.height-height)/2
        width: height

        enabled: !handlingFileDir.isRoot(filefoldermodel.folderFileDialog)

        leftRightTextSpacing: 0
        imageButtonSource: "/filedialog/upwards.svg"

        onClicked: {
            if(handlingGeneral.amIOnWindows())
                filedialog_top.setCurrentDirectory(filefoldermodel.folderFileDialog + "\\..", false)
            else
                filedialog_top.setCurrentDirectory(filefoldermodel.folderFileDialog + "/../", false)
        }

        tooltip: em.pty+qsTranslate("filedialog", "Up a level")
        tooltipFollowsMouse: false

    }

    PQButton {

        id: forwards

        anchors.left: upwards.right
        anchors.leftMargin: 5
        y: (bread_top.height-height)/2
        width: height

        enabled: filedialog_top.historyListIndex<filedialog_top.historyListDirectory.length-1

        leftRightTextSpacing: 0
        imageButtonSource: "/filedialog/forwards.svg"

        onClicked: {
            if(filedialog_top.historyListIndex < filedialog_top.historyListDirectory.length-1) {
                filedialog_top.historyListIndex += 1
                filedialog_top.setCurrentDirectory(filedialog_top.historyListDirectory[filedialog_top.historyListIndex], false)
            }
        }

        tooltip: em.pty+qsTranslate("filedialog", "Forwards")
        tooltipFollowsMouse: false

    }

    Rectangle {
        id: sep1
        anchors.left: forwards.right
        anchors.leftMargin: 5
        width: 1
        height: bread_top.height
        color: "#444444"
    }

    PQText {
        id: dotdotdot
        anchors.left: sep1.right
        anchors.leftMargin: visible ? 10 : 0
        text: visible ? "..." : ""
        height: bread_top.height
        verticalAlignment: Text.AlignVCenter
        opacity: 0.5
        font.bold: true
        visible: path.contentWidth > path.width
    }

    ListView {

        id: path

        anchors.left: dotdotdot.right
        anchors.leftMargin: 10
        anchors.right: sep2.left
        anchors.rightMargin: 10

        height: bread_top.height

        clip: true
        interactive: false

        boundsBehavior: Flickable.StopAtBounds

        orientation: Qt.Horizontal
        Component.onCompleted:
            path.contentX = Math.max(0, path.contentWidth-path.width)
        onWidthChanged:
            path.contentX = Math.max(0, path.contentWidth-path.width)
        onContentWidthChanged:
            path.contentX = Math.max(0, path.contentWidth-path.width)

        // we do this with delay to avoid some visual glitches when the path is wider than the space
        Timer {
            interval: 100
            repeat: false
            running: true
            onTriggered:
                parent.model = Qt.binding(function() { return Math.max(0, 2*pathParts.length); })
        }

        delegate: PQBreadCrumbsButton {}

    }

    Rectangle {
        id: sep2
        anchors.right: cancelbut.left
        anchors.rightMargin: 5
        width: 1
        height: bread_top.height
        color: "#444444"
    }

    PQButton {

        id: cancelbut
        anchors.right: fullscreenwindow.left
        anchors.margins: 5
        y: (parent.height-height)/2

        backgroundColor: "#444444"
        backgroundColorHover: "#5a5a5a"
        backgroundColorActive: "#555555"

        text: genericStringCancel

        onClicked: filedialog_top.hideFileDialog()

    }

    Item {
        id: fullscreenwindow
        anchors.right: closefileview.left
        anchors.rightMargin: -5
        height: parent.height
        width: height

        Image {

            anchors.fill: parent
            anchors.margins: 5

            sourceSize: Qt.size(width, height)

            mipmap: true

            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            source: PQSettings.interfaceWindowMode ? "/mainwindow/fullscreen_on.svg" : "/mainwindow/fullscreen_off.svg"

        }

        PQMouseArea {
            anchors.fill: parent
            tooltip: PQSettings.interfaceWindowMode ? em.pty+qsTranslate("filedialog", "Enter fullscreen")
                                           : em.pty+qsTranslate("filedialog", "Exit fullscreen")
            tooltipFollowsMouse: false
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
        }

    }

    Item {
        id: closefileview
        anchors.right: parent.right
        height: parent.height
        width: height

        Image {

            anchors.fill: parent
            anchors.margins: 5

            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            source: "/other/close.svg"
            sourceSize: Qt.size(width, height)

        }

        PQMouseArea {
            anchors.fill: parent
            tooltip: em.pty+qsTranslate("filedialog", "Close")
            tooltipFollowsMouse: false
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toplevel.close()
        }

    }


    Rectangle {

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: "#aaaaaa"
    }

}
