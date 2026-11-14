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

    id: set_sibl

    width: parent.width
    height: contcol.height

    property bool finishedSetup: false

    Column {

        id: contcol

        width: parent.width
        spacing: 10

        PQTextS {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "Changes will be saved automatically")
        }

        PQTextL {
            //: Sibling here refers to a neighboring folder that is a sibling of the current folder
            text: qsTranslate("settingsmanager", "Sibling Settings")
            font.weight: PQCLook.fontWeightBold
        }

        PQText {
            width: parent.width
            text: qsTranslate("settingsmanager", "A sibling of a file is the first file in a siling folder. That is the next/previous folder in the current parent folder. If there is none, PhotoQt can move up a certain number of levels and descend down a certain number of levels to find the sibling file. Setting the maximum levels down to 0 and maximum levels up to 1 restricts PhotoQt to only look for folders in its immediate parent and no further.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            spacing: 5
            PQText {
                y: (maxLevelUp.height-height)/2
                text: qsTranslate("settingsmanager", "Maximum number of levels up:")
            }

            PQAdvancedSlider {
                id: maxLevelUp
                from: 0
                to: 20
                onValueChanged: {
                    if(set_sibl.finishedSetup)
                        set_sibl.saveChanges()
                }
                onEditModeChanged:
                    PQCConstants.settingsManagerAdvancedSliderEditMode += (editMode ? 1 : -1)
            }
        }

        Row {
            spacing: 5
            PQText {
                y: (maxLevelDown.height-height)/2
                text: qsTranslate("settingsmanager", "Maximum number of levels down:")
            }

            PQAdvancedSlider {
                id: maxLevelDown
                from: 0
                to: 20
                onValueChanged: {
                    if(set_sibl.finishedSetup)
                        set_sibl.saveChanges()
                }
                onEditModeChanged:
                    PQCConstants.settingsManagerAdvancedSliderEditMode += (editMode ? 1 : -1)
            }
        }

        Row {
            spacing: 5
            PQText {
                y: (maxIterations.height-height)/2
                text: qsTranslate("settingsmanager", "Maximum number of iterations in total:")
            }

            PQAdvancedSlider {
                id: maxIterations
                from: 10
                to: 200
                onValueChanged: {
                    if(set_sibl.finishedSetup)
                        set_sibl.saveChanges()
                }
                onEditModeChanged:
                    PQCConstants.settingsManagerAdvancedSliderEditMode += (editMode ? 1 : -1)
            }
        }

    }

    Connections {
        target: PQCNotify
        function onSettingsmanagerSendCommand(what : string, args : list<var>) : void {
            if(what === "advancedSlider" && args[0] === "cancel") {
                maxLevelUp.acceptValue()
                maxLevelDown.acceptValue()
                maxIterations.acceptValue()
            }
        }
    }

    // load
    Component.onCompleted: {

        maxLevelUp.loadAndSetDefault(PQCSettings.imageviewSiblingFileMaxLevelUp)
        maxLevelDown.loadAndSetDefault(PQCSettings.imageviewSiblingFilemaxLevelDown)
        maxIterations.loadAndSetDefault(PQCSettings.imageviewSiblingFileMaxIterations)

        finishedSetup = true

    }

    function saveChanges() {

        PQCSettings.imageviewSiblingFileMaxLevelUp = maxLevelUp.value
        PQCSettings.imageviewSiblingFilemaxLevelDown = maxLevelDown.value
        PQCSettings.imageviewSiblingFileMaxIterations = maxIterations.value

    }

}
