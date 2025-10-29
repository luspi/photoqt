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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

PQMenu {

    id: settingsmenu

    onAboutToShow: {
        PQCConstants.addToWhichContextMenusOpen("filedialogsettingsmenu")
    }

    onAboutToHide: {
        PQCConstants.removeFromWhichContextMenusOpen("filedialogsettingsmenu")
    }

    PQMenu {
        //: file manager settings popdown: menu title
        title: qsTranslate("filedialog", "View")

        PQMenuItem {
            enabled: false
            // moveToRightABit: true
            //: file manager settings popdown: submenu title
            text: qsTranslate("filedialog", "layout")
        }

        PQMenuItem {
            id: mi_listview
            text: qsTranslate("filedialog", "list view")
            checkable: true
            // checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="list"
            onCheckedChanged: {
                if(checked) PQCSettings.filedialogLayout = "list"
                checked = Qt.binding(function() { return (PQCSettings.filedialogLayout==="list") })
            }
        }
        PQMenuItem {
            id: mi_iconview
            text: qsTranslate("filedialog", "grid view")
            checkable: true
            // checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="grid"
            onCheckedChanged: {
                if(checked) PQCSettings.filedialogLayout = "grid"
                checked = Qt.binding(function() { return (PQCSettings.filedialogLayout==="grid") })
            }
        }
        PQMenuItem {
            id: mi_masonryview
            text: qsTranslate("filedialog", "masonry view")
            checkable: true
            // checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="masonry"
            onCheckedChanged: {
                if(checked) PQCSettings.filedialogLayout = "masonry"
                checked = Qt.binding(function() { return (PQCSettings.filedialogLayout==="masonry") })
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            // moveToRightABit: true
            //: file manager settings popdown: submenu title
            text: qsTranslate("filedialog", "drag and drop")
        }
        PQMenuItem {
            id: dnd_list
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for list view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewList
            onCheckedChanged: {
                PQCSettings.filedialogDragDropFileviewList = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropFileviewList })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for grid view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewGrid
            onCheckedChanged: {
                PQCSettings.filedialogDragDropFileviewGrid = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropFileviewGrid })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for masonry view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewMasonry
            onCheckedChanged: {
                PQCSettings.filedialogDragDropFileviewMasonry = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropFileviewMasonry })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for bookmarks")
            checkable: true
            checked: PQCSettings.filedialogDragDropPlaces
            onCheckedChanged: {
                PQCSettings.filedialogDragDropPlaces = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropPlaces })
            }
        }

        PQMenuSeparator {}

        PQMenu {
            id: paddingsubmenu
            //: file manager settings popdown: submenu title
            title: qsTranslate("filedialog", "padding")
            Instantiator {
                model: 11
                delegate: PQMenuItem {
                    required property int modelData
                    text: modelData + " px"
                    checkable: true
                    // checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogElementPadding===modelData
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.filedialogElementPadding = modelData
                        checked = Qt.binding(function() { return (PQCSettings.filedialogElementPadding===modelData); })
                    }
                }
                onObjectAdded: (index, object) => paddingsubmenu.insertItem(index, object)
                onObjectRemoved: (index, object) => paddingsubmenu.removeItem(object)
            }
        }

        PQMenu {
            id: filelabelsubmenu
            //: file manager settings popdown: submenu title
            title: qsTranslate("filedialog", "filename labels")

            PQMenuItem {
                //: file manager settings popdown: scale and crop the thumbnails
                text: qsTranslate("filedialog", "grid view")
                checkable: true
                checked: PQCSettings.filedialogLabelsShowGrid
                onCheckedChanged: {
                    PQCSettings.filedialogLabelsShowGrid = checked
                    checked = Qt.binding(function() { return PQCSettings.filedialogLabelsShowGrid })
                }
            }

            PQMenuItem {
                //: file manager settings popdown: scale and crop the thumbnails
                text: qsTranslate("filedialog", "masonry view")
                checkable: true
                checked: PQCSettings.filedialogLabelsShowMasonry
                onCheckedChanged: {
                    PQCSettings.filedialogLabelsShowMasonry = checked
                    checked = Qt.binding(function() { return PQCSettings.filedialogLabelsShowMasonry })
                }
            }

        }

        PQMenuItem {
            //: file manager settings popdown: how to select files
            text: qsTranslate("filedialog", "select with single click")
            checkable: true
            checked: PQCSettings.filedialogSingleClickSelect
            onCheckedChanged: {
                PQCSettings.filedialogSingleClickSelect = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogSingleClickSelect })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: how to select files
            text: qsTranslate("filedialog", "remember selections")
            checkable: true
            checked: PQCSettings.filedialogRememberSelection
            onCheckedChanged: {
                PQCSettings.filedialogRememberSelection = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogRememberSelection })
            }
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "hidden files")
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders
            onCheckedChanged: {
                PQCSettings.filedialogShowHiddenFilesFolders = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogShowHiddenFilesFolders })
            }
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "tooltips")
            checkable: true
            checked: PQCSettings.filedialogDetailsTooltip
            onCheckedChanged: {
                PQCSettings.filedialogDetailsTooltip = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDetailsTooltip })
            }
        }
        PQMenuItem {
            //: The location here is a folder path
            text: qsTranslate("filedialog", "Remember last location")
            checkable: true
            checked: PQCSettings.filedialogKeepLastLocation
            onCheckedChanged: {
                PQCSettings.filedialogKeepLastLocation = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogKeepLastLocation })
            }
        }
    }
    PQMenu {
        //: file manager settings popdown: menu title
        title: qsTranslate("filedialog", "Thumbnails")
        PQMenuItem {
            id: thumbnailsshow
            //: file manager settings popdown: show thumbnails
            text: qsTranslate("filedialog", "show")
            checkable: true
            checked: PQCSettings.filedialogThumbnails
            onCheckedChanged: {
                PQCSettings.filedialogThumbnails = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogThumbnails })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop the thumbnails
            text: qsTranslate("filedialog", "scale and crop")
            enabled: thumbnailsshow.checked
            checkable: true
            checked: PQCSettings.filedialogThumbnailsScaleCrop
            onCheckedChanged: {
                PQCSettings.filedialogThumbnailsScaleCrop = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogThumbnailsScaleCrop })
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            // moveToRightABit: true
            text: qsTranslate("filedialog", "folder thumbnails")
        }
        PQMenuItem {
            id: folderthumbshow
            //: file manager settings popdown: show folder thumbnails
            text: qsTranslate("filedialog", "show")
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnails
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnails = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnails })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop the folder thumbnails
            text: qsTranslate("filedialog", "scale and crop")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsScaleCrop
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnailsScaleCrop = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnailsScaleCrop })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: automatically load the folder thumbnails
            text: qsTranslate("filedialog", "autoload")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsAutoload
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnailsAutoload = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnailsAutoload })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: loop through the folder thumbnails
            text: qsTranslate("filedialog", "loop")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsLoop
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnailsLoop = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnailsLoop })
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            // moveToRightABit: true
            //: file manager settings popdown: timeout between switching folder thumbnails
            text: qsTranslate("filedialog", "timeout")
        }
        PQMenuItem {
            id: foldthumb2
            enabled: folderthumbshow.checked
            text: "2 seconds"
            checkable: true
            // checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===1
            onCheckedChanged: {
                if(checked)
                    PQCSettings.filedialogFolderContentThumbnailsSpeed = 1
            }
            Connections {
                target: PQCSettings
                function onFiledialogFolderContentThumbnailsSpeedChanged() {
                    foldthumb2.checked = (PQCSettings.filedialogFolderContentThumbnailsSpeed===1)
                }
            }
        }
        PQMenuItem {
            id: foldthumb1
            enabled: folderthumbshow.checked
            text: qsTranslate("filedialog", "1 second")
            checkable: true
            // checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===2
            onCheckedChanged: {
                if(checked)
                    PQCSettings.filedialogFolderContentThumbnailsSpeed = 2
            }
            Connections {
                target: PQCSettings
                function onFiledialogFolderContentThumbnailsSpeedChanged() {
                    foldthumb1.checked = (PQCSettings.filedialogFolderContentThumbnailsSpeed===2)
                }
            }
        }
        PQMenuItem {
            id: foldthumb05
            enabled: folderthumbshow.checked
            text: qsTranslate("filedialog", "half a second")
            checkable: true
            // checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===3
            onCheckedChanged: {
                if(checked)
                    PQCSettings.filedialogFolderContentThumbnailsSpeed = 3
            }
            Connections {
                target: PQCSettings
                function onFiledialogFolderContentThumbnailsSpeedChanged() {
                    foldthumb05.checked = (PQCSettings.filedialogFolderContentThumbnailsSpeed===3)
                }
            }
        }
    }
    PQMenu {
        //: file manager settings popdown: menu title
        title: qsTranslate("filedialog", "Bookmarks")
        PQMenuItem {
            text: qsTranslate("filedialog", "show bookmarks")
            checkable: true
            checked: PQCSettings.filedialogPlaces
            onCheckedChanged: {
                PQCSettings.filedialogPlaces = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogPlaces })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the devices here are the storage devices
            text: qsTranslate("filedialog", "show devices")
            checkable: true
            checked: PQCSettings.filedialogDevices
            onCheckedChanged: {
                PQCSettings.filedialogDevices = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDevices })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the devices here are the storage devices
            text: qsTranslate("filedialog", "show temporary devices")
            checkable: true
            implicitHeight: visible ? 40 : 0
            visible: !PQCScriptsConfig.amIOnWindows()
            checked: PQCSettings.filedialogDevicesShowTmpfs
            onCheckedChanged: {
                PQCSettings.filedialogDevicesShowTmpfs = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogDevicesShowTmpfs })
            }
        }
    }
    PQMenu {
        //: file manager settings popdown: menu title
        title: qsTranslate("filedialog", "Preview")
        PQMenuItem {
            id: previewshow
            //: file manager settings popdown: show image previews
            text: qsTranslate("filedialog", "show")
            checkable: true
            checked: PQCSettings.filedialogPreview
            onCheckedChanged: {
                PQCSettings.filedialogPreview = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogPreview })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: use higher resolution for image previews
            text: qsTranslate("filedialog", "higher resolution")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewHigherResolution
            onCheckedChanged: {
                PQCSettings.filedialogPreviewHigherResolution = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewHigherResolution })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: blur image previews
            text: qsTranslate("filedialog", "blur")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewBlur
            onCheckedChanged: {
                PQCSettings.filedialogPreviewBlur = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewBlur })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: mute the colors in image previews
            text: qsTranslate("filedialog", "mute colors")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewMuted
            onCheckedChanged: {
                PQCSettings.filedialogPreviewMuted = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewMuted })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop image previews
            text: qsTranslate("filedialog", "scale and crop")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewCropToFit
            onCheckedChanged: {
                PQCSettings.filedialogPreviewCropToFit = checked
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewCropToFit })
            }
        }
        PQMenu {
            id: coloritensitysubmenu
            //: file manager settings popdown: color intensity of image previews
            title: qsTranslate("filedialog", "color intensity")
            enabled: previewshow.checked

            ButtonGroup { id: colgrp }
            Instantiator {
                model: 10
                delegate: PQMenuItem {
                    required property int modelData
                    text: (10-modelData)*10 + "%"
                    checkable: true
                    // checkableLikeRadioButton: true
                    checked: Math.round(PQCSettings.filedialogPreviewColorIntensity/10)===(10-modelData)
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.filedialogPreviewColorIntensity = 10*(10-modelData)
                    }
                    ButtonGroup.group: colgrp
                }
                onObjectAdded: (index, object) => coloritensitysubmenu.insertItem(index, object)
                onObjectRemoved: (index, object) => coloritensitysubmenu.removeItem(object)
            }
        }
    }

}
