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

import PQCScriptsChromeCast

import "../elements"

PQTemplateFullscreen {

    id: chromecastmanager_top

    thisis: "chromecastmanager"
    popout: PQCSettings.interfacePopoutChromecast
    shortcut: "__chromecast"

    title: qsTranslate("streaming", "Streaming (Chromecast)")

    onPopoutChanged:
        PQCSettings.interfacePopoutChromecast = popout

    //: Used as in: Connect to chromecast device
    button1.text: qsTranslate("streaming", "Connect")
    button1.enabled: view.currentIndex>-1
    button1.onClicked: connectToDevice()

    button2.visible: true
    button2.text: genericStringCancel
    button2.onClicked:
        hide()

    button3.visible: PQCScriptsChromeCast.connected
    //: Used as in: Disconnect from chromecast device
    button3.text: qsTranslate("streaming", "Disconnect")
    button3.onClicked: PQCScriptsChromeCast.disconnect()

    content: [

        Rectangle {

            x: (parent.width-width)/2

            width: 600
            height: 400

            color: PQCLook.baseColor

            ListView {

                id: view

                anchors.fill: parent
                anchors.margins: 5

                clip: true
                spacing: 10

                model: PQCScriptsChromeCast.availableDevices.length

                delegate: Rectangle {
                    width: 600
                    height: 50
                    color: view.currentIndex==index ? PQCLook.transColorActive : (hovered ? PQCLook.transColorHighlight : PQCLook.transColorAccent)

                    property bool hovered: false

                    Row {
                        x: 10
                        y: (parent.height-height)/2
                        spacing: 10
                        PQText {
                            y: (parent.height-height)/2
                            text: PQCScriptsChromeCast.availableDevices[index][0]
                            font.weight: PQCLook.fontWeightBold
                        }
                        PQText {
                            y: (parent.height-height)/2
                            text: PQCScriptsChromeCast.availableDevices[index][1]
                            font.italic: true
                        }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                        onClicked: view.currentIndex = index
                    }

                }

            }

            PQTextL {
                anchors.centerIn: parent
                visible: !busy.visible && PQCScriptsChromeCast.availableDevices.length === 0
                font.weight: PQCLook.fontWeightBold
                color: PQCLook.textColorActive
                //: The devices here are chromecast devices
                text: qsTranslate("streaming", "No devices found")
            }

            PQWorking {
                id: busy
                anchors.fill: parent
            }

        },

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQText {
                font.weight: PQCLook.fontWeightBold
                //: The status refers to whether the chromecast manager is currently scanning or idle
                text: qsTranslate("streaming", "Status:")
            }
            PQText {
                text: PQCScriptsChromeCast.inDiscovery&&busy.visible ?
                          qsTranslate("streaming", "Looking for Cromecast devices") :
                          (PQCScriptsChromeCast.availableDevices.length>0 ?
                               qsTranslate("streaming", "Select which device to connect to") :
                               qsTranslate("streaming", "No devices found"))
            }
        }

    ]

    Timer {
        id: restartDiscovery
        interval: 5000
        onTriggered: {
            PQCScriptsChromeCast.startDiscovery()
        }
    }

    Connections {
        target: PQCScriptsChromeCast
        function onInDiscoveryChanged() {
            if(PQCScriptsChromeCast.inDiscovery && PQCScriptsChromeCast.availableDevices.length === 0)
                busy.showBusy()
            else
                busy.hide()

            if(!PQCScriptsChromeCast.inDiscovery && chromecastmanager_top.visible)
                restartDiscovery.restart()
        }
    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(chromecastmanager_top.opacity > 0) {

                if(what === "keyEvent") {
                    if(param[0] === Qt.Key_Escape)
                        hide()
                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        connectToDevice()
                }

            }

        }

    }

    function connectToDevice() {
        if(button1.enabled)
            PQCScriptsChromeCast.connectToDevice(view.currentIndex)
        hide()
    }

    function show() {
        opacity = 1
        // we also show the chromecast handler
        loader.show("chromecast")
        if(popout)
            chromecastmanager_popout.show()

        PQCScriptsChromeCast.startDiscovery()


    }

    function hide() {
        opacity = 0
        loader.elementClosed(thisis)
    }

}
