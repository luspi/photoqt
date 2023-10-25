import QtQuick

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfacePopoutMainMenu
// - interfacePopoutMetadata
// - interfacePopoutHistogram
// - interfacePopoutScale
// - interfacePopoutSlideshowSetup
// - interfacePopoutSlideshowControls
// - interfacePopoutFileRename
// - interfacePopoutFileDelete
// - interfacePopoutAbout
// - interfacePopoutImgur
// - interfacePopoutWallpaper
// - interfacePopoutFilter
// - interfacePopoutSettingsManager
// - interfacePopoutExport
// - interfacePopoutChromecast
// - interfacePopoutAdvancedSort
// - interfacePopoutWhenWindowIsSmall
// - interfacePopoutMapCurrent
// - interfacePopoutMapExplorer
// - interfacePopoutMapExplorerKeepOpen
// - interfacePopoutFileDialog
// - interfacePopoutFileDialogKeepOpen

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
