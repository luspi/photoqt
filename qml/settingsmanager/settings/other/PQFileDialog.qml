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
import PQCScriptsConfig

import "../../../elements"

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

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Layout")

            helptext: qsTranslate("settingsmanager", "The files can be shown either as icons with an emphasis on the thumbnails, or as list with an emphasis on getting a clear overview.")

            content: [

                PQRadioButton {
                    id: layout_icon
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "icon view")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: layout_list
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "list view")
                    onCheckedChanged: setting_top.checkDefault()
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
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show hidden files/folders")
                    onCheckedChanged: setting_top.checkDefault()
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
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Show tooltip with details")
                    onCheckedChanged: setting_top.checkDefault()
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
                    enforceMaxWidth: set_sort.rightcol
                    text: qsTranslate("settingsmanager", "Remember")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

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

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

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
                    visible: !PQCScriptsConfig.amIOnWindows() // qmllint disable unqualified
                    enabled: sect_devices.checked
                    enforceMaxWidth: set_sort.rightcol-22
                    text: qsTranslate("settingsmanager", "Include temporary devices")
                    onCheckedChanged: setting_top.checkDefault()
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
                    enforceMaxWidth: set_sort.rightcol
                    text: "Enable drag-and-drop for icon view"
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: drag_list
                    enforceMaxWidth: set_sort.rightcol
                    text: "Enable drag-and-drop for list view"
                    onCheckedChanged: setting_top.checkDefault()
                },
                PQCheckBox {
                    id: drag_bookmarks
                    enforceMaxWidth: set_sort.rightcol
                    text: "Enable drag-and-drop for bookmarks"
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator { howManyLines: 2 }
        /**********************************************************************/

        PQSetting {

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

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

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

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

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

        }

        /**********************************************************************/
        PQSettingsSeparator { howManyLines: 2 }
        /**********************************************************************/

        PQSetting {

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
                                titleWeight: PQCLook.fontWeightNormal // qmllint disable unqualified
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

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        padding.closeContextMenus()
        padding.acceptValue()
        preview_colintspin.closeContextMenus()
        preview_colintspin.acceptValue()
        sortcriteria.popup.close()
        folderthumb_timeout.popup.close()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        var l = ["naturalname", "name", "time", "size", "type"]

        settingChanged = (sortasc.hasChanged() || sortdesc.hasChanged() || sortcriteria.hasChanged() ||
                          layout_icon.hasChanged() || layout_list.hasChanged() || hiddencheck.hasChanged() || tooltipcheck.hasChanged() ||
                          remembercheck.hasChanged() || singlecheck.hasChanged() || sect_bookmarks.hasChanged() || sect_devices.hasChanged() ||
                          sect_devicestmpfs.hasChanged() ||
                          drag_icon.hasChanged() || drag_list.hasChanged() || drag_bookmarks.hasChanged() || singleexec.hasChanged() ||
                          thumb_show.hasChanged() || thumb_scalecrop.hasChanged() || padding.hasChanged() || folderthumb_check.hasChanged() ||
                          folderthumb_timeout.hasChanged() || folderthumb_loop.hasChanged() || folderthumb_autoload.hasChanged() ||
                          folderthumb_scalecrop.hasChanged() || preview_check.hasChanged() || preview_blur.hasChanged() || preview_mute.hasChanged() ||
                          preview_colintspin.hasChanged() || preview_resolution.hasChanged() || preview_scalecrop.hasChanged())

    }

    function load() {

        if(!PQCScriptsConfig.isICUSupportEnabled() && PQCSettings.imageviewSortImagesBy === "naturalname")
            PQCSettings.imageviewSortImagesBy = "name"

        var l = ["naturalname", "name", "time", "size", "type"]
        sortcriteria.loadAndSetDefault(Math.max(0, l.indexOf(PQCSettings.imageviewSortImagesBy))) // qmllint disable unqualified
        sortasc.loadAndSetDefault(PQCSettings.imageviewSortImagesAscending)
        sortdesc.loadAndSetDefault(!PQCSettings.imageviewSortImagesAscending)

        layout_icon.loadAndSetDefault(PQCSettings.filedialogLayout==="icons")
        layout_list.loadAndSetDefault(PQCSettings.filedialogLayout!=="icons")
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

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var l = ["naturalname", "name", "time", "size", "type"]
        PQCSettings.imageviewSortImagesBy = l[sortcriteria.currentIndex] // qmllint disable unqualified
        PQCSettings.imageviewSortImagesAscending = sortasc.checked

        PQCSettings.filedialogLayout = (layout_icon.checked ? "icons" : "list")
        PQCSettings.filedialogShowHiddenFilesFolders = hiddencheck.checked
        PQCSettings.filedialogDetailsTooltip = tooltipcheck.checked
        PQCSettings.filedialogKeepLastLocation = remembercheck.checked
        PQCSettings.filedialogSingleClickSelect = singlecheck.checked
        PQCSettings.filedialogRememberSelection = selremem.checked
        PQCSettings.filedialogPlaces = sect_bookmarks.checked
        PQCSettings.filedialogDevices = sect_devices.checked
        PQCSettings.filedialogDevicesShowTmpfs = sect_devicestmpfs.checked
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
        PQCSettings.filedialogPreviewColorIntensity = preview_colintspin.value
        PQCSettings.filedialogPreviewHigherResolution = preview_resolution.checked
        PQCSettings.filedialogPreviewCropToFit = preview_scalecrop.checked

        sortcriteria.saveDefault()
        sortasc.saveDefault()
        sortdesc.saveDefault()

        layout_icon.saveDefault()
        layout_list.saveDefault()
        hiddencheck.saveDefault()
        tooltipcheck.saveDefault()
        remembercheck.saveDefault()
        singleexec.saveDefault()
        singlecheck.saveDefault()
        selremem.saveDefault()
        sect_bookmarks.saveDefault()
        sect_devices.saveDefault()
        sect_devicestmpfs.saveDefault()
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
        preview_colintspin.saveDefault()
        preview_resolution.saveDefault()
        preview_scalecrop.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
