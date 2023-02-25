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
    helptext: em.pty+qsTranslate("settingsmanager_interface", "This is the color that is shown in the background on top of any background image/etc.")
    expertmodeonly: true
    property var rgba: [PQSettings.interfaceOverlayColorRed, PQSettings.interfaceOverlayColorGreen, PQSettings.interfaceOverlayColorBlue, PQSettings.interfaceOverlayColorAlpha]
    property var fullscreen_rgba: [PQSettings.interfaceFullscreenOverlayColorRed, PQSettings.interfaceFullscreenOverlayColorGreen, PQSettings.interfaceFullscreenOverlayColorBlue, PQSettings.interfaceFullscreenOverlayColorAlpha]
    content: [

        Column {

            spacing: 10
            width: set.contwidth

            Row {

                id: rgba_row

                spacing: 10

                Text {
                    visible: !samecolor_check.checked
                    y: (rgba_rect.height-height)/2
                    color: "white"
                    text: em.pty+qsTranslate("settingsmanager_interface", "window mode")
                    font.pointSize: baselook.fontsize
                }

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
                        text: "RGB = %1, %2, %3".arg(rgba[0]).arg(rgba[1]).arg(rgba[2])
                        font.pointSize: baselook.fontsize
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

                Text {
                    y: (rgba_rect.height-height)/2
                    color: "white"
                    text: "opacity"
                    font.pointSize: baselook.fontsize
                }

                PQSpinBox {
                    id: rgba_spin
                    y: (rgba_rect.height-height)/2
                    from: 50
                    to: 100
                    value: 100*rgba[3]/255
                }

                Text {
                    y: (rgba_rect.height-height)/2
                    color: "white"
                    text: "%"
                    font.pointSize: baselook.fontsize
                }

            }

            Item {
                visible: !samecolor_check.checked
                width: 15
                height: 1
            }

            Row {
                visible: !samecolor_check.checked

                spacing: 10

                Text {
                    y: (fullscreen_rgba_rect.height-height)/2
                    color: "white"
                    text: em.pty+qsTranslate("settingsmanager_interface", "fullscreen mode")
                    font.pointSize: baselook.fontsize
                }

                Rectangle {
                    id: fullscreen_rgba_rect
                    width: fullscreen_rgba_txt.width+20
                    height: fullscreen_rgba_txt.height+20
                    border.width: 1
                    border.color: "#333333"
                    color: Qt.rgba(fullscreen_rgba[0]/255, fullscreen_rgba[1]/255, fullscreen_rgba[2]/255, fullscreen_rgba[3]/255)
                    enabled: !samecolor_check.checked
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Text {
                        id: fullscreen_rgba_txt
                        x: 10
                        y: 10
                        color: "white"
                        style: Text.Outline
                        styleColor: "black"
                        text: "RGB = %1, %2, %3".arg(fullscreen_rgba[0]).arg(fullscreen_rgba[1]).arg(fullscreen_rgba[2])
                        font.pointSize: baselook.fontsize
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

                Text {
                    y: (fullscreen_rgba_rect.height-height)/2
                    color: "white"
                    text: "opacity"
                    font.pointSize: baselook.fontsize
                }

                PQSpinBox {
                    id: fullscreen_rgba_spin
                    y: (fullscreen_rgba_rect.height-height)/2
                    from: 50
                    to: 100
                    value: 100*fullscreen_rgba[3]/255
                }

                Text {
                    y: (fullscreen_rgba_rect.height-height)/2
                    color: "white"
                    text: "%"
                    font.pointSize: baselook.fontsize
                }

            }

            Item {
                width: 1
                height: 1
            }

            PQCheckbox {
                id: samecolor_check
                text: em.pty+qsTranslate("settingsmanager_interface", "use same color in window and fullscreen mode")
            }

        }

    ]

    ColorDialog {
        id: colorDialog
        title: em.pty+qsTranslate("settingsmanager_interface", "please choose a color")
        showAlphaChannel: false
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
            samecolor_check.checked = !PQSettings.interfaceFullscreenOverlayColorDifferent
            fullscreen_rgba = [PQSettings.interfaceFullscreenOverlayColorRed, PQSettings.interfaceFullscreenOverlayColorGreen, PQSettings.interfaceFullscreenOverlayColorBlue, PQSettings.interfaceFullscreenOverlayColorAlpha]
            fullscreen_rgba_spin.value = 100*fullscreen_rgba[3]/255
            rgba_spin.value = 100*rgba[3]/255
        }

        onSaveAllSettings: {
            PQSettings.interfaceOverlayColorRed = rgba[0]
            PQSettings.interfaceOverlayColorGreen = rgba[1]
            PQSettings.interfaceOverlayColorBlue = rgba[2]
            PQSettings.interfaceOverlayColorAlpha = Math.ceil(255*rgba_spin.value/100)
            PQSettings.interfaceFullscreenOverlayColorDifferent = !samecolor_check.checked
            PQSettings.interfaceFullscreenOverlayColorRed = fullscreen_rgba[0]
            PQSettings.interfaceFullscreenOverlayColorGreen = fullscreen_rgba[1]
            PQSettings.interfaceFullscreenOverlayColorBlue = fullscreen_rgba[2]
            PQSettings.interfaceFullscreenOverlayColorAlpha = Math.ceil(255*fullscreen_rgba_spin.value/100)
        }

    }


}
