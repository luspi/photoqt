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
import PhotoQt

Item {

    id: notification_top

    // we fall back to top right location if state is invalid
    x: PQCConstants.availableWidth-width-PQCSettings.interfaceNotificationDistanceFromEdge
    y: PQCSettings.interfaceNotificationDistanceFromEdge

    width: contcol.width+30
    height: contcol.height+30

    state: PQCSettings.interfaceNotificationLocation

    SystemPalette { id: pqtPalette }

    states: [

        State {
            name: "bottomleft"
            PropertyChanges {
                notification_top.x: PQCSettings.interfaceNotificationDistanceFromEdge
                notification_top.y: PQCConstants.availableHeight-notification_top.height-PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "bottom"
            PropertyChanges {
                notification_top.x: (PQCConstants.availableWidth-notification_top.width)/2
                notification_top.y: PQCConstants.availableHeight-notification_top.height-PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "bottomright"
            PropertyChanges {
                notification_top.x: PQCConstants.availableWidth-notification_top.width-PQCSettings.interfaceNotificationDistanceFromEdge
                notification_top.y: PQCConstants.availableHeight-notification_top.height-PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },

        State {
            name: "centerleft"
            PropertyChanges {
                notification_top.x: PQCSettings.interfaceNotificationDistanceFromEdge
                notification_top.y: (PQCConstants.availableHeight-notification_top.height)/2
            }
        },
        State {
            name: "center"
            PropertyChanges {
                notification_top.x: (PQCConstants.availableWidth-notification_top.width)/2
                notification_top.y: (PQCConstants.availableHeight-notification_top.height)/2
            }
        },
        State {
            name: "centerright"
            PropertyChanges {
                notification_top.x: PQCConstants.availableWidth-notification_top.width-PQCSettings.interfaceNotificationDistanceFromEdge
                notification_top.y: (PQCConstants.availableHeight-notification_top.height)/2
            }
        },

        State {
            name: "topleft"
            PropertyChanges {
                notification_top.x: PQCSettings.interfaceNotificationDistanceFromEdge
                notification_top.y: PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "top"
            PropertyChanges {
                notification_top.x: (PQCConstants.availableWidth-notification_top.width)/2
                notification_top.y: PQCSettings.interfaceNotificationDistanceFromEdge
            }
        },
        State {
            name: "topright"
            PropertyChanges {
                notification_top.x: PQCConstants.availableWidth-notification_top.width-PQCSettings.interfaceNotificationDistanceFromEdge
                notification_top.y: PQCSettings.interfaceNotificationDistanceFromEdge
            }
        }

    ]

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    Rectangle {
        anchors.fill: parent
        color: pqtPalette.base
        border.width: 2
        border.color: PQCLook.baseBorder
        radius: 15
        opacity: 0.8
    }

    property alias titletext: tit.text
    property alias statustext: txt.text

    Column {

        id: contcol

        x: 15
        y: 15

        // sometimes for no reason the top loses its property binding
        onWidthChanged:
            notification_top.width = Qt.binding(function() { return contcol.width+30 })
        onHeightChanged:
            notification_top.height = Qt.binding(function() { return contcol.height+30 })

        spacing: 5

        PQTextS {
            id: tit
            visible: text!==""
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

    property bool waitBeforeNextNotification: false
    Timer {
        id: resetWaitBeforeNextNotification
        interval: 1000
        onTriggered: {
            notification_top.waitBeforeNextNotification = false
        }
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param.length === 2 && param[0] === "Notification") {

                    // only one iteration per 1s can be shown at a time
                    // otherwise the check for a native notification might fail
                    // and two notification might be shown (native and integrated)
                    if(notification_top.waitBeforeNextNotification)
                        return
                    notification_top.waitBeforeNextNotification = true
                    resetWaitBeforeNextNotification.restart()

                    var tit = param[1][0]
                    var sum = param[1][1]
                    if(sum === "") {
                        sum = tit;
                        tit = "";
                    }

                    // use external tool if set, otherwise show integrated notification
                    if(!PQCSettings.interfaceNotificationTryNative || !PQCScriptsOther.showDesktopNotification(tit, sum)) {
                        show()
                        titletext = tit
                        statustext = sum
                    }
                }
            }

        }

    }

    Timer {
        id: hideNotification
        interval: 3000
        onTriggered:
            notification_top.hide()
    }

    function show() {
        opacity = 1
        hideNotification.restart()
    }

    function hide() {
        opacity = 0
    }

}
