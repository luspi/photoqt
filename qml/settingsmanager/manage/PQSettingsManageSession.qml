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
import QtQuick.Controls
import PhotoQt

PQSetting {

    id: set_seha

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Single instance")

            helptext: qsTranslate("settingsmanager", "PhotoQt can either run in single-instance mode or allow multiple instances to run at the same time. The former has the advantage that it is possible to interact with a running instance of PhotoQt through the command line (in fact, this is a requirement for that to work). The latter allows, for example, for the comparison of multiple images side by side.")

            showLineAbove: false

        },

        PQRadioButton {
            ButtonGroup { id: grp_single }
            id: sing
            enforceMaxWidth: set_seha.contentWidth
            text: qsTranslate("settingsmanager", "run a single instance only")
            onCheckedChanged: set_seha.checkForChanges()
            ButtonGroup.group: grp_single
        },

        PQRadioButton {
            id: mult
            enforceMaxWidth: set_seha.contentWidth
            text: qsTranslate("settingsmanager", "allow multiple instances")
            onCheckedChanged: set_seha.checkForChanges()
            ButtonGroup.group: grp_single
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                mult.checked = PQCSettings.getDefaultForInterfaceAllowMultipleInstances()
                sing.checked = !mult.checked

                set_seha.checkForChanges()

            }
        },

        /***************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Reopen last image")

            helptext: qsTranslate("settingsmanager", "When PhotoQt is started normally, by default an empty window is shown with the prompt to open an image from the file dialog. Alternatively it is also possible to reopen the image that was last loaded in the previous session.")

        },

        PQRadioButton {
            ButtonGroup { id: grp_reopen }
            id: blanksession
            enforceMaxWidth: set_seha.contentWidth
            text: qsTranslate("settingsmanager", "start with blank session")
            onCheckedChanged: set_seha.checkForChanges()
            ButtonGroup.group: grp_reopen
        },

        PQRadioButton {
            id: reopenlast
            enforceMaxWidth: set_seha.contentWidth
            text: qsTranslate("settingsmanager", "reopen last used image")
            onCheckedChanged: set_seha.checkForChanges()
            ButtonGroup.group: grp_reopen
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                reopenlast.checked = PQCSettings.getDefaultForInterfaceRememberLastImage()
                blanksession.checked = !reopenlast.checked

                set_seha.checkForChanges()

            }
        },

        /***************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Remember changes")

            helptext: qsTranslate("settingsmanager", "Once an image has been loaded it can be manipulated freely by zooming, rotating, or mirroring the image. Once another image is loaded any such changes are forgotten. If preferred, it is possible for PhotoQt to remember any such manipulations per session. Note that once PhotoQt is closed these changes will be forgotten in any case.") + "<br><br>" + qsTranslate("settingsmanager", "In addition to on an per-image basis, PhotoQt can also keep the same changes across different images. If enabled and possible, the next image is loaded with the same scaling, rotation, and mirroring as the image before.")

        },

        PQRadioButton {
            ButtonGroup { id: changedgroup }
            id: forget
            enforceMaxWidth: set_seha.contentWidth
            text: qsTranslate("settingsmanager", "forget changes when other image loaded")
            onCheckedChanged: set_seha.checkForChanges()
            ButtonGroup.group: changedgroup
        },

        PQRadioButton {
            id: remember
            enforceMaxWidth: set_seha.contentWidth
            text: qsTranslate("settingsmanager", "remember changes per session")
            onCheckedChanged: set_seha.checkForChanges()
            ButtonGroup.group: changedgroup
        },

        Flow {
            width: set_seha.contentWidth
            spacing: 5
            PQRadioButton {
                id: reuse
                //: this refers to preserving any selection of zoom/rotation/mirror across different images
                text: qsTranslate("settingsmanager", "preserve across images:")
                ButtonGroup.group: changedgroup
                onCheckedChanged: set_seha.checkForChanges()
            }
            PQCheckBox {
                id: reuse_zoom
                text: qsTranslate("settingsmanager", "Zoom")
                enabled: reuse.checked
                onCheckedChanged: set_seha.checkForChanges()
            }
            PQCheckBox {
                id: reuse_rotation
                text: qsTranslate("settingsmanager", "Rotation")
                enabled: reuse.checked
                onCheckedChanged: set_seha.checkForChanges()
            }
            PQCheckBox {
                id: reuse_mirror
                text: qsTranslate("settingsmanager", "Mirror")
                enabled: reuse.checked
                onCheckedChanged: set_seha.checkForChanges()
            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                remember.checked = PQCSettings.getDefaultForImageviewRememberZoomRotationMirror()
                forget.checked = !remember.checked

                reuse_zoom.checked = PQCSettings.getDefaultForImageviewPreserveZoom()
                reuse_rotation.checked = PQCSettings.getDefaultForImageviewPreserveRotation()
                reuse_mirror.checked = PQCSettings.getDefaultForImageviewPreserveMirror()
                reuse.checked = (reuse_zoom.checked||reuse_rotation.checked||reuse_mirror.checked)

                set_seha.checkForChanges()

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

        PQCConstants.settingsManagerSettingChanged = (mult.hasChanged() || sing.hasChanged() || blanksession.hasChanged() ||
                                                      reopenlast.hasChanged() || forget.hasChanged() || remember.hasChanged() ||
                                                      reuse.hasChanged() || reuse_zoom.hasChanged() || reuse_rotation.hasChanged() ||
                                                      reuse_mirror.hasChanged())

    }

    function load() {

        settingsLoaded = false

        sing.loadAndSetDefault(!PQCSettings.interfaceAllowMultipleInstances)
        mult.loadAndSetDefault(PQCSettings.interfaceAllowMultipleInstances)

        blanksession.loadAndSetDefault(!PQCSettings.interfaceRememberLastImage)
        reopenlast.loadAndSetDefault(PQCSettings.interfaceRememberLastImage)

        forget.loadAndSetDefault(!PQCSettings.imageviewRememberZoomRotationMirror)
        remember.loadAndSetDefault(PQCSettings.imageviewRememberZoomRotationMirror)

        reuse_zoom.loadAndSetDefault(PQCSettings.imageviewPreserveZoom)
        reuse_rotation.loadAndSetDefault(PQCSettings.imageviewPreserveRotation)
        reuse_mirror.loadAndSetDefault(PQCSettings.imageviewPreserveMirror)
        reuse.loadAndSetDefault(reuse_zoom.checked||reuse_rotation.checked||reuse_mirror.checked)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceAllowMultipleInstances = mult.checked
        mult.saveDefault()
        sing.saveDefault()

        PQCSettings.interfaceRememberLastImage = reopenlast.checked
        blanksession.saveDefault()
        reopenlast.saveDefault()

        PQCSettings.imageviewRememberZoomRotationMirror = remember.checked
        PQCSettings.imageviewPreserveZoom = (reuse.checked && reuse_zoom.checked)
        PQCSettings.imageviewPreserveRotation = (reuse.checked && reuse_rotation.checked)
        PQCSettings.imageviewPreserveMirror = (reuse.checked && reuse_mirror.checked)
        forget.saveDefault()
        remember.saveDefault()
        reuse.saveDefault()
        reuse_zoom.saveDefault()
        reuse_rotation.saveDefault()
        reuse_mirror.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
