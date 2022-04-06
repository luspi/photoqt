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

import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: about_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Rectangle {

        anchors.fill: parent
        color: "#f8000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: PQSettings.interfacePopoutAbout ? Qt.ArrowCursor : Qt.PointingHandCursor
            tooltip: em.pty+qsTranslate("about", "Close")
            enabled: !PQSettings.interfacePopoutAbout
            onClicked:
                button_close.clicked()
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
            width: childrenRect.width
            height: childrenRect.height

            Column {

                spacing: 10

                Item {
                    width: 1
                    height: 5
                }

                Image {
                    source: "qrc:/other/logo.png"
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 15
                    property date currentDate: new Date()
                    text: "&copy; 2011-" + Qt.formatDateTime(new Date(), "yyyy") + " Lukas Spies"
                    textFormat: Text.RichText
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "Current version:") + " " + handlingGeneral.getVersion()
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "License:") + " GPL 2+"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: em.pty+qsTranslate("about", "Open license")
                        onClicked:
                            Qt.openUrlExternally("http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt")
                    }
                }

                Item {
                    width: 1
                    height: 1
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "Website:") + " https://photoqt.org"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: em.pty+qsTranslate("about", "Open website")
                        onClicked:
                            Qt.openUrlExternally("https://photoqt.org")
                    }
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "Contact:") + " Lukas@photoqt.org"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: em.pty+qsTranslate("about", "Send an email")
                        onClicked:
                            Qt.openUrlExternally("mailto:Lukas@photoqt.org")
                    }
                }

                Item {
                    width: 1
                    height: 5
                }

                PQButton {
                    id: button_close
                    x: (parent.width-width)/2
                    y: parent.height-height-10
                    text: em.pty+qsTranslate("about", "Close")
                    tooltip: text
                    onClicked: {
                        about_top.opacity = 0
                        variables.visibleItem = ""
                    }
                }

                Item {
                    width: 1
                    height: 5
                }

            }

        }

        Connections {
            target: loader
            onAboutPassOn: {
                if(what == "show") {
                    opacity = 1
                    variables.visibleItem = "about"
                } else if(what == "hide") {
                    button_close.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_close.clicked()
                }
            }
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
            tooltip: PQSettings.interfacePopoutAbout ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutAbout)
                    about_window.storeGeometry()
                button_close.clicked()
                PQSettings.interfacePopoutAbout = !PQSettings.interfacePopoutAbout
                HandleShortcuts.executeInternalFunction("__about")
            }
        }
    }

}
