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
import PQCScriptsConfig

import "../elements"

PQMenu {
    id: settingsmenu

    Connections {
        target: filedialog_top
        function onOpacityChanged() {
            if(filedialog_top.opacity<1)
                settingsmenu.close()
        }
    }

    PQMenu {
        //: file manager settings popdown: menu title
        title: qsTranslate("filedialog", "View")

        PQMenuItem {
            enabled: false
            moveToRightABit: true
            //: file manager settings popdown: submenu title
            text: qsTranslate("filedialog", "layout")
        }

        PQMenuItem {
            text: qsTranslate("filedialog", "list view")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="list"
            onTriggered:
                PQCSettings.filedialogLayout = "list"
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "icon view")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="icons"
            onTriggered:
                PQCSettings.filedialogLayout = "icons"
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            moveToRightABit: true
            //: file manager settings popdown: submenu title
            text: qsTranslate("filedialog", "drag and drop")
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for list view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewList
            onCheckedChanged:
                PQCSettings.filedialogDragDropFileviewList = checked
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for grid view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewGrid
            onCheckedChanged:
                PQCSettings.filedialogDragDropFileviewGrid = checked
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for bookmarks")
            checkable: true
            checked: PQCSettings.filedialogDragDropPlaces
            onCheckedChanged:
                PQCSettings.filedialogDragDropPlaces = checked
        }

        PQMenuSeparator {}

        PQMenu {
            id: paddingsubmenu
            //: file manager settings popdown: submenu title
            title: qsTranslate("filedialog", "padding")
            Instantiator {
                model: 11
                delegate: PQMenuItem {
                    text: modelData + " px"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogElementPadding===modelData
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.filedialogElementPadding = modelData
                    }
                    onTriggered:
                        PQCSettings.filedialogElementPadding = modelData
                }
                onObjectAdded: (index, object) => paddingsubmenu.insertItem(index, object)
                onObjectRemoved: (index, object) => paddingsubmenu.removeItem(object)
            }
        }

        PQMenuItem {
            //: file manager settings popdown: how to select files
            text: qsTranslate("filedialog", "select with single click")
            checkable: true
            checked: PQCSettings.filedialogSingleClickSelect
            onCheckedChanged:
                PQCSettings.filedialogSingleClickSelect = checked
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "hidden files")
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders
            onCheckedChanged:
                PQCSettings.filedialogShowHiddenFilesFolders = checked
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "tooltips")
            checkable: true
            checked: PQCSettings.filedialogDetailsTooltip
            onCheckedChanged:
                PQCSettings.filedialogDetailsTooltip = checked
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "Remember last location")
            checkable: true
            checked: PQCSettings.filedialogKeepLastLocation
            onCheckedChanged:
                PQCSettings.filedialogKeepLastLocation = checked
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
            onCheckedChanged:
                PQCSettings.filedialogThumbnails = checked
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop the thumbnails
            text: qsTranslate("filedialog", "scale and crop")
            enabled: thumbnailsshow.checked
            checkable: true
            checked: PQCSettings.filedialogThumbnailsScaleCrop
            onCheckedChanged:
                PQCSettings.filedialogThumbnailsScaleCrop = checked
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            moveToRightABit: true
            text: qsTranslate("filedialog", "folder thumbnails")
        }
        PQMenuItem {
            id: folderthumbshow
            //: file manager settings popdown: show folder thumbnails
            text: qsTranslate("filedialog", "show")
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnails
            onCheckedChanged:
                PQCSettings.filedialogFolderContentThumbnails = checked
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop the folder thumbnails
            text: qsTranslate("filedialog", "scale and crop")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsScaleCrop
            onCheckedChanged:
                PQCSettings.filedialogFolderContentThumbnailsScaleCrop = checked
        }
        PQMenuItem {
            //: file manager settings popdown: automatically load the folder thumbnails
            text: qsTranslate("filedialog", "autoload")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsAutoload
            onCheckedChanged:
                PQCSettings.filedialogFolderContentThumbnailsAutoload = checked
        }
        PQMenuItem {
            //: file manager settings popdown: loop through the folder thumbnails
            text: qsTranslate("filedialog", "loop")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsLoop
            onCheckedChanged:
                PQCSettings.filedialogFolderContentThumbnailsLoop = checked
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            moveToRightABit: true
            //: file manager settings popdown: timeout between switching folder thumbnails
            text: qsTranslate("filedialog", "timeout")
        }
        PQMenuItem {
            enabled: folderthumbshow.checked
            text: "2 seconds"
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===1
            onTriggered:
                PQCSettings.filedialogFolderContentThumbnailsSpeed = 1
        }
        PQMenuItem {
            enabled: folderthumbshow.checked
            text: qsTranslate("filedialog", "1 second")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===2
            onTriggered:
                PQCSettings.filedialogFolderContentThumbnailsSpeed = 2
        }
        PQMenuItem {
            enabled: folderthumbshow.checked
            text: qsTranslate("filedialog", "half a second")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===3
            onTriggered:
                PQCSettings.filedialogFolderContentThumbnailsSpeed = 3
        }
    }
    PQMenu {
        //: file manager settings popdown: menu title
        title: qsTranslate("filedialog", "Bookmarks")
        PQMenuItem {
            text: qsTranslate("filedialog", "show bookmarks")
            checkable: true
            checked: PQCSettings.filedialogPlaces
            onCheckedChanged:
                PQCSettings.filedialogPlaces = checked
        }
        PQMenuItem {
            //: file manager settings popdown: the devices here are the storage devices
            text: qsTranslate("filedialog", "show devices")
            checkable: true
            checked: PQCSettings.filedialogDevices
            onCheckedChanged:
                PQCSettings.filedialogDevices = checked
        }
        PQMenuItem {
            //: file manager settings popdown: the devices here are the storage devices
            text: qsTranslate("filedialog", "show temporary devices")
            checkable: true
            visible: !PQCScriptsConfig.amIOnWindows()
            checked: PQCSettings.filedialogDevicesShowTmpfs
            onCheckedChanged:
                PQCSettings.filedialogDevicesShowTmpfs = checked
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
            onCheckedChanged:
                PQCSettings.filedialogPreview = checked
        }
        PQMenuItem {
            //: file manager settings popdown: use higher resolution for image previews
            text: qsTranslate("filedialog", "higher resolution")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewHigherResolution
            onCheckedChanged:
                PQCSettings.filedialogPreviewHigherResolution = checked
        }
        PQMenuItem {
            //: file manager settings popdown: blur image previews
            text: qsTranslate("filedialog", "blur")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewBlur
            onCheckedChanged:
                PQCSettings.filedialogPreviewBlur = checked
        }
        PQMenuItem {
            //: file manager settings popdown: mute the colors in image previews
            text: qsTranslate("filedialog", "mute colors")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewMuted
            onCheckedChanged:
                PQCSettings.filedialogPreviewMuted = checked
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop image previews
            text: qsTranslate("filedialog", "scale and crop")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewCropToFit
            onCheckedChanged:
                PQCSettings.filedialogPreviewCropToFit = checked
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
                    text: (10-index)*10 + "%"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: Math.round(PQCSettings.filedialogPreviewColorIntensity/10)===(10-index)
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.filedialogPreviewColorIntensity = 10*(10-index)
                    }
                    ButtonGroup.group: colgrp
                }
                onObjectAdded: (index, object) => coloritensitysubmenu.insertItem(index, object)
                onObjectRemoved: (index, object) => coloritensitysubmenu.removeItem(object)
            }
        }
    }
    onClosed:
        resetChecked.restart()
    Timer {
        id: resetChecked
        interval: 100
        onTriggered:
            settings.checked = false
    }
}
