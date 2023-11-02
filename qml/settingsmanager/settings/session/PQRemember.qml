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
                text: "start with blank session"
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: reopenlast
                text: "reopen last used image"
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

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: forget
                text: "forget changes when other image loaded"
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: remember
                text: "remember changes per session"
                checked: PQCSettings.imageviewRememberZoomRotationMirror
                onCheckedChanged: checkDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        settingChanged = (blanksession.hasChanged() || reopenlast.hasChanged() || forget.hasChanged() || remember.hasChanged())

    }

    function load() {

        blanksession.loadAndSetDefault(!PQCSettings.interfaceRememberLastImage)
        reopenlast.loadAndSetDefault(PQCSettings.interfaceRememberLastImage)

        forget.loadAndSetDefault(!PQCSettings.imageviewRememberZoomRotationMirror)
        remember.loadAndSetDefault(PQCSettings.imageviewRememberZoomRotationMirror)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.interfaceRememberLastImage = reopenlast.checked
        PQCSettings.imageviewRememberZoomRotationMirror = remember.checked

        blanksession.saveDefault()
        reopenlast.saveDefault()
        forget.saveDefault()
        remember.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
