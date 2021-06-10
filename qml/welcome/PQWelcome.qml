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
                text: em.pty+qsTranslate("welcome", "If you do not know what to do here, that is nothing to worry about: Simple click on continue.")
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

            PQSettings.mainMenuPopoutElement = 0
            PQSettings.metadataPopoutElement = 0
            PQSettings.histogramPopoutElement = 0
            PQSettings.scalePopoutElement = 0
            PQSettings.openPopoutElement = 0
            PQSettings.slideShowSettingsPopoutElement = 0
            PQSettings.slideShowControlsPopoutElement = 0
            PQSettings.fileRenamePopoutElement = 0
            PQSettings.fileDeletePopoutElement = 0
            PQSettings.aboutPopoutElement = 0
            PQSettings.imgurPopoutElement = 0
            PQSettings.wallpaperPopoutElement = 0
            PQSettings.filterPopoutElement = 0
            PQSettings.settingsManagerPopoutElement = 0
            PQSettings.fileSaveAsPopoutElement = 0

            PQSettings.windowMode = 1
            PQSettings.windowDecoration = 1

        // everything in its own window
        } else if(radio_individual.checked) {

            PQSettings.mainMenuPopoutElement = 1
            PQSettings.metadataPopoutElement = 1
            PQSettings.histogramPopoutElement = 1
            PQSettings.scalePopoutElement = 1
            PQSettings.openPopoutElement = 1
            PQSettings.slideShowSettingsPopoutElement = 1
            PQSettings.slideShowControlsPopoutElement = 1
            PQSettings.fileRenamePopoutElement = 1
            PQSettings.fileDeletePopoutElement = 1
            PQSettings.aboutPopoutElement = 1
            PQSettings.imgurPopoutElement = 1
            PQSettings.wallpaperPopoutElement = 1
            PQSettings.filterPopoutElement = 1
            PQSettings.settingsManagerPopoutElement = 1
            PQSettings.fileSaveAsPopoutElement = 1

            PQSettings.windowMode = 1
            PQSettings.windowDecoration = 1

        // small elements integrated, large ones in their own window
        } else {

            PQSettings.mainMenuPopoutElement = 0
            PQSettings.metadataPopoutElement = 0
            PQSettings.histogramPopoutElement = 0
            PQSettings.scalePopoutElement = 1
            PQSettings.openPopoutElement = 1
            PQSettings.slideShowSettingsPopoutElement = 1
            PQSettings.slideShowControlsPopoutElement = 1
            PQSettings.fileRenamePopoutElement = 0
            PQSettings.fileDeletePopoutElement = 0
            PQSettings.aboutPopoutElement = 0
            PQSettings.imgurPopoutElement = 1
            PQSettings.wallpaperPopoutElement = 1
            PQSettings.filterPopoutElement = 0
            PQSettings.settingsManagerPopoutElement = 1
            PQSettings.fileSaveAsPopoutElement = 0

            PQSettings.windowMode = 1
            PQSettings.windowDecoration = 1

        }

        // some of the groupings above might coincide with the default versions
        // this wouldn't trigger saving the settings file and this dialog might be shown again at next start
        // making sure this timer is running makes sure the settings file will be created
        PQSettings.restartSaveSettingsTimer()

        toplevel.start()
    }

    Shortcut {
        sequences: ["Escape", "Enter", "Return"]
        onActivated:
            top_first.close()
    }

}
