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
import "../handlestuff.js" as Handle

Rectangle {

    id: rect

    // Positioning and basic look
    x: 0
    y: 0
    width: mainwindow.width
    height: mainwindow.height
    color: colour.fadein_slidein_bg

    // Invisible at startup
    opacity: 0
    visible: opacity!=0

    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    property real lastOpacityValue: 0
    onOpacityChanged: {
        if(openFileAfter == "" && opacity > 0.1 && opacity < lastOpacityValue)
            call.show("openfile")
        else if(!visible)
            Handle.loadFile(openFileAfter, variables.filter)
        lastOpacityValue = opacity
    }

    property string type: ""

    property string openFileAfter: ""

    // Catch mouse events
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    // Scrollarea
    Rectangle {

        id: holder

        color: "transparent"

        width: rect.width
        height: col.height

        anchors.horizontalCenter: rect.horizontalCenter
        anchors.verticalCenter: rect.verticalCenter

        clip: true

        Column {

            id: col

            spacing: 15

            Rectangle {
                color: "#00000000"
                width: 1
                height: 5
            }

            // HEADER LOGO
            Image {
                source: "qrc:/img/logo.png"
                width: Math.min(300, holder.width/2)
                height: sourceSize.height*(width/sourceSize.width)
                x: (holder.width-width)/2
            }

            Rectangle {
                color: "#00000000"
                width: 1
                height: 10
            }

            Text {
                id: welcome
                text: em.pty+qsTr("Welcome to PhotoQt")
                color: "white"
                font.pointSize: 45
                width: holder.width
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                color: "white"
                font.pointSize: 20
                width: Math.min(welcome.width-200,600)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: type=="installed" ? em.pty+qsTr("PhotoQt was successfully installed!") + "<br>"
                                          + em.pty+qsTr("An image viewer packed with features and adjustable in every detail awaits you... Go, enjoy :-)")
                                        : em.pty+qsTr("PhotoQt was successfully updated!") + "<br>"
                                          + em.pty+qsTr("Many new features and bug fixes await you... Go, enjoy :-)")
            }

            Rectangle {
                color: "#00000000"
                width: 1
                height: 15
            }

            CustomButton {
                text: em.pty+qsTr("Lets get started!")
                fontsize: 30
                anchors.horizontalCenter: col.horizontalCenter
                onClickedButton: hideStartup()
            }

        } // END Column

    } // END Flickable

    Connections {
        target: call
        onStartupShow:
            showStartup(type, filename)
        onShortcut: {
            if(!rect.visible) return
            if(sh == "Escape")
                hideStartup()
        }
        onCloseAnyElement:
            if(rect.visible)
                hideStartup()
    }

    function showStartup(t, filenameAfter) {

        verboseMessage("Other/Startup", "showStartup(): " + t + " / " + filenameAfter)

        type = (t===1 ? "updated" : "installed");
        openFileAfter = filenameAfter

        opacity = 1
        variables.guiBlocked = true

    }

    function hideStartup() {

        verboseMessage("Other/Startup", "hideStartup()")

        opacity = 0
        variables.guiBlocked = false

    }

}
