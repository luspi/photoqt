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
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title. The face tags are labels that can be shown (if available) on faces including their name.
    title: em.pty+qsTranslate("settingsmanager_metadata", "face tags - border")
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "If and what style of border to show around tagged faces.")
    expertmodeonly: true
    property var rgba: handlingGeneral.convertHexToRgba(PQSettings.metadataFaceTagsBorderColor)
    content: [

        Column {

            spacing: 20

            PQCheckbox {
                id: ft_border
                //: The border here is the border around face tags.
                text: em.pty+qsTranslate("settingsmanager_metadata", "show border")
            }

            Row {

                spacing: 10
                height: ft_border_w.height

                Text {
                    y: (parent.height-height)/2
                    color: ft_border.checked ? "white" : "#888888"
                    text: "1 px"
                }

                PQSlider {
                    id: ft_border_w
                    enabled: ft_border.checked
                    from: 1
                    to: 20
                }

                Text {
                    y: (parent.height-height)/2
                    color: ft_border.checked ? "white" : "#888888"
                    text: "20 px"
                }

            }

            Rectangle {
                enabled: ft_border.checked
                id: rgba_rect
                width: rgba_txt.width+20
                height: rgba_txt.height+20
                border.width: 1
                border.color: "#333333"
                opacity: ft_border.checked ? 1 : 0.5
                color: Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
                Text {
                    id: rgba_txt
                    x: 10
                    y: 10
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                    text: "rgba = %1, %2, %3, %4".arg(rgba[0]).arg(rgba[1]).arg(rgba[2]).arg(rgba[3])
                }
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: em.pty+qsTranslate("settingsmanager_metadata", "click to change color")
                    onClicked: {
                        colorDialog.color = Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
                        colorDialog.visible = true
                    }
                }
            }

        }

    ]

    ColorDialog {
        id: colorDialog
        title: em.pty+qsTranslate("settingsmanager_metadata", "please choose a color")
        showAlphaChannel: true
        modality: Qt.ApplicationModal
        onAccepted:
            rgba = handlingGeneral.convertHexToRgba(colorDialog.color)
        onVisibleChanged:
            settingsmanager_top.modalWindowOpen = visible
    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metadataFaceTagsBorder = ft_border.checked
            PQSettings.metadataFaceTagsBorderWidth = ft_border_w.value
            PQSettings.metadataFaceTagsBorderColor = handlingGeneral.convertRgbaToHex(rgba)
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        ft_border.checked = PQSettings.metadataFaceTagsBorder
        ft_border_w.value = PQSettings.metadataFaceTagsBorderWidth
        rgba = handlingGeneral.convertHexToRgba(PQSettings.metadataFaceTagsBorderColor)
    }

}
