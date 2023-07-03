import QtQuick
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
        title: "View"
        PQMenu {
            title: "layout"
            PQMenuItem {
                text: "list view"
                checkable: true
                checkableLikeRadioButton: true
                checked: PQCSettings.filedialogDefaultView==="list"
                onTriggered:
                    PQCSettings.filedialogDefaultView = "list"
            }
            PQMenuItem {
                text: "icon view"
                checkable: true
                checkableLikeRadioButton: true
                checked: PQCSettings.filedialogDefaultView==="icons"
                onTriggered:
                    PQCSettings.filedialogDefaultView = "icons"
            }
        }
        PQMenu {
            id: paddingsubmenu
            title: "padding"
            Instantiator {
                model: 10
                delegate: PQMenuItem {
                    text: modelData+1 + " px"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogElementPadding===modelData+1
                    onTriggered:
                        PQCSettings.filedialogElementPadding = modelData+1
                }
                onObjectAdded: (index, object) => paddingsubmenu.insertItem(index, object)
                onObjectRemoved: (index, object) => paddingsubmenu.removeItem(object)
            }
        }

        PQMenuItem {
            text: "hidden files"
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders
            onCheckedChanged:
                PQCSettings.filedialogShowHiddenFilesFolders = checked
        }
        PQMenuItem {
            text: "tooltips"
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders
            onCheckedChanged:
                PQCSettings.filedialogShowHiddenFilesFolders = checked
        }
    }
    PQMenu {
        title: "Thumbnails"
        PQMenuItem {
            id: thumbnailsshow
            text: "show"
            checkable: true
            checked: PQCSettings.filedialogThumbnails
            onCheckedChanged:
                PQCSettings.filedialogThumbnails = checked
        }
        PQMenuItem {
            text: "scale and crop"
            enabled: thumbnailsshow.checked
            checkable: true
            checked: PQCSettings.filedialogThumbnailsScaleCrop
            onCheckedChanged:
                PQCSettings.filedialogThumbnailsScaleCrop = checked
        }
        PQMenu {
            title: "folder thumbnails"

            PQMenuItem {
                id: folderthumbshow
                text: "show"
                checkable: true
                checked: PQCSettings.filedialogFolderContentThumbnails
                onCheckedChanged:
                    PQCSettings.filedialogFolderContentThumbnails = checked
            }
            PQMenuItem {
                text: "scale and crop"
                enabled: folderthumbshow.checked
                checkable: true
                checked: PQCSettings.filedialogFolderContentThumbnailsScaleCrop
                onCheckedChanged:
                    PQCSettings.filedialogFolderContentThumbnailsScaleCrop = checked
            }
            PQMenuItem {
                text: "autoload"
                enabled: folderthumbshow.checked
                checkable: true
                checked: PQCSettings.filedialogFolderContentThumbnailsAutoload
                onCheckedChanged:
                    PQCSettings.filedialogFolderContentThumbnailsAutoload = checked
            }
            PQMenuItem {
                text: "loop"
                enabled: folderthumbshow.checked
                checkable: true
                checked: PQCSettings.filedialogFolderContentThumbnailsLoop
                onCheckedChanged:
                    PQCSettings.filedialogFolderContentThumbnailsLoop = checked
            }
            PQMenu {
                title: "timeout"
                enabled: folderthumbshow.checked
                PQMenuItem {
                    text: "2 seconds"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===1
                    onTriggered:
                        PQCSettings.filedialogFolderContentThumbnailsSpeed = 1
                }
                PQMenuItem {
                    text: "1 second"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===2
                    onTriggered:
                        PQCSettings.filedialogFolderContentThumbnailsSpeed = 2
                }
                PQMenuItem {
                    text: "half a second"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogFolderContentThumbnailsSpeed===3
                    onTriggered:
                        PQCSettings.filedialogFolderContentThumbnailsSpeed = 3
                }
            }
        }
    }
    PQMenu {
        title: "Bookmarks"
        PQMenuItem {
            text: "show bookmarks"
            checkable: true
            checked: PQCSettings.filedialogPlaces
            onCheckedChanged:
                PQCSettings.filedialogPlaces = checked
        }
        PQMenuItem {
            text: "show devices"
            checkable: true
            checked: PQCSettings.filedialogDevices
            onCheckedChanged:
                PQCSettings.filedialogDevices = checked
        }
    }
    PQMenu {
        title: "Preview"
        PQMenuItem {
            id: previewshow
            text: "show"
            checkable: true
            checked: PQCSettings.filedialogPreview
            onCheckedChanged:
                PQCSettings.filedialogPreview = checked
        }
        PQMenuItem {
            text: "higher resolution"
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewHigherResolution
            onCheckedChanged:
                PQCSettings.filedialogPreviewHigherResolution = checked
        }
        PQMenuItem {
            text: "blur"
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewBlur
            onCheckedChanged:
                PQCSettings.filedialogPreviewBlur = checked
        }
        PQMenuItem {
            text: "scale and crop"
            enabled: previewshow.checked
            checkable: true
            checked: PQCSettings.filedialogPreviewCropToFit
            onCheckedChanged:
                PQCSettings.filedialogPreviewCropToFit = checked
        }
        PQMenu {
            id: coloritensitysubmenu
            title: "color intensity"
            enabled: previewshow.checked
            Instantiator {
                model: 10
                delegate: PQMenuItem {
                    text: (10-index)*10 + "%"
                    checkable: true
                    checkableLikeRadioButton: true
                    checked: PQCSettings.filedialogPreviewColorIntensity===(10-index)
                    onTriggered:
                        PQCSettings.filedialogPreviewColorIntensity = (10-index)
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
