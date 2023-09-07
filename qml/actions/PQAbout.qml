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

import PQCScriptsConfig
import PQCScriptsClipboard

import "../elements"

PQTemplateFullscreen {

    id: about_top

    thisis: "about"
    popout: PQCSettings.interfacePopoutAbout
    shortcut: "__about"

    title: qsTranslate("about", "About")

    onPopoutChanged:
        PQCSettings.interfacePopoutAbout = popout

    button1.onClicked:
        hide()

    content: [

        Image {
            x: (parent.width-width)/2
            source: "/white/logo.png"
        },

        PQTextL {
            x: (parent.width-width)/2
            property date currentDate: new Date()
            text: "&copy; 2011-" + Qt.formatDateTime(new Date(), "yyyy") + " Lukas Spies"
            textFormat: Text.RichText
        },

        PQButton {
            x: (parent.width-width)/2
            text: "PhotoQt v" + PQCScriptsConfig.getVersion()
            //: The 'configuration' talked about here refers to the configuration at compile time, i.e., which image libraries were enabled and which versions
            tooltip: qsTranslate("about", "Show configuration overview")
            onClicked:
                configinfo.opacity = 1
        },

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("about", "License:") + " GPL 2+"
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("about", "Open license in browser")
                onClicked:
                    Qt.openUrlExternally("http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt")
            }
        },

        Item {
            width: 1
            height: 1
        },

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("about", "Website:") + " https://photoqt.org"
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("about", "Open website in browser")
                onClicked:
                    Qt.openUrlExternally("https://photoqt.org")
            }
        },

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("about", "Contact:") + " Lukas@photoqt.org"
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("about", "Send an email")
                onClicked:
                    Qt.openUrlExternally("mailto:Lukas@photoqt.org")
            }
        }
    ]

    Rectangle {

        id: configinfo

        anchors.fill: parent
        color: PQCLook.baseColor

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        Flickable {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            width: parent.width
            height: Math.min(parent.height-20, configcol.height)

            contentHeight: configcol.height

            ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

            Column {

                id: configcol

                x: (parent.width-width)/2
                y: (parent.height-height)/2

                spacing: 10

                PQTextXL {
                    x: (parent.width-width)/2
                    //: The 'configuration' talked about here refers to the configuration at compile time, i.e., which image libraries were enabled and which versions
                    text: qsTranslate("about", "Configuration")
                    lineHeight: 1.2
                    font.weight: PQCLook.fontWeightBold
                }

                PQText {
                    id: configinfo_txt
                    text: PQCScriptsConfig.getConfigInfo(true)
                    lineHeight: 1.2
                }

                Row {
                    x: (parent.width-width)/2
                    spacing: 10
                    PQButton {
                        text: qsTranslate("about", "Copy to clipboard")
                        onClicked:
                            PQCScriptsClipboard.copyTextToClipboard(configinfo_txt.text, true)
                    }
                    PQButton {
                        text: genericStringClose
                        onClicked:
                            configinfo.opacity = 0
                    }
                }

            }

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

            } else if(about_top.opacity > 0) {

                if(what === "keyEvent") {
                    if(param[0] === Qt.Key_Escape)
                        hide()
                }

            }

        }

    }

    function show() {
        opacity = 1
    }

    function hide() {
        if(configinfo.opacity > 0)
            configinfo.opacity = 0
        else {
            about_top.opacity = 0
            loader.elementClosed(thisis)
        }
    }

}
