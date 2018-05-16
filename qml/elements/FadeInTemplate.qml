/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"

Rectangle {

    id: fadein_top

    x: 0
    y: 0
    width: mainwindow.width
    height: mainwindow.height
    color: colour.fadein_slidein_bg

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    visible: opacity!=0
    property real lastOpacityValue: 0
    onOpacityChanged: {
        if(variables.currentFile === "" && opacity > 0.1 && opacity < lastOpacityValue)
            call.show("openfile")
        lastOpacityValue = opacity
    }

    property int marginLeftRight: mainwindow.width > 800 ? 25 : 5
    property int marginTopBottom: mainwindow.height > 600 ? 25 : 5

    property int contentWidth: fadein_top.width-2*marginLeftRight
    property int contentHeight: fadein_top.height-2*marginTopBottom

    property bool showSeperators: true

    // These are used to insert the elements
    property string heading: ""
    property alias content: content_placeholder.children
    property alias buttons: button_placeholder.children

    property bool hideButtons: false
    property bool hideTitle: false

    property bool clipContent: true

    // catch mousevent, don't pass them through
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }

    // Display heading at top
    Text {

        id: title
        x: marginLeftRight*1.5
        y: marginTopBottom
        width: fadein_top.width-2*marginLeftRight
        visible: !hideTitle
        text: heading

        font.pointSize: 40
        color: "white"
        font.bold: true

    }

    Rectangle {
        id: sep1
        width: content_placeholder.width
        x: marginLeftRight
        anchors.top: title.bottom
        anchors.topMargin: hideTitle ? 0 : 5
        height: hideTitle ? 0 : 1
        visible: showSeperators && !hideTitle
        color: colour.linecolour
    }

    // Scrollable content in the middle
    Flickable {

        id: item

        contentHeight: content_placeholder.childrenRect.height
        contentWidth: fadein_top.width-2*marginLeftRight
        clip: clipContent

        // Set size
        anchors {
            left: parent.left
            right: parent.right
            top: hideTitle ? parent.top : sep1.bottom
            bottom: hideButtons ? parent.bottom : sep2.top
            leftMargin: marginLeftRight
            rightMargin: marginLeftRight
            topMargin: hideTitle ? 15 : 5
            bottomMargin: hideButtons ? 15 : 5
        }

        Column {

            // PLACEHOLDER

            id: content_placeholder
            spacing: 10

        }

    }

    // Horizontal line
    Rectangle {
        id: sep2
        x: marginLeftRight
        anchors.bottom: button_placeholder.top
        anchors.bottomMargin: hideButtons ? 0 : 10
        width: content_placeholder.width
        height: hideButtons ? 0 : 1
        visible: showSeperators && !hideButtons
        color: colour.linecolour
    }

    Rectangle {

        // PLACEHOLDER

        id: button_placeholder

        visible: !hideButtons

        x: marginLeftRight
        width: content_placeholder.width
        height: hideButtons ? 0 : childrenRect.height+10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: hideButtons ? 0 : 40

        color: "#00000000"

    }

    function show() {
        verboseMessage("FadeInTemplate", "show(): " + getanddostuff.convertIdIntoString(fadein_top))
        opacity = 1
        variables.guiBlocked = true
    }
    function hide() {
        verboseMessage("FadeInTemplate", "hide(): " + getanddostuff.convertIdIntoString(fadein_top))
        opacity = 0
        variables.guiBlocked = false
    }

}

