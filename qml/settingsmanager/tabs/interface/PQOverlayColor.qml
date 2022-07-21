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
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "overlay color")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "This is the color that is shown on top of any background image/...")
    expertmodeonly: true
    property var rgba: [PQSettings.interfaceOverlayColorRed, PQSettings.interfaceOverlayColorGreen, PQSettings.interfaceOverlayColorBlue, PQSettings.interfaceOverlayColorAlpha]
    property var fullscreen_rgba: [PQSettings.interfaceFullscreenOverlayColorRed, PQSettings.interfaceFullscreenOverlayColorGreen, PQSettings.interfaceFullscreenOverlayColorBlue, PQSettings.interfaceFullscreenOverlayColorAlpha]
    content: [

        Flow {
            spacing: 5
            width: set.contwidth

            Rectangle {
                id: rgba_rect
                width: rgba_txt.width+20
                height: rgba_txt.height+20
                border.width: 1
                border.color: "#333333"
                color: Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
                Text {
                    id: rgba_txt
                    x: 10
                    y: 10
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                    text: "RGBA = %1, %2, %3, %4".arg(rgba[0]).arg(rgba[1]).arg(rgba[2]).arg(rgba[3])
                }
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: em.pty+qsTranslate("settingsmanager_interface", "click to change color")
                    onClicked: {
                        colorDialog.fullscreen = false
                        colorDialog.color = Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
                        colorDialog.visible = true
                    }
                }
            }

            Item {
                width: 15
                height: 1
            }

            Item {
                width: fullscreen_check.width
                height: fullscreen_rgba_rect.height
                PQCheckbox {
                    id: fullscreen_check
                    y: (fullscreen_rgba_rect.height-height)/2
                    text: "different color in fullsceen"
                }
            }

            Item {
                width: 5
                height: 1
            }

            Rectangle {
                id: fullscreen_rgba_rect
                width: fullscreen_rgba_txt.width+20
                height: fullscreen_rgba_txt.height+20
                border.width: 1
                border.color: "#333333"
                color: Qt.rgba(fullscreen_rgba[0]/255, fullscreen_rgba[1]/255, fullscreen_rgba[2]/255, fullscreen_rgba[3]/255)
                enabled: fullscreen_check.checked
                opacity: enabled ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Text {
                    id: fullscreen_rgba_txt
                    x: 10
                    y: 10
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                    text: "RGBA = %1, %2, %3, %4".arg(fullscreen_rgba[0]).arg(fullscreen_rgba[1]).arg(fullscreen_rgba[2]).arg(fullscreen_rgba[3])
                }
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: em.pty+qsTranslate("settingsmanager_interface", "click to change color")
                    onClicked: {
                        colorDialog.fullscreen = true
                        colorDialog.color = Qt.rgba(fullscreen_rgba[0]/255, fullscreen_rgba[1]/255, fullscreen_rgba[2]/255, fullscreen_rgba[3]/255)
                        colorDialog.visible = true
                    }
                }
            }

        }

    ]

    ColorDialog {
        id: colorDialog
        title: em.pty+qsTranslate("settingsmanager_interface", "please choose a color")
        showAlphaChannel: true
        modality: Qt.ApplicationModal
        property bool fullscreen: false
        onAccepted: {
            if(fullscreen)
                fullscreen_rgba = handlingGeneral.convertHexToRgba(colorDialog.color)
            else
                rgba = handlingGeneral.convertHexToRgba(colorDialog.color)
        }
        onVisibleChanged:
            settingsmanager_top.modalWindowOpen = visible
    }

    Connections {

        target: settingsmanager_top

        onCloseModalWindow:
            colorDialog.close()

        onLoadAllSettings: {
            rgba = [PQSettings.interfaceOverlayColorRed, PQSettings.interfaceOverlayColorGreen, PQSettings.interfaceOverlayColorBlue, PQSettings.interfaceOverlayColorAlpha]
            fullscreen_check.checked = PQSettings.interfaceFullscreenOverlayColorDifferent
            fullscreen_rgba = [PQSettings.interfaceFullscreenOverlayColorRed, PQSettings.interfaceFullscreenOverlayColorGreen, PQSettings.interfaceFullscreenOverlayColorBlue, PQSettings.interfaceFullscreenOverlayColorAlpha]
        }

        onSaveAllSettings: {
            PQSettings.interfaceOverlayColorRed = rgba[0]
            PQSettings.interfaceOverlayColorGreen = rgba[1]
            PQSettings.interfaceOverlayColorBlue = rgba[2]
            PQSettings.interfaceOverlayColorAlpha = rgba[3]
            PQSettings.interfaceFullscreenOverlayColorDifferent = fullscreen_check.checked
            PQSettings.interfaceFullscreenOverlayColorRed = fullscreen_rgba[0]
            PQSettings.interfaceFullscreenOverlayColorGreen = fullscreen_rgba[1]
            PQSettings.interfaceFullscreenOverlayColorBlue = fullscreen_rgba[2]
            PQSettings.interfaceFullscreenOverlayColorAlpha = fullscreen_rgba[3]
        }

    }


}
