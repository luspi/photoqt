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
import PhotoQt

PQSetting {

    id: set_fd

    content: [

        PQText {
            x: -set_fd.indentWidth
            width: set_fd.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager", "These settings can also be adjusted from within the file dialog.")
        },

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Sort images")

            helptext: qsTranslate("settingsmanager", "Images in a folder can be sorted in different ways. Once a folder is loaded it is possible to further sort a folder in several advanced ways using the menu option for sorting.")

            showLineAbove: false

        },

        Row {
            spacing: 5
            PQText {
                y: (sortcriteria.height-height)/2
                font.bold: true
                text: qsTranslate("settingsmanager", "Sort by:")
            }
            PQComboBox {
                id: sortcriteria
                                                      //: A criteria for sorting images
                property list<string> modeldata_icu: [qsTranslate("settingsmanager", "natural name"),
                                                      //: A criteria for sorting images
                                                      qsTranslate("settingsmanager", "name"),
                                                      //: A criteria for sorting images
                                                      qsTranslate("settingsmanager", "time"),
                                                      //: A criteria for sorting images
                                                      qsTranslate("settingsmanager", "size"),
                                                      //: A criteria for sorting images
                                                      qsTranslate("settingsmanager", "type")]
                                                        //: A criteria for sorting images
                property list<string> modeldata_noicu: [qsTranslate("settingsmanager", "name"),
                                                        //: A criteria for sorting images
                                                        qsTranslate("settingsmanager", "time"),
                                                        //: A criteria for sorting images
                                                        qsTranslate("settingsmanager", "size"),
                                                        //: A criteria for sorting images
                                                        qsTranslate("settingsmanager", "type")]
                model: PQCScriptsConfig.isICUSupportEnabled() ? modeldata_icu : modeldata_noicu
                onCurrentIndexChanged: set_fd.checkForChanges()
            }
        },

        Flow {
            width: set_fd.contentWidth
            spacing: 5
            PQRadioButton {
                ButtonGroup { id: grp_asc }
                id: sortasc
                //: Sort images in ascending order
                text: qsTranslate("settingsmanager", "ascending order")
                onCheckedChanged: set_fd.checkForChanges()
                ButtonGroup.group: grp_asc
            }
            PQRadioButton {
                id: sortdesc
                //: Sort images in descending order
                text: qsTranslate("settingsmanager", "descending order")
                onCheckedChanged: set_fd.checkForChanges()
                ButtonGroup.group: grp_asc
            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                sortcriteria.currentIndex = 0
                sortasc.checked = PQCSettings.getDefaultForImageviewSortImagesAscending()
                sortdesc.checked = !sortasc.checked

                set_fd.checkForChanges()

            }
        },

        /*********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Layout")

            helptext: qsTranslate("settingsmanager", "The files can be shown either as grid with an emphasis on the thumbnails, or as list with an emphasis on getting a clear overview.")

        },

        PQRadioButton {
            ButtonGroup { id: grp_lay }
            id: layout_icon
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "grid view")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_lay
        },

        PQRadioButton {
            id: layout_list
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "list view")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_lay
        },

        PQRadioButton {
            id: layout_masonry
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "masonry view")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_lay
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                layout_icon.checked = (PQCSettings.getDefaultForFiledialogLayout()==="grid")
                layout_masonry.checked = (PQCSettings.getDefaultForFiledialogLayout() === "masonry")
                layout_list.checked = !layout_icon.checked&&!layout_masonry.checked

            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Hidden files")

            helptext: qsTranslate("settingsmanager", "Hidden files and folders are by default not included in the list of files.")

        },

        PQCheckBox {
            id: hiddencheck
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Show hidden files/folders")
            onCheckedChanged: set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                hiddencheck.checked = PQCSettings.getDefaultForFiledialogShowHiddenFilesFolders()
            }
        },

        /************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Tooltip")

            helptext: qsTranslate("settingsmanager", "When moving the mouse cursor over an entry, a tooltip with a larger preview and more information about the file or folder can be shown.")

        },

        PQCheckBox {
            id: tooltipcheck
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Show tooltip with details")
            onCheckedChanged: set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                tooltipcheck.checked = PQCSettings.getDefaultForFiledialogDetailsTooltip()
            }
        },

        /*************************************/

        PQSettingSubtitle {

            //: Settings title, location here is a folder path
            title: qsTranslate("settingsmanager", "Last location")

            helptext: qsTranslate("settingsmanager", "By default the file dialog starts out in your home folder at start. Enabling this setting makes the file dialog reopen at the same location where it ended in the last session.")

        },

        PQCheckBox {
            id: remembercheck
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Remember")
            onCheckedChanged: set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                remembercheck.checked = PQCSettings.getDefaultForFiledialogKeepLastLocation()
            }
        },

        /***************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Single clicks")

            helptext: qsTranslate("settingsmanager", "By default the behavior of single clicks follows the standard behavior on Linux, where a single click opens a file or folder. Enabling this setting results in single clicks only selecting files and folders with double clicks required to actually open them.")

        },

        PQRadioButton {
            ButtonGroup { id: grp_sin }
            id: singleexec
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Open with single click")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_sin
        },

        PQRadioButton {
            id: singlecheck
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Select with single click, open with double click")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_sin
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                singlecheck.checked = PQCSettings.getDefaultForFiledialogSingleClickSelect()
                singleexec.checked = !singlecheck.checked
            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Selection")

            helptext: qsTranslate("settingsmanager", "Usually, once a folder is navigated away from any selection is lost. However, it is possible to remember the file/folder selection for each folder and have it recalled next time the folder is loaded.")

        },

        PQCheckBox {
            id: selremem
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Remember selection for each folder")
            onCheckedChanged: set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                selremem.checked = PQCSettings.getDefaultForFiledialogRememberSelection()
            }
        },

        /************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Sections")

            helptext: qsTranslate("settingsmanager", "In the left column there are two sections that can be shown. The bookmarks are a combination of some standard locations on any computer and a customizable list of your own bookmarks. The devices are a list of storage devices found on your system.")

        },

        PQCheckBox {
            id: sect_bookmarks
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Show bookmarks")
            onCheckedChanged: set_fd.checkForChanges()
        },
        PQCheckBox {
            id: sect_devices
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Show devices")
            onCheckedChanged: set_fd.checkForChanges()
        },
        PQCheckBox {
            id: sect_devicestmpfs
            visible: !PQCScriptsConfig.amIOnWindows()
            enabled: sect_devices.checked
            enforceMaxWidth: set_fd.contentWidth-22
            text: qsTranslate("settingsmanager", "Include temporary devices")
            onCheckedChanged: set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                sect_bookmarks.checked = PQCSettings.getDefaultForFiledialogPlaces()
                sect_devices.checked = PQCSettings.getDefaultForFiledialogDevices()
                sect_devicestmpfs.checked = PQCSettings.getDefaultForFiledialogDevicesShowTmpfs()
            }
        },

        /*********************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Drag and drop")

            helptext: qsTranslate("settingsmanager", "There are two different drag-and-drop actions that exist in the file dialog. 1) It is possible to drag folders from either the list or icon view (or both) and drop them on the bookmarks. And 2) it is possible to reorder the bookmarks through drag-and-drop.")

        },

        PQCheckBox {
            id: drag_icon
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Enable drag-and-drop for grid view")
            onCheckedChanged: set_fd.checkForChanges()
        },
        PQCheckBox {
            id: drag_list
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Enable drag-and-drop for list view")
            onCheckedChanged: set_fd.checkForChanges()
        },
        PQCheckBox {
            id: drag_masonry
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Enable drag-and-drop for masonry view")
            onCheckedChanged: set_fd.checkForChanges()
        },
        PQCheckBox {
            id: drag_bookmarks
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Enable drag-and-drop for bookmarks")
            onCheckedChanged: set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                drag_icon.checked = PQCSettings.getDefaultForFiledialogDragDropFileviewGrid()
                drag_list.checked = PQCSettings.getDefaultForFiledialogDragDropFileviewList()
                drag_masonry.checked = PQCSettings.getDefaultForFiledialogDragDropFileviewMasonry()
                drag_bookmarks.checked = PQCSettings.getDefaultForFiledialogDragDropPlaces()
            }
        },

        /***************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Thumbnails")

            helptext: qsTranslate("settingsmanager", "For all files PhotoQt can either show an icon corresponding to its file type or a small thumbnail preview. The thumbnail can either be shown fitted into the available space or cropped to fill out the full space.")

        },

        PQCheckBox {
            id: thumb_show
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Show thumbnails")
            onCheckedChanged: set_fd.checkForChanges()
        },
        Item {

            clip: true
            enabled: thumb_show.checked

            width: thumb_scalecrop.width
            height: enabled ? thumb_scalecrop.height : 0
            opacity: enabled ? 1 : 0

            Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }

            PQCheckBox {
                id: thumb_scalecrop
                enforceMaxWidth: set_fd.contentWidth
                text: qsTranslate("settingsmanager", "Scale and crop thumbnails")
                onCheckedChanged: set_fd.checkForChanges()
            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                thumb_show.checked = PQCSettings.getDefaultForFiledialogThumbnails()
                thumb_scalecrop.checked = PQCSettings.getDefaultForFiledialogThumbnailsScaleCrop()
            }
        },

        /***************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Padding")

            helptext: qsTranslate("settingsmanager", "The empty space between the different thumbnails.")

        },

        PQAdvancedSlider {
            id: padding
            width: set_fd.contentWidth
            minval: 0
            maxval: 10
            title: ""
            suffix: " px"
            onValueChanged:
                set_fd.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                padding.setValue(PQCSettings.getDefaultForFiledialogElementPadding())
            }
        },

        /*************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Filename labels")

            helptext: qsTranslate("settingsmanager", "Whether to show labels with filenames on top of the thumbnails. Labels for folders are always shown")

        },

        PQRadioButton {
            ButtonGroup { id: grp_lab }
            id: labels_grid
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "filename labels in grid view")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_lab
        },

        PQRadioButton {
            id: labels_masonry
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "filename labels in masonry view")
            onCheckedChanged: set_fd.checkForChanges()
            ButtonGroup.group: grp_lab
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                labels_grid.checked = PQCSettings.getDefaultForFiledialogLabelsShowGrid()
                labels_masonry.checked = PQCSettings.getDefaultForFiledialogLabelsShowMasonry()
            }
        },

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Folder thumbnails")

            helptext: qsTranslate("settingsmanager", "When hovering over a folder PhotoQt can give a preview of that folder by iterating through thumbnails of its content. Additionally, the timeout before changing the thumbnail and whether to loop around can be adjusted. Enabling the auto load setting preloads the first thumbnail when the parent folder is opened.")

        },

        PQCheckBox {
            id: folderthumb_check
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Enable folder thumbnails")
            onCheckedChanged: set_fd.checkForChanges()
        },

        Item {
            clip: true
            enabled: folderthumb_check.checked
            width: folderthumb_col.width
            height: enabled ? folderthumb_col.height : 0
            opacity: enabled ? 1 : 0

            Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }

            Column {
                id: folderthumb_col

                spacing: 10

                PQCheckBox {
                    id: folderthumb_loop
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Loop through content")
                    onCheckedChanged: set_fd.checkForChanges()
                }

                Flow {
                    width: set_fd.contentWidth
                    spacing: 5
                    Item {
                        width: 25
                        height: 1
                    }

                    PQText {
                        height: folderthumb_timeout.height
                        verticalAlignment: Text.AlignVCenter
                        text: qsTranslate("settingsmanager", "Timeout:")
                    }
                    PQComboBox {
                        id: folderthumb_timeout
                        extrasmall: true
                        property list<string> modeldata: ["2 s",
                                                          "1 s",
                                                          "0.5 s"]
                        model: modeldata
                        onCurrentIndexChanged: set_fd.checkForChanges()
                    }
                }

                PQCheckBox {
                    id: folderthumb_autoload
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Auto-load first thumbnail")
                    onCheckedChanged: set_fd.checkForChanges()
                }

                PQCheckBox {
                    id: folderthumb_scalecrop
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Scale and crop thumbnails")
                    onCheckedChanged: set_fd.checkForChanges()
                }

            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {
                folderthumb_check.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnails()
                folderthumb_timeout.currentIndex = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsSpeed()
                folderthumb_loop.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsLoop()
                folderthumb_autoload.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsAutoload()
                folderthumb_scalecrop.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsScaleCrop()
            }
        },

        /*************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Preview")

            helptext: qsTranslate("settingsmanager", "The preview refers to the larger preview of a file shown behind the list of all files and folders. Various properties of that preview can be adjusted.")

        },

        PQCheckBox {
            id: preview_check
            enforceMaxWidth: set_fd.contentWidth
            text: qsTranslate("settingsmanager", "Show preview")
            onCheckedChanged: set_fd.checkForChanges()
        },

        Item {

            clip: true
            enabled: preview_check.checked
            width: previewcol.width
            height: enabled ? previewcol.height : 0
            opacity: enabled ? 1 : 0

            Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 150 } }

            Column {

                id: previewcol

                spacing: 10

                Row {
                    Item {
                        width: 30
                        height: 1
                    }

                    PQAdvancedSlider {
                        id: preview_colintspin
                        width: set_fd.contentWidth - 30
                        title: qsTranslate("settingsmanager", "color intensity:")
                        titleWeight: PQCLook.fontWeightNormal
                        minval: 10
                        maxval: 100
                        suffix: " %"
                        onValueChanged: set_fd.checkForChanges()
                    }
                }

                PQCheckBox {
                    id: preview_blur
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Blur the preview")
                    onCheckedChanged: set_fd.checkForChanges()
                }

                PQCheckBox {
                    id: preview_mute
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Mute its colors")
                    onCheckedChanged: set_fd.checkForChanges()
                }

                PQCheckBox {
                    id: preview_resolution
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Higher resolution")
                    onCheckedChanged: set_fd.checkForChanges()
                }

                PQCheckBox {
                    id: preview_scalecrop
                    enforceMaxWidth: set_fd.contentWidth
                    text: qsTranslate("settingsmanager", "Scale and crop")
                    onCheckedChanged: set_fd.checkForChanges()
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {
                preview_check.checked = PQCSettings.getDefaultForFiledialogPreview()
                preview_blur.checked = PQCSettings.getDefaultForFiledialogPreviewBlur()
                preview_mute.checked = PQCSettings.getDefaultForFiledialogPreviewMuted()
                preview_colintspin.setValue(PQCSettings.getDefaultForFiledialogPreviewColorIntensity())
                preview_resolution.checked = PQCSettings.getDefaultForFiledialogPreviewHigherResolution()
                preview_scalecrop.checked = PQCSettings.getDefaultForFiledialogPreviewCropToFit()
            }
        }

    ]

    function handleEscape() {
        sortcriteria.popup.close()
        padding.acceptValue()
        preview_colintspin.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (sortasc.hasChanged() || sortdesc.hasChanged() || sortcriteria.hasChanged() ||
                                                      layout_icon.hasChanged() || layout_list.hasChanged() || layout_masonry.hasChanged() ||
                                                      hiddencheck.hasChanged() || remembercheck.hasChanged() ||
                                                      singlecheck.hasChanged() || singleexec.hasChanged() || selremem.hasChanged() ||
                                                      sect_bookmarks.hasChanged() || sect_devices.hasChanged() || sect_devicestmpfs.hasChanged() ||
                                                      drag_icon.hasChanged() || drag_list.hasChanged() || drag_bookmarks.hasChanged() ||
                                                      thumb_show.hasChanged() || thumb_scalecrop.hasChanged() || padding.hasChanged() ||
                                                      labels_grid.hasChanged() || labels_masonry.hasChanged() ||
                                                      folderthumb_check.hasChanged() || folderthumb_timeout.hasChanged() || folderthumb_loop.hasChanged() ||
                                                      folderthumb_autoload.hasChanged() || folderthumb_scalecrop.hasChanged() ||
                                                      preview_check.hasChanged() || preview_blur.hasChanged() || preview_mute.hasChanged() ||
                                                      preview_colintspin.hasChanged() || preview_resolution.hasChanged() || preview_scalecrop.hasChanged() ||
                                                      tooltipcheck.hasChanged())

    }

    function load() {

        settingsLoaded = false

        var l = ["naturalname", "name", "time", "size", "type"]
        sortcriteria.loadAndSetDefault(Math.max(0, l.indexOf(PQCSettings.imageviewSortImagesBy)))
        sortasc.loadAndSetDefault(PQCSettings.imageviewSortImagesAscending)
        sortdesc.loadAndSetDefault(!PQCSettings.imageviewSortImagesAscending)

        layout_icon.loadAndSetDefault(PQCSettings.filedialogLayout==="grid")
        layout_masonry.loadAndSetDefault(PQCSettings.filedialogLayout==="masonry")
        layout_list.loadAndSetDefault(!layout_icon.checked&&!layout_masonry.checked)

        hiddencheck.loadAndSetDefault(PQCSettings.filedialogShowHiddenFilesFolders)

        tooltipcheck.loadAndSetDefault(PQCSettings.filedialogDetailsTooltip)

        remembercheck.loadAndSetDefault(PQCSettings.filedialogKeepLastLocation)

        singleexec.loadAndSetDefault(!PQCSettings.filedialogSingleClickSelect)
        singlecheck.loadAndSetDefault(PQCSettings.filedialogSingleClickSelect)

        selremem.loadAndSetDefault(PQCSettings.filedialogRememberSelection)

        sect_bookmarks.loadAndSetDefault(PQCSettings.filedialogPlaces)
        sect_devices.loadAndSetDefault(PQCSettings.filedialogDevices)
        sect_devicestmpfs.loadAndSetDefault(PQCSettings.filedialogDevicesShowTmpfs)

        drag_icon.loadAndSetDefault(PQCSettings.filedialogDragDropFileviewGrid)
        drag_list.loadAndSetDefault(PQCSettings.filedialogDragDropFileviewList)
        drag_bookmarks.loadAndSetDefault(PQCSettings.filedialogDragDropPlaces)

        thumb_show.loadAndSetDefault(PQCSettings.filedialogThumbnails)
        thumb_scalecrop.loadAndSetDefault(PQCSettings.filedialogThumbnailsScaleCrop)

        padding.loadAndSetDefault(PQCSettings.filedialogElementPadding)

        labels_grid.loadAndSetDefault(PQCSettings.filedialogLabelsShowGrid)
        labels_masonry.loadAndSetDefault(PQCSettings.filedialogLabelsShowMasonry)

        folderthumb_check.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnails)
        folderthumb_timeout.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsSpeed-1)
        folderthumb_loop.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsLoop)
        folderthumb_autoload.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsAutoload)
        folderthumb_scalecrop.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsScaleCrop)

        preview_check.loadAndSetDefault(PQCSettings.filedialogPreview)
        preview_blur.loadAndSetDefault(PQCSettings.filedialogPreviewBlur)
        preview_mute.loadAndSetDefault(PQCSettings.filedialogPreviewMuted)
        preview_colintspin.loadAndSetDefault(PQCSettings.filedialogPreviewColorIntensity)
        preview_resolution.loadAndSetDefault(PQCSettings.filedialogPreviewHigherResolution)
        preview_scalecrop.loadAndSetDefault(PQCSettings.filedialogPreviewCropToFit)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var l = ["naturalname", "name", "time", "size", "type"]
        PQCSettings.imageviewSortImagesBy = l[sortcriteria.currentIndex]
        PQCSettings.imageviewSortImagesAscending = sortasc.checked
        sortcriteria.saveDefault()
        sortasc.saveDefault()
        sortdesc.saveDefault()

        PQCSettings.filedialogLayout = (layout_icon.checked ? "grid" : (layout_masonry.checked ? "masonry" : "list"))
        layout_icon.saveDefault()
        layout_list.saveDefault()
        layout_masonry.saveDefault()

        PQCSettings.filedialogShowHiddenFilesFolders = hiddencheck.checked
        hiddencheck.saveDefault()

        PQCSettings.filedialogDetailsTooltip = tooltipcheck.checked
        tooltipcheck.saveDefault()

        PQCSettings.filedialogKeepLastLocation = remembercheck.checked
        remembercheck.saveDefault()

        PQCSettings.filedialogSingleClickSelect = singlecheck.checked
        singleexec.saveDefault()
        singlecheck.saveDefault()

        PQCSettings.filedialogRememberSelection = selremem.checked
        selremem.saveDefault()

        PQCSettings.filedialogPlaces = sect_bookmarks.checked
        PQCSettings.filedialogDevices = sect_devices.checked
        PQCSettings.filedialogDevicesShowTmpfs = sect_devicestmpfs.checked
        sect_bookmarks.saveDefault()
        sect_devices.saveDefault()
        sect_devicestmpfs.saveDefault()

        PQCSettings.filedialogDragDropFileviewGrid = drag_icon.checked
        PQCSettings.filedialogDragDropFileviewList = drag_list.checked
        PQCSettings.filedialogDragDropPlaces = drag_bookmarks.checked
        drag_icon.saveDefault()
        drag_list.saveDefault()
        drag_bookmarks.saveDefault()

        PQCSettings.filedialogThumbnails = thumb_show.checked
        PQCSettings.filedialogThumbnailsScaleCrop = thumb_scalecrop.checked
        thumb_show.saveDefault()
        thumb_scalecrop.saveDefault()

        PQCSettings.filedialogElementPadding = padding.value
        padding.saveDefault()

        PQCSettings.filedialogLabelsShowGrid = labels_grid.checked
        PQCSettings.filedialogLabelsShowMasonry = labels_masonry.checked
        labels_grid.saveDefault()
        labels_masonry.saveDefault()

        PQCSettings.filedialogFolderContentThumbnails = folderthumb_check.checked
        PQCSettings.filedialogFolderContentThumbnailsSpeed = folderthumb_timeout.currentIndex+1
        PQCSettings.filedialogFolderContentThumbnailsLoop = folderthumb_loop.checked
        PQCSettings.filedialogFolderContentThumbnailsAutoload = folderthumb_autoload.checked
        PQCSettings.filedialogFolderContentThumbnailsScaleCrop = folderthumb_scalecrop.checked
        folderthumb_check.saveDefault()
        folderthumb_timeout.saveDefault()
        folderthumb_loop.saveDefault()
        folderthumb_autoload.saveDefault()
        folderthumb_scalecrop.saveDefault()


        PQCSettings.filedialogPreview = preview_check.checked
        PQCSettings.filedialogPreviewBlur = preview_blur.checked
        PQCSettings.filedialogPreviewMuted = preview_mute.checked
        PQCSettings.filedialogPreviewColorIntensity = preview_colintspin.value
        PQCSettings.filedialogPreviewHigherResolution = preview_resolution.checked
        PQCSettings.filedialogPreviewCropToFit = preview_scalecrop.checked
        preview_check.saveDefault()
        preview_blur.saveDefault()
        preview_mute.saveDefault()
        preview_colintspin.saveDefault()
        preview_resolution.saveDefault()
        preview_scalecrop.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
