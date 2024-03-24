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
            title: qsTranslate("settingsmanager", "Layout")

            helptext: qsTranslate("settingsmanager", "The files can be shown either as icons with an emphasis on the thumbnails, or as list with an emphasis on getting a clear overview.")

            content: [

                PQRadioButton {
                    id: layout_icon
                    text: qsTranslate("settingsmanager", "icon view")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: layout_list
                    text: qsTranslate("settingsmanager", "list view")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Hidden files")

            helptext: qsTranslate("settingsmanager", "Hidden files and folders are by default not included in the list of files.")

            content: [
                PQCheckBox {
                    id: hiddencheck
                    text: qsTranslate("settingsmanager", "Show hidden files/folders")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Tooltip")

            helptext: qsTranslate("settingsmanager", "When moving the mouse cursor over an entry, a tooltip with a larger preview and more information about the file or folder can be shown.")

            content: [
                PQCheckBox {
                    id: tooltipcheck
                    text: qsTranslate("settingsmanager", "Show tooltip with details")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Last location")

            helptext: qsTranslate("settingsmanager", "By default the file dialog starts out in your home folder at start. Enabling this setting makes the file dialog reopen at the same location where it ended in the last session.")

            content: [
                PQCheckBox {
                    id: remembercheck
                    text: qsTranslate("settingsmanager", "Remember")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Single clicks")

            helptext: qsTranslate("settingsmanager", "By default the behavior of single clicks follows the standard behavior on Linux, where a single click opens a file or folder. Enabling this section results in single clicks only selecting files and folders with double clicks required to actually open them.")

            content: [
                PQRadioButton {
                    id: singleexec
                    text: qsTranslate("settingsmanager", "Open with single click")
                    onCheckedChanged: checkDefault()
                },

                PQRadioButton {
                    id: singlecheck
                    text: qsTranslate("settingsmanager", "Select with single click, open with double click")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Sections")

            helptext: qsTranslate("settingsmanager", "In the left column there are two sections that can be shown. The bookmarks are a combination of some standard locations on any computer and a customizable list of your own bookmarks. The devices are a list of storage devices found on your system.")

            content: [
                PQCheckBox {
                    id: sect_bookmarks
                    text: qsTranslate("settingsmanager", "Show bookmarks")
                    onCheckedChanged: checkDefault()
                },
                PQCheckBox {
                    id: sect_devices
                    text: qsTranslate("settingsmanager", "Show devices")
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Drag and drop")

            helptext: qsTranslate("settingsmanager", "There are two different drag-and-drop actions that exist in the file dialog. 1) It is possible to drag folders from either the list or icon view (or both) and drop them on the bookmarks. And 2) it is possible to reorder the bookmarks through drag-and-drop.")

            content: [
                PQCheckBox {
                    id: drag_icon
                    text: "Enable drag-and-drop for icon view"
                    onCheckedChanged: checkDefault()
                },
                PQCheckBox {
                    id: drag_list
                    text: "Enable drag-and-drop for list view"
                    onCheckedChanged: checkDefault()
                },
                PQCheckBox {
                    id: drag_bookmarks
                    text: "Enable drag-and-drop for bookmarks"
                    onCheckedChanged: checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Thumbnails")

            helptext: qsTranslate("settingsmanager", "For all files PhotoQt can either show an icon corresponding to its file type or a small thumbnail preview. The thumbnail can either be shown fitted into the available space or cropped to fill out the full space.")

            content: [
                PQCheckBox {
                    id: thumb_show
                    text: qsTranslate("settingsmanager", "Show thumbnails")
                    onCheckedChanged: checkDefault()
                },
                Item {

                    clip: true
                    enabled: thumb_show.checked

                    width: thumb_scalecrop.width
                    height: enabled ? thumb_scalecrop.height : 0
                    opacity: enabled ? 1 : 0

                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQCheckBox {
                        id: thumb_scalecrop
                        text: qsTranslate("settingsmanager", "Scale and crop thumbnails")
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
            title: qsTranslate("settingsmanager", "Padding")

            helptext: qsTranslate("settingsmanager", "The space between the different thumbnails is the gap shown between them.")

            content: [
                PQSpinBoxAdvanced {
                    id: padding
                    minval: 0
                    maxval: 10
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
            title: qsTranslate("settingsmanager", "Folder thumbnails")

            helptext: qsTranslate("settingsmanager", "When hovering over a folder PhotoQt can give a preview of that folder by rotating through thumbnails of its content. Additionally, the timeout before changing the thumbnail and whether to loop around can be adjusted. Enabling the auto load setting preloads the first thumbnail when the parent folder is loaded.")

            content: [
                PQCheckBox {
                    id: folderthumb_check
                    text: qsTranslate("settingsmanager", "Enable folder thumbnails")
                    onCheckedChanged: checkDefault()
                },

                Item {
                    clip: true
                    enabled: folderthumb_check.checked
                    width: folderthumb_col.width
                    height: enabled ? folderthumb_col.height : 0
                    opacity: enabled ? 1 : 0

                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Column {
                        id: folderthumb_col

                        spacing: 10

                        Row {
                            spacing: 5
                            PQText {
                                y: (folderthumb_timeout.height-height)/2
                                text: qsTranslate("settingsmanager", "Timeout:")
                            }
                            PQComboBox {
                                id: folderthumb_timeout
                                extrasmall: true
                                model: ["2 s",
                                        "1 s",
                                        "0.5 s"]
                                onCurrentIndexChanged: checkDefault()
                            }
                        }

                        PQCheckBox {
                            id: folderthumb_loop
                            text: qsTranslate("settingsmanager", "Loop through content")
                            onCheckedChanged: checkDefault()
                        }

                        PQCheckBox {
                            id: folderthumb_autoload
                            text: qsTranslate("settingsmanager", "Auto-load first thumbnail")
                            onCheckedChanged: checkDefault()
                        }

                        PQCheckBox {
                            id: folderthumb_scalecrop
                            text: qsTranslate("settingsmanager", "Scale and crop thumbnails")
                            onCheckedChanged: checkDefault()
                        }

                    }
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Preview")

            helptext: qsTranslate("settingsmanager", "The preview refers to the larger preview of a file shown behind the list of all files and folders. Various properties of that preview can be adjusted.")

            content: [

                PQCheckBox {
                    id: preview_check
                    text: qsTranslate("settingsmanager", "Show preview")
                    onCheckedChanged: checkDefault()
                },

                Item {

                    clip: true
                    enabled: preview_check.checked
                    width: previewcol.width
                    height: enabled ? previewcol.height : 0
                    opacity: enabled ? 1 : 0

                    Behavior on height { NumberAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Column {

                        id: previewcol

                        spacing: 10

                        PQCheckBox {
                            id: preview_blur
                            text: qsTranslate("settingsmanager", "Blur the preview")
                            onCheckedChanged: checkDefault()
                        }

                        PQCheckBox {
                            id: preview_mute
                            text: qsTranslate("settingsmanager", "Mute its colors")
                            onCheckedChanged: checkDefault()
                        }

                        Row {
                            spacing: 5
                            PQText {
                                y: (preview_colintspin.height-height)/2
                                text: qsTranslate("settingsmanager", "color intensity:")
                            }
                            PQSlider {
                                id: preview_colint
                                y: (preview_colintspin.height-height)/2
                                from: 10
                                to: 100
                                onValueChanged: {
                                    if(value != preview_colintspin.value)
                                        preview_colintspin.value = value
                                    checkDefault()
                                }
                            }
                            PQSpinBoxAdvanced {
                                id: preview_colintspin
                                minval: 10
                                maxval: 100
                                title: ""
                                suffix: " %"
                                onValueChanged: {
                                    if(value != preview_colint.value)
                                        preview_colint.value = value
                                    checkDefault()
                                }
                            }
                        }

                        PQCheckBox {
                            id: preview_resolution
                            text: qsTranslate("settingsmanager", "Higher resolution")
                            onCheckedChanged: checkDefault()
                        }

                        PQCheckBox {
                            id: preview_scalecrop
                            text: qsTranslate("settingsmanager", "Scale and crop")
                            onCheckedChanged: checkDefault()
                        }

                    }

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

        settingChanged = (layout_icon.hasChanged() || layout_list.hasChanged() || hiddencheck.hasChanged() || tooltipcheck.hasChanged() ||
                          remembercheck.hasChanged() || singlecheck.hasChanged() || sect_bookmarks.hasChanged() || sect_devices.hasChanged() ||
                          drag_icon.hasChanged() || drag_list.hasChanged() || drag_bookmarks.hasChanged() || singleexec.hasChanged() ||
                          thumb_show.hasChanged() || thumb_scalecrop.hasChanged() || padding.hasChanged() || folderthumb_check.hasChanged() ||
                          folderthumb_timeout.hasChanged() || folderthumb_loop.hasChanged() || folderthumb_autoload.hasChanged() ||
                          folderthumb_scalecrop.hasChanged() || preview_check.hasChanged() || preview_blur.hasChanged() || preview_mute.hasChanged() ||
                          preview_colint.hasChanged() || preview_colintspin.hasChanged() || preview_resolution.hasChanged() || preview_scalecrop.hasChanged())

    }

    function load() {

        layout_icon.loadAndSetDefault(PQCSettings.filedialogLayout==="icons")
        layout_list.loadAndSetDefault(PQCSettings.filedialogLayout!=="icons")
        hiddencheck.loadAndSetDefault(PQCSettings.filedialogShowHiddenFilesFolders)
        tooltipcheck.loadAndSetDefault(PQCSettings.filedialogDetailsTooltip)
        remembercheck.loadAndSetDefault(PQCSettings.filedialogKeepLastLocation)
        singleexec.loadAndSetDefault(!PQCSettings.filedialogSingleClickSelect)
        singlecheck.loadAndSetDefault(PQCSettings.filedialogSingleClickSelect)
        sect_bookmarks.loadAndSetDefault(PQCSettings.filedialogPlaces)
        sect_devices.loadAndSetDefault(PQCSettings.filedialogDevices)
        drag_icon.loadAndSetDefault(PQCSettings.filedialogDragDropFileviewGrid)
        drag_list.loadAndSetDefault(PQCSettings.filedialogDragDropFileviewList)
        drag_bookmarks.loadAndSetDefault(PQCSettings.filedialogDragDropPlaces)

        thumb_show.loadAndSetDefault(PQCSettings.filedialogThumbnails)
        thumb_scalecrop.loadAndSetDefault(PQCSettings.filedialogThumbnailsScaleCrop)
        padding.loadAndSetDefault(PQCSettings.filedialogElementPadding)
        folderthumb_check.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnails)
        folderthumb_timeout.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsSpeed-1)
        folderthumb_loop.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsLoop)
        folderthumb_autoload.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsAutoload)
        folderthumb_scalecrop.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsScaleCrop)
        preview_check.loadAndSetDefault(PQCSettings.filedialogPreview)
        preview_blur.loadAndSetDefault(PQCSettings.filedialogPreviewBlur)
        preview_mute.loadAndSetDefault(PQCSettings.filedialogPreviewMuted)
        preview_colint.loadAndSetDefault(PQCSettings.filedialogPreviewColorIntensity)
        preview_colintspin.loadAndSetDefault(PQCSettings.filedialogPreviewColorIntensity)
        preview_resolution.loadAndSetDefault(PQCSettings.filedialogPreviewHigherResolution)
        preview_scalecrop.loadAndSetDefault(PQCSettings.filedialogPreviewCropToFit)

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.filedialogLayout = (layout_icon.checked ? "icons" : "list")
        PQCSettings.filedialogShowHiddenFilesFolders = hiddencheck.checked
        PQCSettings.filedialogDetailsTooltip = tooltipcheck.checked
        PQCSettings.filedialogKeepLastLocation = remembercheck.checked
        PQCSettings.filedialogSingleClickSelect = singlecheck.checked
        PQCSettings.filedialogPlaces = sect_bookmarks.checked
        PQCSettings.filedialogDevices = sect_devices.checked
        PQCSettings.filedialogDragDropFileviewGrid = drag_icon.checked
        PQCSettings.filedialogDragDropFileviewList = drag_list.checked
        PQCSettings.filedialogDragDropPlaces = drag_bookmarks.checked

        PQCSettings.filedialogThumbnails = thumb_show.checked
        PQCSettings.filedialogThumbnailsScaleCrop = thumb_scalecrop.checked
        PQCSettings.filedialogElementPadding = padding.value
        PQCSettings.filedialogFolderContentThumbnails = folderthumb_check.checked
        PQCSettings.filedialogFolderContentThumbnailsSpeed = folderthumb_timeout.currentIndex+1
        PQCSettings.filedialogFolderContentThumbnailsLoop = folderthumb_loop.checked
        PQCSettings.filedialogFolderContentThumbnailsAutoload = folderthumb_autoload.checked
        PQCSettings.filedialogFolderContentThumbnailsScaleCrop = folderthumb_scalecrop.checked
        PQCSettings.filedialogPreview = preview_check.checked
        PQCSettings.filedialogPreviewBlur = preview_blur.checked
        PQCSettings.filedialogPreviewMuted = preview_mute.checked
        PQCSettings.filedialogPreviewColorIntensity = preview_colint.value
        PQCSettings.filedialogPreviewHigherResolution = preview_resolution.checked
        PQCSettings.filedialogPreviewCropToFit = preview_scalecrop.checked

        layout_icon.saveDefault()
        layout_list.saveDefault()
        hiddencheck.saveDefault()
        tooltipcheck.saveDefault()
        remembercheck.saveDefault()
        singleexec.saveDefault()
        singlecheck.saveDefault()
        sect_bookmarks.saveDefault()
        sect_devices.saveDefault()
        drag_icon.saveDefault()
        drag_list.saveDefault()
        drag_bookmarks.saveDefault()

        thumb_show.saveDefault()
        thumb_scalecrop.saveDefault()
        padding.saveDefault()
        folderthumb_check.saveDefault()
        folderthumb_timeout.saveDefault()
        folderthumb_loop.saveDefault()
        folderthumb_autoload.saveDefault()
        folderthumb_scalecrop.saveDefault()
        preview_check.saveDefault()
        preview_blur.saveDefault()
        preview_mute.saveDefault()
        preview_colint.saveDefault()
        preview_colintspin.saveDefault()
        preview_resolution.saveDefault()
        preview_scalecrop.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
