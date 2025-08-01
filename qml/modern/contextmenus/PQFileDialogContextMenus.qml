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
import PhotoQt.Modern
import PhotoQt.Shared
import PQCImageFormats

Item {

    id: context_top

    /////////////////////////////////////////////////
    // context menus in here in order:
    //
    // 1. Fileview entry menu
    // 2. Places context menu
    // 3. File types popup (tweaks)
    //
    /////////////////////////////////////////////////

    property int filetypesVisibleItems: 0

    Connections {

        target: PQCNotify

        function onShowFileDialogContextMenu(vis : bool, opts : var) {

            if(opts[0] === "filevvisibleItemsiewentry") {
                fileview_entry_menu.path = opts[1]
                fileview_entry_menu.setCurrentIndexToThisAfterClose = opts[2]
                if(vis)
                    fileview_entry_menu.popup()
                else
                    fileview_entry_menu.close()
            } else if(opts[0] === "fileviewplaces") {
                if(vis)
                    places_menu.popup()
                else
                    places_menu.close()
            } else if(opts[0] === "filedialogtypes") {
                if(vis) {
                    const diff = context_top.filetypesVisibleItems*40
                    var pos = context_top.mapToItem(fullscreenitem, context_top.mapFromGlobal(Qt.point(opts[1].x-265, opts[1].y-diff-PQCConstants.menuBarHeight-PQCConstants.footerHeight)))
                    tweaks_filetypes.popup(pos)
                } else
                    tweaks_filetypes.close()
            }

        }

    }

    PQMenu {

        id: fileview_entry_menu

        property bool isFolder: false
        property bool isFile: false
        property string path: ""

        property bool isCurrentFileSelected: (PQCConstants.filedialogCurrentSelection.indexOf(PQCConstants.filedialogCurrentIndex)!==-1)

        onPathChanged: {
            if(path == "") {
                isFolder = false
                isFile = false
            } else {
                isFolder = PQCScriptsFilesPaths.isFolder(path)
                isFile = !isFolder
            }
        }

        property int setCurrentIndexToThisAfterClose: -1
        onVisibleChanged: {
            if(!visible && setCurrentIndexToThisAfterClose != -2) {
                // view_top.currentIndex = setCurrentIndexToThisAfterClose
                setCurrentIndexToThisAfterClose = -2
            }
        }

        Connections {
            target: PQCConstants
            function onIdOfVisibleItemChanged() {
                if(PQCConstants.idOfVisibleItem !== "filedialog")
                    fileview_entry_menu.close()
            }
        }

        PQMenuItem {
            visible: fileview_entry_menu.isFile
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg"
            // icon.width: height-5
            // icon.height: height-5
            text: qsTranslate("thumbnails","Reload thumbnail")
            onTriggered: {
                PQCScriptsImages.removeThumbnailFor(fileview_entry_menu.path)
                PQCNotify.filedialogReloadCurrentThumbnail()
            }
        }

        PQMenuItem {
            visible: fileview_entry_menu.isFolder
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/folder.svg"
            text: qsTranslate("filedialog", "Open this folder")
            onTriggered: {
                PQCNotify.filedialogLoadNewPath(fileview_entry_menu.path)
            }
        }
        PQMenuItem {
            visible: (PQCConstants.filedialogCurrentSelection.length===1 && fileview_entry_menu.isCurrentFileSelected) || !fileview_entry_menu.isCurrentFileSelected
            enabled: fileview_entry_menu.isFolder && PQCScriptsConfig.isPugixmlSupportEnabled()
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/star.svg"
            text: qsTranslate("filedialog", "Add to Favorites")
            onTriggered: {
                PQCScriptsFileDialog.addPlacesEntry(fileview_entry_menu.path, fd_places.entries_favorites.length)
                PQCNotify.filedialogReloadPlaces()
            }
        }

        PQMenuItem {
            // implicitHeight: visible ? 40 : 0
            visible: PQCConstants.filedialogCurrentSelection.length < 2 || !fileview_entry_menu.isCurrentFileSelected || !menuitemLoadSelection.atLeastOneFolderSelected
            enabled: fileview_entry_menu.isFile || fileview_entry_menu.isFolder
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/folder.svg"
            text: (fileview_entry_menu.isFolder ? qsTranslate("filedialog", "Load content of folder") : qsTranslate("filedialog", "Load this file"))
            onTriggered: {
                PQCFileFolderModel.extraFoldersToLoad = []
                PQCFileFolderModel.fileInFolderMainView = fileview_entry_menu.path
                PQCNotify.filedialogClose()
            }
        }

        PQMenuItem {
            id: menuItemLoadSelection
            // implicitHeight: visible ? 40 : 0
            visible: (PQCConstants.filedialogCurrentSelection.length>1 && (fileview_entry_menu.isCurrentFileSelected || (!fileview_entry_menu.isFile && !fileview_entry_menu.isFolder))) && atLeastOneFolderSelected
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/folder.svg"
            text: (atLeastOneFolderSelected&&atLeastOneFileSelected) ? qsTranslate("filedialog", "Load all selected files/folders") : qsTranslate("filedialog", "Load all selected folders")
            // THis menu item is only visible if at least one folder is visible
            // If only files are selected we will load the current folder anyways
            property bool atLeastOneFolderSelected: false
            property bool atLeastOneFileSelected: false
            Connections {
                target: PQCConstants
                function onFiledialogCurrentSelectionChanged() {
                    var havefolder = false
                    var havefile = false
                    for(var i in PQCConstants.filedialogCurrentSelection) {
                        var cur = PQCFileFolderModel.entriesFileDialog[PQCConstants.filedialogCurrentSelection[i]]
                        if(PQCScriptsFilesPaths.isFolder(cur)) {
                            havefolder = true
                        } else {
                            havefile = true
                        }
                        // we found as much as we can find -> can stop now
                        if(havefile && havefolder)
                            break
                    }
                    menuItemLoadSelection.atLeastOneFolderSelected = havefolder
                    menuItemLoadSelection.atLeastOneFileSelected = havefile
                }
            }

            onTriggered: {
                var allfiles = []
                var allfolders = []
                for(var i in PQCConstants.filedialogCurrentSelection) {
                    var cur = PQCFileFolderModel.entriesFileDialog[PQCConstants.filedialogCurrentSelection[i]]
                    if(PQCScriptsFilesPaths.isFolder(cur))
                        allfolders.push(cur)
                    else
                        allfiles.push(cur)
                }

                var comb = allfiles.concat(allfolders)

                if(comb.length > 0) {

                    var f = comb.shift()

                    PQCFileFolderModel.extraFoldersToLoad = comb
                    PQCFileFolderModel.fileInFolderMainView = f
                    PQCNotify.filedialogClose()

                }
            }
        }

        PQMenuSeparator { }

        PQMenuItem {
            enabled: fileview_entry_menu.isFile || fileview_entry_menu.isFolder
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/select.svg"
            text: fileview_entry_menu.isCurrentFileSelected ? qsTranslate("filedialog", "Remove file selection") : qsTranslate("filedialog", "Select file")
            onTriggered: {
                if(fileview_entry_menu.isCurrentFileSelected) {
                    PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==PQCConstants.filedialogCurrentIndex)
                } else {
                    PQCConstants.filedialogCurrentSelection.push(PQCConstants.filedialogCurrentIndex)
                    PQCConstants.filedialogCurrentSelectionChanged()
                }
            }
        }
        PQMenuItem {
            text: fileview_entry_menu.isCurrentFileSelected ? qsTranslate("filedialog", "Remove all file selection") : qsTranslate("filedialog", "Select all files")
            onTriggered: {
                PQCNotify.filedialogSelectAll(!fileview_entry_menu.isCurrentFileSelected)
            }
        }
        PQMenuSeparator { }
        PQMenuItem {
            // implicitHeight: visible ? 40 : 0
            visible: !PQCScriptsConfig.amIOnWindows()
            enabled: visible && (fileview_entry_menu.isFile || fileview_entry_menu.isFolder || PQCConstants.filedialogCurrentSelection.length)
            font.weight: PQCConstants.shiftKeyPressed ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg"
            text: (fileview_entry_menu.isCurrentFileSelected || (!fileview_entry_menu.isFile && !fileview_entry_menu.isFolder && PQCConstants.filedialogCurrentSelection.length))
                        ? (PQCConstants.shiftKeyPressed ? qsTranslate("filedialog", "Delete selection permanently") : qsTranslate("filedialog", "Delete selection"))
                        : (fileview_entry_menu.isFile ? (PQCConstants.shiftKeyPressed ? qsTranslate("filedialog", "Delete file permanently") : qsTranslate("filedialog", "Delete file"))
                                              : (fileview_entry_menu.isFolder ? (PQCConstants.shiftKeyPressed ? qsTranslate("filedialog", "Delete folder permanently") : qsTranslate("filedialog", "Delete folder"))
                                                                      : (PQCConstants.shiftKeyPressed ? qsTranslate("filedialog", "Delete file/folder permanently") : qsTranslate("filedialog", "Delete file/folder"))))
            onTriggered:
                PQCNotify.filedialogDeleteFiles()
        }
        PQMenuItem {
            enabled: (fileview_entry_menu.isFile || fileview_entry_menu.isFolder || PQCConstants.filedialogCurrentSelection.length)
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/cut.svg"
            text: (fileview_entry_menu.isCurrentFileSelected || (!fileview_entry_menu.isFile && !fileview_entry_menu.isFolder && PQCConstants.filedialogCurrentSelection.length))
                        ? qsTranslate("filedialog", "Cut selection")
                        : (fileview_entry_menu.isFile ? qsTranslate("filedialog", "Cut file")
                                              : (fileview_entry_menu.isFolder ? qsTranslate("filedialog", "Cut folder")
                                                                      : qsTranslate("filedialog", "Cut file/folder")))
            onTriggered:
                PQCNotify.filedialogCutFiles(false)
        }
        PQMenuItem {
            enabled: (fileview_entry_menu.isFile || fileview_entry_menu.isFolder || PQCConstants.filedialogCurrentSelection.length)
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
            text: (fileview_entry_menu.isCurrentFileSelected || (!fileview_entry_menu.isFile && !fileview_entry_menu.isFolder && PQCConstants.filedialogCurrentSelection.length))
                        ? qsTranslate("filedialog", "Copy selection")
                        : (fileview_entry_menu.isFile ? qsTranslate("filedialog", "Copy file")
                                              : (fileview_entry_menu.isFolder ? qsTranslate("filedialog", "Copy folder")
                                                                      : qsTranslate("filedialog", "Copy file/folder")))
            onTriggered:
                PQCNotify.filedialogCopyFiles(false)
        }
        PQMenuItem {
            id: menuItem_paste
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg"
            text: qsTranslate("filedialog", "Paste files from clipboard")
            onTriggered:
                PQCNotify.filedialogPasteFiles()

            Component.onCompleted: {
                enabled = PQCScriptsClipboard.areFilesInClipboard()
            }
            Connections {
                target: PQCScriptsClipboard
                function onClipboardUpdated() {
                    menuItem_paste.enabled = PQCScriptsClipboard.areFilesInClipboard()
                }
            }
        }

        PQMenuSeparator { }

        PQMenuItem {
            text: PQCSettings.filedialogShowHiddenFilesFolders ? qsTranslate("filedialog", "Hide hidden files") : qsTranslate("filedialog", "Show hidden files")
            onTriggered:
                PQCSettings.filedialogShowHiddenFilesFolders = checked
        }
        PQMenuItem {
            text: PQCSettings.filedialogDetailsTooltip ? qsTranslate("filedialog", "Hide tooltip with image details") : qsTranslate("filedialog", "Show tooltip with image details")
            onTriggered:
                PQCSettings.filedialogDetailsTooltip = checked
        }

        onAboutToHide: {
            recordAsClosed.restart()
        }
        onAboutToShow: {
            PQCConstants.addToWhichContextMenusOpen("fileviewentry")
        }

        Timer {
            id: recordAsClosed
            interval: 200
            onTriggered: {
                if(!fileview_entry_menu.visible)
                    PQCConstants.removeFromWhichContextMenusOpen("fileviewentry")
            }
        }

    }

    /************************************************************/
    /************************************************************/

    PQMenu {

        id: places_menu

        PQMenuItem {
            id: entry1
            visible: PQCConstants.filedialogPlacesCurrentEntryId!==""
            text: (PQCConstants.filedialogPlacesCurrentEntryHidden==="true" ? qsTranslate("filedialog", "Show entry") : qsTranslate("filedialog", "Hide entry"))
            states: [
                State {
                    when: PQCConstants.filedialogPlacesCurrentEntryId===""
                    PropertyChanges {
                        entry1.height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.hidePlacesEntry(PQCConstants.filedialogPlacesCurrentEntryId, PQCConstants.filedialogPlacesCurrentEntryHidden==="false")
                PQCNotify.filedialogReloadPlaces()
            }
        }

        PQMenuItem {
            id: entry2
            visible: PQCConstants.filedialogPlacesCurrentEntryId!==""
            text: (qsTranslate("filedialog", "Remove entry"))
            states: [
                State {
                    when: PQCConstants.filedialogPlacesCurrentEntryId===""
                    PropertyChanges {
                        entry2.height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.deletePlacesEntry(PQCConstants.filedialogPlacesCurrentEntryId)
                PQCNotify.filedialogReloadPlaces()
            }
        }

        PQMenuItem {
            id: entry3
            visible: PQCConstants.filedialogPlacesCurrentEntryId!==""
            text: (PQCConstants.filedialogPlacesShowHidden ? (qsTranslate("filedialog", "Hide hidden entries")) : (qsTranslate("filedialog", "Show hidden entries")))
            states: [
                State {
                    when: PQCConstants.filedialogPlacesCurrentEntryId===""
                    PropertyChanges {
                        entry3.height: 0
                    }
                }
            ]
            onTriggered:
                PQCConstants.filedialogPlacesShowHidden = !PQCConstants.filedialogPlacesShowHidden
        }

        PQMenuSeparator { visible: PQCConstants.filedialogPlacesCurrentEntryId!=="" }

        PQMenuItem {
            text: (PQCSettings.filedialogPlaces ? (qsTranslate("filedialog", "Hide bookmarked places")) : (qsTranslate("filedialog", "Show bookmarked places")))
            onTriggered:
                PQCSettings.filedialogPlaces = !PQCSettings.filedialogPlaces
        }

        PQMenuItem {
            text: (PQCSettings.filedialogDevices ? (qsTranslate("filedialog", "Hide storage devices")) : (qsTranslate("filedialog", "Show storage devices")))
            onTriggered:
                PQCSettings.filedialogDevices = !PQCSettings.filedialogDevices
        }

        onAboutToShow: {
            PQCConstants.addToWhichContextMenusOpen("fileviewplaces")
        }

        onAboutToHide: {
            PQCConstants.removeFromWhichContextMenusOpen("fileviewplaces")
        }

    }

    /************************************************************/
    /************************************************************/

    PQMenu {

        id: tweaks_filetypes
        width: 300

        onAboutToShow: {
            PQCConstants.addToWhichContextMenusOpen("filedialogtypes")
        }

        onAboutToHide: {
            resetTypesMenu.restart()
        }
        Timer {
            id: resetTypesMenu
            interval: 300
            onTriggered:
                PQCConstants.removeFromWhichContextMenusOpen("filedialogtypes")
        }

        PQMenuItem {
            id: chk_all
            checkable: true
            checked: true
            text: qsTranslate("filedialog", "All supported images")
            onCheckedChanged: {
                if(checked)
                    tweaks_filetypes.checkAll()
            }
            Component.onCompleted: context_top.filetypesVisibleItems += 1
        }

        PQMenuSeparator {}

        PQMenuItem {
            id: chk_qt
            checkable: true
            checked: true
            text: "Qt"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("qt")
            Component.onCompleted: context_top.filetypesVisibleItems += 1
        }

        PQMenuItem {
            id: chk_magick
            checkable: true
            checked: true
            implicitHeight: isSupported ? 40 : 0
            property bool isSupported: PQCScriptsConfig.isImageMagickSupportEnabled()||PQCScriptsConfig.isGraphicsMagickSupportEnabled()
            visible: isSupported
            text: (PQCScriptsConfig.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick")
            onCheckedChanged:
                tweaks_filetypes.checkChecked("magick")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_libraw
            checkable: true
            checked: true
            implicitHeight: isSupported ? 40 : 0
            property bool isSupported: PQCScriptsConfig.isLibRawSupportEnabled()
            visible: isSupported
            text: "LibRaw"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("libraw")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_devil
            checkable: true
            checked: true
            implicitHeight: isSupported ? 40 : 0
            property bool isSupported: PQCScriptsConfig.isDevILSupportEnabled()
            visible: isSupported
            text: "DevIL"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("devil")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_freeimage
            checkable: true
            checked: true
            implicitHeight: isSupported ? 40 : 0
            property bool isSupported: PQCScriptsConfig.isFreeImageSupportEnabled()
            visible: isSupported
            text: "FreeImage"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("freeimage")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_libvips
            checkable: true
            checked: true
            implicitHeight: isSupported ? 40 : 0
            property bool isSupported: PQCScriptsConfig.isLibVipsSupportEnabled()
            visible: isSupported
            text: "LibVips"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("libvips")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_libarchive
            checkable: true
            checked: true
            implicitHeight: isSupported ? 40 : 0
            property bool isSupported: PQCScriptsConfig.isLibArchiveSupportEnabled()
            visible: isSupported
            text: "LibArchive"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("libarchive")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_pdf
            checkable: true
            checked: true
            property bool isSupported: PQCScriptsConfig.isPDFSupportEnabled()
            visible: isSupported
            text: "PDF/PS"
            onCheckedChanged:
                tweaks_filetypes.checkChecked("pdf")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)
        }

        PQMenuItem {
            id: chk_video
            checkable: true
            checked: true
            property bool isSupported: PQCScriptsConfig.isMPVSupportEnabled()||PQCScriptsConfig.isVideoQtSupportEnabled()
            visible: isSupported
            implicitHeight: isSupported ? 40 : 0
            text: qsTranslate("filedialog", "Video files")
            onCheckedChanged:
                tweaks_filetypes.checkChecked("video")
            onIsSupportedChanged: context_top.filetypesVisibleItems += (isSupported ? 1 : -1)

        }

        function countChecked() {
            var ret = 0
            var maxchk = 0
            if(chk_qt.visible) {
                maxchk += 1
                if(chk_qt.checked)
                    ret += 1
            }
            if(chk_magick.visible) {
                maxchk += 1
                if(chk_magick.checked)
                    ret += 1
            }
            if(chk_libraw.visible) {
                maxchk += 1
                if(chk_libraw.checked)
                    ret += 1
            }
            if(chk_devil.visible) {
                maxchk += 1
                if(chk_devil.checked)
                    ret += 1
            }
            if(chk_freeimage.visible) {
                maxchk += 1
                if(chk_freeimage.checked)
                    ret += 1
            }
            if(chk_libvips.visible) {
                maxchk += 1
                if(chk_libvips.checked)
                    ret += 1
            }
            if(chk_libarchive.visible) {
                maxchk += 1
                if(chk_libarchive.checked)
                    ret += 1
            }
            if(chk_pdf.visible) {
                maxchk += 1
                if(chk_pdf.checked)
                    ret += 1
            }
            if(chk_video.visible) {
                maxchk += 1
                if(chk_video.checked)
                    ret += 1
            }
            return [ret, maxchk]
        }

        function checkChecked(src : string) {

            var situation = countChecked()
            var numChecked = situation[0]
            var maxChecked = situation[1]

            if(numChecked === maxChecked)
                chk_all.checked = true
            else
                chk_all.checked = false

            if(numChecked === 0) {
                if(src === "qt")
                    chk_qt.checked = true
                else if(src === "magick")
                    chk_magick.checked = true
                else if(src === "libraw")
                    chk_libraw.checked = true
                else if(src === "devil")
                    chk_devil.checked = true
                else if(src === "freeimage")
                    chk_freeimage.checked = true
                else if(src === "libvips")
                    chk_libvips.checked = true
                else if(src === "libarchive")
                    chk_libarchive.checked = true
                else if(src === "pdf")
                    chk_pdf.checked = true
                else if(src === "video")
                    chk_video.checked = true
            }

            applyChanges.restart()

        }

        function checkAll() {
            chk_qt.checked = true
            if(chk_magick.visible)
                chk_magick.checked = true
            if(chk_libraw.visible)
                chk_libraw.checked = true
            if(chk_devil.visible)
                chk_devil.checked = true
            if(chk_freeimage.visible)
                chk_freeimage.checked = true
            if(chk_libvips.visible)
                chk_libvips.checked = true
            if(chk_libarchive.visible)
                chk_libarchive.checked = true
            if(chk_pdf.visible)
                chk_pdf.checked = true
            if(chk_video.visible)
                chk_video.checked = true
            applyChanges.restart()
        }

        Component.onCompleted:
            applyChanges.triggered()

        Timer {
            id: applyChanges
            interval: 50
            onTriggered: {

                if(chk_all.checked) {

                    PQCNotify.filedialogTweaksSetFiletypesButtonText(qsTranslate("filedialog", "All supported images"))

                    PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormats()
                    PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypes()

                } else {

                    var txts = []

                    var suffixes = []
                    var mimetypes = []

                    if(chk_qt.checked) {
                        txts.push("Qt")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsQt())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesQt())
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsResvg())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesResvg())
                    }
                    if(chk_magick.checked) {
                        if(PQCScriptsConfig.isImageMagickSupportEnabled())
                            txts.push("ImageMagick")
                        else
                            txts.push("GraphicsMagick")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsMagick())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesMagick())
                    }
                    if(chk_libraw.checked) {
                        txts.push("LibRaw")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibRaw())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibRaw())
                    }
                    if(chk_devil.checked) {
                        txts.push("DevIL")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsDevIL())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesDevIL())
                    }
                    if(chk_freeimage.checked) {
                        txts.push("FreeImage")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsFreeImage())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesFreeImage())
                    }
                    if(chk_libvips.checked) {
                        txts.push("LibVips")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibVips())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibVips())
                    }
                    if(chk_libarchive.checked) {
                        txts.push("LibArchive")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibArchive())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibArchive())
                    }
                    if(chk_pdf.checked) {
                        txts.push("PDF/PS")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsPoppler())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesPoppler())
                    }
                    if(chk_video.checked) {
                        txts.push("Video")
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsVideo())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesVideo())
                        suffixes = suffixes.concat(PQCImageFormats.getEnabledFormatsLibmpv())
                        mimetypes = mimetypes.concat(PQCImageFormats.getEnabledMimeTypesLibmpv())
                    }

                    var situation = tweaks_filetypes.countChecked()
                    if(situation[0] === situation[1])
                        PQCNotify.filedialogTweaksSetFiletypesButtonText(qsTranslate("filedialog", "All supported images"))
                    else
                        PQCNotify.filedialogTweaksSetFiletypesButtonText(txts.join(", "))

                    PQCFileFolderModel.restrictToSuffixes = suffixes
                    PQCFileFolderModel.restrictToMimeTypes = mimetypes

                }

            }
        }


    }

}
