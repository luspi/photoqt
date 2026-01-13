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

Item {

    id: confirmUnsaved

    parent: settingsmanager_top
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        opacity: 0.8
        color: palette.alternateBase
    }

    opacity: 0
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
    visible: opacity>0

    property int ind: -1
    property string cat: ""
    property int catIndex: -1

    signal updateTabTo(mainCat : int, subCat : string, subCatIndex : int)

    Column {

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        spacing: 20

        PQTextXL {
            x: (parent.width-width)/2
            font.weight: PQCLook.fontWeightBold
            text: qsTranslate("settingsmanager", "Unsaved changes")
        }

        PQText {
            x: (parent.width-width)/2
            width: 400
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTranslate("settingsmanager", "The settings on this page have changed. Do you want to apply or discard them?")
        }

        Row {

            x: (parent.width-width)/2

            spacing: 10

            PQButton {
                id: confirmApply
                //: written on button, used as in: apply changes
                text: qsTranslate("settingsmanager", "Apply")
                onClicked: {

                    PQCNotify.settingsmanagerSendCommand("applychanges", []);

                    if(confirmUnsaved.cat == "-") {
                        settingsmanager_top.hide()
                    } else {
                        confirmUnsaved.updateTabTo(confirmUnsaved.ind, confirmUnsaved.cat, confirmUnsaved.catIndex)
                    }

                    confirmUnsaved.opacity = 0
                    confirmUnsaved.cat = ""
                    confirmUnsaved.ind = -1
                }
            }
            PQButton {
                id: confirmDiscard
                //: written on button, used as in: discard changes
                text: qsTranslate("settingsmanager", "Discard")
                onClicked: {
                    if(confirmUnsaved.cat == "-") {
                        PQCConstants.settingsManagerSettingChanged = false
                        settingsmanager_top.hide()
                    } else {
                        confirmUnsaved.updateTabTo(confirmUnsaved.ind, confirmUnsaved.cat, confirmUnsaved.catIndex)
                    }
                    confirmUnsaved.opacity = 0
                    confirmUnsaved.cat = ""
                    confirmUnsaved.ind = -1
                }
            }
            PQButton {
                id: confirmCancel
                text: genericStringCancel
                onClicked: {
                    confirmUnsaved.opacity = 0
                    confirmUnsaved.cat = ""
                    confirmUnsaved.ind = -1
                }
            }
        }

    }

    function cancelDialog() {
        confirmCancel.clicked()
    }

}
