import QtQuick

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

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false
    property string defaultSettingChecker: ""

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager_interface", "Background")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager_interface",  "The background is the area in the back (no surprise there) behind any image that is currently being viewed. By default, PhotoQt is partially transparent with a dark overlay. This is only possible, though, whenever a compositor is available. On some platforms, PhotoQt can fake a transparent background with screenshots taken at startup. Another option is to show a background image (also with a dark overlay) in the background.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            spacing: 10

            PQRadioButton {
                id: radio_real
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager_interface", "real transparency")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_fake
                visible: PQCNotify.haveScreenshots
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager_interface", "fake transparency")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_solid
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager_interface", "solid background color")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_custom
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager_interface", "custom background image")
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
                        text: qsTranslate("settingsmanager_interface", "background image")
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
                        text: qsTranslate("settingsmanager_interface", "Click to select an image")
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
                        source: "/white/close.svg"
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
                        text: qsTranslate("settingsmanager_interface", "scale to fit")
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_scaleandcrop
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager_interface", "scale and crop to fit")
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_stretch
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager_interface", "stretch to fit")
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_center
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager_interface", "center image")
                        onCheckedChanged: checkDefault()
                    }
                    PQRadioButton {
                        id: radio_bg_tile
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager_interface", "tile image")
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
            text: qsTranslate("settingsmanager_interface", "Click on empty background")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager_interface", "The empty background area is the part of the background that is not covered by any image. A click on that area can trigger certain actions, some depending on where exactly the click occured")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2

            spacing: 10

            PQRadioButton {
                id: radio_noaction
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager_interface", "no action")
                checked: true
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_closeclick
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager_interface", "close window")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_navclick
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager_interface", "navigate between images")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: radio_toggledeco
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager_interface", "toggle window decoration")
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
            text: qsTranslate("settingsmanager_interface", "Blurring elements behind other elements")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            visible: PQCScriptsConfig.isQtAtLeast6_4()
            width: setting_top.width
            text: qsTranslate("settingsmanager_interface", "Whenever an element (e.g., histogram, main menu, etc.) is open, anything behind it can be blurred slightly. This reduces the contrast in the background which improves readability. Note that this requires a slightly higher amount of computations. It also does not work with anything behind PhotoQt that is not part of the window itself.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            visible: PQCScriptsConfig.isQtAtLeast6_4()
            id: check_blurbg
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager_interface", "Blur elements in the back")
            onCheckedChanged: checkDefault()

        }

        Item {
            width: 1
            height: 10
        }


    }

    Component.onCompleted:
        load()

    function composeDefaultChecker() {

        var tmp = ""

        tmp += (radio_fake.checked ? "1" : "0")
        tmp += (radio_custom.checked ? "1" : "0")
        tmp += (radio_solid.checked ? "1" : "0")

        /******************************/

        tmp += (radio_bg_scaletofit.checked ? "1" : "0")
        tmp += (radio_bg_scaleandcrop.checked ? "1" : "0")
        tmp += (radio_bg_stretch.checked ? "1" : "0")
        tmp += (radio_bg_center.checked ? "1" : "0")
        tmp += (radio_bg_tile.checked ? "1" : "0")

        /******************************/

        tmp += (radio_closeclick.checked ? "1" : "0")
        tmp += (radio_navclick.checked ? "1" : "0")
        tmp += (radio_toggledeco.checked ? "1" : "0")

        /******************************/

        tmp += (check_blurbg.checked ? "1" : "0")

        return tmp
    }

    function checkDefault() {

        var tmp = composeDefaultChecker()+""
        settingChanged = (tmp!==defaultSettingChecker)

        console.warn("checkDefault:", tmp, defaultSettingChecker)

    }

    function load() {

        radio_real.checked = (!PQCSettings.interfaceBackgroundImageScreenshot && !PQCSettings.interfaceBackgroundImageUse)
        radio_fake.checked = PQCSettings.interfaceBackgroundImageScreenshot
        radio_solid.checked = PQCSettings.interfaceBackgroundSolid
        radio_custom.checked = PQCSettings.interfaceBackgroundImageUse

        /******************************/

        if(PQCSettings.interfaceBackgroundImagePath !== "")
            previewimage.source = "file:/" + PQCSettings.interfaceBackgroundImagePath
        else
            previewimage.source = ""
        radio_bg_scaletofit.checked = PQCSettings.interfaceBackgroundImageScale
        radio_bg_scaleandcrop.checked = PQCSettings.interfaceBackgroundImageScaleCrop
        radio_bg_stretch.checked = PQCSettings.interfaceBackgroundImageStretch
        radio_bg_center.checked = PQCSettings.interfaceBackgroundImageCenter
        radio_bg_tile.checked = PQCSettings.interfaceBackgroundImageTile

        /******************************/

        radio_closeclick.checked = PQCSettings.interfaceCloseOnEmptyBackground
        radio_navclick.checked = PQCSettings.interfaceNavigateOnEmptyBackground
        radio_toggledeco.checked = PQCSettings.interfaceWindowDecorationOnEmptyBackground
        radio_noaction.checked = (!radio_closeclick.checked && !radio_navclick.checked && !radio_toggledeco.checked)

        /******************************/

        check_blurbg.checked = PQCSettings.interfaceBlurElementsInBackground

        defaultSettingChecker = composeDefaultChecker()
        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.interfaceBackgroundImageScreenshot = radio_fake.checked
        PQCSettings.interfaceBackgroundImageUse = radio_custom.checked
        PQCSettings.interfaceBackgroundSolid = radio_solid.checked

        /******************************/

        PQCSettings.interfaceBackgroundImagePath = PQCScriptsFilesPaths.cleanPath(previewimage.source)
        PQCSettings.interfaceBackgroundImageScale = radio_bg_scaletofit.checked
        PQCSettings.interfaceBackgroundImageScaleCrop = radio_bg_scaleandcrop.checked
        PQCSettings.interfaceBackgroundImageStretch = radio_bg_stretch.checked
        PQCSettings.interfaceBackgroundImageCenter = radio_bg_center.checked
        PQCSettings.interfaceBackgroundImageTile = radio_bg_tile.checked

        /******************************/

        PQCSettings.interfaceCloseOnEmptyBackground = radio_closeclick.checked
        PQCSettings.interfaceNavigateOnEmptyBackground = radio_navclick.checked
        PQCSettings.interfaceWindowDecorationOnEmptyBackground = radio_toggledeco.checked

        /******************************/

        PQCSettings.interfaceBlurElementsInBackground = check_blurbg.checked

        defaultSettingChecker = composeDefaultChecker()
        settingChanged = false


    }

    function revertChanges() {
        load()
    }

}
