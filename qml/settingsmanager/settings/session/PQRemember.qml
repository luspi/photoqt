/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imageviewRememberZoomRotationMirror
// - interfaceRememberLastImage
// - imageviewPreserveZoom
// - imageviewPreserveRotation
// - imageviewPreserveMirror

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false
    property bool settingsLoaded: false

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Reopen last image")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When PhotoQt is started normally, by default an empty window is shown with the prompt to open an image from the file dialog. Alternatively it is also possible to reopen the image that was last loaded in the previous session.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: blanksession
                text: qsTranslate("settingsmanager", "start with blank session")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: reopenlast
                text: qsTranslate("settingsmanager", "reopen last used image")
                checked: PQCSettings.interfaceRememberLastImage
                onCheckedChanged: checkDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Remember changes")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Once an image has been loaded it can be manipulated freely by zooming, rotating, or mirroring the image. Once another image is loaded any such changes are forgotten. If preferred, it is possible for PhotoQt to remember any such manipulations per session. Note that once PhotoQt is closed these changes will be forgotten in any case.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "In addition to on an per-image basis, PhotoQt can also keep the same changes across different images. If enabled and possible, the next image is loaded with the same scaling, rotation, and mirroring as the image before.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            ButtonGroup { id: changedgroup }

            PQRadioButton {
                id: forget
                text: qsTranslate("settingsmanager", "forget changes when other image loaded")
                onCheckedChanged: checkDefault()
                ButtonGroup.group: changedgroup
            }

            PQRadioButton {
                id: remember
                text: qsTranslate("settingsmanager", "remember changes per session")
                checked: PQCSettings.imageviewRememberZoomRotationMirror
                onCheckedChanged: checkDefault()
                ButtonGroup.group: changedgroup
            }

            Row {
                PQRadioButton {
                    id: reuse
                    //: this refers to preserving any selection of zoom/rotation/mirror across different images
                    text: qsTranslate("settingsmanager", "preserve across images:")
                    ButtonGroup.group: changedgroup
                    onCheckedChanged: checkDefault()
                }
                PQCheckBox {
                    id: reuse_zoom
                    text: qsTranslate("settingsmanager", "Zoom")
                    enabled: reuse.checked
                    onCheckedChanged: checkDefault()
                }
                PQCheckBox {
                    id: reuse_rotation
                    text: qsTranslate("settingsmanager", "Rotation")
                    enabled: reuse.checked
                    onCheckedChanged: checkDefault()
                }
                PQCheckBox {
                    id: reuse_mirror
                    text: qsTranslate("settingsmanager", "Mirror")
                    enabled: reuse.checked
                    onCheckedChanged: checkDefault()
                }
            }

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (blanksession.hasChanged() || reopenlast.hasChanged() || forget.hasChanged() || remember.hasChanged() ||
                          reuse.hasChanged() || reuse_zoom.hasChanged() || reuse_rotation.hasChanged() || reuse_mirror.hasChanged())

    }

    function load() {

        blanksession.loadAndSetDefault(!PQCSettings.interfaceRememberLastImage)
        reopenlast.loadAndSetDefault(PQCSettings.interfaceRememberLastImage)

        forget.loadAndSetDefault(!PQCSettings.imageviewRememberZoomRotationMirror)
        remember.loadAndSetDefault(PQCSettings.imageviewRememberZoomRotationMirror)

        reuse_zoom.loadAndSetDefault(PQCSettings.imageviewPreserveZoom)
        reuse_rotation.loadAndSetDefault(PQCSettings.imageviewPreserveRotation)
        reuse_mirror.loadAndSetDefault(PQCSettings.imageviewPreserveMirror)
        reuse.loadAndSetDefault(reuse_zoom.checked||reuse_rotation.checked||reuse_mirror.checked)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceRememberLastImage = reopenlast.checked
        PQCSettings.imageviewRememberZoomRotationMirror = remember.checked
        PQCSettings.imageviewPreserveZoom = (reuse.checked && reuse_zoom.checked)
        PQCSettings.imageviewPreserveRotation = (reuse.checked && reuse_rotation.checked)
        PQCSettings.imageviewPreserveMirror = (reuse.checked && reuse_mirror.checked)

        blanksession.saveDefault()
        reopenlast.saveDefault()
        forget.saveDefault()
        remember.saveDefault()
        reuse.saveDefault()
        reuse_zoom.saveDefault()
        reuse_rotation.saveDefault()
        reuse_mirror.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
