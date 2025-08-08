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
import QtQuick.Controls
import PhotoQt.Modern

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - filetypesLoadMotionPhotos
// - filetypesLoadAppleLivePhotos

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: ps_entering.popup.visible

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_motion

            //: Settings title
            title: qsTranslate("settingsmanager", "Motion/Live photos")

            helptext: qsTranslate("settingsmanager", "Both Apple and Android devices can connect a short video clip to photos. Apple refers to this as Apple Live Photo, and Google refers to it as Motion Photo (or sometimes Micro Video). Apple stores small video files next to the image files that have the same filename but different file ending. Android embeds these video files in the image file. If the former is enabled, PhotoQt will hide the video files from the file list and automatically load them when the connected image file is loaded. If the latter is enabled PhotoQt will try to extract and show the video file once the respective image file is loaded. All of this is done asynchronously and should not cause any slowdown. PhotoQt can also show a small play/pause button in the bottom right corner of the window, and it can force the space bar to always play/pause the detected video.")

            enabled: PQCScriptsConfig.isMotionPhotoSupportEnabled() 

            content: [

                PQTextL {
                    width: set_motion.rightcol
                    text: ">> " + qsTranslate("settingsmanager", "This feature is not supported by your build of PhotoQt.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.weight: PQCLook.fontWeightBold 
                    visible: !PQCScriptsConfig.isMotionPhotoSupportEnabled() 
                },

                PQCheckBox {
                    id: applelive
                    enforceMaxWidth: set_motion.rightcol
                    text: qsTranslate("settingsmanager", "Look for Apple Live Photos")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: motionmicro
                    enforceMaxWidth: set_motion.rightcol
                    text: qsTranslate("settingsmanager", "Look for Google Motion Photos")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Item {
                    width: 1
                    height: 10
                },

                PQCheckBox {
                    id: motionplaypause
                    enforceMaxWidth: set_motion.rightcol
                    text: qsTranslate("settingsmanager", "Show small play/pause/autoplay button in bottom right corner of window")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: motionspace
                    enforceMaxWidth: set_motion.rightcol
                    text: qsTranslate("settingsmanager", "Always use space key to play/pause videos")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                applelive.checked = PQCSettings.getDefaultForFiletypesLoadAppleLivePhotos()
                motionmicro.checked = PQCSettings.getDefaultForFiletypesLoadMotionPhotos()
                motionplaypause.checked = PQCSettings.getDefaultForFiletypesMotionPhotoPlayPause()
                motionspace.checked = PQCSettings.getDefaultForFiletypesMotionSpacePause()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return(applelive.hasChanged() || motionmicro.hasChanged() ||
                       motionplaypause.hasChanged() || motionspace.hasChanged())
            }

            function load() {
                applelive.loadAndSetDefault(PQCSettings.filetypesLoadAppleLivePhotos) 
                motionmicro.loadAndSetDefault(PQCSettings.filetypesLoadMotionPhotos)
                motionplaypause.loadAndSetDefault(PQCSettings.filetypesMotionPhotoPlayPause)
                motionspace.loadAndSetDefault(PQCSettings.filetypesMotionSpacePause)
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
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sph

            //: Settings title
            title: qsTranslate("settingsmanager", "Photo spheres")

            helptext: qsTranslate("settingsmanager",  "PhotoQt can check whether the current image is a photo sphere by analyzing its metadata. If a equirectangular projection is detected, the photo sphere will be loaded instead of a flat image. In addition, the arrow keys can optionally be forced to be used for moving around the sphere regardless of which shortcut actions they are set to. Both partial photo spheres and 360 degree views are supported.")

            enabled: PQCScriptsConfig.isPhotoSphereSupportEnabled() 

            content: [

                PQTextL {
                    width: set_sph.rightcol
                    text: ">> " + qsTranslate("settingsmanager", "This feature is not supported by your build of PhotoQt.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.weight: PQCLook.fontWeightBold 
                    visible: !PQCScriptsConfig.isPhotoSphereSupportEnabled() 
                },

                Flow {

                    width: set_sph.rightcol
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
                            setting_top.checkDefault()
                    }
                },

                PQCheckBox {
                    id: ps_controls
                    enforceMaxWidth: set_sph.rightcol
                    text: qsTranslate("settingsmanager", "show floating controls for photo spheres")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: ps_arrows
                    enforceMaxWidth: set_sph.rightcol
                    text: qsTranslate("settingsmanager", "use arrow keys for moving around photo spheres")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: ps_escape
                    enforceMaxWidth: set_sph.rightcol
                    text: qsTranslate("settingsmanager", "Escape key leaves manually entered photo sphere")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: ps_pan
                    enforceMaxWidth: set_sph.rightcol
                    text: qsTranslate("settingsmanager", "perform short panning animation after loading photo spheres")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

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
            }

            function handleEscape() {
                ps_entering.popup.close()
            }

            function hasChanged() {
                return (ps_escape.hasChanged() || ps_entering.hasChanged() || ps_controls.hasChanged() || ps_arrows.hasChanged() || ps_pan.hasChanged())
            }

            function load() {
                ps_entering.loadAndSetDefault(PQCSettings.filetypesPhotoSphereAutoLoad ? 0 : (PQCSettings.filetypesPhotoSphereBigButton ? 1 : 2))
                ps_controls.loadAndSetDefault(PQCSettings.filetypesPhotoSphereControls)
                ps_arrows.loadAndSetDefault(PQCSettings.filetypesPhotoSphereArrowKeys)
                ps_pan.loadAndSetDefault(PQCSettings.filetypesPhotoSpherePanOnLoad)
                ps_escape.loadAndSetDefault(PQCSettings.imageviewEscapeExitSphere)
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

            }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_motion.handleEscape()
        set_sph.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        settingChanged = (set_motion.hasChanged() || set_sph.hasChanged())

    }

    function load() {

        set_motion.load()
        set_sph.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_motion.applyChanges()
        set_sph.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
