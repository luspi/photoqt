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
import PQCNotify

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

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

    property bool catchEscape: thumb_size.contextMenuOpen || thumb_size.editMode ||
                               label_fontsize.contextMenuOpen || label_fontsize.editMode

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_size

            //: Settings title
            title: qsTranslate("settingsmanager", "Size")

            helptext: qsTranslate("settingsmanager", "The thumbnails are typically hidden behind one of the screen edges. Which screen edge can be specified in the interface settings. The size of the thumbnails refers to the maximum size of each individual thumbnail image.")

            content: [

                PQSliderSpinBox {
                    id: thumb_size
                    width: set_size.rightcol
                    minval: 32
                    maxval: 512
                    title: ""
                    suffix: " px"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_scale

            //: Settings title
            title: qsTranslate("settingsmanager", "Scale and crop")

            helptext: qsTranslate("settingsmanager", "The thumbnail for an image can either be scaled to fit fully inside the maximum size specified above, or it can be scaled and cropped such that it takes up all available space. In the latter case some parts of a thumbnail image might be cut off. In addition, thumbnails that are smaller than the size specified above can be kept at their original size.") +
                      "<br><br>" + qsTranslate("settingsmanager", "A third option is to scale all thumbnails to the height of the bar and vary their width. Note that this requires all thumbnails to be preloaded at the start potentially causing short stutters in the interface. Such a listing of images at various widths can also be a little more difficult to scroll through.")

            content: [

                PQRadioButton {
                    id: thumb_fit
                    enforceMaxWidth: set_scale.rightcol
                    text: qsTranslate("settingsmanager", "fit thumbnail")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: thumb_crop
                    enforceMaxWidth: set_scale.rightcol
                    text: qsTranslate("settingsmanager", "scale and crop thumbnail")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: thumb_sameheight
                    enforceMaxWidth: set_scale.rightcol
                    text: qsTranslate("settingsmanager", "same height, varying width")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Item {
                    width: 1
                    height: 1
                },

                PQCheckBox {
                    id: thumb_small
                    enforceMaxWidth: set_scale.rightcol
                    text: qsTranslate("settingsmanager", "keep small thumbnails small")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_icn

            //: Settings title
            title: qsTranslate("settingsmanager", "Icons only")

            helptext: qsTranslate("settingsmanager", "Instead of loading actual thumbnail images in the background, PhotoQt can instead simply show the respective icon for the filetype. This requires much fewer resources and time but is not as user friendly.")

            content: [

                PQRadioButton {
                    id: thumb_actual
                    enforceMaxWidth: set_icn.rightcol
                    //: The word actual is used with the same meaning as: real
                    text: qsTranslate("settingsmanager", "use actual thumbnail images")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: thumb_icon
                    enforceMaxWidth: set_icn.rightcol
                    text: qsTranslate("settingsmanager", "use filetype icons")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_label

            //: Settings title
            title: qsTranslate("settingsmanager", "Label")

            helptext: qsTranslate("settingsmanager", "On top of each thumbnail image PhotoQt can put a small text label with the filename. The font size of the filename is freely adjustable. If a filename is too long for the available space only the beginning and end of the filename will be visible. Additionally, the label of thumbnails that are neither loaded nor hovered can be shown with less opacity.")

            content: [

                PQCheckBox {
                    id: label_enable
                    enforceMaxWidth: set_label.rightcol
                    text: qsTranslate("settingsmanager", "show filename label")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Column {

                    enabled: label_enable.checked
                    clip: true
                    height: enabled ? fontsizerow.height+thumb_opaque.height+spacing : 0
                    opacity: fontsizerow ? 1 : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    spacing: 10

                    Row {

                        id: fontsizerow
                        spacing: 10

                        Item {
                            width: 22
                            height: 1
                        }

                        PQSliderSpinBox {
                            id: label_fontsize
                            width: set_label.rightcol - 32
                            minval: 5
                            maxval: 20
                            title: qsTranslate("settingsmanager", "Font size:")
                            suffix: " pt"
                            onValueChanged:
                                setting_top.checkDefault()
                        }

                    }

                    PQCheckBox {
                        id: thumb_opaque
                        enforceMaxWidth: set_label.rightcol
                        text: qsTranslate("settingsmanager", "decrease opacity for inactive thumbnails")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_ttip

            //: Settings title
            title: qsTranslate("settingsmanager", "Tooltip")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show additional information about an image in the form of a tooltip that is shown when the mouse cursor hovers above a thumbnail. The displayed information includes the full file name, file size, and file type.")

            content: [
                PQCheckBox {
                    id: tooltips_show
                    enforceMaxWidth: set_ttip.rightcol
                    text: qsTranslate("settingsmanager", "show tooltips")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        thumb_size.acceptValue()
        label_fontsize.acceptValue()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        settingChanged = (thumb_size.hasChanged() || thumb_fit.hasChanged() || thumb_crop.hasChanged() || thumb_small.hasChanged() ||
                          thumb_actual.hasChanged() || thumb_icon.hasChanged() || label_enable.hasChanged() || label_fontsize.hasChanged() ||
                          tooltips_show.hasChanged() || thumb_sameheight.hasChanged())

    }

    function load() {

        thumb_size.loadAndSetDefault(PQCSettings.thumbnailsSize) // qmllint disable unqualified

        thumb_fit.loadAndSetDefault(!PQCSettings.thumbnailsCropToFit && !PQCSettings.thumbnailsSameHeightVaryWidth)
        thumb_crop.loadAndSetDefault(PQCSettings.thumbnailsCropToFit)
        thumb_sameheight.loadAndSetDefault(PQCSettings.thumbnailsSameHeightVaryWidth)
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

        PQCSettings.thumbnailsSize = thumb_size.value // qmllint disable unqualified

        PQCSettings.thumbnailsCropToFit = thumb_crop.checked
        PQCSettings.thumbnailsSameHeightVaryWidth = thumb_sameheight.checked
        PQCSettings.thumbnailsSmallThumbnailsKeepSmall = thumb_small.checked

        PQCSettings.thumbnailsIconsOnly = thumb_icon.checked

        PQCSettings.thumbnailsFilename = label_enable.checked
        PQCSettings.thumbnailsFontSize = label_fontsize.value
        PQCSettings.thumbnailsInactiveTransparent = thumb_opaque.checked

        PQCSettings.thumbnailsTooltip = tooltips_show.checked

        thumb_size.saveDefault()
        thumb_fit.saveDefault()
        thumb_crop.saveDefault()
        thumb_sameheight.saveDefault()
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
