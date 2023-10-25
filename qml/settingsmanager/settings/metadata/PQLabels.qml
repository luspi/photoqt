import QtQuick

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - metadataFilename
// - metadataFileType
// - metadataFileSize
// - metadataImageNumber
// - metadataCopyright
// - metadataDimensions
// - metadataExposureTime
// - metadataFlash
// - metadataFLength
// - metadataFNumber
// - metadataGps
// - metadataIso
// - metadataKeywords
// - metadataLightSource
// - metadataLocation
// - metadataMake
// - metadataModel
// - metadataSceneType
// - metadataSoftware
// - metadataTime

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    property bool settingChanged: false

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
