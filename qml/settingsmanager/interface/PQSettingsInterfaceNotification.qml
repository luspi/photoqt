/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

PQSetting {

    id: set_noti

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Notification")

            helptext: qsTranslate("settingsmanager", "For certain actions a notification is shown. On Linux this notification can be shown as native notification. Alternatively it can also be shown integrated into the main interface.")

        },

        Column {

            id: notif_grid

            property string loc: "center"
            property string default_loc: "center"

            onLocChanged:
                set_noti.checkForChanges()

            spacing: 20

            Row {
                spacing: 5

                Column {
                    spacing: 5

                    PQText {
                        text: " "
                    }

                    PQText {
                        x: (parent.width-width)
                        height: 50
                        verticalAlignment: Text.AlignVCenter
                        //: Vertical position of the integrated notification popup. Please keep short!
                        text: qsTranslate("settingsmanager", "top")
                    }

                    PQText {
                        x: (parent.width-width)
                        height: 50
                        verticalAlignment: Text.AlignVCenter
                        //: Vertical position of the integrated notification popup. Please keep short!
                        text: qsTranslate("settingsmanager", "center")
                    }

                    PQText {
                        x: (parent.width-width)
                        height: 50
                        verticalAlignment: Text.AlignVCenter
                        //: Vertical position of the integrated notification popup. Please keep short!
                        text: qsTranslate("settingsmanager", "bottom")
                    }
                }

                Column {
                    spacing: 5
                    Row {
                        spacing: 5
                        PQText {
                            width: 100
                            horizontalAlignment: Text.AlignHCenter
                            //: Horizontal position of the integrated notification popup. Please keep short!
                            text: qsTranslate("settingsmanager", "left")
                        }
                        PQText {
                            width: 100
                            horizontalAlignment: Text.AlignHCenter
                            //: Horizontal position of the integrated notification popup. Please keep short!
                            text: qsTranslate("settingsmanager", "center")
                        }
                        PQText {
                            width: 100
                            horizontalAlignment: Text.AlignHCenter
                            //: Horizontal position of the integrated notification popup. Please keep short!
                            text: qsTranslate("settingsmanager", "right")
                        }
                    }

                    Row {
                        spacing: 5
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="topleft"||mouse_tl.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_tl
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "topleft"
                                }
                            }
                        }
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="top"||mouse_t.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_t
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "top"
                                }
                            }
                        }
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="topright"||mouse_tr.containsMouse
                            }

                            PQMouseArea {
                                id: mouse_tr
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "topright"
                                }
                            }
                        }
                    }
                    Row {
                        spacing: 5
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="centerleft"||mouse_ml.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_ml
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "centerleft"
                                }
                            }
                        }
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="center"||mouse_m.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_m
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "center"
                                }
                            }
                        }
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="centerright"||mouse_mr.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_mr
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "centerright"
                                }
                            }
                        }
                    }
                    Row {
                        spacing: 5
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="bottomleft"||mouse_bl.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_bl
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "bottomleft"
                                }
                            }
                        }
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="bottom"||mouse_b.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_b
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "bottom"
                                }
                            }
                        }
                        Rectangle {
                            color: "transparent"
                            width: 100
                            height: 50
                            border.width: 1
                            border.color: PQCLook.baseBorder
                            PQHighlightMarker {
                                visible: notif_grid.loc==="bottomright"||mouse_br.containsMouse
                            }
                            PQMouseArea {
                                id: mouse_br
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("settingsmanager", "Show notification at this position")
                                onClicked: {
                                    notif_grid.loc = "bottomright"
                                }
                            }
                        }
                    }
                }
            }
        },

        Item {
            width: 1
            height: 10
        },

        PQAdvancedSlider {
            id: notif_dist
            width: set_noti.width
            minval: 0
            maxval: 200
            title: qsTranslate("settingsmanager", "Distance from edge:")
            suffix: " px"
            onValueChanged:
                set_noti.checkForChanges()
        },

        PQCheckBox {
            id: notif_external
            visible: !PQCScriptsConfig.amIOnWindows()
            text: qsTranslate("settingsmanager", "try to show native notification")
            onCheckedChanged:
                set_noti.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                notif_grid.loc = PQCSettings.getDefaultForInterfaceNotificationLocation()
                notif_external.checked = PQCSettings.getDefaultForInterfaceNotificationTryNative()
                notif_dist.setValue(PQCSettings.getDefaultForInterfaceNotificationDistanceFromEdge())

                set_noti.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        notif_dist.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (notif_grid.default_loc !== notif_grid.loc || notif_external.hasChanged() || notif_dist.hasChanged())

    }

    function load() {

        settingsLoaded = false

        notif_grid.loc = PQCSettings.interfaceNotificationLocation
        notif_grid.default_loc = PQCSettings.interfaceNotificationLocation
        notif_external.loadAndSetDefault(PQCSettings.interfaceNotificationTryNative)
        notif_dist.loadAndSetDefault(PQCSettings.interfaceNotificationDistanceFromEdge)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceNotificationLocation = notif_grid.loc
        PQCSettings.interfaceNotificationTryNative = notif_external.checked
        PQCSettings.interfaceNotificationDistanceFromEdge = notif_dist.value

        notif_grid.default_loc = notif_grid.loc
        notif_external.saveDefault()
        notif_dist.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
