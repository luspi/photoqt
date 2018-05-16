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
import "../elements"

Rectangle {

    id: ele_top

    color: "#bb000000"
    anchors.fill: parent

    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    // click on bg closes element
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked:
            hide()
        onWheel: { }
    }

    // item containing text in middle
    Rectangle {
        id: cont
        color: "#88000000"
        width: 640
        height: Math.min(Math.min(flick.height, 800), settings_top.height-20)
        radius: 5
        x: (parent.width-width)/2
        y: (parent.height-height)/2

        // don't close when clicking on text
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        ScrollBarVertical {
            flickable: flick
            opacityHidden: opacityVisible
        }

        // since we have a max height, we use a flickable to accommodate longer text
        Flickable {

            id: flick

            x: 20
            y: 20
            width: parent.width-40
            height: Math.min(Math.min(flickcont.height,800), settings_top.height-20)
            contentHeight: flickcont.height
            clip: true


            // the content item
            Rectangle {

                id: flickcont

                color: "transparent"
                width: flick.width
                height: childrenRect.height

                // a colum for two text items: settings title and settings helptext
                Column {

                    spacing: 20

                    // the settings title
                    Text {
                        id: setting_title
                        width: flick.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 30
                        wrapMode: Text.WordWrap
                        font.bold: true
                        color: "white"
                        // no need to translate, they will be set to a different value before showing element
                        text: "Settings Title"
                    }
                    // the settings helptext
                    Text {
                        id: setting_helptext
                        width: flick.width
                        font.pointSize: 15
                        wrapMode: Text.WordWrap
                        color: "white"
                        // no need to translate, they will be set to a different value before showing element
                        text: "Some helptext for this setting"

                    }

                }

            }

        }

    }

    // An transparent 'x' also for closing item
    Text {
        x: cont.x+cont.width-width/2
        y: cont.y-height/2
        font.pointSize: 15
        font.bold: true
        opacity: 0.1
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
        color: "white"
        text: "x"
        ToolTip {
            text: em.pty+qsTr("Click to close")
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: parent.opacity = 0.6
            onExited: parent.opacity = 0.1
            onClicked: hide()
        }
    }

    function show(title, helptext) {
        verboseMessage("SettingsManager/SettingsInfoOverlay", "show(): " + title + " / " + helptext)
        setting_title.text = title
        setting_helptext.text = helptext+"<br>"
        opacity = 1
    }
    function hide() {
        opacity = 0
    }

}
