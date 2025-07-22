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

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: padding.contextMenuOpen || padding.editMode || preview_colintspin.contextMenuOpen ||
                               preview_colintspin.editMode || sortcriteria.popup.visible || folderthumb_timeout.popup.visible

    Column {

        id: contcol

        spacing: 10
        width: parent.width

        PQText {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager", "These settings can also be adjusted from within the file dialog.")
        }

        PQSetting {

            id: set_sort

            //: Settings title
            title: qsTranslate("settingsmanager", "Sort images")

            helptext: qsTranslate("settingsmanager", "Images in a folder can be sorted in different ways. Once a folder is loaded it is possible to further sort a folder in several advanced ways using the menu option for sorting.")

            content: [
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
                        property list<string> modeldata: [qsTranslate("settingsmanager", "natural name"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "name"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "time"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "size"),
                                                          //: A criteria for sorting images
                                                          qsTranslate("settingsmanager", "type")]
                        model: modeldata
                        onCurrentIndexChanged: setting_top.checkDefault()
                        hideEntries: PQCScriptsConfig.isICUSupportEnabled() ? [] : [0]
                    }
                },

                Flow {
                    width: set_sort.rightcol
                    spacing: 5
                    PQRadioButton {
                        id: sortasc
                        //: Sort images in ascending order
                        text: qsTranslate("settingsmanager", "ascending order")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQRadioButton {
                        id: sortdesc
                        //: Sort images in descending order
                        text: qsTranslate("settingsmanager", "descending order")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                }
            ]

            onResetToDefaults: {
                sortcriteria.currentIndex = 0
                sortasc.checked = PQCSettings.getDefaultForImageviewSortImagesAscending()
                sortdesc.checked = !sortasc.checked
            }

            function handleEscape() {
                sortcriteria.popup.close()
            }

            function hasChanged() {
                return (sortasc.hasChanged() || sortdesc.hasChanged() || sortcriteria.hasChanged())
            }

            function load() {

                if(!PQCScriptsConfig.isICUSupportEnabled() && PQCSettings.imageviewSortImagesBy === "naturalname")
                    PQCSettings.imageviewSortImagesBy = "name"

                var l = ["naturalname", "name", "time", "size", "type"]
                sortcriteria.loadAndSetDefault(Math.max(0, l.indexOf(PQCSettings.imageviewSortImagesBy))) 
                sortasc.loadAndSetDefault(PQCSettings.imageviewSortImagesAscending)
                sortdesc.loadAndSetDefault(!PQCSettings.imageviewSortImagesAscending)

            }

            function applyChanges() {
                var l = ["naturalname", "name", "time", "size", "type"]
                PQCSettings.imageviewSortImagesBy = l[sortcriteria.currentIndex] 
                PQCSettings.imageviewSortImagesAscending = sortasc.checked
                sortcriteria.saveDefault()
                sortasc.saveDefault()
                sortdesc.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_lay

            //: Settings title
            title: qsTranslate("settingsmanager", "Layout")

            helptext: qsTranslate("settingsmanager", "The files can be shown either as grid with an emphasis on the thumbnails, or as list with an emphasis on getting a clear overview.")

            content: [

                PQRadioButton {
                    id: layout_icon
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "grid view")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: layout_list
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "list view")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: layout_masonry
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "masonry view")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                layout_icon.checked = (PQCSettings.getDefaultForFiledialogLayout()==="grid")
                layout_masonry.checked = (PQCSettings.getDefaultForFiledialogLayout() === "masonry")
                layout_list.checked = !layout_icon.checked&&!layout_masonry.checked
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (layout_icon.hasChanged() || layout_list.hasChanged() || layout_masonry.hasChanged())
            }

            function load() {
                layout_icon.loadAndSetDefault(PQCSettings.filedialogLayout==="grid")
                layout_masonry.loadAndSetDefault(PQCSettings.filedialogLayout==="masonry")
                layout_list.loadAndSetDefault(!layout_icon.checked&&!layout_masonry.checked)
            }

            function applyChanges() {
                PQCSettings.filedialogLayout = (layout_icon.checked ? "grid" : (layout_masonry.checked ? "masonry" : "list"))
                layout_icon.saveDefault()
                layout_list.saveDefault()
                layout_masonry.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_hid

            //: Settings title
            title: qsTranslate("settingsmanager", "Hidden files")

            helptext: qsTranslate("settingsmanager", "Hidden files and folders are by default not included in the list of files.")

            content: [
                PQCheckBox {
                    id: hiddencheck
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show hidden files/folders")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                hiddencheck.checked = PQCSettings.getDefaultForFiledialogShowHiddenFilesFolders()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return hiddencheck.hasChanged()
            }

            function load() {
                hiddencheck.loadAndSetDefault(PQCSettings.filedialogShowHiddenFilesFolders)
            }

            function applyChanges() {
                PQCSettings.filedialogShowHiddenFilesFolders = hiddencheck.checked
                hiddencheck.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {
            id: set_ttp

            //: Settings title
            title: qsTranslate("settingsmanager", "Tooltip")

            helptext: qsTranslate("settingsmanager", "When moving the mouse cursor over an entry, a tooltip with a larger preview and more information about the file or folder can be shown.")

            content: [
                PQCheckBox {
                    id: tooltipcheck
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show tooltip with details")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                tooltipcheck.checked = PQCSettings.getDefaultForFiledialogDetailsTooltip()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return tooltipcheck.hasChanged()
            }

            function load() {
                tooltipcheck.loadAndSetDefault(PQCSettings.filedialogDetailsTooltip)
            }

            function applyChanges() {
                PQCSettings.filedialogDetailsTooltip = tooltipcheck.checked
                tooltipcheck.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_loc

            //: Settings title, location here is a folder path
            title: qsTranslate("settingsmanager", "Last location")

            helptext: qsTranslate("settingsmanager", "By default the file dialog starts out in your home folder at start. Enabling this setting makes the file dialog reopen at the same location where it ended in the last session.")

            content: [
                PQCheckBox {
                    id: remembercheck
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Remember")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                remembercheck.checked = PQCSettings.getDefaultForFiledialogKeepLastLocation()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return remembercheck.hasChanged()
            }

            function load() {
                remembercheck.loadAndSetDefault(PQCSettings.filedialogKeepLastLocation)
            }

            function applyChanges() {
                PQCSettings.filedialogKeepLastLocation = remembercheck.checked
                remembercheck.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sin

            //: Settings title
            title: qsTranslate("settingsmanager", "Single clicks")

            helptext: qsTranslate("settingsmanager", "By default the behavior of single clicks follows the standard behavior on Linux, where a single click opens a file or folder. Enabling this setting results in single clicks only selecting files and folders with double clicks required to actually open them.")

            content: [
                PQRadioButton {
                    id: singleexec
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Open with single click")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: singlecheck
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Select with single click, open with double click")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                singlecheck.checked = PQCSettings.getDefaultForFiledialogSingleClickSelect()
                singleexec.checked = !singlecheck.checked
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (singlecheck.hasChanged() || singleexec.hasChanged())
            }

            function load() {
                singleexec.loadAndSetDefault(!PQCSettings.filedialogSingleClickSelect)
                singlecheck.loadAndSetDefault(PQCSettings.filedialogSingleClickSelect)
            }

            function applyChanges() {
                PQCSettings.filedialogSingleClickSelect = singlecheck.checked
                singleexec.saveDefault()
                singlecheck.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sel

            //: Settings title
            title: qsTranslate("settingsmanager", "Selection")

            helptext: qsTranslate("settingsmanager", "Usually, once a folder is navigated away from any selection is lost. However, it is possible to remember the file/folder selection for each folder and have it recalled next time the folder is loaded.")

            content: [
                PQCheckBox {
                    id: selremem
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Remember selection for each folder")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                selremem.checked = PQCSettings.getDefaultForFiledialogRememberSelection()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return selremem.hasChanged()
            }

            function load() {
                selremem.loadAndSetDefault(PQCSettings.filedialogRememberSelection)
            }

            function applyChanges() {
                PQCSettings.filedialogRememberSelection = selremem.checked
                selremem.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sec

            //: Settings title
            title: qsTranslate("settingsmanager", "Sections")

            helptext: qsTranslate("settingsmanager", "In the left column there are two sections that can be shown. The bookmarks are a combination of some standard locations on any computer and a customizable list of your own bookmarks. The devices are a list of storage devices found on your system.")

            content: [
                PQCheckBox {
                    id: sect_bookmarks
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show bookmarks")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: sect_devices
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show devices")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: sect_devicestmpfs
                    visible: !PQCScriptsConfig.amIOnWindows() 
                    enabled: sect_devices.checked
                    enforceMaxWidth: set_sort.rightcol-22
                    text: qsTranslate("settingsmanager", "Include temporary devices")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                sect_bookmarks.checked = PQCSettings.getDefaultForFiledialogPlaces()
                sect_devices.checked = PQCSettings.getDefaultForFiledialogDevices()
                sect_devicestmpfs.checked = PQCSettings.getDefaultForFiledialogDevicesShowTmpfs()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (sect_bookmarks.hasChanged() || sect_devices.hasChanged() || sect_devicestmpfs.hasChanged())
            }

            function load() {
                sect_bookmarks.loadAndSetDefault(PQCSettings.filedialogPlaces)
                sect_devices.loadAndSetDefault(PQCSettings.filedialogDevices)
                sect_devicestmpfs.loadAndSetDefault(PQCSettings.filedialogDevicesShowTmpfs)
            }

            function applyChanges() {
                PQCSettings.filedialogPlaces = sect_bookmarks.checked
                PQCSettings.filedialogDevices = sect_devices.checked
                PQCSettings.filedialogDevicesShowTmpfs = sect_devicestmpfs.checked
                sect_bookmarks.saveDefault()
                sect_devices.saveDefault()
                sect_devicestmpfs.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_dad

            //: Settings title
            title: qsTranslate("settingsmanager", "Drag and drop")

            helptext: qsTranslate("settingsmanager", "There are two different drag-and-drop actions that exist in the file dialog. 1) It is possible to drag folders from either the list or icon view (or both) and drop them on the bookmarks. And 2) it is possible to reorder the bookmarks through drag-and-drop.")

            content: [
                PQCheckBox {
                    id: drag_icon
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Enable drag-and-drop for grid view")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: drag_list
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Enable drag-and-drop for list view")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: drag_masonry
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Enable drag-and-drop for masonry view")
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: drag_bookmarks
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Enable drag-and-drop for bookmarks")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                drag_icon.checked = PQCSettings.getDefaultForFiledialogDragDropFileviewGrid()
                drag_list.checked = PQCSettings.getDefaultForFiledialogDragDropFileviewList()
                drag_masonry.checked = PQCSettings.getDefaultForFiledialogDragDropFileviewMasonry()
                drag_bookmarks.checked = PQCSettings.getDefaultForFiledialogDragDropPlaces()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (drag_icon.hasChanged() || drag_list.hasChanged() || drag_bookmarks.hasChanged())
            }

            function load() {
                drag_icon.loadAndSetDefault(PQCSettings.filedialogDragDropFileviewGrid)
                drag_list.loadAndSetDefault(PQCSettings.filedialogDragDropFileviewList)
                drag_bookmarks.loadAndSetDefault(PQCSettings.filedialogDragDropPlaces)
            }

            function applyChanges() {
                PQCSettings.filedialogDragDropFileviewGrid = drag_icon.checked
                PQCSettings.filedialogDragDropFileviewList = drag_list.checked
                PQCSettings.filedialogDragDropPlaces = drag_bookmarks.checked
                drag_icon.saveDefault()
                drag_list.saveDefault()
                drag_bookmarks.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator { howManyLines: 2 }
        /**********************************************************************/

        PQSetting {

            id: set_thb

            //: Settings title
            title: qsTranslate("settingsmanager", "Thumbnails")

            helptext: qsTranslate("settingsmanager", "For all files PhotoQt can either show an icon corresponding to its file type or a small thumbnail preview. The thumbnail can either be shown fitted into the available space or cropped to fill out the full space.")

            content: [
                PQCheckBox {
                    id: thumb_show
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show thumbnails")
                    onCheckedChanged: setting_top.checkDefault()
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
                        enforceMaxWidth: set_sort.rightcol
                        text: qsTranslate("settingsmanager", "Scale and crop thumbnails")
                        onCheckedChanged: setting_top.checkDefault()
                    }
                }

            ]

            onResetToDefaults: {
                thumb_show.checked = PQCSettings.getDefaultForFiledialogThumbnails()
                thumb_scalecrop.checked = PQCSettings.getDefaultForFiledialogThumbnailsScaleCrop()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (thumb_show.hasChanged() || thumb_scalecrop.hasChanged())
            }

            function load() {
                thumb_show.loadAndSetDefault(PQCSettings.filedialogThumbnails)
                thumb_scalecrop.loadAndSetDefault(PQCSettings.filedialogThumbnailsScaleCrop)
            }

            function applyChanges() {
                PQCSettings.filedialogThumbnails = thumb_show.checked
                PQCSettings.filedialogThumbnailsScaleCrop = thumb_scalecrop.checked
                thumb_show.saveDefault()
                thumb_scalecrop.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_pad

            //: Settings title
            title: qsTranslate("settingsmanager", "Padding")

            helptext: qsTranslate("settingsmanager", "The empty space between the different thumbnails.")

            content: [
                PQSliderSpinBox {
                    id: padding
                    width: set_sort.rightcol
                    minval: 0
                    maxval: 10
                    title: ""
                    suffix: " px"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                padding.setValue(PQCSettings.getDefaultForFiledialogElementPadding())
            }

            function handleEscape() {
                padding.closeContextMenus()
                padding.acceptValue()
            }

            function hasChanged() {
                return padding.hasChanged()
            }

            function load() {
                padding.loadAndSetDefault(PQCSettings.filedialogElementPadding)
            }

            function applyChanges() {
                PQCSettings.filedialogElementPadding = padding.value
                padding.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_lab

            //: Settings title
            title: qsTranslate("settingsmanager", "Filename labels")

            helptext: qsTranslate("settingsmanager", "Whether to show labels with filenames on top of the thumbnails. Labels for folders are always shown")

            content: [

                PQRadioButton {
                    id: labels_grid
                    enforceMaxWidth: set_lab.rightcol
                    text: qsTranslate("settingsmanager", "filename labels in grid view")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: labels_masonry
                    enforceMaxWidth: set_lab.rightcol
                    text: qsTranslate("settingsmanager", "filename labels in masonry view")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                labels_grid.checked = PQCSettings.getDefaultForFiledialogLabelsShowGrid()
                labels_masonry.checked = PQCSettings.getDefaultForFiledialogLabelsShowMasonry()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return labels_grid.hasChanged() || labels_masonry.hasChanged()
            }

            function load() {
                labels_grid.loadAndSetDefault(PQCSettings.filedialogLabelsShowGrid)
                labels_masonry.loadAndSetDefault(PQCSettings.filedialogLabelsShowMasonry)
            }

            function applyChanges() {
                PQCSettings.filedialogLabelsShowGrid = labels_grid.checked
                PQCSettings.filedialogLabelsShowMasonry = labels_masonry.checked
                labels_grid.saveDefault()
                labels_masonry.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_fol

            //: Settings title
            title: qsTranslate("settingsmanager", "Folder thumbnails")

            helptext: qsTranslate("settingsmanager", "When hovering over a folder PhotoQt can give a preview of that folder by iterating through thumbnails of its content. Additionally, the timeout before changing the thumbnail and whether to loop around can be adjusted. Enabling the auto load setting preloads the first thumbnail when the parent folder is opened.")

            content: [
                PQCheckBox {
                    id: folderthumb_check
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Enable folder thumbnails")
                    onCheckedChanged: setting_top.checkDefault()
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

                        PQCheckBox {
                            id: folderthumb_loop
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Loop through content")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        Flow {
                            width: set_sort.rightcol
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
                                onCurrentIndexChanged: setting_top.checkDefault()
                            }
                        }

                        PQCheckBox {
                            id: folderthumb_autoload
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Auto-load first thumbnail")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQCheckBox {
                            id: folderthumb_scalecrop
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Scale and crop thumbnails")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                    }
                }

            ]

            onResetToDefaults: {
                folderthumb_check.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnails()
                folderthumb_timeout.currentIndex = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsSpeed()
                folderthumb_loop.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsLoop()
                folderthumb_autoload.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsAutoload()
                folderthumb_scalecrop.checked = PQCSettings.getDefaultForFiledialogFolderContentThumbnailsScaleCrop()
            }

            function handleEscape() {
                folderthumb_timeout.popup.close()
            }

            function hasChanged() {
                return (folderthumb_check.hasChanged() || folderthumb_timeout.hasChanged() || folderthumb_loop.hasChanged() ||
                        folderthumb_autoload.hasChanged() || folderthumb_scalecrop.hasChanged())
            }

            function load() {
                folderthumb_check.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnails)
                folderthumb_timeout.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsSpeed-1)
                folderthumb_loop.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsLoop)
                folderthumb_autoload.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsAutoload)
                folderthumb_scalecrop.loadAndSetDefault(PQCSettings.filedialogFolderContentThumbnailsScaleCrop)
            }

            function applyChanges() {

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

            }

        }

        /**********************************************************************/
        PQSettingsSeparator { howManyLines: 2 }
        /**********************************************************************/

        PQSetting {

            id: set_pre

            //: Settings title
            title: qsTranslate("settingsmanager", "Preview")

            helptext: qsTranslate("settingsmanager", "The preview refers to the larger preview of a file shown behind the list of all files and folders. Various properties of that preview can be adjusted.")

            content: [

                PQCheckBox {
                    id: preview_check
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show preview")
                    onCheckedChanged: setting_top.checkDefault()
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

                        Row {
                            Item {
                                width: 30
                                height: 1
                            }

                            PQSliderSpinBox {
                                id: preview_colintspin
                                width: set_sort.rightcol - 30
                                title: qsTranslate("settingsmanager", "color intensity:")
                                titleWeight: PQCLook.fontWeightNormal 
                                minval: 10
                                maxval: 100
                                suffix: " %"
                                onValueChanged: setting_top.checkDefault()
                            }
                        }

                        PQCheckBox {
                            id: preview_blur
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Blur the preview")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQCheckBox {
                            id: preview_mute
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Mute its colors")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQCheckBox {
                            id: preview_resolution
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Higher resolution")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                        PQCheckBox {
                            id: preview_scalecrop
                            enforceMaxWidth: set_sort.rightcol
                            text: qsTranslate("settingsmanager", "Scale and crop")
                            onCheckedChanged: setting_top.checkDefault()
                        }

                    }

                }

            ]

            onResetToDefaults: {
                preview_check.checked = PQCSettings.getDefaultForFiledialogPreview()
                preview_blur.checked = PQCSettings.getDefaultForFiledialogPreviewBlur()
                preview_mute.checked = PQCSettings.getDefaultForFiledialogPreviewMuted()
                preview_colintspin.setValue(PQCSettings.getDefaultForFiledialogPreviewColorIntensity())
                preview_resolution.checked = PQCSettings.getDefaultForFiledialogPreviewHigherResolution()
                preview_scalecrop.checked = PQCSettings.getDefaultForFiledialogPreviewCropToFit()
            }

            function handleEscape() {
                preview_colintspin.closeContextMenus()
                preview_colintspin.acceptValue()
            }

            function hasChanged() {
                return (preview_check.hasChanged() || preview_blur.hasChanged() || preview_mute.hasChanged() ||
                        preview_colintspin.hasChanged() || preview_resolution.hasChanged() || preview_scalecrop.hasChanged())
            }

            function load() {
                preview_check.loadAndSetDefault(PQCSettings.filedialogPreview)
                preview_blur.loadAndSetDefault(PQCSettings.filedialogPreviewBlur)
                preview_mute.loadAndSetDefault(PQCSettings.filedialogPreviewMuted)
                preview_colintspin.loadAndSetDefault(PQCSettings.filedialogPreviewColorIntensity)
                preview_resolution.loadAndSetDefault(PQCSettings.filedialogPreviewHigherResolution)
                preview_scalecrop.loadAndSetDefault(PQCSettings.filedialogPreviewCropToFit)
            }

            function applyChanges() {

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

            }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_sort.handleEscape()
        set_lay.handleEscape()
        set_hid.handleEscape()
        set_ttp.handleEscape()
        set_loc.handleEscape()
        set_sin.handleEscape()
        set_sel.handleEscape()
        set_sec.handleEscape()
        set_dad.handleEscape()
        set_thb.handleEscape()
        set_pad.handleEscape()
        set_lab.handleEscape()
        set_fol.handleEscape()
        set_pre.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        var l = ["naturalname", "name", "time", "size", "type"]

        settingChanged = (set_sort.hasChanged() || set_lay.hasChanged() || set_hid.hasChanged() ||
                          set_ttp.hasChanged() || set_loc.hasChanged() || set_sin.hasChanged() ||
                          set_sel.hasChanged() || set_sec.hasChanged() || set_dad.hasChanged() ||
                          set_thb.hasChanged() || set_pad.hasChanged() || set_fol.hasChanged() ||
                          set_pre.hasChanged() || set_lab.hasChanged())

    }

    function load() {

        set_sort.load()
        set_lay.load()
        set_hid.load()
        set_ttp.load()
        set_loc.load()
        set_sin.load()
        set_sel.load()
        set_sec.load()
        set_dad.load()
        set_thb.load()
        set_pad.load()
        set_fol.load()
        set_pre.load()
        set_lab.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_sort.applyChanges()
        set_lay.applyChanges()
        set_hid.applyChanges()
        set_ttp.applyChanges()
        set_loc.applyChanges()
        set_sin.applyChanges()
        set_sel.applyChanges()
        set_sec.applyChanges()
        set_dad.applyChanges()
        set_thb.applyChanges()
        set_pad.applyChanges()
        set_fol.applyChanges()
        set_pre.applyChanges()
        set_lab.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
