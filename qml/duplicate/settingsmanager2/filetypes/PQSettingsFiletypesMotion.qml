/**************************************************************************
 * *                                                                      **
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
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_moli

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Motion/Live photos")

            helptext: qsTranslate("settingsmanager",  "Both Apple and Android devices can connect a short video clip to photos. Apple refers to this as Apple Live Photo, and Google refers to it as Motion Photo (or sometimes Micro Video). Apple stores small video files next to the image files that have the same filename but different file ending. Android embeds these video files in the image file. If the former is enabled, PhotoQt will hide the video files from the file list and automatically load them when the connected image file is loaded. If the latter is enabled PhotoQt will try to extract and show the video file once the respective image file is loaded. All of this is done asynchronously and should not cause any slowdown. PhotoQt can also show a small play/pause button in the bottom right corner of the window, and it can force the space bar to always play/pause the detected video.")

            showLineAbove: false

        },

        PQTextL {
            width: set_moli.contentWidth
            text: ">> " + qsTranslate("settingsmanager", "This feature is not supported by your build of PhotoQt.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.weight: PQCLook.fontWeightBold
            visible: !PQCScriptsConfig.isMotionPhotoSupportEnabled()
        },

        PQCheckBox {
            id: applelive
            enforceMaxWidth: set_moli.contentWidth
            text: qsTranslate("settingsmanager", "Look for Apple Live Photos")
            onCheckedChanged: set_moli.checkForChanges()
        },

        PQCheckBox {
            id: motionmicro
            enforceMaxWidth: set_moli.contentWidth
            text: qsTranslate("settingsmanager", "Look for Google Motion Photos")
            onCheckedChanged: set_moli.checkForChanges()
        },

        Item {
            width: 1
            height: 10
        },

        PQCheckBox {
            id: motionplaypause
            enforceMaxWidth: set_moli.contentWidth
            text: qsTranslate("settingsmanager", "Show small play/pause/autoplay button in bottom right corner of window")
            onCheckedChanged: set_moli.checkForChanges()
        },

        PQCheckBox {
            id: motionspace
            enforceMaxWidth: set_moli.contentWidth
            text: qsTranslate("settingsmanager", "Always use space key to play/pause videos")
            onCheckedChanged: set_moli.checkForChanges()
        }

    ]

    onResetToDefaults: {

        applelive.checked = PQCSettings.getDefaultForFiletypesLoadAppleLivePhotos()
        motionmicro.checked = PQCSettings.getDefaultForFiletypesLoadMotionPhotos()
        motionplaypause.checked = PQCSettings.getDefaultForFiletypesMotionPhotoPlayPause()
        motionspace.checked = PQCSettings.getDefaultForFiletypesMotionSpacePause()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        PQCConstants.settingsManagerSettingChanged = (applelive.hasChanged() || motionmicro.hasChanged() ||
                                                      motionplaypause.hasChanged() || motionspace.hasChanged())

    }

    function load() {

        settingsLoaded = false

        applelive.loadAndSetDefault(PQCSettings.filetypesLoadAppleLivePhotos)
        motionmicro.loadAndSetDefault(PQCSettings.filetypesLoadMotionPhotos)
        motionplaypause.loadAndSetDefault(PQCSettings.filetypesMotionPhotoPlayPause)
        motionspace.loadAndSetDefault(PQCSettings.filetypesMotionSpacePause)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesLoadAppleLivePhotos = applelive.checked
        PQCSettings.filetypesLoadMotionPhotos = motionmicro.checked
        PQCSettings.filetypesMotionPhotoPlayPause = motionplaypause.checked
        PQCSettings.filetypesMotionSpacePause = motionspace.checked
        applelive.saveDefault()
        motionmicro.saveDefault()
        motionplaypause.saveDefault()
        motionspace.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
