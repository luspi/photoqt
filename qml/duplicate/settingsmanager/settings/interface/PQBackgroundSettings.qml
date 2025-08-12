/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import PQCImageFormats

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

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

    property bool settingsLoaded: false
    property bool catchEscape: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    SystemPalette { id: pqtPalette }

    Column {

        id: contcol

        x: (parent.width-width)/2

        PQSetting {

            id: set_bg

            helptext: qsTranslate("settingsmanager",  "The background is the area in the back (no surprise there) behind any image that is currently being viewed. By default, PhotoQt is partially transparent with a dark overlay. This is only possible, though, whenever a compositor is available. On some platforms, PhotoQt can fake a transparent background with screenshots taken at startup. Another option is to show a background image (also with a dark overlay) in the background.")

            //: Settings title
            title: qsTranslate("settingsmanager", "Background")

            ButtonGroup {
                id: bggrp
            }

            content: [

                PQRadioButton {
                    id: radio_real
                    enforceMaxWidth: set_bg.rightcol
                    //: How the background of PhotoQt should be
                    text: qsTranslate("settingsmanager", "real transparency")
                    ButtonGroup.group: bggrp
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: radio_fake
                    enforceMaxWidth: set_bg.rightcol
                    visible: PQCConstants.startupHaveScreenshots
                    //: How the background of PhotoQt should be
                    text: qsTranslate("settingsmanager", "fake transparency")
                    ButtonGroup.group: bggrp
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: radio_solid
                    enforceMaxWidth: set_bg.rightcol
                    //: How the background of PhotoQt should be
                    text: qsTranslate("settingsmanager", "solid background color")
                    ButtonGroup.group: bggrp
                    onCheckedChanged: setting_top.checkDefault()
                },

                Column {

                    PQRadioButton {
                        id: radio_nobg
                        enforceMaxWidth: set_bg.rightcol
                        //: How the background of PhotoQt should be
                        text: qsTranslate("settingsmanager", "fully transparent background")
                        ButtonGroup.group: bggrp
                        onCheckedChanged: setting_top.checkDefault()
                    }

                    Item {
                        height: radio_nobg.checked ? nobgwarning.height : 0
                        width: nobgwarning.width+radio_nobg.leftPadding
                        opacity: radio_nobg.checked ? 1 : 0
                        Behavior on height { NumberAnimation { duration: 200 } }
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        clip: true
                        PQText {
                            id: nobgwarning
                            x: radio_nobg.leftPadding
                            width: set_bg.rightcol-radio_nobg.leftPadding
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.weight: PQCLook.fontWeightBold
                            text: qsTranslate("settingsmanager", "Warning: This will make the background fully transparent. This is only recommended if there is a different way to mask the area behind the window.")
                        }
                    }

                },


                PQRadioButton {
                    id: radio_custom
                    enforceMaxWidth: set_bg.rightcol
                    //: How the background of PhotoQt should be
                    text: qsTranslate("settingsmanager", "custom background image")
                    ButtonGroup.group: bggrp
                    onCheckedChanged: setting_top.checkDefault()
                },

                Row {

                    spacing: 10

                    enabled: radio_custom.checked

                    clip: true
                    height: enabled ? custombg_optcol.height : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Rectangle {

                        id: bgimagerow

                        width: custombg_optcol.height
                        height: custombg_optcol.height
                        color: pqtPalette.alternateBase
                        border.color: PQCLook.baseBorder
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
                            onSourceChanged:
                                setting_top.checkDefault()
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
                                    previewimage.source = encodeURI("file:" + path)
                            }
                        }

                        Image {
                            x: parent.width-width-2
                            y: 2
                            width: 24
                            height: 24
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
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
                            onCheckedChanged: setting_top.checkDefault()
                        }
                        PQRadioButton {
                            id: radio_bg_scaleandcrop
                            //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                            text: qsTranslate("settingsmanager", "scale and crop to fit")
                            checked: PQCSettings.interfaceBackgroundImageScaleCrop
                            onCheckedChanged: setting_top.checkDefault()
                        }
                        PQRadioButton {
                            id: radio_bg_stretch
                            //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                            text: qsTranslate("settingsmanager", "stretch to fit")
                            checked: PQCSettings.interfaceBackgroundImageStretch
                            onCheckedChanged: setting_top.checkDefault()
                        }
                        PQRadioButton {
                            id: radio_bg_center
                            //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                            text: qsTranslate("settingsmanager", "center image")
                            checked: PQCSettings.interfaceBackgroundImageCenter
                            onCheckedChanged: setting_top.checkDefault()
                        }
                        PQRadioButton {
                            id: radio_bg_tile
                            //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                            text: qsTranslate("settingsmanager", "tile image")
                            checked: PQCSettings.interfaceBackgroundImageTile
                            onCheckedChanged: setting_top.checkDefault()
                        }
                    }

                },

                Item {
                    width: 1
                    height: 1
                },

                Rectangle {
                    width: set_bg.rightcol
                    height: 1
                    color: PQCLook.baseBorder
                },

                Item {
                    width: 1
                    height: 1
                },

                Flow {
                    id: accentrow
                    width: set_bg.rightcol
                    PQRadioButton {
                        id: accentusecheck
                        text: qsTranslate("settingsmanager", "overlay with accent color")
                        checked: !PQCSettings.interfaceBackgroundCustomOverlay
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: customusecheck
                        text: qsTranslate("settingsmanager", "overlay with custom color")
                        checked: PQCSettings.interfaceBackgroundCustomOverlay
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    Rectangle {
                        id: customuse
                        height: customusecheck.height
                        width: customusecheck.checked ? 200 : 0
                        Behavior on width { NumberAnimation { duration: 200 } }
                        opacity: customusecheck.checked ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        clip: true
                        color: PQCSettings.interfaceBackgroundCustomOverlayColor==="" ? pqtPalette.base : PQCSettings.interfaceBackgroundCustomOverlayColor
                        onColorChanged: setting_top.checkDefault()
                        Rectangle {
                            x: (parent.width-width)/2
                            y: (parent.height-height)/2
                            width: customusetxt.width+20
                            height: customusetxt.height+10
                            radius: 5
                            color: "#88000000"
                            PQText {
                                id: customusetxt
                                x: 10
                                y: 5
                                text: PQCScriptsOther.convertRgbToHex([255*customuse.color.r, 255*customuse.color.g, 255*customuse.color.b])
                            }
                        }

                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("settingsmanager", "Click to change color")
                            onClicked: {
                                coldiag.currentColor = customuse.color
                                coldiag.open()
                            }
                        }

                        ColorDialog {
                            id: coldiag
                            modality: Qt.ApplicationModal
                            onAccepted: {
                                customuse.color = coldiag.currentColor
                            }
                        }
                    }
                }

            ]

            onResetToDefaults: {
                var valBIS = PQCSettings.getDefaultForInterfaceBackgroundImageScreenshot()
                var valBISo = PQCSettings.getDefaultForInterfaceBackgroundSolid()
                var valBIU = PQCSettings.getDefaultForInterfaceBackgroundImageUse()
                var valBIT = PQCSettings.getDefaultForInterfaceBackgroundFullyTransparent()
                radio_real.checked = (valBIS===0 && valBIU===0 && valBIT===0)
                radio_fake.checked = valBIS
                radio_solid.checked = valBISo
                radio_nobg.checked = valBIT
                radio_custom.checked = valBIU

                var val = PQCSettings.getDefaultForInterfaceBackgroundCustomOverlay()
                accentusecheck.checked = (val === 0)
                customusecheck.checked = (val === 1)

                previewimage.source = PQCSettings.getDefaultForInterfaceBackgroundImagePath()
                radio_bg_scaletofit.checked = PQCSettings.getDefaultForInterfaceBackgroundImageScale()
                radio_bg_scaleandcrop.checked = PQCSettings.getDefaultForInterfaceBackgroundImageScaleCrop()
                radio_bg_stretch.checked = PQCSettings.getDefaultForInterfaceBackgroundImageStretch()
                radio_bg_center.checked = PQCSettings.getDefaultForInterfaceBackgroundImageCenter()
                radio_bg_tile.checked = PQCSettings.getDefaultForInterfaceBackgroundImageTile()
            }

            function handleEscape() {}

            function hasChanged() {

                if(radio_real.hasChanged() || radio_fake.hasChanged() || radio_solid.hasChanged() || radio_custom.hasChanged() || radio_nobg.hasChanged()) {
                    return true
                }

                if(accentusecheck.hasChanged() || customusecheck.hasChanged() || (customusecheck.checked && customuse.color != PQCSettings.interfaceBackgroundCustomOverlayColor)) {
                    return true
                }

                if(previewimage.source !== "file:" + PQCSettings.interfaceBackgroundImagePath ||
                   radio_bg_scaletofit.hasChanged() ||  radio_bg_scaleandcrop.hasChanged() ||
                   radio_bg_stretch.hasChanged() || radio_bg_center.hasChanged() || radio_bg_tile.hasChanged()) {
                    return true
                }

                return false
            }

            function load() {

                radio_real.loadAndSetDefault(!PQCSettings.interfaceBackgroundImageScreenshot && !PQCSettings.interfaceBackgroundImageUse && !PQCSettings.interfaceBackgroundFullyTransparent)
                radio_fake.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScreenshot)
                radio_solid.loadAndSetDefault(PQCSettings.interfaceBackgroundSolid)
                radio_nobg.loadAndSetDefault(PQCSettings.interfaceBackgroundFullyTransparent)
                radio_custom.loadAndSetDefault(PQCSettings.interfaceBackgroundImageUse)

                accentusecheck.loadAndSetDefault(!PQCSettings.interfaceBackgroundCustomOverlay)
                customusecheck.loadAndSetDefault(PQCSettings.interfaceBackgroundCustomOverlay)


                /******************************/

                if(PQCSettings.interfaceBackgroundImagePath !== "")
                    previewimage.source = encodeURI("file:" + PQCSettings.interfaceBackgroundImagePath)
                else
                    previewimage.source = ""
                radio_bg_scaletofit.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScale)
                radio_bg_scaleandcrop.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScaleCrop)
                radio_bg_stretch.loadAndSetDefault(PQCSettings.interfaceBackgroundImageStretch)
                radio_bg_center.loadAndSetDefault(PQCSettings.interfaceBackgroundImageCenter)
                radio_bg_tile.loadAndSetDefault(PQCSettings.interfaceBackgroundImageTile)

            }

            function applyChanges() {

                PQCSettings.interfaceBackgroundImageScreenshot = radio_fake.checked
                PQCSettings.interfaceBackgroundImageUse = radio_custom.checked
                PQCSettings.interfaceBackgroundSolid = radio_solid.checked
                PQCSettings.interfaceBackgroundFullyTransparent = radio_nobg.checked

                radio_real.saveDefault()
                radio_fake.saveDefault()
                radio_solid.saveDefault()
                radio_custom.saveDefault()
                radio_nobg.saveDefault()

                PQCSettings.interfaceBackgroundCustomOverlay = customusecheck.checked
                if(customusecheck.checked)
                    PQCSettings.interfaceBackgroundCustomOverlayColor = PQCScriptsOther.convertRgbToHex([255*customuse.color.r, 255*customuse.color.g, 255*customuse.color.b])

                customusecheck.saveDefault()
                accentusecheck.saveDefault()

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

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_emp

            title: qsTranslate("settingsmanager", "Click on empty background")
            helptext: qsTranslate("settingsmanager", "The empty background area is the part of the background that is not covered by any image. A click on that area can trigger certain actions, some depending on where exactly the click occured")

            content: [

                PQRadioButton {
                    id: radio_noaction
                    enforceMaxWidth: set_emp.rightcol
                    //: what to do when the empty background is clicked
                    text: qsTranslate("settingsmanager", "no action")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: radio_closeclick
                    enforceMaxWidth: set_emp.rightcol
                    //: what to do when the empty background is clicked
                    text: qsTranslate("settingsmanager", "close window")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: radio_navclick
                    enforceMaxWidth: set_emp.rightcol
                    //: what to do when the empty background is clicked
                    text: qsTranslate("settingsmanager", "navigate between images")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: radio_toggledeco
                    enforceMaxWidth: set_emp.rightcol
                    //: what to do when the empty background is clicked
                    text: qsTranslate("settingsmanager", "toggle window decoration")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                radio_closeclick.checked = PQCSettings.getDefaultForInterfaceCloseOnEmptyBackground()
                radio_navclick.checked = PQCSettings.getDefaultForInterfaceNavigateOnEmptyBackground()
                radio_toggledeco.checked = PQCSettings.getDefaultForInterfaceWindowDecorationOnEmptyBackground()
                radio_noaction.checked = (!radio_closeclick.checked && !radio_navclick.checked && !radio_toggledeco.checked)
            }

            function handleEscape() {}

            function hasChanged() {
                return (radio_closeclick.hasChanged() || radio_navclick.hasChanged() || radio_toggledeco.hasChanged() || radio_noaction.hasChanged())
            }

            function load() {
                radio_closeclick.loadAndSetDefault(PQCSettings.interfaceCloseOnEmptyBackground)
                radio_navclick.loadAndSetDefault(PQCSettings.interfaceNavigateOnEmptyBackground)
                radio_toggledeco.loadAndSetDefault(PQCSettings.interfaceWindowDecorationOnEmptyBackground)
                radio_noaction.loadAndSetDefault(!radio_closeclick.checked && !radio_navclick.checked && !radio_toggledeco.checked)
            }

            function applyChanges() {
                PQCSettings.interfaceCloseOnEmptyBackground = radio_closeclick.checked
                PQCSettings.interfaceNavigateOnEmptyBackground = radio_navclick.checked
                PQCSettings.interfaceWindowDecorationOnEmptyBackground = radio_toggledeco.checked

                radio_closeclick.saveDefault()
                radio_navclick.saveDefault()
                radio_toggledeco.saveDefault()
                radio_noaction.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator { visible: PQCScriptsConfig.isQtAtLeast6_5() }
        /**********************************************************************/

        PQSetting {

            id: set_blur

            visible: PQCScriptsConfig.isQtAtLeast6_5()

            //: A settings title
            title: qsTranslate("settingsmanager", "Blurring elements behind other elements")
            helptext: qsTranslate("settingsmanager", "Whenever an element (e.g., histogram, main menu, etc.) is open, anything behind it can be blurred slightly. This reduces the contrast in the background which improves readability. Note that this requires a slightly higher amount of computations. It also does not work with anything behind PhotoQt that is not part of the window itself.")

            content: [

                PQCheckBox {
                    visible: PQCScriptsConfig.isQtAtLeast6_5()
                    id: check_blurbg
                    enforceMaxWidth: set_blur.rightcol
                    text: qsTranslate("settingsmanager", "Blur elements in the back")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                check_blurbg.checked = PQCSettings.getDefaultForInterfaceBlurElementsInBackground()
            }

            function handleEscape() {}

            function hasChanged() {
                return check_blurbg.hasChanged()
            }

            function load() {
                check_blurbg.loadAndSetDefault(PQCSettings.interfaceBlurElementsInBackground)
            }

            function applyChanges() {
                PQCSettings.interfaceBlurElementsInBackground = check_blurbg.checked
                check_blurbg.saveDefault()
            }

        }

        Item {
            width: 1
            height: 10
        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_bg.handleEscape()
        set_emp.handleEscape()
        set_blur.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        if(set_bg.hasChanged() || set_emp.hasChanged() || set_blur.hasChanged()) {
            PQCConstants.settingsManagerSettingChanged = true
            return
        }

        PQCConstants.settingsManagerSettingChanged = false

    }

    function load() {

        set_bg.load()
        set_emp.load()
        set_blur.load()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_bg.applyChanges()
        set_emp.applyChanges()
        set_blur.applyChanges()

        PQCConstants.settingsManagerSettingChanged = false

    }

    function revertChanges() {
        load()
    }

}
