/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9

import "../elements"
import QtGraphicalEffects 1.0

Item {

    id: streaming_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: PQSettings.interfacePopoutStreaming ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.interfacePopoutStreaming ? 0 : PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    property bool iAmScanning: false
    property var chromecastData: []

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.interfacePopoutStreaming ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#ee000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.interfacePopoutStreaming
            onClicked:
                button_cancel.clicked()
        }

        Text {
            id: heading
            y: insidecont.y-height
            width: parent.width
            text: "Chromecast"
            font.pointSize: 25
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
        }

        PQMouseArea {
            anchors.fill: insidecont
            anchors.margins: -50
            hoverEnabled: true
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: Math.max(300,childrenRect.width)
            height: Math.max(300, childrenRect.height)

            clip: true

            Column {

                spacing: 20

                Item {
                    width: 1
                    height: 1
                }

                Item {

                    x: (insidecont.width-width)/2
                    id: scanbut
                    width: 40
                    height: 40
                    PQMouseArea {
                        id: refreshmousearea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: "Scan for devices"
                        onClicked:
                            refresh()
                    }

                    Image {
                        anchors.fill: parent
                        mipmap: true
                        source: "/streaming/refresh.png"

                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            running: iAmScanning
                            from: 0
                            to: 360
                            duration: 1500
                        }

                    }

                }

                Repeater {
                    id: devs
                    model: chromecastData.length/2
                    Row {
                        spacing: 10
                        Text {
                            id: txt1
                            text: chromecastData[2*index]
                            font.pointSize: 15
                            color: "white"
                            font.bold: true
                        }
                        Text {
                            id: txt2
                            y: (txt1.height-height)/2
                            text: chromecastData[2*index+1]
                            font.pointSize: 12
                            font.italic: true
                            color: "#aaaaaa"
                        }

                    }
                }

                Item {
                    width: 1
                    height: 1
                }

            }

            Text {

                anchors.fill: insidecont
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "#aaaaaa"
                visible: chromecastData.length==0
                text: iAmScanning ? "searching for devices..." : "no devices found"

            }

        }

        PQButton {
            id: button_cancel
            x: (parent.width-width)/2
            y: insidecont.y+insidecont.height
            text: genericStringCancel
            onClicked: {
                if(PQSettings.interfacePopoutStreaming) {
                    streaming_window.visible = false
                } else {
                    streaming_top.opacity = 0
                    variables.visibleItem = ""
                }
                handlingstreaming.cancelScanForChromecast()
            }
        }

        Connections {
            target: handlingstreaming
            onUpdatedListChromecast: {
                chromecastData = devices
                iAmScanning = false
            }
        }

        Image {
            x: 5
            y: 5
            width: 15
            height: 15
            source: "/popin.png"
            opacity: popinmouse.containsMouse ? 1 : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                id: popinmouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: PQSettings.interfacePopoutStreaming ?
                             //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                             em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                             //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                             em.pty+qsTranslate("popinpopout", "Move to its own window")
                onClicked: {
                    if(PQSettings.interfacePopoutStreaming)
                        streaming_window.storeGeometry()
                    button_cancel.clicked()
                    PQSettings.interfacePopoutStreaming = !PQSettings.interfacePopoutStreaming
                    HandleShortcuts.executeInternalFunction("__streaming")
                }
            }
        }

        Connections {
            target: loader
            onStreamingPassOn: {
                if(what == "show") {
                    if(PQSettings.interfacePopoutStreaming) {
                        streaming_window.visible = true
                    } else {
                        opacity = 1
                        variables.visibleItem = "streaming"
                    }
                    refresh()
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_cancel.clicked()
                }
            }
        }

    }

    function refresh() {

        if(iAmScanning)
            return

        iAmScanning = true
        handlingstreaming.getListOfChromecastDevices()

    }

}
