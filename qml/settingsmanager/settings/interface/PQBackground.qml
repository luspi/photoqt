import QtQuick
import QtQuick.Controls

import PQCNotify
import PQCScriptsFilesPaths
import PQCImageFormats
import PQCScriptsConfig

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - interfaceBackgroundImageCenter
// - interfaceBackgroundImagePath
// - interfaceBackgroundImageScale
// - interfaceBackgroundImageScaleCrop
// - interfaceBackgroundImageScreenshot
// - interfaceBackgroundImageStretch
// - interfaceBackgroundImageTile
// - interfaceBackgroundImageUse
// - interfaceBackgroundSolid
// - interfaceCloseOnEmptyBackground
// - interfaceNavigateOnEmptyBackground
// - interfaceBlurElementsInBackground
// - interfaceWindowDecorationOnEmptyBackground

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
            text: qsTranslate("settingsmanager", "Background")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "The background is the area in the back (no surprise there) behind any image that is currently being viewed. By default, PhotoQt is partially transparent with a dark overlay. This is only possible, though, whenever a compositor is available. On some platforms, PhotoQt can fake a transparent background with screenshots taken at startup. Another option is to show a background image (also with a dark overlay) in the background.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            spacing: 10

            PQRadioButton {
                id: radio_real
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "real transparency")
                checked: (!PQCSettings.interfaceBackgroundImageScreenshot && !PQCSettings.interfaceBackgroundImageUse)
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_fake
                visible: PQCNotify.haveScreenshots
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "fake transparency")
                checked: PQCSettings.interfaceBackgroundImageScreenshot
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_solid
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "solid background color")
                checked: PQCSettings.interfaceBackgroundSolid
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_custom
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "custom background image")
                checked: PQCSettings.interfaceBackgroundImageUse
                onCheckedChanged: checkDefault()
            }

            Row {

                spacing: 10

                enabled: radio_custom.checked

                Item {
                    width: 1
                    height: 1
                }

                Rectangle {
                    width: custombg_optcol.height
                    height: custombg_optcol.height
                    color: PQCLook.baseColorHighlight
                    border.color: PQCLook.baseColorActive
                    border.width: 1

                    opacity: radio_custom.checked ? 1 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    PQText {
                        anchors.centerIn: parent
                        text: qsTranslate("settingsmanager", "background image")
                    }

                    Image {
                        id: previewimage
                        anchors.fill: parent
                        anchors.margins: 1
                        fillMode: Image.PreserveAspectFit
                        source: ""
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: Tooltip for a mouse area, a click on which opens a file dialog for selecting an image
                        text: qsTranslate("settingsmanager", "Click to select an image")
                        onClicked: {
                            var path = PQCScriptsFilesPaths.openFileFromDialog("Select", PQCScriptsFilesPaths.getHomeDir(), PQCImageFormats.getEnabledFormats())
                            if(path !== "")
                                previewimage.source = "file:/" + path
                        }
                    }

                    Image {
                        x: parent.width-width-2
                        y: 2
                        width: 24
                        height: 24
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/white/close.svg"
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                previewimage.source = ""
                        }
                    }

                }

                Column {
                    id: custombg_optcol
                    PQRadioButton {
                        id: radio_bg_scaletofit
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "scale to fit")
                        checked: PQCSettings.interfaceBackgroundImageScale
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_scaleandcrop
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "scale and crop to fit")
                        checked: PQCSettings.interfaceBackgroundImageScaleCrop
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_stretch
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "stretch to fit")
                        checked: PQCSettings.interfaceBackgroundImageStretch
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_center
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "center image")
                        checked: PQCSettings.interfaceBackgroundImageCenter
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_tile
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "tile image")
                        checked: PQCSettings.interfaceBackgroundImageTile
                        onCheckedChanged: checkDefault()
                    }
                }

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            text: qsTranslate("settingsmanager", "Click on empty background")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The empty background area is the part of the background that is not covered by any image. A click on that area can trigger certain actions, some depending on where exactly the click occured")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            spacing: 10

            PQRadioButton {
                id: radio_noaction
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "no action")
                checked: PQCSettings.interfaceCloseOnEmptyBackground
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_closeclick
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "close window")
                checked: PQCSettings.interfaceNavigateOnEmptyBackground
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_navclick
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "navigate between images")
                checked: PQCSettings.interfaceWindowDecorationOnEmptyBackground
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_toggledeco
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "toggle window decoration")
                onCheckedChanged: checkDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator { visible: PQCScriptsConfig.isQtAtLeast6_4() }
        /**********************************************************************/

        PQTextXL {
            visible: PQCScriptsConfig.isQtAtLeast6_4()
            font.weight: PQCLook.fontWeightBold
            //: A settings title
            text: qsTranslate("settingsmanager", "Blurring elements behind other elements")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            visible: PQCScriptsConfig.isQtAtLeast6_4()
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Whenever an element (e.g., histogram, main menu, etc.) is open, anything behind it can be blurred slightly. This reduces the contrast in the background which improves readability. Note that this requires a slightly higher amount of computations. It also does not work with anything behind PhotoQt that is not part of the window itself.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            visible: PQCScriptsConfig.isQtAtLeast6_4()
            id: check_blurbg
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "Blur elements in the back")
            checked: PQCSettings.interfaceBlurElementsInBackground
            onCheckedChanged: checkDefault()

        }

        Item {
            width: 1
            height: 10
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(radio_real.hasChanged() || radio_fake.hasChanged() || radio_solid.hasChanged() || radio_custom.hasChanged()) {
            settingChanged = true
            return
        }

        if(previewimage.source !== "file:/" + PQCSettings.interfaceBackgroundImagePath ||
           radio_bg_scaletofit.hasChanged() ||  radio_bg_scaleandcrop.hasChanged() ||
           radio_bg_stretch.hasChanged() || radio_bg_center.hasChanged() || radio_bg_tile.hasChanged()) {
            settingChanged = true
            return
        }

        if(radio_closeclick.hasChanged() || radio_navclick.hasChanged() || radio_toggledeco.hasChanged() || radio_noaction.hasChanged()) {
            settingChanged = true
            return
        }

        if(check_blurbg.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        radio_real.loadAndSetDefault(!PQCSettings.interfaceBackgroundImageScreenshot && !PQCSettings.interfaceBackgroundImageUse)
        radio_fake.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScreenshot)
        radio_solid.loadAndSetDefault(PQCSettings.interfaceBackgroundSolid)
        radio_custom.loadAndSetDefault(PQCSettings.interfaceBackgroundImageUse)

        /******************************/

        if(PQCSettings.interfaceBackgroundImagePath !== "")
            previewimage.source = "file:/" + PQCSettings.interfaceBackgroundImagePath
        else
            previewimage.source = ""
        radio_bg_scaletofit.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScale)
        radio_bg_scaleandcrop.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScaleCrop)
        radio_bg_stretch.loadAndSetDefault(PQCSettings.interfaceBackgroundImageStretch)
        radio_bg_center.loadAndSetDefault(PQCSettings.interfaceBackgroundImageCenter)
        radio_bg_tile.loadAndSetDefault(PQCSettings.interfaceBackgroundImageTile)

        /******************************/

        radio_closeclick.loadAndSetDefault(PQCSettings.interfaceCloseOnEmptyBackground)
        radio_navclick.loadAndSetDefault(PQCSettings.interfaceNavigateOnEmptyBackground)
        radio_toggledeco.loadAndSetDefault(PQCSettings.interfaceWindowDecorationOnEmptyBackground)
        radio_noaction.loadAndSetDefault(!radio_closeclick.checked && !radio_navclick.checked && !radio_toggledeco.checked)

        /******************************/

        check_blurbg.loadAndSetDefault(PQCSettings.interfaceBlurElementsInBackground)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.interfaceBackgroundImageScreenshot = radio_fake.checked
        PQCSettings.interfaceBackgroundImageUse = radio_custom.checked
        PQCSettings.interfaceBackgroundSolid = radio_solid.checked

        radio_real.saveDefault()
        radio_fake.saveDefault()
        radio_solid.saveDefault()
        radio_custom.saveDefault()

        /******************************/

        PQCSettings.interfaceBackgroundImagePath = PQCScriptsFilesPaths.cleanPath(previewimage.source)
        PQCSettings.interfaceBackgroundImageScale = radio_bg_scaletofit.checked
        PQCSettings.interfaceBackgroundImageScaleCrop = radio_bg_scaleandcrop.checked
        PQCSettings.interfaceBackgroundImageStretch = radio_bg_stretch.checked
        PQCSettings.interfaceBackgroundImageCenter = radio_bg_center.checked
        PQCSettings.interfaceBackgroundImageTile = radio_bg_tile.checked

        radio_bg_scaletofit.saveDefault()
        radio_bg_scaleandcrop.saveDefault()
        radio_bg_stretch.saveDefault()
        radio_bg_center.saveDefault()
        radio_bg_tile.saveDefault()

        /******************************/

        PQCSettings.interfaceCloseOnEmptyBackground = radio_closeclick.checked
        PQCSettings.interfaceNavigateOnEmptyBackground = radio_navclick.checked
        PQCSettings.interfaceWindowDecorationOnEmptyBackground = radio_toggledeco.checked

        radio_closeclick.saveDefault()
        radio_navclick.saveDefault()
        radio_toggledeco.saveDefault()
        radio_noaction.saveDefault()

        /******************************/

        PQCSettings.interfaceBlurElementsInBackground = check_blurbg.checked

        check_blurbg.saveDefault()


        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
