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
import PQCScriptsConfig
import org.photoqt.qml

PQMenu {
    id: settingsmenu

    Connections {
        target: filedialog_top // qmllint disable unqualified
        function onOpacityChanged() {
            if(filedialog_top.opacity<1) // qmllint disable unqualified
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
            id: mi_listview
            text: qsTranslate("filedialog", "list view")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="list" // qmllint disable unqualified
            onCheckedChanged: {
                if(checked) PQCSettings.filedialogLayout = "list" // qmllint disable unqualified
                checked = Qt.binding(function() { return (PQCSettings.filedialogLayout==="list") })
            }
        }
        PQMenuItem {
            id: mi_iconview
            text: qsTranslate("filedialog", "grid view")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="grid" // qmllint disable unqualified
            onCheckedChanged: {
                if(checked) PQCSettings.filedialogLayout = "grid" // qmllint disable unqualified
                checked = Qt.binding(function() { return (PQCSettings.filedialogLayout==="grid") })
            }
        }
        PQMenuItem {
            id: mi_masonryview
            text: qsTranslate("filedialog", "masonry view")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogLayout==="masonry" // qmllint disable unqualified
            onCheckedChanged: {
                if(checked) PQCSettings.filedialogLayout = "masonry" // qmllint disable unqualified
                checked = Qt.binding(function() { return (PQCSettings.filedialogLayout==="masonry") })
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            moveToRightABit: true
            //: file manager settings popdown: submenu title
            text: qsTranslate("filedialog", "drag and drop")
        }
        PQMenuItem {
            id: dnd_list
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for list view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewList // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDragDropFileviewList = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropFileviewList })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for grid view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewGrid // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDragDropFileviewGrid = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropFileviewGrid })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for masonry view")
            checkable: true
            checked: PQCSettings.filedialogDragDropFileviewMasonry // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDragDropFileviewMasonry = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogDragDropFileviewMasonry })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the thing to enable here is drag-and-drop
            text: qsTranslate("filedialog", "enable for bookmarks")
            checkable: true
            checked: PQCSettings.filedialogDragDropPlaces // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDragDropPlaces = checked // qmllint disable unqualified
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
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogElementPadding===modelData // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.filedialogElementPadding = modelData // qmllint disable unqualified
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
                checked: PQCSettings.filedialogLabelsShowGrid // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.filedialogLabelsShowGrid = checked // qmllint disable unqualified
                    checked = Qt.binding(function() { return PQCSettings.filedialogLabelsShowGrid })
                }
            }

            PQMenuItem {
                //: file manager settings popdown: scale and crop the thumbnails
                text: qsTranslate("filedialog", "masonry view")
                checkable: true
                checked: PQCSettings.filedialogLabelsShowMasonry // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.filedialogLabelsShowMasonry = checked // qmllint disable unqualified
                    checked = Qt.binding(function() { return PQCSettings.filedialogLabelsShowMasonry })
                }
            }

        }

        PQMenuItem {
            //: file manager settings popdown: how to select files
            text: qsTranslate("filedialog", "select with single click")
            checkable: true
            checked: PQCSettings.filedialogSingleClickSelect // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogSingleClickSelect = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogSingleClickSelect })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: how to select files
            text: qsTranslate("filedialog", "remember selections")
            checkable: true
            checked: PQCSettings.filedialogRememberSelection // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogRememberSelection = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogRememberSelection })
            }
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "hidden files")
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogShowHiddenFilesFolders = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogShowHiddenFilesFolders })
            }
        }
        PQMenuItem {
            text: qsTranslate("filedialog", "tooltips")
            checkable: true
            checked: PQCSettings.filedialogDetailsTooltip // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDetailsTooltip = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogDetailsTooltip })
            }
        }
        PQMenuItem {
            //: The location here is a folder path
            text: qsTranslate("filedialog", "Remember last location")
            checkable: true
            checked: PQCSettings.filedialogKeepLastLocation // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogKeepLastLocation = checked // qmllint disable unqualified
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
            checked: PQCSettings.filedialogThumbnails // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogThumbnails = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogThumbnails })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop the thumbnails
            text: qsTranslate("filedialog", "scale and crop")
            enabled: thumbnailsshow.checked
            checkable: true
            checked: PQCSettings.filedialogThumbnailsScaleCrop // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogThumbnailsScaleCrop = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogThumbnailsScaleCrop })
            }
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
            checked: PQCSettings.filedialogFolderContentThumbnails // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnails = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnails })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop the folder thumbnails
            text: qsTranslate("filedialog", "scale and crop")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsScaleCrop // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnailsScaleCrop = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnailsScaleCrop })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: automatically load the folder thumbnails
            text: qsTranslate("filedialog", "autoload")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsAutoload // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnailsAutoload = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnailsAutoload })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: loop through the folder thumbnails
            text: qsTranslate("filedialog", "loop")
            enabled: folderthumbshow.checked
            checkable: true
            checked: PQCSettings.filedialogFolderContentThumbnailsLoop // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogFolderContentThumbnailsLoop = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogFolderContentThumbnailsLoop })
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            enabled: false
            moveToRightABit: true
            //: file manager settings popdown: timeout between switching folder thumbnails
            text: qsTranslate("filedialog", "timeout")
        }
        PQMenuItem {
            id: foldthumb2
            enabled: folderthumbshow.checked
            text: "2 seconds"
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===1 // qmllint disable unqualified
            onCheckedChanged: {
                if(checked)
                    PQCSettings.filedialogFolderContentThumbnailsSpeed = 1 // qmllint disable unqualified
            }
            Connections {
                target: PQCSettings // qmllint disable unqualified
                function onFiledialogFolderContentThumbnailsSpeedChanged() {
                    foldthumb2.checked = (PQCSettings.filedialogFolderContentThumbnailsSpeed===1) // qmllint disable unqualified
                }
            }
        }
        PQMenuItem {
            id: foldthumb1
            enabled: folderthumbshow.checked
            text: qsTranslate("filedialog", "1 second")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===2 // qmllint disable unqualified
            onCheckedChanged: {
                if(checked)
                    PQCSettings.filedialogFolderContentThumbnailsSpeed = 2 // qmllint disable unqualified
            }
            Connections {
                target: PQCSettings // qmllint disable unqualified
                function onFiledialogFolderContentThumbnailsSpeedChanged() {
                    foldthumb1.checked = (PQCSettings.filedialogFolderContentThumbnailsSpeed===2) // qmllint disable unqualified
                }
            }
        }
        PQMenuItem {
            id: foldthumb05
            enabled: folderthumbshow.checked
            text: qsTranslate("filedialog", "half a second")
            checkable: true
            checkableLikeRadioButton: true
            checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===3 // qmllint disable unqualified
            onCheckedChanged: {
                if(checked)
                    PQCSettings.filedialogFolderContentThumbnailsSpeed = 3 // qmllint disable unqualified
            }
            Connections {
                target: PQCSettings // qmllint disable unqualified
                function onFiledialogFolderContentThumbnailsSpeedChanged() {
                    foldthumb05.checked = (PQCSettings.filedialogFolderContentThumbnailsSpeed===3) // qmllint disable unqualified
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
            checked: PQCSettings.filedialogPlaces // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogPlaces = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogPlaces })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the devices here are the storage devices
            text: qsTranslate("filedialog", "show devices")
            checkable: true
            checked: PQCSettings.filedialogDevices // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDevices = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogDevices })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: the devices here are the storage devices
            text: qsTranslate("filedialog", "show temporary devices")
            checkable: true
            implicitHeight: visible ? 40 : 0
            visible: !PQCScriptsConfig.amIOnWindows() // qmllint disable unqualified
            checked: PQCSettings.filedialogDevicesShowTmpfs // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogDevicesShowTmpfs = checked // qmllint disable unqualified
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
            checked: PQCSettings.filedialogPreview // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogPreview = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogPreview })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: use higher resolution for image previews
            text: qsTranslate("filedialog", "higher resolution")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewHigherResolution // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogPreviewHigherResolution = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewHigherResolution })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: blur image previews
            text: qsTranslate("filedialog", "blur")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewBlur // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogPreviewBlur = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewBlur })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: mute the colors in image previews
            text: qsTranslate("filedialog", "mute colors")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewMuted // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogPreviewMuted = checked // qmllint disable unqualified
                checked = Qt.binding(function() { return PQCSettings.filedialogPreviewMuted })
            }
        }
        PQMenuItem {
            //: file manager settings popdown: scale and crop image previews
            text: qsTranslate("filedialog", "scale and crop")
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewCropToFit // qmllint disable unqualified
            onCheckedChanged: {
                PQCSettings.filedialogPreviewCropToFit = checked // qmllint disable unqualified
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
                    checkableLikeRadioButton: true
                    checked: Math.round(PQCSettings.filedialogPreviewColorIntensity/10)===(10-modelData) // qmllint disable unqualified
                    onCheckedChanged: {
                        if(checked)
                            PQCSettings.filedialogPreviewColorIntensity = 10*(10-modelData) // qmllint disable unqualified
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
            settings.checked = false // qmllint disable unqualified
    }
}
