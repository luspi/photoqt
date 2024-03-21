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
import PQCNotify

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

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Size")

            helptext: qsTranslate("settingsmanager", "The thumbnails are typically hidden behind one of the screen edges. Which screen edge can be specified in the interface settings. The size of the thumbnails refers to the maximum size of each individual thumbnail image.")

            content: [

                PQSpinBoxAdvanced {
                    id: thumb_size
                    minval: 32
                    maxval: 512
                    title: ""
                    suffix: " px"
                    onValueChanged:
                        checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Scale and crop")

            helptext: qsTranslate("settingsmanager", "The thumbnail for an image can either be scaled to fit fully inside the maximum size specified above, or it can be scaled and cropped such that it takes up all available space. In the latter case some parts of a thumbnail image might be cut off. In addition, thumbnails that are smaller than the size specified above can be kept at their original size.")

            content: [

                PQRadioButton {
                    id: thumb_fit
                    text: qsTranslate("settingsmanager", "fit thumbnail")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: thumb_crop
                    text: qsTranslate("settingsmanager", "scale and crop thumbnail")
                    onCheckedChanged: checkDefault()
                },

                Item {
                    width: 1
                    height: 1
                },

                PQCheckBox {
                    id: thumb_small
                    text: qsTranslate("settingsmanager", "keep small thumbnails small")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Icons only")

            helptext: qsTranslate("settingsmanager", "Instead of loading actual thumbnail images in the background, PhotoQt can instead simply show the respective icon for the filetype. This requires much fewer resources and time but is not as user friendly.")

            content: [

                PQRadioButton {
                    id: thumb_actual
                    //: The word actual is used with the same meaning as: real
                    text: qsTranslate("settingsmanager", "use actual thumbnail images")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: thumb_icon
                    text: qsTranslate("settingsmanager", "use filetype icons")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Label")

            helptext: qsTranslate("settingsmanager", "On top of each thumbnail image PhotoQt can put a small text label with the filename. The font size of the filename is freely adjustable. If a filename is too long for the available space only the beginning and end of the filename will be visible. Additionally, the label of thumbnails that are neither loaded nor hovered can be shown with less opacity.")

            content: [

                PQCheckBox {
                    id: label_enable
                    text: qsTranslate("settingsmanager", "show filename label")
                    onCheckedChanged: checkDefault()
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

                        PQSpinBoxAdvanced {
                            id: label_fontsize
                            minval: 5
                            maxval: 20
                            title: qsTranslate("settingsmanager", "Font size:")
                            suffix: " pt"
                            onValueChanged:
                                checkDefault()
                        }

                    }

                    PQCheckBox {
                        id: thumb_opaque
                        text: qsTranslate("settingsmanager", "decrease opacity for inactive thumbnails")
                        onCheckedChanged: checkDefault()
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Tooltip")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show additional information about an image in the form of a tooltip that is shown when the mouse cursor hovers above a thumbnail. The displayed information includes the full file name, file size, and file type.")

            content: [
                PQCheckBox {
                    id: tooltips_show
                    text: qsTranslate("settingsmanager", "show tooltips")
                    onCheckedChanged: checkDefault()
                }
            ]

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
