import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - metadataGpsMap
// - metadataAutoRotation
// - metadataElementFloating

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Auto Rotation")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "When an image is taken with the camera turned on its side, some cameras store that rotation in the metadata. PhotoQt can use that information to display an image the way it was meant to be viewed. Disabling this will load all photos without any rotation applied by default.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: autorot
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "Apply default rotation automatically")
            checked: PQCSettings.metadataAutoRotation
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "GPS map")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "Some cameras store the location of where the image was taken in the metadata of its images. PhotoQt can use that information in multiple ways. It can show a floating embedded map with a pin on that location, and it can show the GPS coordinates in the metadata element. In the latter case, a click on the GPS coordinates will open the location in an online map service, the choice of which can be set here.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: osm
                text: "openstreetmap.org"
                checked: PQCSettings.metadataGpsMap==="openstreetmap.org"
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: google
                text: "maps.google.com"
                checked: PQCSettings.metadataGpsMap==="maps.google.com"
                onCheckedChanged: checkDefault()
            }
            PQRadioButton {
                id: bing
                text: "bing.com/maps"
                checked: PQCSettings.metadataGpsMap==="bing.com/maps"
                onCheckedChanged: checkDefault()
            }
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Floating element")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The metadata element can be show in two different ways. It can either be shown hidden behind one of the screen edges and shown when the cursor is close to said edge. Or it can be shown as floating element that can be triggered by shortcut and stays visible until manually hidden.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: screenegde
                text: qsTranslate("settingsmanager", "hide behind screen edge")
                checked: !PQCSettings.metadataElementFloating
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: floating
                text: qsTranslate("settingsmanager", "use floating element")
                checked: PQCSettings.metadataElementFloating
                onCheckedChanged: checkDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        settingChanged = (autorot.hasChanged() || osm.hasChanged() || google.hasChanged() ||
                          bing.hasChanged() || screenegde.hasChanged() || floating.hasChanged())

    }

    function load() {

        autorot.loadAndSetDefault(PQCSettings.metadataAutoRotation)

        osm.loadAndSetDefault(PQCSettings.metadataGpsMap==="openstreetmap.org")
        google.loadAndSetDefault(PQCSettings.metadataGpsMap==="maps.google.com")
        bing.loadAndSetDefault(PQCSettings.metadataGpsMap==="bing.com/maps")

        screenegde.loadAndSetDefault(!PQCSettings.metadataElementFloating)
        floating.loadAndSetDefault(PQCSettings.metadataElementFloating)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.metadataAutoRotation = autorot.checked

        if(osm.checked)
            PQCSettings.metadataGpsMap = "openstreetmap.org"
        else if(google.checked)
            PQCSettings.metadataGpsMap = "maps.google.com"
        else
            PQCSettings.metadataGpsMap = "bing.com/maps"

        PQCSettings.metadataElementFloating = floating.checked

        autorot.saveDefault()
        osm.saveDefault()
        google.saveDefault()
        bing.saveDefault()
        screenegde.saveDefault()
        floating.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
