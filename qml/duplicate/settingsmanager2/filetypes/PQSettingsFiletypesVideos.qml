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

    id: set_vide

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Videos")

            helptext: qsTranslate("settingsmanager",  "PhotoQt can treat video files the same as image files, as long as the respective video formats are enabled. There are a few settings available for managing how videos behave in PhotoQt: Whether they should autoplay when loaded, whether they should loop from the beginning when the end is reached, whether to prefer libmpv (if available) or Qt for video playback, and which video thumbnail generator to use.")

            showLineAbove: false

        },

        PQCheckBox {
            id: vid_autoplay
            enforceMaxWidth: set_vide.contentWidth
            text: qsTranslate("settingsmanager", "Autoplay")
            onCheckedChanged: set_vide.checkForChanges()
        },

        PQCheckBox {
            id: vid_loop
            enforceMaxWidth: set_vide.contentWidth
            text: qsTranslate("settingsmanager", "Loop")
            onCheckedChanged: set_vide.checkForChanges()
        },

        Flow {
            width: set_vide.contentWidth
            PQRadioButton {
                id: vid_qtmult
                text: qsTranslate("settingsmanager", "prefer Qt Multimedia")
                onCheckedChanged: set_vide.checkForChanges()
            }
            PQRadioButton {
                id: vid_libmpv
                text: qsTranslate("settingsmanager", "prefer Libmpv")
                onCheckedChanged: set_vide.checkForChanges()
            }
        },

        Flow {
            width: set_vide.contentWidth
            spacing: 10
            Item {
                width: 25
                height: 1
            }

            PQText {
                height: videothumb.height
                verticalAlignment: Text.AlignVCenter
                text: qsTranslate("settingsmanager", "Video thumbnail generator:")
            }
            PQComboBox {
                id: videothumb
                model: ["------",
                        "ffmpegthumbnailer"]
                currentIndex: (PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)
                onCurrentIndexChanged: set_vide.checkForChanges()
            }
        },

        PQCheckBox {
            id: videojump
            enforceMaxWidth: set_vide.contentWidth
            spacing: 10
            text: qsTranslate("settingsmanager", "Always use left/right arrow keys to jump back/ahead in videos")
            onCheckedChanged: set_vide.checkForChanges()
        },

        PQCheckBox {
            id: videospace
            enforceMaxWidth: set_vide.contentWidth
            spacing: 10
            text: qsTranslate("settingsmanager", "Always use space key to play/pause videos")
            onCheckedChanged: set_vide.checkForChanges()
        }

    ]

    onResetToDefaults: {

        vid_autoplay.checked = PQCSettings.getDefaultForFiletypesVideoAutoplay()
        vid_loop.checked = PQCSettings.getDefaultForFiletypesVideoLoop()
        vid_qtmult.checked = !PQCSettings.getDefaultForFiletypesVideoPreferLibmpv()
        vid_libmpv.checked = PQCSettings.getDefaultForFiletypesVideoPreferLibmpv()
        videothumb.currentIndex = (PQCSettings.getDefaultForFiletypesVideoThumbnailer()==="" ? 0 : 1)
        videojump.checked = PQCSettings.getDefaultForFiletypesVideoLeftRightJumpVideo()
        videospace.checked = PQCSettings.getDefaultForFiletypesVideoSpacePause()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        PQCConstants.settingsManagerSettingChanged = (vid_autoplay.hasChanged() || vid_loop.hasChanged() || vid_qtmult.hasChanged() ||
                                                      vid_libmpv.hasChanged() || videothumb.hasChanged() ||
                                                      videojump.hasChanged() || videospace.hasChanged())

    }

    function load() {

        settingsLoaded = false

        vid_autoplay.loadAndSetDefault(PQCSettings.filetypesVideoAutoplay)
        vid_loop.loadAndSetDefault(PQCSettings.filetypesVideoLoop)
        vid_qtmult.loadAndSetDefault(!PQCSettings.filetypesVideoPreferLibmpv)
        vid_libmpv.loadAndSetDefault(PQCSettings.filetypesVideoPreferLibmpv)
        videothumb.loadAndSetDefault(PQCSettings.filetypesVideoThumbnailer==="" ? 0 : 1)
        videojump.loadAndSetDefault(PQCSettings.filetypesVideoLeftRightJumpVideo)
        videospace.loadAndSetDefault(PQCSettings.filetypesVideoSpacePause)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesVideoAutoplay = vid_autoplay.checked
        PQCSettings.filetypesVideoLoop = vid_loop.checked
        PQCSettings.filetypesVideoPreferLibmpv = vid_libmpv.checked
        PQCSettings.filetypesVideoThumbnailer = (videothumb.currentIndex===1 ? videothumb.currentText : "")
        PQCSettings.filetypesVideoLeftRightJumpVideo = videojump.checked
        PQCSettings.filetypesVideoSpacePause = videospace.checked
        vid_autoplay.saveDefault()
        vid_loop.saveDefault()
        vid_qtmult.saveDefault()
        vid_libmpv.saveDefault()
        videothumb.saveDefault()
        videojump.saveDefault()
        videospace.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
