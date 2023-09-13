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
import QtQuick.Window
import QtQuick.Controls

import PQCScriptsConfig
import PQCScriptsClipboard
import PQCScriptsFilesPaths
import PQCNotify

import "../../elements"

Window {

    id: logging_popout

    width: 800
    height: 600

    minimumWidth: 300
    minimumHeight: 200

    title: "Log/Debug"

    /////////

    // on windows there is a white flash when the window is created
    // thus we set up the window with opacity set to 0
    // and this animation fades the window without white flash
    PropertyAnimation {
        id: showOpacity
        target: logging_top
        property: "opacity"
        from: 0
        to: 1
        duration: 100
    }

    flags: Qt.Window|Qt.WindowStaysOnTopHint
    modality: Qt.NonModal

    visible: false

    color: PQCLook.transColor

    PQTextL {
        id: title
        y: 5
        width: logging_top.width
        horizontalAlignment: Text.AlignHCenter
        text: "Debug/Log"
    }
    PQTextArea {

        id: scrollView

        y: title.height+10
        width: parent.width
        height: logging_top.height-title.height-bottomrow.height-15

        text: PQCNotify.debugLogMessages

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: PQCLook.baseColor

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseColorActive
        }

        PQCheckBox {
            id: enabledebug
            x: 5
            y: (parent.height-height)/2
            //: Used as in: enable debug message
            text: qsTranslate("logging", "enable")
            onClicked:
                PQCNotify.debug = checked
        }

        PQButtonElement {
            id: close
            x: (parent.width-width)/2
            y: 1
            height: parent.height-1
            text: genericStringClose
            font.weight: PQCLook.fontWeightBold
            onClicked:
                logging_top.close()
        }

        PQButtonElement {
            id: actions
            x: (parent.width-width)
            y: 1
            width: height
            height: parent.height-1
            text: "..."
            font.weight: PQCLook.fontWeightBold
            onClicked:
                actionsmenu.popup(parent.width-width, -actionsmenu.height)
        }

        PQMenu {
            id: actionsmenu
            PQMenuItem {
                //: the thing being copied here are the debug messages
                text: qsTranslate("logging", "copy to clipboard")
                onTriggered:
                    PQCScriptsClipboard.copyTextToClipboard(PQCNotify.debugLogMessages)
            }
            PQMenuItem {
                //: the thing saved to files here are the debug messages
                text: qsTranslate("logging", "save to file")
                onTriggered:
                    PQCScriptsFilesPaths.saveLogToFile(PQCNotify.debugLogMessages)
            }
        }

    }

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === "logging") {

                    if(PQCScriptsConfig.amIOnWindows())
                        logging_top.opacity = 0

                    showNormal()

                    if(PQCScriptsConfig.amIOnWindows())
                        showOpacity.restart()

                    enabledebug.checked = PQCNotify.debug

                }

            }

        }
    }

}
