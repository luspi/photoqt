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

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        settingChanged = (applelive.hasChanged() || motionmicro.hasChanged())

    }

    function load() {

        applelive.loadAndSetDefault(PQCSettings.imageviewLoadAppleLivePhotos)
        motionmicro.loadAndSetDefault(PQCSettings.imageviewLoadMotionPhotos)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.imageviewLoadAppleLivePhotos = applelive.checked
        PQCSettings.imageviewLoadMotionPhotos = motionmicro.checked

        applelive.saveDefault()
        motionmicro.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
