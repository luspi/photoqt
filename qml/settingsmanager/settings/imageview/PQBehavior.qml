import QtQuick

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imageviewLoopThroughFolder
// - imageviewCache
// - imageviewBigViewerModeButton
// - imageviewAlwaysActualSize
// - imageviewResetViewShow
// - imageviewResetViewAutoHideTimeout
// - imageviewNavigationFloating
// - interfaceNavigationTopRight
// - interfaceWindowDecorationOnEmptyBackground
// - imageviewZoomSpeed
// - imageviewZoomToCenter
// - imageviewZoomMin
// - imageviewZoomMax
// - imageviewZoomMinEnabled
// - imageviewZoomMaxEnabled
// - imageviewSortImagesBy
// - imageviewSortImagesAscending
// - imageviewAnimationDuration
// - imageviewAnimationType
// - imageviewUseMouseWheelForImageMove
// - imageviewHideCursorTimeout
// - interfaceMouseWheelSensitivity
// - interfaceDoubleClickThreshold

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
