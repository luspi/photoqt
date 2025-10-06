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

    id: set_anim

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Animated images")

            helptext: qsTranslate("settingsmanager",  "PhotoQt can show controls for animated images that allow for stepping through an animated image frame by frame, jumping to a specific frame, and play/pause the animation. Additionally is is possible to force the left/right arrow keys to load the previous/next frame and/or use the space key to play/pause the animation, no matter what shortcut action is set to these keys.")

            showLineAbove: false

        },

        PQCheckBox {
            id: animatedcontrol
            enforceMaxWidth: set_anim.contentWidth
            text: qsTranslate("settingsmanager", "show floating controls for animated images")
            onCheckedChanged: set_anim.checkForChanges()
        },

        PQCheckBox {
            id: animatedleftright
            enforceMaxWidth: set_anim.contentWidth
            text: qsTranslate("settingsmanager", "use left/right arrow to load previous/next frame")
            onCheckedChanged: set_anim.checkForChanges()
        },

        PQCheckBox {
            id: animspace
            enforceMaxWidth: set_anim.contentWidth
            text: qsTranslate("settingsmanager", "Always use space key to play/pause animation")
            onCheckedChanged: set_anim.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                animatedcontrol.checked = PQCSettings.getDefaultForFiletypesAnimatedControls()
                animatedleftright.checked = PQCSettings.getDefaultForFiletypesAnimatedLeftRight()
                animspace.checked = PQCSettings.getDefaultForFiletypesAnimatedSpacePause()

                set_anim.checkForChanges()

            }
        }

    ]

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (animatedcontrol.hasChanged() || animatedleftright.hasChanged() || animspace.hasChanged())

    }

    function load() {

        settingsLoaded = false

        animatedcontrol.loadAndSetDefault(PQCSettings.filetypesAnimatedControls)
        animatedleftright.loadAndSetDefault(PQCSettings.filetypesAnimatedLeftRight)
        animspace.loadAndSetDefault(PQCSettings.filetypesAnimatedSpacePause)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesAnimatedControls = animatedcontrol.checked
        PQCSettings.filetypesAnimatedLeftRight = animatedleftright.checked
        PQCSettings.filetypesAnimatedSpacePause = animspace.checked
        animatedcontrol.saveDefault()
        animatedleftright.saveDefault()
        animspace.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
