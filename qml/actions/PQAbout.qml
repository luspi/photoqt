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

PQTemplate {

    id: about_top

    title: "About PhotoQt"

    elementId: "About"

    width: 640
    height: 640

    property bool configShown: false
    signal showConfig()
    signal hideConfig()

    SystemPalette { id: pqtPalette }

    Connections {
        target: about_top.button1
        function onClicked() {
            about_top.hide()
        }
    }

    content: [

        Flickable {

            y: (about_top.availableHeight-height)/2

            width: about_top.width
            height: Math.min(about_top.availableHeight, contentHeight)

            contentHeight: col.height

            Column {

                id: col

                spacing: 5

                Image {
                    x: (about_top.width-width)/2
                    width: 300
                    height: 300
                    fillMode: Image.PreserveAspectFit
                    source: "image://svg/:/other/logo_full.svg"
                }

                Item {
                    width: 1
                    height: -20
                }

                PQTextL {
                    x: (about_top.width-width)/2
                    property date currentDate: new Date()
                    text: "&copy; 2011-" + Qt.formatDateTime(new Date(), "yyyy") + " Lukas Spies"
                    textFormat: Text.RichText
                }

                PQButton {
                    id: configbutton
                    flat: true
                    x: (about_top.width-width)/2
                    font.weight: PQCLook.fontWeightBold
                    text: "PhotoQt v" + PQCScriptsConfig.getVersion()
                    //: The 'configuration' talked about here refers to the configuration at compile time, i.e., which image libraries were enabled and which versions
                    onClicked: {
                        if(!configloader.active)
                            configloader.active = true
                        else
                            about_top.showConfig()
                    }
                    tooltip: qsTranslate("about", "Show configuration overview")


                }

                PQText {
                    x: (about_top.width-width)/2
                    text: qsTranslate("about", "License:") + " GPL 2+"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("about", "Open license in browser")
                        onClicked:
                            Qt.openUrlExternally("http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt")
                    }
                }

                Item {
                    width: 1
                    height: 1
                }

                PQText {
                    x: (about_top.width-width)/2
                    text: qsTranslate("about", "Website:") + " https://photoqt.org"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("about", "Open website in browser")
                        onClicked:
                            Qt.openUrlExternally("https://photoqt.org")
                    }
                }

                PQText {
                    x: (about_top.width-width)/2
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

                Item {
                    visible: closebut.visible
                    width: 1
                    height: 20
                }

                PQButton {
                    id: closebut
                    visible: PQCSettings.generalInterfaceVariant==="integrated"
                    x: (about_top.width-width)/2
                    text: genericStringClose
                    Component.onCompleted:
                        visible = visible   // don't have property binding in case setting changes at runtime
                    onClicked:
                        about_top.hide()
                }

            }
        }

    ]

    Loader {
        id: configloader
        active: false
        sourceComponent:
        ApplicationWindow {

            id: config_window

            width: 600
            height: 400

            modality: Qt.ApplicationModal
            flags: Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint

            onVisibilityChanged: (visibility) => {
                if(visibility === Window.Hidden)
                    about_top.configShown = false
                else
                    about_top.configShown = true
            }

            Flickable {

                anchors.fill: parent
                anchors.bottomMargin: config_window.height-configcloserow.y+5

                contentHeight: configcol.height+20
                clip: true

                ScrollBar.vertical: ScrollBar { id: scroll }

                Column {

                    id: configcol

                    x: 5
                    width: config_window.width-scroll.width-10

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

                }

            }

            Rectangle {
                y: configcloserow.y-5
                width: parent.width
                height: 1
                color: pqtPalette.text
            }

            Row {
                id: configcloserow
                x: (parent.width-width)/2
                y: (parent.height-height-10)
                spacing: 10
                PQButton {
                    id: configclipbut
                    text: qsTranslate("about", "Copy to clipboard")
                    onClicked:
                        PQCScriptsClipboard.copyTextToClipboard(configinfo_txt.text, true)
                }

                PQButton {
                    id: configclosebutton
                    text: "Close"
                    onClicked: {
                        config_window.close()
                    }
                }
            }

            Connections {
                target: about_top
                function onShowConfig() {
                    config_window.show()
                }
                function onHideConfig() {
                    config_window.close()
                }
            }

            Component.onCompleted:
                config_window.show()

        }
    }

    PQToolTipDisplay { id: ttip }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(about_top.visible) {

                if(what === "keyEvent") {
                    if(param[0] === Qt.Key_Escape) {
                        if(about_top.configShown)
                            about_top.hideConfig()
                        else
                            about_top.hide()
                    }
                }

            }

        }

    }

}
