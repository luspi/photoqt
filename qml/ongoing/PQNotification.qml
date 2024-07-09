/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import PQCScriptsOther

import "../elements"

Rectangle {
    id: notification_top

    // we fall back to top right location if state is invalid
    x: toplevel.width-width-PQCSettings.interfaceNotificationDistanceFromEdge
    y: PQCSettings.interfaceNotificationDistanceFromEdge

    width: contcol.width+30
    height: contcol.height+30

    state: PQCSettings.interfaceNotificationLocation

    states: [

        State {
            name: "bottomleft"
            PropertyChanges {
                target: notification_top
                x: PQCSettings.interfaceNotificationDistanceFromEdge
                y: toplevel.height-height-PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "bottom"
            PropertyChanges {
                target: notification_top
                x: (toplevel.width-width)/2
                y: toplevel.height-height-PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "bottomright"
            PropertyChanges {
                target: notification_top
                x: toplevel.width-width-PQCSettings.interfaceNotificationDistanceFromEdge
                y: toplevel.height-height-PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },

        State {
            name: "centerleft"
            PropertyChanges {
                target: notification_top
                x: PQCSettings.interfaceNotificationDistanceFromEdge
                y: (toplevel.height-height)/2
            }
        },
        State {
            name: "center"
            PropertyChanges {
                target: notification_top
                x: (toplevel.width-width)/2
                y: (toplevel.height-height)/2
            }
        },
        State {
            name: "centerright"
            PropertyChanges {
                target: notification_top
                x: toplevel.width-width-PQCSettings.interfaceNotificationDistanceFromEdge
                y: (toplevel.height-height)/2
            }
        },

        State {
            name: "topleft"
            PropertyChanges {
                target: notification_top
                x: PQCSettings.interfaceNotificationDistanceFromEdge
                y: PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "top"
            PropertyChanges {
                target: notification_top
                x: (toplevel.width-width)/2
                y: PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "topright"
            PropertyChanges {
                target: notification_top
                x: toplevel.width-width-PQCSettings.interfaceNotificationDistanceFromEdge
                y: PQCSettings.interfaceNotificationDistanceFromEdge
            }
        }

    ]

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    color: PQCLook.transColor

    property alias titletext: tit.text
    property alias statustext: txt.text

    radius: 15

    Column {

        id: contcol

        x: 15
        y: 15

        spacing: 5

        PQTextS {
            id: tit
            visible: text!=""
            width: Math.min(300, contentWidth)
            font.weight: PQCLook.fontWeightBold
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: ""
            onTextChanged: {
                width = undefined
                width = Math.min(300, contentWidth)
            }
        }

        PQText {
            id: txt
            width: Math.min(300, contentWidth)
            font.weight: PQCLook.fontWeightBold
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: ""
            onTextChanged: {
                width = undefined
                width = Math.min(300, contentWidth)
            }
        }

    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {
                if(param.length === 2 && param[0] === "notification") {

                    // use external tool if set, otherwise show integrated notification
                    if(!PQCSettings.interfaceNotificationTryNative || !PQCScriptsOther.showDesktopNotification(param[1][0], param[1][1])) {
                        show()
                        if(param[1][1] === "") {
                            titletext = ""
                            statustext = param[1][0]
                        } else {
                            titletext = param[1][0]
                            statustext = param[1][1]
                        }
                    }
                }
            }

        }

    }

    Timer {
        id: hideNotification
        interval: 2500
        onTriggered:
            hide()
    }

    function show() {
        opacity = 1
        hideNotification.restart()
    }

    function hide() {
        opacity = 0
    }

}
