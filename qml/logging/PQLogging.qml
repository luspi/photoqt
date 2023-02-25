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
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import "../elements"

Window {

    id: logging_window

    //: Window title
    title: em.pty+qsTranslate("logging", "Logging")

    Component.onCompleted: {
        logging_window.setX(windowgeometry.loggingWindowGeometry.x)
        logging_window.setY(windowgeometry.loggingWindowGeometry.y)
        logging_window.setWidth(windowgeometry.loggingWindowGeometry.width)
        logging_window.setHeight(windowgeometry.loggingWindowGeometry.height)
    }

    minimumWidth: 400
    minimumHeight: 300

    onClosing: {
        storeGeometry()
    }

    flags: Qt.WindowStaysOnTopHint

    color: "#cc000000"

    visible: false

    Text {
        id: title
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 10
        }
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        font.pointSize: baselook.fontsize_xl
        font.bold: true
        // We don't need to translate this
        text: "Debug/Log"
    }

    ScrollView {
        id: scroll
        anchors {
            fill: parent
            topMargin: title.height+20
            bottomMargin: buttons.height+10
        }
        PQTextArea {
            id: textarea
            placeholderText: ""
            text: ""
            readOnly: true
            font.pointSize: baselook.fontsize
        }
    }

    Timer {
        interval: 1000
        running: logging_window.visible
        repeat: true
        onTriggered: {
            textarea.text = PQLogDebugMessage.getMessage()
            textarea.cursorPosition = textarea.text.length
        }
    }

    Item {

        id: buttons

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: button_close.height+20

        PQCheckbox {
            text: em.pty+qsTranslate("logging", "enable debug messages")
            x: 10
            y: (parent.height-height)/2
            checked: PQDebugLog.debug
            onCheckedChanged:
                PQDebugLog.debug = checked
        }

        PQButton {
            id: button_close
            x: (parent.width-width)/2
            y: 10
            text: genericStringClose
            onClicked: {
                logging_window.setVisible(false)
            }
        }

        PQButton {
            x: parent.width-width-10
            y: 10
            text: "..."
            clickOpensMenu: true
            menuOpenDownward: false
            scale: 0.8
            listMenuItems: [em.pty+qsTranslate("logging", "copy to clipboard"),
                            em.pty+qsTranslate("logging", "save to file")]
            onMenuItemClicked: {
                if(pos == 0) {
                    handlingExternal.copyTextToClipboard(PQLogDebugMessage.getMessage())
                } else if(pos == 1) {
                    handlingFileDir.saveStringToNewFile(PQLogDebugMessage.getMessage())
                }
            }
        }

    }

    Shortcut {
        sequence: "Esc"
        onActivated:
            logging_window.setVisible(false)
    }


    Connections {
        target: loader
        onLoggingPassOn: {
            if(what == "show") {
                logging_window.setVisible(true)
                textarea.text = PQLogDebugMessage.getMessage()
                textarea.cursorPosition = textarea.text.length
            } else if(what == "hide") {
                button_close.clicked()
            }
        }
    }

    function storeGeometry() {
        windowgeometry.loggingWindowGeometry = Qt.rect(logging_window.x, logging_window.y, logging_window.width, logging_window.height)
        windowgeometry.loggingWindowMaximized = (logging_window.visibility==Window.Maximized)
    }

}
