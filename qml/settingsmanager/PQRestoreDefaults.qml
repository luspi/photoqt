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

import "../elements"

Rectangle {

    id: restoredefaults_top

    parent: settingsmanager_top
    anchors.fill: parent

    color: "#cd000000"

    opacity: 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked:
            hide()
    }

    Item {
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: Math.min(800, parent.width)
        height: col.height

        MouseArea {
            anchors.fill: parent
            anchors.margins: -50
            hoverEnabled: true
        }

        Column {

            id: col

            width: parent.width

            spacing: 15

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                //: As in 'restore the default settings and/or file formats and/or shortcuts'. Please keep short!
                text: em.pty+qsTranslate("settingsmanager", "Restore defaults")
                color: "white"
                font.bold: true
                font.pointSize: 25
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                color: "white"
                font.pointSize: 15
                text: em.pty+qsTranslate("settingsmanager", "Here you can restore the default configuration of PhotoQt. You can choose to restore any combination of the following three categories.")
            }

            Item {
                x: (parent.width-width)/2
                width: butcol.width
                height: butcol.height

                Column {
                    id: butcol
                    spacing: 10
                    PQCheckbox {
                        id: restore_set
                        text: em.pty+qsTranslate("settingsmanager", "Restore default settings")
                        font.pointSize: 14
                        checked: true
                    }

                    PQCheckbox {
                        id: restore_for
                        text: em.pty+qsTranslate("settingsmanager", "Restore default file formats")
                        font.pointSize: 14
                    }

                    PQCheckbox {
                        id: restore_sho
                        text: em.pty+qsTranslate("settingsmanager", "Restore default shortcuts")
                        font.pointSize: 14
                    }
                }

            }

            Item {
                width: 1
                height: 1
            }

            Row {

                x: (parent.width-width)/2

                spacing: 10
                PQButton {
                    fontPointSize: 15
                    text: em.pty+qsTranslate("settingsmanager", "Restore defaults")

                    onClicked: {
                        if(restore_set.checked)
                            handlingGeneral.setDefaultSettings(true)
                        if(restore_for.checked)
                            PQImageFormats.restoreDefaults()
                        if(restore_sho.checked) {
                            PQShortcuts.setDefault()
                        }
                        settingsmanager_top.resetSettings()
                        hide()
                    }

                }
                PQButton {
                    fontPointSize: 15
                    text: "Cancel"
                    onClicked:
                        hide()
                }
            }

        }

    }

    function show() {
        restore_set.checked = true
        restore_for.checked = false
        restore_sho.checked = false
        restoredefaults_top.opacity = 1
        settingsmanager_top.modalWindowOpen = true
        settingsmanager_top.detectingShortcutCombo = true
    }

    function hide() {
        restoredefaults_top.opacity = 0
        settingsmanager_top.modalWindowOpen = false
        settingsmanager_top.detectingShortcutCombo = false
    }

}
