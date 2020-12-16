/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "overlay color")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "This is the color that is shown on top of any background image/...")
    expertmodeonly: true
    property var rgba: [PQSettings.backgroundColorRed, PQSettings.backgroundColorGreen, PQSettings.backgroundColorBlue, PQSettings.backgroundColorAlpha]
    content: [

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
                    colorDialog.color = Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
                    colorDialog.visible = true
                    settingsmanager_top.modalWindowOpen = true
                }
            }
        }

    ]

    ColorDialog {
        id: colorDialog
        title: em.pty+qsTranslate("settingsmanager_interface", "please choose a color")
        showAlphaChannel: true
        modality: Qt.ApplicationModal
        onAccepted:
            rgba = handlingGeneral.convertHexToRgba(colorDialog.color)
    }

    Connections {

        target: settingsmanager_top

        onCloseModalWindow: {
            colorDialog.close()
            settingsmanager_top.modalWindowOpen = false
        }

        onLoadAllSettings:
            rgba = [PQSettings.backgroundColorRed, PQSettings.backgroundColorGreen, PQSettings.backgroundColorBlue, PQSettings.backgroundColorAlpha]

        onSaveAllSettings: {
            PQSettings.backgroundColorRed = rgba[0]
            PQSettings.backgroundColorGreen = rgba[1]
            PQSettings.backgroundColorBlue = rgba[2]
            PQSettings.backgroundColorAlpha = rgba[3]
        }

    }


}
