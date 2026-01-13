/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import Qt.labs.platform
import QtQuick.Controls
import PhotoQt

PQSetting {

    id: set_bg

    ButtonGroup {
        id: bggrp
    }

    content: [

        PQSettingSubtitle {

            visible: set_bg.modernInterface
            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Background")

            helptext: qsTranslate("settingsmanager", "The background is the area in the back (no surprise there) behind any image that is currently being viewed. By default, PhotoQt is partially transparent with a dark overlay. This is only possible, though, whenever a compositor is available. On some platforms, PhotoQt can fake a transparent background with screenshots taken at startup. Another option is to show a background image (also with a dark overlay) in the background.")

        },

        Column {

            visible: set_bg.modernInterface
            spacing: 5

            PQRadioButton {
                id: radio_real
                enforceMaxWidth: set_bg.contentWidth
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "real transparency")
                ButtonGroup.group: bggrp
                onCheckedChanged: set_bg.checkForChanges()
            }

            PQRadioButton {
                id: radio_fake
                visible: PQCConstants.startupHaveScreenshots
                enforceMaxWidth: set_bg.contentWidth
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "fake transparency")
                ButtonGroup.group: bggrp
                onCheckedChanged: set_bg.checkForChanges()
            }

            PQRadioButton {
                id: radio_solid
                enforceMaxWidth: set_bg.contentWidth
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "solid background color")
                ButtonGroup.group: bggrp
                onCheckedChanged: set_bg.checkForChanges()
            }

            Column {

                PQRadioButton {
                    id: radio_nobg
                    enforceMaxWidth: set_bg.contentWidth
                    //: How the background of PhotoQt should be
                    text: qsTranslate("settingsmanager", "fully transparent background")
                    ButtonGroup.group: bggrp
                    onCheckedChanged: set_bg.checkForChanges()
                }

                Item {
                    height: radio_nobg.checked ? nobgwarning.height+20 : 0
                    width: nobgwarning.width+radio_nobg.leftPadding
                    opacity: radio_nobg.checked ? 1 : 0
                    Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }
                    clip: true
                    PQText {
                        id: nobgwarning
                        x: 25
                        y: 10
                        width: set_bg.contentWidth-50
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.weight: PQCLook.fontWeightBold
                        text: qsTranslate("settingsmanager", "Warning: This will make the background fully transparent. This is only recommended if there is a different way to mask the area behind the window.")
                    }
                }

            }


            PQRadioButton {
                id: radio_custom
                enforceMaxWidth: set_bg.contentWidth
                //: How the background of PhotoQt should be
                text: qsTranslate("settingsmanager", "custom background image")
                ButtonGroup.group: bggrp
                onCheckedChanged: set_bg.checkForChanges()
            }

            Row {

                spacing: 10

                x: 25
                enabled: radio_custom.checked

                clip: true
                height: enabled ? custombg_optcol.height : 0
                Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                opacity: enabled ? 1 : 0
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }

                Rectangle {

                    id: bgimagerow

                    width: custombg_optcol.height*1.2
                    height: custombg_optcol.height
                    color: palette.alternateBase
                    border.color: PQCLook.baseBorder
                    border.width: 1

                    opacity: radio_custom.checked ? 1 : 0.3
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                    PQText {
                        anchors.centerIn: parent
                        text: qsTranslate("settingsmanager", "background image")
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Image {
                        id: previewimage
                        anchors.fill: parent
                        anchors.margins: 1
                        fillMode: Image.PreserveAspectFit
                        source: ""
                        onSourceChanged:
                            set_bg.checkForChanges()
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
                    ButtonGroup { id: grp_custombg }
                    id: custombg_optcol
                    spacing: 15
                    PQRadioButton {
                        id: radio_bg_scaletofit
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "scale to fit")
                        checked: PQCSettings.interfaceBackgroundImageScale
                        onCheckedChanged: set_bg.checkForChanges()
                        ButtonGroup.group: grp_custombg
                    }
                    PQRadioButton {
                        id: radio_bg_scaleandcrop
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "scale and crop to fit")
                        checked: PQCSettings.interfaceBackgroundImageScaleCrop
                        onCheckedChanged: set_bg.checkForChanges()
                        ButtonGroup.group: grp_custombg
                    }
                    PQRadioButton {
                        id: radio_bg_stretch
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "stretch to fit")
                        checked: PQCSettings.interfaceBackgroundImageStretch
                        onCheckedChanged: set_bg.checkForChanges()
                        ButtonGroup.group: grp_custombg
                    }
                    PQRadioButton {
                        id: radio_bg_center
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "center image")
                        checked: PQCSettings.interfaceBackgroundImageCenter
                        onCheckedChanged: set_bg.checkForChanges()
                        ButtonGroup.group: grp_custombg
                    }
                    PQRadioButton {
                        id: radio_bg_tile
                        //: If an image is set as background of PhotoQt this is one way it can be shown/scaled
                        text: qsTranslate("settingsmanager", "tile image")
                        checked: PQCSettings.interfaceBackgroundImageTile
                        onCheckedChanged: set_bg.checkForChanges()
                        ButtonGroup.group: grp_custombg
                    }
                }

            }

        },

        PQSettingsResetButton {
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

                previewimage.source = PQCSettings.getDefaultForInterfaceBackgroundImagePath()
                radio_bg_scaletofit.checked = PQCSettings.getDefaultForInterfaceBackgroundImageScale()
                radio_bg_scaleandcrop.checked = PQCSettings.getDefaultForInterfaceBackgroundImageScaleCrop()
                radio_bg_stretch.checked = PQCSettings.getDefaultForInterfaceBackgroundImageStretch()
                radio_bg_center.checked = PQCSettings.getDefaultForInterfaceBackgroundImageCenter()
                radio_bg_tile.checked = PQCSettings.getDefaultForInterfaceBackgroundImageTile()

                set_bg.checkForChanges()

            }
        },

        /**************************************************/

        PQSettingSubtitle {
            visible: set_bg.modernInterface
            ButtonGroup { id: grp_bgaccent }
            title: qsTranslate("settingsmanager", "Background accent")
        },

        Column {

            visible: set_bg.modernInterface
            spacing: 5

            PQRadioButton {
                id: bgaccentusecheck
                text: qsTranslate("settingsmanager", "use accent color for background")
                onCheckedChanged: set_bg.checkForChanges()
                ButtonGroup.group: grp_bgaccent
            }

            PQRadioButton {
                id: bgcustomusecheck
                text: qsTranslate("settingsmanager", "use custom color for background")
                onCheckedChanged: set_bg.checkForChanges()
                ButtonGroup.group: grp_bgaccent
            }

            Rectangle {
                id: bgcustomuse
                x: 25
                height: bgcustomusecheck.checked ? 50 : 0
                Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                width: 200
                opacity: bgcustomusecheck.checked ? 1 : 0
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }
                clip: true
                property string setColor: ""
                color: setColor==="" ? palette.base : setColor
                onColorChanged: set_bg.checkForChanges()
                border.width: 1
                border.color: PQCLook.baseBorder

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("settingsmanager", "Click to change color")
                    onClicked: {
                        coldiag.currentColor = bgcustomuse.color
                        coldiag.open()
                    }
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var val = PQCSettings.getDefaultForInterfaceBackgroundCustomOverlay()
                bgaccentusecheck.checked = !val
                bgcustomusecheck.checked = val
                bgcustomuse.setColor = PQCSettings.getDefaultForInterfaceBackgroundCustomOverlayColor()

                set_bg.checkForChanges()

            }
        },

        /**************************************************/

        PQSettingSubtitle {
            showLineAbove: set_bg.modernInterface
            ButtonGroup { id: grp_conb }
            title: qsTranslate("settingsmanager", "Click on empty background")
            helptext: qsTranslate("settingsmanager", "The empty background area is the part of the background that is not covered by any image. A click on that area can trigger certain actions, some depending on where exactly the click occured")
        },

        Column {

            spacing: 5

            PQRadioButton {
                id: radio_noaction
                enforceMaxWidth: set_bg.contentWidth
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "no action")
                onCheckedChanged: set_bg.checkForChanges()
                ButtonGroup.group: grp_conb
            }

            PQRadioButton {
                id: radio_closeclick
                enforceMaxWidth: set_bg.contentWidth
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "close window")
                onCheckedChanged: set_bg.checkForChanges()
                ButtonGroup.group: grp_conb
            }

            PQRadioButton {
                id: radio_navclick
                enforceMaxWidth: set_bg.contentWidth
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "navigate between images")
                onCheckedChanged: set_bg.checkForChanges()
                ButtonGroup.group: grp_conb
            }

            PQRadioButton {
                id: radio_toggledeco
                enforceMaxWidth: set_bg.contentWidth
                //: what to do when the empty background is clicked
                text: qsTranslate("settingsmanager", "toggle window decoration")
                onCheckedChanged: set_bg.checkForChanges()
                ButtonGroup.group: grp_conb
            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                radio_closeclick.checked = PQCSettings.getDefaultForInterfaceCloseOnEmptyBackground()
                radio_navclick.checked = PQCSettings.getDefaultForInterfaceNavigateOnEmptyBackground()
                radio_toggledeco.checked = PQCSettings.getDefaultForInterfaceWindowDecorationOnEmptyBackground()
                radio_noaction.checked = (!radio_closeclick.checked && !radio_navclick.checked && !radio_toggledeco.checked)

                set_bg.checkForChanges()

            }
        }

    ]

    ColorDialog {
        id: coldiag
        modality: Qt.ApplicationModal
        onAccepted: {
            bgcustomuse.setColor = PQCScriptsOther.convertRgbToHex([255*coldiag.currentColor.r, 255*coldiag.currentColor.g, 255*coldiag.currentColor.b])
        }
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        if(radio_real.hasChanged() || radio_fake.hasChanged() || radio_solid.hasChanged() || radio_custom.hasChanged() || radio_nobg.hasChanged()) {
            PQCConstants.settingsManagerSettingChanged = true
            return
        }

        if(bgaccentusecheck.hasChanged() || bgcustomusecheck.hasChanged() || (bgcustomusecheck.checked && bgcustomuse.setColor !== PQCSettings.interfaceBackgroundCustomOverlayColor)) {
            PQCConstants.settingsManagerSettingChanged = true
            return
        }

        // this intermediate step is necessary to make sure the soruce is registered as string, otherwise the check below will not work as expected
        var prevsrc = previewimage.source+""
        if((!(prevsrc == "" && PQCSettings.interfaceBackgroundImagePath === "") && (prevsrc !== "file:" + PQCSettings.interfaceBackgroundImagePath)) ||
            radio_bg_scaletofit.hasChanged() ||  radio_bg_scaleandcrop.hasChanged() ||
            radio_bg_stretch.hasChanged() || radio_bg_center.hasChanged() || radio_bg_tile.hasChanged()) {
            PQCConstants.settingsManagerSettingChanged = true
            return
        }

        if(radio_closeclick.hasChanged() || radio_navclick.hasChanged() || radio_toggledeco.hasChanged() || radio_noaction.hasChanged()) {
            PQCConstants.settingsManagerSettingChanged = true
            return
        }

        PQCConstants.settingsManagerSettingChanged = false

    }

    function load() {

        settingsLoaded = false

        radio_real.loadAndSetDefault(!PQCSettings.interfaceBackgroundImageScreenshot && !PQCSettings.interfaceBackgroundImageUse && !PQCSettings.interfaceBackgroundFullyTransparent)
        radio_fake.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScreenshot)
        radio_solid.loadAndSetDefault(PQCSettings.interfaceBackgroundSolid)
        radio_nobg.loadAndSetDefault(PQCSettings.interfaceBackgroundFullyTransparent)
        radio_custom.loadAndSetDefault(PQCSettings.interfaceBackgroundImageUse)

        bgaccentusecheck.loadAndSetDefault(!PQCSettings.interfaceBackgroundCustomOverlay)
        bgcustomusecheck.loadAndSetDefault(PQCSettings.interfaceBackgroundCustomOverlay)
        bgcustomuse.setColor = PQCSettings.interfaceBackgroundCustomOverlayColor

        if(PQCSettings.interfaceBackgroundImagePath !== "")
            previewimage.source = encodeURI("file:" + PQCSettings.interfaceBackgroundImagePath)
        else
            previewimage.source = ""
        radio_bg_scaletofit.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScale)
        radio_bg_scaleandcrop.loadAndSetDefault(PQCSettings.interfaceBackgroundImageScaleCrop)
        radio_bg_stretch.loadAndSetDefault(PQCSettings.interfaceBackgroundImageStretch)
        radio_bg_center.loadAndSetDefault(PQCSettings.interfaceBackgroundImageCenter)
        radio_bg_tile.loadAndSetDefault(PQCSettings.interfaceBackgroundImageTile)

        radio_closeclick.loadAndSetDefault(PQCSettings.interfaceCloseOnEmptyBackground)
        radio_navclick.loadAndSetDefault(PQCSettings.interfaceNavigateOnEmptyBackground)
        radio_toggledeco.loadAndSetDefault(PQCSettings.interfaceWindowDecorationOnEmptyBackground)
        radio_noaction.loadAndSetDefault(!radio_closeclick.checked && !radio_navclick.checked && !radio_toggledeco.checked)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

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

        PQCSettings.interfaceBackgroundCustomOverlay = bgcustomusecheck.checked
        if(bgcustomusecheck.checked)
            PQCSettings.interfaceBackgroundCustomOverlayColor = bgcustomuse.setColor

        bgcustomusecheck.saveDefault()
        bgaccentusecheck.saveDefault()

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

        PQCSettings.interfaceCloseOnEmptyBackground = radio_closeclick.checked
        PQCSettings.interfaceNavigateOnEmptyBackground = radio_navclick.checked
        PQCSettings.interfaceWindowDecorationOnEmptyBackground = radio_toggledeco.checked

        radio_closeclick.saveDefault()
        radio_navclick.saveDefault()
        radio_toggledeco.saveDefault()
        radio_noaction.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
