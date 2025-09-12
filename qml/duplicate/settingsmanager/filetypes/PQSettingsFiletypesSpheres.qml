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

    id: set_phsp

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Photo spheres")

            helptext: qsTranslate("settingsmanager",  "PhotoQt can check whether the current image is a photo sphere by analyzing its metadata. If a equirectangular projection is detected, the photo sphere will be loaded instead of a flat image. In addition, the arrow keys can optionally be forced to be used for moving around the sphere regardless of which shortcut actions they are set to. Both partial photo spheres and 360 degree views are supported.")

            showLineAbove: false

        },

        PQTextL {
            width: set_phsp.contentWidth
            text: ">> " + qsTranslate("settingsmanager", "This feature is not supported by your build of PhotoQt.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.weight: PQCLook.fontWeightBold
            visible: !PQCScriptsConfig.isPhotoSphereSupportEnabled()
        },

        Flow {

            width: set_phsp.contentWidth
            spacing: 5

            PQText {
                height: ps_entering.height
                verticalAlignment: Text.AlignVCenter
                //: This is the info text for a combobox about how to enter photo spheres
                text: qsTranslate("settingsmanager", "Enter photo spheres:")
            }

            PQComboBox {
                id: ps_entering
                extrawide: true
                                                  //: Used as in: Enter photo spheres automatically
                property list<string> modeldata: [qsTranslate("settingsmanager", "automatically"),
                                                  //: Used as in: Enter photo spheres through central big button
                                                  qsTranslate("settingsmanager", "through central big button"),
                                                  //: Used as in: Enter photo spheres never
                                                  qsTranslate("settingsmanager", "never")]
                model: modeldata
                onCurrentIndexChanged:
                    set_phsp.checkForChanges()
            }
        },

        PQCheckBox {
            id: ps_controls
            enforceMaxWidth: set_phsp.contentWidth
            text: qsTranslate("settingsmanager", "show floating controls for photo spheres")
            onCheckedChanged: set_phsp.checkForChanges()
        },

        PQCheckBox {
            id: ps_arrows
            enforceMaxWidth: set_phsp.contentWidth
            text: qsTranslate("settingsmanager", "use arrow keys for moving around photo spheres")
            onCheckedChanged: set_phsp.checkForChanges()
        },

        PQCheckBox {
            id: ps_escape
            enforceMaxWidth: set_phsp.contentWidth
            text: qsTranslate("settingsmanager", "Escape key leaves manually entered photo sphere")
            onCheckedChanged: set_phsp.checkForChanges()
        },

        PQCheckBox {
            id: ps_pan
            enforceMaxWidth: set_phsp.contentWidth
            text: qsTranslate("settingsmanager", "perform short panning animation after loading photo spheres")
            onCheckedChanged: set_phsp.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                ps_entering.currentIndex = (PQCSettings.getDefaultForFiletypesPhotoSphereAutoLoad() ?
                                                0 :
                                                (PQCSettings.getDefaultForFiletypesPhotoSphereBigButton() ?
                                                     1 :
                                                     2))
                ps_controls.checked = PQCSettings.getDefaultForFiletypesPhotoSphereControls()
                ps_arrows.checked = PQCSettings.getDefaultForFiletypesPhotoSphereArrowKeys()
                ps_pan.checked = PQCSettings.getDefaultForFiletypesPhotoSpherePanOnLoad()
                ps_escape.checked = PQCSettings.getDefaultForImageviewEscapeExitSphere()

                set_phsp.checkForChanges()

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

        PQCConstants.settingsManagerSettingChanged = (ps_escape.hasChanged() || ps_entering.hasChanged() || ps_controls.hasChanged() ||
                                                      ps_arrows.hasChanged() || ps_pan.hasChanged())

    }

    function load() {

        settingsLoaded = false

        ps_entering.loadAndSetDefault(PQCSettings.filetypesPhotoSphereAutoLoad ? 0 : (PQCSettings.filetypesPhotoSphereBigButton ? 1 : 2))
        ps_controls.loadAndSetDefault(PQCSettings.filetypesPhotoSphereControls)
        ps_arrows.loadAndSetDefault(PQCSettings.filetypesPhotoSphereArrowKeys)
        ps_pan.loadAndSetDefault(PQCSettings.filetypesPhotoSpherePanOnLoad)
        ps_escape.loadAndSetDefault(PQCSettings.imageviewEscapeExitSphere)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesPhotoSphereAutoLoad = ps_entering.currentIndex===0
        PQCSettings.filetypesPhotoSphereBigButton = ps_entering.currentIndex===1
        PQCSettings.filetypesPhotoSphereControls = ps_controls.checked
        PQCSettings.filetypesPhotoSphereArrowKeys = ps_arrows.checked
        PQCSettings.filetypesPhotoSpherePanOnLoad = ps_pan.checked
        PQCSettings.imageviewEscapeExitSphere = ps_escape.checked

        ps_entering.saveDefault()
        ps_controls.saveDefault()
        ps_arrows.saveDefault()
        ps_pan.saveDefault()
        ps_escape.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
