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

import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: chromecast_top

    spacing: 20

    popout: PQSettings.interfacePopoutChromecast
    shortcut: "__chromecast"
    title: em.pty+qsTranslate("streaming", "Streaming (Chromecast)")

    buttonFirstText: genericStringClose


    property bool iAmScanning: false
    property var chromecastData: []

    onPopoutChanged:
        PQSettings.interfacePopoutChromecast = popout

    onButtonFirstClicked:
        closeElement()

    content: [

        Item {

            x: (parent.width-width)/2
            id: scanbut
            width: 40
            height: 40
            PQMouseArea {
                id: refreshmousearea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                //: Used as tooltip for button that starts a scan for Chromecast streaming devices in the local network
                tooltip: em.pty+qsTranslate("streaming", "Scan for devices")
                onClicked:
                    refresh()
            }

            Image {
                anchors.fill: parent
                mipmap: true
                source: "/streaming/refresh.svg"
                sourceSize: Qt.size(width, height)

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    running: iAmScanning
                    from: 0
                    to: 360
                    duration: 1500
                }

            }

        },

        Rectangle {

            id: devlistrect

            x: (parent.width-width)/2

            width: Math.min(parent.width, Math.max(500, parent.width/3))
            height: Math.min(parent.height, Math.max(300, parent.height/3))
            color: "transparent"
            border.width: 1
            border.color: "#aaaaaa"

            ListView {

                id: devs

                orientation: ListView.Vertical

                anchors.fill: parent
                anchors.margins: 1

                clip: true

                model: chromecastData.length/2

                delegate: Rectangle {

                    id: deleg
                    width: parent.width
                    height: 50

                    property bool hovering: false

                    color: hovering ? "#22ffffff" : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        width: parent.width
                        spacing: 10

                        Item {
                            width: 1
                            height: 1
                        }

                        PQTextL {
                            y: (deleg.height-height)/2
                            id: txt1
                            text: chromecastData[2*index]
                            font.weight: baselook.boldweight
                        }
                        PQText {
                            id: txt2
                            y: (deleg.height-height)/2
                            text: chromecastData[2*index+1]
                            font.italic: true
                            color: "#aaaaaa"
                        }

                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            deleg.hovering = true
                            connectbut.mouseOver = true
                        }
                        onExited: {
                            deleg.hovering = false
                            connectbut.mouseOver = false
                        }
                        onClicked:
                            connectbut.clicked()
                    }

                    PQButton {
                        id: connectbut
                        x: parent.width-width-10
                        y: (deleg.height-height)/2
                        text: ((variables.chromecastConnected && variables.chromecastName==chromecastData[2*index]) ?
                                   //: Written on button, as in 'Disconnect from connected Chromecast streaming device'
                                   em.pty+qsTranslate("streaming", "Disconnect") :
                                   //: Written on button, as in 'Connect to Chromecast streaming device'
                                   em.pty+qsTranslate("streaming", "Connect"))
                        enabled: !iAmScanning
                        onMouseOverChanged:
                            deleg.hovering = mouseOver
                        onClicked: {
                            if(enabled)
                                connectChromecast(chromecastData[2*index])
                        }
                    }

                    Rectangle {
                        y: parent.height-1
                        visible: index<chromecastData.length/2-1
                        width: parent.width
                        height: 1
                        color: "#aaaaaa"
                    }

                }

            }

            PQText {

                anchors.fill: devlistrect
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "#aaaaaa"
                visible: chromecastData.length==0
                text: iAmScanning ?
                          //: status text while searching for chromecast streaming devices in the local network
                          em.pty+qsTranslate("streaming", "searching for devices...") :
                          //: result of scan for chromecast streaming devices
                          em.pty+qsTranslate("streaming", "no devices found")

            }

        }

    ]

    Connections {
        target: handlingchromecast
        onUpdatedListChromecast: {
            chromecastData = devices
            iAmScanning = false
        }
    }

    Connections {
        target: loader
        onChromecastPassOn: {
            if(what == "show") {
//                if(PQSettings.interfacePopoutChromecast) {
//                    ele_window.visible = true
//                } else {
                handlingchromecast.cancelScanForChromecast()
                    opacity = 1
                    variables.visibleItem = "chromecast"
//                }
                if(chromecastData.length == 0 && !iAmScanning)
                    refresh()
            } else if(what == "hide") {
                closeElement()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    closeElement()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    closeElement()
            }
        }
    }

    function refresh() {

        if(iAmScanning)
            return

        iAmScanning = true
        handlingchromecast.getListOfChromecastDevices()

    }

    function connectChromecast(friendly_name) {

        if(variables.chromecastConnected) {

            handlingchromecast.disconnectFromDevice()

            if(variables.chromecastName == friendly_name) {
                variables.chromecastConnected = false
                variables.chromecastName = ""
                return
            }

        }

        if(handlingchromecast.connectToDevice(friendly_name)) {

            variables.chromecastConnected = true
            variables.chromecastName = friendly_name

            handlingchromecast.streamOnDevice(filefoldermodel.currentFilePath)

            closeElement()

        }

    }

    function closeElement() {

//        if(PQSettings.interfacePopoutChromecast) {
//            ele_window.visible = false
//        } else {
            chromecast_top.opacity = 0
            variables.visibleItem = ""
//        }
        handlingchromecast.cancelScanForChromecast()

    }

}
