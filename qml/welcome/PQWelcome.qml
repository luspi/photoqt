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
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {

    id: top_first

    //: Window title
    title: em.pty+qsTranslate("welcome", "Welcome to PhotoQt")

    minimumWidth: 600
    minimumHeight: 500

    color: "#ffffff"

    x: (handlingExternal.getScreenSize().width-width)/2
    y: (handlingExternal.getScreenSize().height-height)/2

    Item {

        anchors.fill: parent

        Column {

            spacing: 10
            x: 5
            width: top_first.width-10

            Item {
                width: 1
                height: 1
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: em.pty+qsTranslate("welcome", "Welcome to PhotoQt")
                font.pointSize: 20
                font.bold: true
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: em.pty+qsTranslate("welcome", "PhotoQt is an image viewer that wants to adapt to your needs, thus it is highly customizable. Below you can choose one of three sets of default settings to start out with.")
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                //: The 'here' refers to the welcome window new users see where they can choose one of three sets of default settings
                text: em.pty+qsTranslate("welcome", "If you do not know what to do here, that is nothing to worry about: Simply click on continue.")
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: em.pty+qsTranslate("welcome", "Note that you can change any and all of these settings (and many more) at any time from the settings manager.")
            }

            Row {

                id: optrow

                x: (parent.width-width)/2

                spacing: 20

                property int maxRadioheight: 0

                Column {

                    Image {
                        width: 150
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        source: "/welcome/single.png"
                        opacity: radio_single.checked ? 1 : 0.5
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                radio_single.checked = true
                        }
                    }

                    RadioButton {
                        id: radio_single
                        x: (150-width)/2
                        text: ""
                        ButtonGroup.group: radiogroup
                        checked: true
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Text {
                        width: 150
                        horizontalAlignment: Text.AlignHCenter
                        //: one of three sets of default settings in the welcome screen
                        text: em.pty+qsTranslate("welcome", "show everything integrated into main window")
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: radio_single.checked ? "#000000" : "#888888"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: radio_single.checked = true
                        }
                    }

                }

                Column {

                    Image {
                        width: 150
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        source: "/welcome/mixed.png"
                        opacity: radio_mixed.checked ? 1 : 0.5
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                radio_mixed.checked = true
                        }
                    }

                    RadioButton {
                        id: radio_mixed
                        x: (150-width)/2
                        text: ""
                        ButtonGroup.group: radiogroup
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Text {
                        width: 150
                        horizontalAlignment: Text.AlignHCenter
                        //: one of three sets of default settings in the welcome screen
                        text: em.pty+qsTranslate("welcome", "show some things integrated into the main window and some on their own")
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: radio_mixed.checked ? "#000000" : "#888888"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: radio_mixed.checked = true
                        }
                    }

                }

                Column {


                    Image {
                        width: 150
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        source: "/welcome/individual.png"
                        opacity: radio_individual.checked ? 1 : 0.5
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                radio_individual.checked = true
                        }
                    }

                    RadioButton {
                        id: radio_individual
                        x: (150-width)/2
                        text: ""
                        ButtonGroup.group: radiogroup
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Text {
                        width: 150
                        horizontalAlignment: Text.AlignHCenter
                        //: one of three sets of default settings in the welcome screen
                        text: em.pty+qsTranslate("welcome", "show everything in its own window")
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: radio_individual.checked ? "#000000" : "#888888"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: radio_individual.checked = true
                        }
                    }

                }

                ButtonGroup { id: radiogroup }

            }

            Item {
                width: 1
                height: 20
            }

            Button {
                x: (parent.width-width)/2
                //: written on a clickable button
                text: em.pty+qsTranslate("welcome", "Continue")
                focus: true
                onClicked:
                    top_first.close()
            }

        }

    }

    Component.onCompleted: {
        top_first.showNormal()
    }

    onClosing: {

        // everything in one single window
        if(radio_single.checked) {

            PQSettings.interfacePopoutMainMenu = 0
            PQSettings.interfacePopoutMetadata = 0
            PQSettings.interfacePopoutHistogram = 0
            PQSettings.interfacePopoutScale = 0
            PQSettings.interfacePopoutOpenFile = 0
            PQSettings.interfacePopoutSlideShowSettings = 0
            PQSettings.interfacePopoutSlideShowControls = 0
            PQSettings.interfacePopoutFileRename = 0
            PQSettings.interfacePopoutFileDelete = 0
            PQSettings.interfacePopoutAbout = 0
            PQSettings.interfacePopoutImgur = 0
            PQSettings.interfacePopoutWallpaper = 0
            PQSettings.interfacePopoutFilter = 0
            PQSettings.interfacePopoutSettingsManager = 0
            PQSettings.interfacePopoutFileSaveAs = 0

            PQSettings.interfaceWindowMode = 1
            PQSettings.interfaceWindowDecoration = 1

        // everything in its own window
        } else if(radio_individual.checked) {

            PQSettings.interfacePopoutMainMenu = 1
            PQSettings.interfacePopoutMetadata = 1
            PQSettings.interfacePopoutHistogram = 1
            PQSettings.interfacePopoutScale = 1
            PQSettings.interfacePopoutOpenFile = 1
            PQSettings.interfacePopoutSlideShowSettings = 1
            PQSettings.interfacePopoutSlideShowControls = 1
            PQSettings.interfacePopoutFileRename = 1
            PQSettings.interfacePopoutFileDelete = 1
            PQSettings.interfacePopoutAbout = 1
            PQSettings.interfacePopoutImgur = 1
            PQSettings.interfacePopoutWallpaper = 1
            PQSettings.interfacePopoutFilter = 1
            PQSettings.interfacePopoutSettingsManager = 1
            PQSettings.interfacePopoutFileSaveAs = 1

            PQSettings.interfaceWindowMode = 1
            PQSettings.interfaceWindowDecoration = 1

        // small elements integrated, large ones in their own window
        } else {

            PQSettings.interfacePopoutMainMenu = 0
            PQSettings.interfacePopoutMetadata = 0
            PQSettings.interfacePopoutHistogram = 0
            PQSettings.interfacePopoutScale = 1
            PQSettings.interfacePopoutOpenFile = 1
            PQSettings.interfacePopoutSlideShowSettings = 1
            PQSettings.interfacePopoutSlideShowControls = 1
            PQSettings.interfacePopoutFileRename = 0
            PQSettings.interfacePopoutFileDelete = 0
            PQSettings.interfacePopoutAbout = 0
            PQSettings.interfacePopoutImgur = 1
            PQSettings.interfacePopoutWallpaper = 1
            PQSettings.interfacePopoutFilter = 0
            PQSettings.interfacePopoutSettingsManager = 1
            PQSettings.interfacePopoutFileSaveAs = 0

            PQSettings.interfaceWindowMode = 1
            PQSettings.interfaceWindowDecoration = 1

        }

        toplevel.start()
    }

    Shortcut {
        sequences: ["Escape", "Enter", "Return"]
        onActivated:
            top_first.close()
    }

}
