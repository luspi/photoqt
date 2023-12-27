import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imageviewLoadMotionPhotos
// - imageviewLoadAppleLivePhotos

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Motion/Live photos")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Both Apple and Android devices can connect a short video clip to photos. Apple refers to this as Apple Live Photo, and Google refers to it as Motion Photo (or sometimes Micro Video). Apple stores small video files next to the image files that have the same filename but different file ending. Android embeds these video files in the image file. If the former is enabled, PhotoQt will hide the video files from the file list and automatically load them when the connected image file is loaded. If the latter is enabled PhotoQt will try to extract and show the video file once the respective image file is loaded. All of this is done assynchronously and should not cause any slowdown.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQCheckBox {
                id: applelive
                text: qsTranslate("settingsmanager", "Look for Apple Live Photo")
                checked: PQCSettings.imageviewLoadAppleLivePhotos
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: motionmicro
                text: qsTranslate("settingsmanager", "Look for Google Motion Photos")
                checked: PQCSettings.imageviewLoadMotionPhotos
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
            checked: PQCSettings.imageviewCheckForPhotoSphere
            onCheckedChanged: checkDefault()
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        settingChanged = (applelive.hasChanged() || motionmicro.hasChanged())

    }

    function load() {

        applelive.loadAndSetDefault(PQCSettings.imageviewLoadAppleLivePhotos)
        motionmicro.loadAndSetDefault(PQCSettings.imageviewLoadMotionPhotos)
        photosphere.loadAndSetDefault(PQCSettings.imageviewCheckForPhotoSphere)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.imageviewLoadAppleLivePhotos = applelive.checked
        PQCSettings.imageviewLoadMotionPhotos = motionmicro.checked
        PQCSettings.imageviewCheckForPhotoSphere = photosphere.checked

        applelive.saveDefault()
        motionmicro.saveDefault()
        photosphere.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
