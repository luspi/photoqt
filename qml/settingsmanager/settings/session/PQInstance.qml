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
                text: "run a single instance only"
            }

            PQRadioButton {
                text: "allow multiple instances"
            }

        }

    }

    Component.onCompleted:
        load()

    function load() {
    }

    function applyChanges() {
    }

    function revertChanges() {
        load()
    }

}
