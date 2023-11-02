import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfaceAllowMultipleInstances

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
            text: qsTranslate("settingsmanager", "Single instance")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt can either run in single-instance mode or allow multiple instances to run at the same time. The former has the advantage that it is possible to interact with a running instance of PhotoQt through the command line (in fact, this is a requirement for that to work). The latter allows, for example, for the comparison of multiple images side by side. ")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: sing
                text: qsTranslate("settingsmanager", "run a single instance only")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: mult
                text: qsTranslate("settingsmanager", "allow multiple instances")
                checked: PQCSettings.interfaceAllowMultipleInstances
                onCheckedChanged: checkDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(mult.hasChanged() || sing.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {
        sing.loadAndSetDefault(!PQCSettings.interfaceAllowMultipleInstances)
        mult.loadAndSetDefault(PQCSettings.interfaceAllowMultipleInstances)

        settingChanged = false
    }

    function applyChanges() {

        PQCSettings.interfaceAllowMultipleInstances = mult.checked

        mult.saveDefault()
        sing.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
