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
import PhotoQt.Integrated
import PhotoQt.Shared

Item {

    PQMenu {

        id: rightclickmenu

        PQMenuItem {
            enabled: false
            font.italic: true
            // moveToRightABit: true
            text: qsTranslate("MainMenu", "Thumbnails")
        }

        PQMenuSeparator { }

        PQMenuItem {
            visible: PQCConstants.thumbnailsMenuReloadIndex>-1
            text: qsTranslate("thumbnails", "Reload thumbnail")
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg"
            onTriggered: {
                PQCScriptsImages.removeThumbnailFor(PQCFileFolderModel.entriesMainView[PQCConstants.thumbnailsMenuReloadIndex])
                PQCNotify.thumbnailReloadImage(PQCConstants.thumbnailsMenuReloadIndex)
            }
        }

        PQMenuSeparator { /*lighterColor: true; */visible: PQCConstants.thumbnailsMenuReloadIndex>-1 }

        PQMenu {

            title: "thumbnail image"

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "fit thumbnails")
                // ButtonGroup.group: grp1
                checked: (!PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth)
                onCheckedChanged: {
                    if(checked && (PQCSettings.thumbnailsCropToFit || PQCSettings.thumbnailsSameHeightVaryWidth)) {
                        PQCSettings.thumbnailsCropToFit = false
                        PQCSettings.thumbnailsSameHeightVaryWidth = false
                    }
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "scale and crop thumbnails")
                // ButtonGroup.group: grp1
                checked: PQCSettings.thumbnailsCropToFit
                onCheckedChanged: {
                    if(checked) {
                        PQCSettings.thumbnailsCropToFit = true
                        PQCSettings.thumbnailsSameHeightVaryWidth = false
                    }
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "same height, varying width")
                // ButtonGroup.group: grp1
                checked: PQCSettings.thumbnailsSameHeightVaryWidth
                onCheckedChanged: {
                    if(checked) {
                        // See the comment below for why this check is here
                        if(PQCSettings.thumbnailsCropToFit) {
                            PQCSettings.thumbnailsCropToFit = false
                            delayChecking.restart()
                        } else
                            PQCSettings.thumbnailsSameHeightVaryWidth = true
                    }
                }
                // When switching from CropToFit to SameHeightVaryWidth we can't go immediately there
                // If we do then the padding/sourceSize of the images might not cooperate well
                // This short delay in that case ensures that everything works just fine
                Timer {
                    id: delayChecking
                    interval: 100
                    onTriggered: {
                        PQCSettings.thumbnailsSameHeightVaryWidth = true
                    }
                }
            }

            PQMenuItem {
                checkable: true
                text: qsTranslate("settingsmanager", "keep small thumbnails small")
                checked: PQCSettings.thumbnailsSmallThumbnailsKeepSmall
                onCheckedChanged:
                    PQCSettings.thumbnailsSmallThumbnailsKeepSmall = checked
            }

        }

        PQMenu {

            title: "visibility"

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "hide when not needed")
                // ButtonGroup.group: grp2
                checked: PQCSettings.thumbnailsVisibility===0
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.thumbnailsVisibility = 0
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "always keep visible")
                // ButtonGroup.group: grp2
                checked: PQCSettings.thumbnailsVisibility===1
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.thumbnailsVisibility = 1
                }
            }

            PQMenuItem {
                checkable: true
                // checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "hide when zoomed in")
                // ButtonGroup.group: grp2
                checked: PQCSettings.thumbnailsVisibility===2
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.thumbnailsVisibility = 2
                }
            }

        }

        PQMenuSeparator {}

        PQMenuItem {
            checkable: true
            text: qsTranslate("settingsmanager", "show filename labels")
            checked: PQCSettings.thumbnailsFilename
            onCheckedChanged:
                PQCSettings.thumbnailsFilename = checked
        }

        PQMenuItem {
            checkable: true
            text: qsTranslate("settingsmanager", "show tooltips")
            checked: PQCSettings.thumbnailsTooltip
            onCheckedChanged:
                PQCSettings.thumbnailsTooltip = checked
        }

        PQMenuSeparator {}

        PQMenuItem {
            text: qsTranslate("settingsmanager", "Manage in settings manager")
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
            onTriggered: {
                PQCNotify.openSettingsManagerAt("showSettings", ["thumbnails"])
            }
        }

        onAboutToHide: {
            // PQCConstants.thumbnailsMenuReloadIndex = -1
        }

    }

    Connections {

        target: PQCNotify

        function onShowThumbnailsContextMenu(vis : bool) {
            if(vis)
                rightclickmenu.popup()
            else
                rightclickmenu.dismiss()
        }

        function onShowThumbnailsContextMenuAtTouch(pos : point) {
            rightclickmenu.popup(pos)
        }

    }

}
