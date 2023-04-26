/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 1.4
import "../../elements"
import "../../modal"

PQMenu {

    id: control

    property bool isFolder: false
    property bool isFile: false
    property string path: ""

    signal closed()

    MenuItem {
        visible: isFile || isFolder
        text: (isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file"))
        onTriggered: {
            if(isFolder)
                filedialog_top.setCurrentDirectory(path)
            else {
                filefoldermodel.setFileNameOnceReloaded = path
                filefoldermodel.fileInFolderMainView = path
                filedialog_top.hideFileDialog()
            }
        }
    }
    MenuItem {
        visible: isFolder
        text: (em.pty+qsTranslate("filedialog", "Add to Favorites"))
        onTriggered:
            handlingFileDialog.addNewUserPlacesEntry(path, upl.model.count)
    }
    MenuSeparator { visible: isFile || isFolder }
    MenuItem {
        visible: isFile || isFolder
        text: fileview.isCurrentFileSelected() ? qsTranslate("filedialog", "Remove file selection") : qsTranslate("filedialog", "Select file")
        onTriggered: {
            fileview.toggleCurrentFileSelection()
        }
    }
    MenuItem {
        text: fileview.isCurrentFileSelected() ? qsTranslate("filedialog", "Remove all file selection") : qsTranslate("filedialog", "Select all files")
        onTriggered: {
            fileview.setFilesSelection(!fileview.isCurrentFileSelected())
        }
    }
    MenuSeparator { }
    MenuItem {
        enabled: (isFile || isFolder || fileview.anyFilesSelected())
        text: fileview.isCurrentFileSelected() ? qsTranslate("filedialog", "Delete all selected files/folders") : (isFile ? qsTranslate("filedialog", "Delete this file") : (isFolder ? qsTranslate("filedialog", "Delete this folder") : qsTranslate("filedialog", "Delete this file/folder")))
        onTriggered: {
            confirmDelete.open()
            files_grid.selectedFiles = ({})
        }
    }
    MenuItem {
        text: fileview.anyFilesSelected() ? qsTranslate("filedialog", "Cut selection") : (isFile ? qsTranslate("filedialog", "Cut file") : (isFolder ? qsTranslate("filedialog", "Cut folder") : qsTranslate("filedialog", "Cut file/folder")))
        onTriggered: {
            if(fileview.anyFilesSelected()) {
                var urls = []
                for (const [key, value] of Object.entries(fileview.selectedFiles)) {
                    if(value == 1)
                        urls.push(filefoldermodel.entriesFileDialog[key])
                }
                handlingExternal.copyFilesToClipboard(urls)
                // this has to come AFTER copying files to clipboard as this resets the cutFiles variable at first
                fileview.cutFilesTimestamp = handlingGeneral.getTimestamp()
                fileview.cutFiles = urls
            } else {
                handlingExternal.copyFilesToClipboard([path])
                // this has to come AFTER copying files to clipboard as this resets the cutFiles variable at first
                fileview.cutFilesTimestamp = handlingGeneral.getTimestamp()
                fileview.setCurrentFileCut()
            }
        }
    }
    MenuItem {
        enabled: (isFile || isFolder || fileview.anyFilesSelected())
        text: fileview.anyFilesSelected() ? qsTranslate("filedialog", "Copy selection") : (isFile ? qsTranslate("filedialog", "Copy file") : (isFolder ? qsTranslate("filedialog", "Copy folder") : qsTranslate("filedialog", "Copy file/folder")))
        onTriggered: {
            fileview.cutFiles = []
            if(fileview.anyFilesSelected()) {
                var urls = []
                for (const [key, value] of Object.entries(fileview.selectedFiles)) {
                    if(value == 1)
                        urls.push(filefoldermodel.entriesFileDialog[key])
                }
                handlingExternal.copyFilesToClipboard(urls)
            } else {
                handlingExternal.copyFilesToClipboard([path])
            }
        }
    }
    MenuItem {
        id: item_paste
        text: qsTranslate("filedialog", "Paste files from clipboard")
        onTriggered: {

            var lst = handlingExternal.getListOfFilesInClipboard()

            var nonexisting = []
            var existing = []

            for(var l in lst) {
                if(handlingFileDir.doesItExist(filefoldermodel.folderFileDialog + "/" + handlingFileDir.getFileNameFromFullPath(lst[l])))
                    existing.push(lst[l])
                else
                    nonexisting.push(lst[l])
            }

            if(existing.length > 0) {
                confirmCopy.files = existing
                confirmCopy.clearCutFilesAtEnd = (nonexisting.length == 0)
                confirmCopy.open()
            }

            if(nonexisting.length > 0) {
                for(var f in nonexisting) {
                    if(handlingFileDir.copyFileToHere(nonexisting[f], filefoldermodel.folderFileDialog)) {
                        if(fileview.cutFiles.indexOf(nonexisting[f]) != -1)
                            handlingFileDir.deleteFile(nonexisting[f], true)
                    }
                }
                if(existing.length == 0)
                    fileview.cutFiles = []
            }

            if(existing.length == 0 && nonexisting.length == 0)
                informUser.informUser("Nothing found", "There are no files/folders in the clipboard.")


        }

        Component.onCompleted: {
            item_paste.enabled = handlingExternal.areFilesInClipboard()
        }
    }
    Connections {
        target: handlingExternal
        onChangedClipboardData: {
            item_paste.enabled = handlingExternal.areFilesInClipboard()
        }
    }

    MenuSeparator { }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileShowHiddenFilesFolders
        text: qsTranslate("filedialog", "Show hidden files")
        onTriggered:
            PQSettings.openfileShowHiddenFilesFolders = !PQSettings.openfileShowHiddenFilesFolders
    }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileThumbnails
        text: qsTranslate("filedialog", "Show thumbnails")
        onTriggered:
            PQSettings.openfileThumbnails = !PQSettings.openfileThumbnails
    }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileDetailsTooltip
        text: qsTranslate("filedialog", "Show tooltip with image details")
        onTriggered:
            PQSettings.openfileDetailsTooltip = !PQSettings.openfileDetailsTooltip
    }
    PQMenu {
        title: qsTranslate("filedialog", "Folder content thumbnails")
        MenuItem {
            checkable: true
            checked: PQSettings.openfileFolderContentThumbnails
            text: qsTranslate("filedialog", "Show rotating thumbnails")
            onTriggered:
                PQSettings.openfileFolderContentThumbnails = !PQSettings.openfileFolderContentThumbnails
        }
        MenuItem {
            checkable: true
            checked: PQSettings.openfileFolderContentThumbnailsAlwaysLoadFirst
            //: The first one refers to the first image thumbnail of the folder content
            text: qsTranslate("filedialog", "Always load the first thumbnail")
            onTriggered:
                PQSettings.openfileFolderContentThumbnailsAlwaysLoadFirst = !PQSettings.openfileFolderContentThumbnailsAlwaysLoadFirst
        }
        PQMenu {
            id: speed_submenu
            title: em.pty+qsTranslate("filedialog", "Speed")
            ExclusiveGroup { id: exlspeed }

            Instantiator {
                model: 3
                MenuItem {
                    checkable: true
                    exclusiveGroup: exlspeed
                    checked: PQSettings.openfileFolderContentThumbnailsSpeed==(index+1)
                    text: index==0 ?
                              em.pty+qsTranslate("filedialog", "2 seconds") :
                              (index==1 ?
                                   em.pty+qsTranslate("filedialog", "1 second") :
                                   em.pty+qsTranslate("filedialog", "half a second"))

                    onTriggered:
                        PQSettings.openfileFolderContentThumbnailsSpeed = index+1
                }
                onObjectAdded: speed_submenu.insertItem(index, object)
                onObjectRemoved: speed_submenu.removeItem(object)
            }

        }
    }
    PQMenu {
        //: The preview is the large preview image shown in the back of the file dialog
        title: qsTranslate("filedialog", "Preview")
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreview
            //: This is a context menu entry, referring to whether the large preview image is VISIBLE
            text: em.pty+qsTranslate("filedialog", "Visible")
            onTriggered:
                PQSettings.openfilePreview = !PQSettings.openfilePreview
        }
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreviewHigherResolution
            //: This is a context menu entry, referring to whether a preview image with a HIGHER RESOLUTION should be loaded
            text: em.pty+qsTranslate("filedialog", "Higher resolution")
            onTriggered:
                PQSettings.openfilePreviewHigherResolution = !PQSettings.openfilePreviewHigherResolution
        }
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreviewBlur
            //: This is a context menu entry, selecting it will BLUR the preview IMAGE
            text: em.pty+qsTranslate("filedialog", "Blurred image")
            onTriggered:
                PQSettings.openfilePreviewBlur = !PQSettings.openfilePreviewBlur
        }
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreviewCropToFit
            //: This is a context menu entry, selecting it will crop the preview image to make it fit the available space
            text: em.pty+qsTranslate("filedialog", "Scale and crop")
            onTriggered:
                PQSettings.openfilePreviewCropToFit = !PQSettings.openfilePreviewCropToFit
        }
        PQMenu {
            id: colint_submenu
            title: em.pty+qsTranslate("filedialog", "Color intensity")
            ExclusiveGroup { id: exl }

            Instantiator {
                model: 10
                MenuItem {
                    checkable: true
                    exclusiveGroup: exl
                    checked: PQSettings.openfilePreviewColorIntensity==(10-index)
                    text: (10*(10-index))+"%"
                    onTriggered:
                        PQSettings.openfilePreviewColorIntensity = 10-index
                }
                onObjectAdded: colint_submenu.insertItem(index, object)
                onObjectRemoved: colint_submenu.removeItem(object)
            }

        }
    }

    PQModalConfirm {
        id: confirmDelete
        text: qsTranslate("filedialog", "Are you sure you want to move all selected files/folders to the trash?")
        informativeText: ""
        onConfirmedChanged: {
            if(confirmed) {
                if(fileview.isCurrentFileSelected()) {
                    for (const [key, value] of Object.entries(fileview.selectedFiles)) {
                        if(value == 1)
                            handlingFileDir.deleteFile(filefoldermodel.entriesFileDialog[key], false)
                    }
                } else
                    handlingFileDir.deleteFile(path, false)
            }
        }
    }

    PQModalConfirm {
        id: confirmCopy
        text: qsTranslate("filedialog", "Some files already exist in the current directory.")
        informativeText: "Do you want to overwrite the existing files?"
        property var files: []
        property bool clearCutFilesAtEnd: false
        onConfirmedChanged: {
            if(confirmed) {
                for(var f in files) {
                    handlingFileDir.copyFileToHere(files[f], filefoldermodel.folderFileDialog)
                    if(fileview.cutFiles.indexOf(files[f]) != -1)
                        handlingFileDir.deleteFile(files[f], true)
                }
                if(clearCutFilesAtEnd)
                    fileview.cutFiles = []
            }
        }
    }

    PQModalInform {
        id: informUser
    }

}
