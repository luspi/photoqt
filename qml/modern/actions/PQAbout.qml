/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import PhotoQt

PQTemplateFullscreen {

    id: about_top

    thisis: "about"
    popout: PQCSettings.interfacePopoutAbout // qmllint disable unqualified
    forcePopout: PQCWindowGeometry.aboutForcePopout // qmllint disable unqualified
    shortcut: "__about"

    title: qsTranslate("about", "About")

    onPopoutChanged:
        PQCSettings.interfacePopoutAbout = popout // qmllint disable unqualified

    button1.onClicked:
        hide()

    content: [

        Image {
            x: (parent.width-width)/2
            width: 400
            height: 400
            fillMode: Image.PreserveAspectFit
            source: "image://svg/:/other/logo_full.svg"
        },

        PQTextL {
            x: (parent.width-width)/2
            property date currentDate: new Date()
            text: "&copy; 2011-" + Qt.formatDateTime(new Date(), "yyyy") + " Lukas Spies"
            textFormat: Text.RichText
        },

        PQButton {
            id: configbutton
            x: (parent.width-width)/2
            text: "PhotoQt v" + PQCScriptsConfig.getVersion() // qmllint disable unqualified
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
        color: PQCLook.baseColor // qmllint disable unqualified

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

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
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                }

                PQText {
                    id: configinfo_txt
                    text: PQCScriptsConfig.getConfigInfo(true) // qmllint disable unqualified
                    lineHeight: 1.2
                }

                Row {
                    x: (parent.width-width)/2
                    spacing: 10
                    PQButton {
                        id: configclipbut
                        text: qsTranslate("about", "Copy to clipboard")
                        onClicked:
                            PQCScriptsClipboard.copyTextToClipboard(configinfo_txt.text, true) // qmllint disable unqualified
                    }
                    PQButton {
                        id: configclosebut
                        text: genericStringClose
                        onClicked:
                            configinfo.opacity = 0
                    }
                }

            }

        }

    }

    Connections {

        target: PQCNotifyQML

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === about_top.thisis)
                    about_top.show()

            } else if(what === "hide") {

                if(param[0] === about_top.thisis)
                    about_top.hide()

            } else if(about_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(about_top.closeAnyMenu())
                        return

                    else if(param[0] === Qt.Key_Escape)
                        about_top.hide()

                }

            }

        }

    }

    function closeAnyMenu() : bool {

        if(configbutton.contextmenuVisible) {
            configbutton.closeContextmenu()
            return true
        }
        if(configclipbut.contextmenuVisible) {
            configclipbut.closeContextmenu()
            return true
        }
        if(configclosebut.contextmenuVisible) {
            configclosebut.closeContextmenu()
            return true
        }
        if(about_top.contextMenuOpen) {
            about_top.closeContextMenus()
            return true
        }
        return false
    }

    function show() {
        opacity = 1
        if(popoutWindowUsed)
            about_popout.visible = true // qmllint disable unqualified
    }

    function hide() {

        closeAnyMenu()

        if(configinfo.opacity > 0)
            configinfo.opacity = 0
        else {
            about_top.opacity = 0
            if(popoutWindowUsed)
                about_popout.visible = false // qmllint disable unqualified
            else
                PQCNotifyQML.loaderRegisterClose(thisis)
        }
    }

}
