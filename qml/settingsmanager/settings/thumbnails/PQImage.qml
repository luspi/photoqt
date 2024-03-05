/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - thumbnailsSize
// - thumbnailsCropToFit
// - thumbnailsSmallThumbnailsKeepSmall
// - thumbnailsIconsOnly
// - thumbnailsFontSize
// - thumbnailsFilename
// - thumbnailsInactiveTransparent
// - thumbnailsTooltip

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false
    property bool settingsLoaded: false

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Size")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The thumbnails are typically hidden behind one of the screen edges. Which screen edge can be specified in the interface settings. The size of the thumbnails refers to the maximum size of each individual thumbnail image.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {

            x: (parent.width-width)/2

            PQText {
                text: "32px"
            }

            PQSlider {
                id: thumb_size
                from: 32
                to: 512
                value: PQCSettings.thumbnailsSize
                onValueChanged: checkDefault()
            }

            PQText {
                text: "512px"
            }

        }

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "current value:") + " " + thumb_size.value + "px"
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Scale and crop")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The thumbnail for an image can either be scaled to fit fully inside the maximum size specified above, or it can be scaled and cropped such that it takes up all available space. In the latter case some parts of a thumbnail image might be cut off. In addition, thumbnails that are smaller than the size specified above can be kept at their original size.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: thumb_fit
                text: qsTranslate("settingsmanager", "fit thumbnail")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: thumb_crop
                text: qsTranslate("settingsmanager", "scale and crop thumbnail")
                checked: PQCSettings.thumbnailsCropToFit
                onCheckedChanged: checkDefault()
            }

            Item {
                width: 1
                height: 1
            }

            PQCheckBox {
                id: thumb_small
                text: qsTranslate("settingsmanager", "keep small thumbnails small")
                checked: PQCSettings.thumbnailsSmallThumbnailsKeepSmall
                onCheckedChanged: checkDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Icons only")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Instead of loading actual thumbnail images in the background, PhotoQt can instead simply show the respective icon for the filetype. This requires much fewer resources and time but is not as user friendly.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQRadioButton {
                id: thumb_actual
                //: The word actual is used with the same meaning as: real
                text: qsTranslate("settingsmanager", "use actual thumbnail images")
                onCheckedChanged: checkDefault()
            }

            PQRadioButton {
                id: thumb_icon
                text: qsTranslate("settingsmanager", "use filetype icons")
                checked: PQCSettings.thumbnailsIconsOnly
                onCheckedChanged: checkDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Label")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "On top of each thumbnail image PhotoQt can put a small text label with the filename. The font size of the filename is freely adjustable. If a filename is too long for the available space only the beginning and end of the filename will be visible. Additionally, the label of thumbnails that are neither loaded nor hovered can be shown with less opacity.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: label_enable
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show filename label")
            checked: PQCSettings.thumbnailsFilename
            onCheckedChanged: checkDefault()
        }

        Item {
            width: 1
            height: 1
        }

        Row {
            x: (parent.width-width)/2
            enabled: label_enable.checked
            PQText {
                text: "5pt"
            }
            PQSlider {
                id: label_fontsize
                from: 5
                to: 20
                value: PQCSettings.thumbnailsFontSize
                onValueChanged: checkDefault()
            }
            PQText {
                text: "20pt"
            }
        }

        PQText {
            x: (parent.width-width)/2
            enabled: label_enable.checked
            text: qsTranslate("settingsmanager", "current value:") + " " + label_fontsize.value + "pt"
        }

        PQCheckBox {
            id: thumb_opaque
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "decrease opacity for inactive thumbnails")
            checked: PQCSettings.thumbnailsInactiveTransparent
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Tooltip")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt can show additional information about an image in the form of a tooltip that is shown when the mouse cursor hovers above a thumbnail. The displayed information includes the full file name, file size, and file type.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: tooltips_show
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "show tooltips")
            checked: PQCSettings.thumbnailsTooltip
            onCheckedChanged: checkDefault()
        }

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (thumb_size.hasChanged() || thumb_fit.hasChanged() || thumb_crop.hasChanged() || thumb_small.hasChanged() ||
                          thumb_actual.hasChanged() || thumb_icon.hasChanged() || label_enable.hasChanged() || label_fontsize.hasChanged() ||
                          tooltips_show.hasChanged())

    }

    function load() {

        thumb_size.loadAndSetDefault(PQCSettings.thumbnailsSize)

        thumb_fit.loadAndSetDefault(!PQCSettings.thumbnailsCropToFit)
        thumb_crop.loadAndSetDefault(PQCSettings.thumbnailsCropToFit)
        thumb_small.loadAndSetDefault(PQCSettings.thumbnailsSmallThumbnailsKeepSmall)

        thumb_actual.loadAndSetDefault(!PQCSettings.thumbnailsIconsOnly)
        thumb_icon.loadAndSetDefault(PQCSettings.thumbnailsIconsOnly)

        label_enable.loadAndSetDefault(PQCSettings.thumbnailsFilename)
        label_fontsize.loadAndSetDefault(PQCSettings.thumbnailsFontSize)
        thumb_opaque.loadAndSetDefault(PQCSettings.thumbnailsInactiveTransparent)

        tooltips_show.loadAndSetDefault(PQCSettings.thumbnailsTooltip)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsSize = thumb_size .value

        PQCSettings.thumbnailsCropToFit = thumb_crop.checked
        PQCSettings.thumbnailsSmallThumbnailsKeepSmall = thumb_small .checked

        PQCSettings.thumbnailsIconsOnly = thumb_icon.checked

        PQCSettings.thumbnailsFilename = label_enable.checked
        PQCSettings.thumbnailsFontSize = label_fontsize.value
        PQCSettings.thumbnailsInactiveTransparent = thumb_opaque.checked

        PQCSettings.thumbnailsTooltip = tooltips_show.checked

        thumb_size.saveDefault()
        thumb_fit.saveDefault()
        thumb_crop.saveDefault()
        thumb_small.saveDefault()
        thumb_actual.saveDefault()
        thumb_icon.saveDefault()
        label_enable.saveDefault()
        label_fontsize.saveDefault()
        thumb_opaque.saveDefault()
        tooltips_show.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
