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
import PQCScriptsConfig

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - filetypesLoadMotionPhotos
// - filetypesLoadAppleLivePhotos

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
            text: qsTranslate("settingsmanager", "Motion/Live photos")
            font.capitalization: Font.SmallCaps
            enabled: PQCScriptsConfig.isMotionPhotoSupportEnabled()
        }

        PQText {
            width: setting_top.width
            text: ">> " + qsTranslate("settingsmanager", "This feature is not supported by your build of PhotoQt.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.weight: PQCLook.fontWeightBold
            visible: !PQCScriptsConfig.isMotionPhotoSupportEnabled()
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Both Apple and Android devices can connect a short video clip to photos. Apple refers to this as Apple Live Photo, and Google refers to it as Motion Photo (or sometimes Micro Video). Apple stores small video files next to the image files that have the same filename but different file ending. Android embeds these video files in the image file. If the former is enabled, PhotoQt will hide the video files from the file list and automatically load them when the connected image file is loaded. If the latter is enabled PhotoQt will try to extract and show the video file once the respective image file is loaded. All of this is done asynchronously and should not cause any slowdown.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            enabled: PQCScriptsConfig.isMotionPhotoSupportEnabled()
        }

        Item {
            width: 1
            height: 1
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            enabled: PQCScriptsConfig.isMotionPhotoSupportEnabled()

            PQCheckBox {
                id: applelive
                text: qsTranslate("settingsmanager", "Look for Apple Live Photos")
                checked: PQCSettings.filetypesLoadAppleLivePhotos
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: motionmicro
                text: qsTranslate("settingsmanager", "Look for Google Motion Photos")
                checked: PQCSettings.filetypesLoadMotionPhotos
                onCheckedChanged: checkDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Photo spheres")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "PhotoQt is able to check whether a current image is a photo sphere, this is done by analyzing the meta data of an image in the background. If a equirectangular projection is detected, then a button is visible in the center of the image for entering the photo sphere. This is supported for both partial photo spheres and for 360 degree views.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: photosphere
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "Check for photo spheres")
            checked: PQCSettings.filetypesCheckForPhotoSphere
            onCheckedChanged: checkDefault()
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

        settingChanged = (applelive.hasChanged() || motionmicro.hasChanged())

    }

    function load() {

        applelive.loadAndSetDefault(PQCSettings.filetypesLoadAppleLivePhotos)
        motionmicro.loadAndSetDefault(PQCSettings.filetypesLoadMotionPhotos)
        photosphere.loadAndSetDefault(PQCSettings.filetypesCheckForPhotoSphere)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filetypesLoadAppleLivePhotos = applelive.checked
        PQCSettings.filetypesLoadMotionPhotos = motionmicro.checked
        PQCSettings.filetypesCheckForPhotoSphere = photosphere.checked

        applelive.saveDefault()
        motionmicro.saveDefault()
        photosphere.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
