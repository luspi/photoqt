/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

Item {

    id: view_top

    y: 1
    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height-2

    onWidthChanged:
        PQCConstants.filedialogFileviewWidth = width

    // select/cut
    property int shiftClickIndexStart: -1
    property list<string> currentCuts: []
    property bool currentFileSelected: (PQCConstants.filedialogCurrentSelection.indexOf(currentIndex)!==-1)
    property bool currentFileCut: (currentCuts.indexOf(currentIndex)!==-1)
    property bool ignoreMouseEvents: false
    property list<string> navigateToFileStartingWith: []

    property int currentIndex: -1
    onCurrentIndexChanged: {
        view_top.currentIndex = currentIndex
        if(currentIndex !== getCurrentViewId().currentIndex)
            getCurrentViewId().currentIndex = currentIndex
    }

    // properties
    property bool currentFolderExcluded: false
    property bool currentFolderOnNetwork: false
    property int currentFolderThumbnailIndex: -1
    property string storeCurrentFolderName: ""
    property var cacheSelection: ({})

    signal refreshCurrentThumbnail()

    property var storeMouseClicks: ({})

    onIgnoreMouseEventsChanged: {
        if(ignoreMouseEvents)
            resetIgnoreMouseEvents.restart()
    }

    onVisibleChanged: {
        if(!visible)
            fileview_entry_menu.close()
    }

    /*********************************************************************/

    PQFileViewList {

        id: listfileview

        onIsCurrentViewChanged: {
            if(isCurrentView)
                view_top.setupNewData()
            else
                model = 0
        }

    }

    PQFileViewGrid {

        id: gridfileview

        ignoreMouseEvents: view_top.ignoreMouseEvents

        onIsCurrentViewChanged: {
            if(isCurrentView)
                view_top.setupNewData()
            else
                model = 0
        }

    }

    PQFileViewMasonry {

        id: masonryfileview

        onIsCurrentViewChanged: {
            if(isCurrentView) {
                view_top.setupNewData()
            } else
                model = 0
        }

    }

    PinchHandler {

        target: null

        onScaleChanged: (delta) => {
            var newval = Math.round(PQCSettings.filedialogZoom*delta)
            if(newval !== PQCSettings.filedialogZoom)
                PQCSettings.filedialogZoom = newval
        }

    }

    function getCurrentViewId() : var {
        if(PQCSettings.filedialogLayout === "grid")
            return gridfileview
        else if(PQCSettings.filedialogLayout === "list")
            return listfileview
        else if(PQCSettings.filedialogLayout === "masonry")
            return masonryfileview

        console.warn("ERROR! I don't know which view is supposed to be active... using listview")
        PQCSettings.filedialogLayout = "list"
        return listfileview
    }


    PQMenu {

        id: fileview_entry_menu

        property bool isFolder: false
        property bool isFile: false
        property string path: ""

        property bool isCurrentFileSelected: (PQCConstants.filedialogCurrentSelection.indexOf(view_top.currentIndex)!==-1)

        onPathChanged: {
            if(path == "") {
                isFolder = false
                isFile = false
            } else {
                isFolder = PQCScriptsFilesPaths.isFolder(path)
                isFile = !isFolder
            }
        }

        PQMenuItem {
            visible: fileview_entry_menu.isFile
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg"
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
            enabled: fileview_entry_menu.isFolder
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/star.svg"
            text: qsTranslate("filedialog", "Add to Favorites")
            onTriggered: {
                PQCScriptsFileDialog.addPlacesEntry(fileview_entry_menu.path, fd_places.entries_favorites.length)
                PQCNotify.filedialogReloadPlaces()
            }
        }

        PQMenuItem {
            visible: PQCConstants.filedialogCurrentSelection.length < 2 || !fileview_entry_menu.isCurrentFileSelected || !menuItemLoadSelection.atLeastOneFolderSelected
            enabled: fileview_entry_menu.isFile || fileview_entry_menu.isFolder
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/folder.svg"
            text: (fileview_entry_menu.isFolder ? qsTranslate("filedialog", "Load content of folder") : qsTranslate("filedialog", "Load this file"))
            onTriggered: {
                PQCFileFolderModel.fileInFolderMainView = fileview_entry_menu.path
                PQCNotify.filedialogClose()
            }
        }

        PQMenuItem {
            id: menuItemLoadSelection
            visible: (PQCConstants.filedialogCurrentSelection.length>1 && (fileview_entry_menu.isCurrentFileSelected || (!fileview_entry_menu.isFile && !fileview_entry_menu.isFolder))) && atLeastOneFolderSelected
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/folder.svg"
            text: (atLeastOneFolderSelected&&atLeastOneFileSelected) ? qsTranslate("filedialog", "Load all selected files/folders") : qsTranslate("filedialog", "Load all selected folders")
            // This menu item is only visible if at least one folder is visible
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

                    PQCFileFolderModel.virtualFolders = allfolders
                    PQCFileFolderModel.virtualFiles = allfiles
                    PQCFileFolderModel.loadVirtualFolderMainView = (allfolders.length+allfiles.length > 1)
                    PQCFileFolderModel.loadVirtualFolderFileDialog = PQCFileFolderModel.loadVirtualFolderMainView
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
                    PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==view_top.currentIndex)
                } else {
                    PQCConstants.filedialogCurrentSelection.push(view_top.currentIndex)
                    PQCConstants.filedialogCurrentSelectionChanged()
                }
            }
        }
        PQMenuItem {
            moveToRightABit: true
            text: fileview_entry_menu.isCurrentFileSelected ? qsTranslate("filedialog", "Remove all file selection") : qsTranslate("filedialog", "Select all files")
            onTriggered: {
                PQCNotify.filedialogSelectAll(!fileview_entry_menu.isCurrentFileSelected)
            }
        }
        PQMenuSeparator { }
        PQMenuItem {
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
            onTriggered: {
                PQCNotify.filedialogCutFiles(false)
            }
        }
        PQMenuItem {
            enabled: (fileview_entry_menu.isFile || fileview_entry_menu.isFolder || PQCConstants.filedialogCurrentSelection.length)
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
            text: (fileview_entry_menu.isCurrentFileSelected || (!fileview_entry_menu.isFile && !fileview_entry_menu.isFolder && PQCConstants.filedialogCurrentSelection.length))
            ? qsTranslate("filedialog", "Copy selection")
            : (fileview_entry_menu.isFile ? qsTranslate("filedialog", "Copy file")
            : (fileview_entry_menu.isFolder ? qsTranslate("filedialog", "Copy folder")
            : qsTranslate("filedialog", "Copy file/folder")))
            onTriggered: {
                PQCNotify.filedialogCopyFiles(false)
            }
        }
        PQMenuItem {
            id: menuItem_paste
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg"
            text: qsTranslate("filedialog", "Paste files from clipboard")
            onTriggered: {
                PQCNotify.filedialogPasteFiles()
            }

            Component.onCompleted: {
                enabled = (PQCScriptsClipboard.areFilesInClipboard() && !PQCFileFolderModel.loadVirtualFolderFileDialog)
            }
            Connections {
                target: PQCScriptsClipboard
                function onClipboardUpdated() {
                    menuItem_paste.enabled = (PQCScriptsClipboard.areFilesInClipboard() && !PQCFileFolderModel.loadVirtualFolderFileDialog)
                }
            }
        }

        PQMenuSeparator { }

        PQMenuItem {
            moveToRightABit: true
            text: PQCSettings.filedialogShowHiddenFilesFolders ? qsTranslate("filedialog", "Hide hidden files") : qsTranslate("filedialog", "Show hidden files")
            onTriggered: {
                PQCSettings.filedialogShowHiddenFilesFolders = !PQCSettings.filedialogShowHiddenFilesFolders
            }
        }
        PQMenuItem {
            moveToRightABit: true
            text: PQCSettings.filedialogDetailsTooltip ? qsTranslate("filedialog", "Hide tooltip with image details") : qsTranslate("filedialog", "Show tooltip with image details")
            onTriggered: {
                PQCSettings.filedialogDetailsTooltip = !PQCSettings.filedialogDetailsTooltip
            }
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

    /*********************************************************************/
    // mouse events from different views

    function handleEntriesMouseEnter(index : int, currentPath : string, fileThumbStatus : int, fileInfo : string,
                                     isFolder : bool, numberFilesInsideFolder : int, currentFolderThumbNum : int) : string {


        if(view_top.ignoreMouseEvents || PQCConstants.isContextmenuOpen("filedialogsettingsmenu") || fileview_entry_menu.opened)
            return ""

        var ret = ""

        if(!fileview_entry_menu.opened) {
            view_top.currentIndex = index
            resetCurrentIndex.stop()
        }

        // we reset the tooltip everytime it is requested as some info/thumbnails might have changed/updated since last time

        if(PQCSettings.filedialogDetailsTooltip) {

            var fmodi = PQCScriptsFilesPaths.getFileModified(currentPath)
            var ftype = PQCScriptsFilesPaths.getFileType(currentPath)
            var currentFile = decodeURIComponent(PQCScriptsFilesPaths.getFilename(currentPath))

            var str = ""

            if(isFolder) {

                if(!view_top.currentFolderExcluded && PQCSettings.filedialogFolderContentThumbnails && numberFilesInsideFolder>0) {
                    // when a folder is hovered before a thumbnail inside is loaded, this will result in an empty image
                    var n = currentFolderThumbNum
                    if(n === 0 && numberFilesInsideFolder > 0)
                        n = 1
                    str += "<img width=256 src=\"image://folderthumb/" + currentPath + ":://::" + n + "\"><br><br>"
                }

                str += "<span style='font-size: " + PQCLook.fontSizeL + "pt; font-weight: bold'>" + currentFile + "</span><br><br>" +
                       (numberFilesInsideFolder===0 ? "" : (qsTranslate("filedialog", "# images")+": <b>" + numberFilesInsideFolder + "</b><br>")) +
                        qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                        qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString() + "</b>"

                ret = str

            } else {

                str = "<table><tr>"

                // if we do not cache this directory, we do not show a thumbnail image
                if(!view_top.currentFolderExcluded && fileThumbStatus === Image.Ready && PQCSettings.filedialogThumbnails) {
                    str += "<td valign=middle><img width=256 src=\"" + encodeURI("image://tooltipthumb/" + currentPath) + "\"></td>"
                    str += "<td>&nbsp;</td>"
                }

                // This breaks the filename into multiple lines if it is too long
                var usefilename = [currentFile]
                var lim = 35
                if(currentFile.length > lim) {
                    // this helps to avoid having one very long line and one line with almost nothing
                    if(currentFile.length%lim < 5)
                        lim -= 2
                    usefilename = []
                    for(var i = 0; i <= currentFile.length; i += lim)
                        usefilename.push(currentFile.substring(i, i+lim))
                }

                // add details
                str += "<td valign=middle>";
                for(var f in usefilename) {
                    str += "<div style='font-size: " + PQCLook.fontSizeL + "pt; font-weight: bold'>" + usefilename[f] + "</div>"
                }
                str += "<br><br>" +
                          qsTranslate("filedialog", "File size:")+" <b>" + fileInfo + "</b><br>" +
                          qsTranslate("filedialog", "File type:")+" <b>" + ftype + "</b><br>" +
                          qsTranslate("filedialog", "Date:")+" <b>" + fmodi.toLocaleDateString() + "</b><br>" +
                          qsTranslate("filedialog", "Time:")+" <b>" + fmodi.toLocaleTimeString()+ "</b></td></tr></table>"

                ret = str

                // if the thumbnail is not yet loaded and a temp icon is shown, we want to check again for the thumbnail the next time the tooltip is shown

            }

        } else if(!PQCSettings.filedialogDetailsTooltip) {

            ret = ""

        }

        return ret

    }

    function handleEntriesMouseExit(index : int) {

        if(view_top.ignoreMouseEvents || PQCConstants.isContextmenuOpen("filedialogsettingsmenu") || fileview_entry_menu.opened)
            return

        if(!view_top.ignoreMouseEvents) {
            resetCurrentIndex.oldIndex = index
            resetCurrentIndex.restart()
        }

    }

    function handleEntriesMouseClick(index : int, currentPath : string, isFolder : bool,
                                     mouseModifiers : int, mouseButton : int) {

        fd_breadcrumbs.disableAddressEdit()

        if(!fileview_entry_menu.opened)
            view_top.currentIndex = index

        if(mouseButton === Qt.BackButton) {
            PQCNotify.filedialogGoBackInHistory()
            return
        } else if(mouseButton === Qt.ForwardButton) {
            goForwardsInHistory()
            return
        }

        if(mouseButton === Qt.RightButton) {
            fileview_entry_menu.path = currentPath
            fileview_entry_menu.popup()
            return;
        }

        if(mouseModifiers & Qt.ShiftModifier) {

            if(view_top.shiftClickIndexStart === index) {
                if(!view_top.currentFileSelected) {
                    PQCConstants.filedialogCurrentSelection.push(index)
                    PQCConstants.filedialogCurrentSelectionChanged()
                    view_top.shiftClickIndexStart = index
                } else {
                    PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==index)
                    view_top.shiftClickIndexStart = -1
                }
            } else if(view_top.shiftClickIndexStart !== -1) {

                if(view_top.shiftClickIndexStart < index) {
                    for(var i = view_top.shiftClickIndexStart; i < index+1; ++i)
                        PQCConstants.filedialogCurrentSelection.push(i)
                } else {
                    for(var l = index; l < view_top.shiftClickIndexStart+1; ++l)
                        PQCConstants.filedialogCurrentSelection.push(l)
                }

                PQCConstants.filedialogCurrentSelectionChanged()

            } else {

                if(!view_top.currentFileSelected) {
                    view_top.shiftClickIndexStart = index
                    PQCConstants.filedialogCurrentSelection.push(index)
                    PQCConstants.filedialogCurrentSelectionChanged()
                } else {
                    PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==index)
                    view_top.shiftClickIndexStart = -1

                }
            }

        } else if(mouseModifiers & Qt.ControlModifier) {

            view_top.shiftClickIndexStart = index

            if(view_top.currentFileSelected) {
                PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==index)
            } else {
                PQCConstants.filedialogCurrentSelection.push(index)
                PQCConstants.filedialogCurrentSelectionChanged()
            }

        } else {

            view_top.shiftClickIndexStart = -1

            if(PQCSettings.filedialogSingleClickSelect) {

                if(!view_top.currentFileSelected) {

                    PQCConstants.filedialogCurrentSelection = [index]
                    view_top.storeMouseClicks[currentPath] = PQCScriptsOther.getTimestamp()

                } else {

                    var t = PQCScriptsOther.getTimestamp()
                    var o = view_top.storeMouseClicks[currentPath]

                    if(t-o < 300) {
                        if(isFolder)
                            filedialog_top.loadNewPath(currentPath)
                        else {
                            PQCFileFolderModel.fileInFolderMainView = currentPath
                            filedialog_top.handleHiding(true)
                        }

                        PQCConstants.filedialogCurrentSelection = []
                    } else {
                        PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==index)
                    }
                }

            } else {

                view_top.loadOnClick(index)

            }
        }

    }

    /*********************************************************************/

    // we need to do all the below as otherwise loading a folder with the same number of items as the previous one would not reload the model
    Connections {

        target: PQCFileFolderModel

        function onNewDataLoadedFileDialog() {

            view_top.setupNewData()

        }
    }

    function setupNewData() {

        // This check is necessary, otherwise this function MIGHT get called BEFORE everything is accessible to QML
        // resulting in a bunch of undefined warnings before the function is called AGAIN seting everything up properly
        if((PQCFileFolderModel.folderFileDialog === "" && PQCFileFolderModel.countAllFileDialog > 0) ||
                PQCFileFolderModel.countAllFileDialog > PQCFileFolderModel.entriesFileDialog.length)
            return

        if(PQCSettings.filedialogRememberSelection) {

            // If this is not the first folder
            if(view_top.storeCurrentFolderName != "") {
                // this is needed to perform a deepcopy
                // otherwise a reference is stored that is changed subsequently
                var l = []
                for (var i in PQCConstants.filedialogCurrentSelection)
                    l.push(PQCConstants.filedialogCurrentSelection[i])
                view_top.cacheSelection[view_top.storeCurrentFolderName] = l
            }

            // load selection
            if(view_top.cacheSelection.hasOwnProperty(PQCFileFolderModel.folderFileDialog))
                PQCConstants.filedialogCurrentSelection = view_top.cacheSelection[PQCFileFolderModel.folderFileDialog]
            else
                PQCConstants.filedialogCurrentSelection = []

        } else
            PQCConstants.filedialogCurrentSelection = []

        // we check if we just went up a level
        // in that case we find the index of the previous child folder and set it as the currentIndex below
        var setCurrentIndexTo = 0
        if(view_top.storeCurrentFolderName !== "" &&
                PQCFileFolderModel.folderFileDialog !== "" &&
                view_top.storeCurrentFolderName !== PQCFileFolderModel.folderFileDialog &&
                view_top.storeCurrentFolderName.indexOf(PQCFileFolderModel.folderFileDialog) === 0) {

            setCurrentIndexTo = PQCFileFolderModel.entriesFileDialog.indexOf(view_top.storeCurrentFolderName)

        }

        // store new folder name
        view_top.storeCurrentFolderName = PQCFileFolderModel.folderFileDialog

        getCurrentViewId().model = 0

        view_top.currentFolderExcluded = PQCScriptsFilesPaths.isExcludeDirFromCaching(PQCFileFolderModel.folderFileDialog)
        view_top.currentFolderOnNetwork = PQCScriptsFilesPaths.isOnNetwork(PQCFileFolderModel.folderFileDialog)

        getCurrentViewId().model = PQCFileFolderModel.countAllFileDialog

        // We set the currentIndex AFTER the model was loaded so that it doesn't mess with this property
        // By default we pre-select the first entry in the list.
        // BUT: if we just went up a folder level we set the currentIndex to the index of the child folder
        // That way it is quick and easy to go back to where we came from without having to do much
        view_top.currentIndex = setCurrentIndexTo

    }

    Component.onCompleted: {
        getCurrentViewId().model = PQCFileFolderModel.countAllFileDialog
    }

    Connections {
        target: PQCImageFormats
        function onFormatsUpdated() {
            view_top.getCurrentViewId().model = 0
            PQCFileFolderModel.forceReloadFileDialog()
            view_top.getCurrentViewId().model = PQCFileFolderModel.countAllFileDialog
        }
    }

    Connections {

        target: PQCSettings

        // react to changes to this setting
        // otherwise this is not happening automatically when this setting is changed at runtime
        function onThumbnailsExcludeNetworkSharesChanged() {
            view_top.currentFolderExcluded = PQCScriptsFilesPaths.isExcludeDirFromCaching(PQCFileFolderModel.folderFileDialog)
        }

    }

    clip: true

    // reset index to -1 if no other item has been hovered in the meantime
    Timer {
        id: resetCurrentIndex
        property int oldIndex
        interval: 100
        onTriggered: {
            if(!fileview_entry_menu.opened) {
                if(oldIndex === view_top.currentIndex)
                    view_top.currentIndex = -1
            }
        }
    }

    Timer {
        id: resetIgnoreMouseEvents
        interval: 500
        onTriggered:
            view_top.ignoreMouseEvents = false
    }

    Timer {
        id: resetNavigateToFileStartingWith
        interval: 2000
        repeat: false
        running: false
        onTriggered:
            view_top.navigateToFileStartingWith = []
    }

    PQPreview {
        z: -1
    }

    PQTextL {
        anchors.fill: parent
        anchors.margins: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        enabled: false
        visible: PQCFileFolderModel.countAllFileDialog===0
        text: qsTranslate("filedialog", "no supported files/folders found")
        color: palette.text
    }

    Rectangle {

        id: floatingString

        x: parent.width-width-10
        y: parent.height-height-10
        width: floatingStringLabel.width+20
        height: floatingStringLabel.height+10

        color: palette.base
        radius: 5

        opacity: 0
        visible: opacity>0
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

        SequentialAnimation {

            loops: Animation.Infinite
            running: floatingString.opacity>0

            NumberAnimation {
                target: floatingString
                property: "scale"
                to: 0.8
                duration: 500
            }
            NumberAnimation {
                target: floatingString
                property: "scale"
                to: 1
                duration: 500
            }

        }

        PQTextL {

            id: floatingStringLabel

            x: 10
            y: 5

            verticalAlignment: Text.AlignVCenter
            font.weight: PQCLook.fontWeightBold
            color: palette.text

            text: ""

            Connections {

                target: view_top

                function onNavigateToFileStartingWithChanged() {

                    if(view_top.navigateToFileStartingWith.length === 0) {
                        floatingString.opacity = 0
                        return
                    }

                    floatingString.opacity = 0.8

                    var s = ""
                    for(var i = 0; i < view_top.navigateToFileStartingWith.length; ++i) {
                        s += view_top.navigateToFileStartingWith[i]
                    }
                    floatingStringLabel.text = s
                }
            }

        }
    }

    Connections {

        target: PQCNotify

        function onFiledialogSelectAll(sel : bool) {
            view_top.selectAll(sel)
        }

        function onFiledialogDeleteFiles() {
            view_top.deleteFiles()
        }

        function onFiledialogCutFiles(forceSelection : bool) {
            view_top.cutFiles(forceSelection)
        }

        function onFiledialogCopyFiles(forceSelection : bool) {
            view_top.copyFiles(forceSelection)
        }

        function onFiledialogPasteFiles() {
            view_top.pasteFiles()
        }

    }

    function setCurrentIndexToCurrentFile() {

        view_top.currentIndex = PQCFileFolderModel.entriesFileDialog.indexOf(PQCFileFolderModel.currentFile)

    }

    // this has been pulled out of the delegate to allow clicks at startup without moving the mouse to be handled
    function loadOnClick(index : int) {

        if(index < PQCFileFolderModel.countFoldersFileDialog)
            filedialog_top.loadNewPath(PQCFileFolderModel.entriesFileDialog[index])
        else {
            PQCFileFolderModel.loadVirtualFolderMainView = PQCFileFolderModel.loadVirtualFolderFileDialog
            PQCFileFolderModel.fileInFolderMainView = PQCFileFolderModel.entriesFileDialog[index]
            if(!PQCSettings.interfacePopoutFileDialog || !PQCSettings.interfacePopoutFileDialogNonModal)
                filedialog_top.handleHiding(true)

            if(!PQCSettings.filedialogRememberSelection)
                PQCConstants.filedialogCurrentSelection = []
        }

    }

    function selectAll(select : bool) {
        if(!select) {
            PQCConstants.filedialogCurrentSelection = []
            return
        }
        PQCConstants.filedialogCurrentSelection = [...Array(getCurrentViewId().model).keys()]
    }

    function copyFiles(forceSelection : bool) {
        currentCuts = []
        if(currentFileSelected || (view_top.currentIndex===-1 && PQCConstants.filedialogCurrentSelection.length) || (forceSelection && PQCConstants.filedialogCurrentSelection.length>0)) {
            var urls = []
            for(var key in PQCConstants.filedialogCurrentSelection)
                urls.push(PQCFileFolderModel.entriesFileDialog[PQCConstants.filedialogCurrentSelection[key]])
            PQCScriptsClipboard.copyFilesToClipboard(urls)
        } else if(view_top.currentIndex > -1) {
            PQCScriptsClipboard.copyFilesToClipboard([PQCFileFolderModel.entriesFileDialog[view_top.currentIndex]])
        }
        PQCConstants.filedialogCurrentSelection = []
    }

    function cutFiles(forceSelection : bool) {

        var urls = []

        if(currentFileSelected || (view_top.currentIndex===-1 && PQCConstants.filedialogCurrentSelection.length) || (forceSelection && PQCConstants.filedialogCurrentSelection.length>0)) {
            for(var key in PQCConstants.filedialogCurrentSelection)
                urls.push(PQCFileFolderModel.entriesFileDialog[PQCConstants.filedialogCurrentSelection[key]])
        } else if(view_top.currentIndex > -1)
            urls = [PQCFileFolderModel.entriesFileDialog[view_top.currentIndex]]

        if(urls.length > 0) {
            PQCScriptsClipboard.copyFilesToClipboard(urls)
            currentCuts = urls
        }

        PQCConstants.filedialogCurrentSelection = []

    }

    function pasteFiles() {

        if(PQCFileFolderModel.loadVirtualFolderFileDialog) {
            PQCNotify.showNotificationMessage(qsTranslate("filedialog", "Virtual folder"), qsTranslate("filedialog", "Pasting files into a virtual folder is not possible."))
            return
        }

        PQCConstants.filedialogCurrentSelection = []

        var lst = PQCScriptsClipboard.getListOfFilesInClipboard()

        var nonexisting = []
        var existing = []

        for(var l in lst) {
            if(PQCScriptsFilesPaths.doesItExist(PQCFileFolderModel.folderFileDialog + "/" + PQCScriptsFilesPaths.getFilename(lst[l])))
                existing.push(lst[l])
            else
                nonexisting.push(lst[l])
        }

        if(existing.length > 0)
            pasteExisting.pasteExistingFiles(existing)

        if(nonexisting.length > 0) {
            for(var f in nonexisting) {
                var fln = nonexisting[f]
                if(PQCScriptsFileManagement.copyFileToHere(fln, PQCFileFolderModel.folderFileDialog)) {
                    if(currentCuts.indexOf(fln) !== -1)
                        PQCScriptsFileManagement.deletePermanent(fln)
                }
            }
            if(existing.length == 0)
                currentCuts = []
        }

        if(existing.length == 0 && nonexisting.length == 0)
            PQCNotify.showNotificationMessage("Nothing found", "There are no supported files/folders in the clipboard.")

    }

    function deleteFiles() {

        if(PQCConstants.shiftKeyPressed) {

            if(currentFileSelected || (view_top.currentIndex===-1 && PQCConstants.filedialogCurrentSelection.length))
                modal.show("Delete permanently?",
                           "Are you sure you want to delete all selected files/folders PERMANENTLY?",
                           "permanent",
                           PQCConstants.filedialogCurrentSelection)
            else
                modal.show("Delete permanently?",
                           "Are you sure you want to delete all selected files/folders PERMANENTLY?",
                           "permanent",
                           [view_top.currentIndex])

        } else {

            if(currentFileSelected || (view_top.currentIndex===-1 && PQCConstants.filedialogCurrentSelection.length))
                modal.show("Move to Trash?",
                           "Are you sure you want to move all selected files/folders to the trash?",
                           "trash",
                           PQCConstants.filedialogCurrentSelection)
            else
                modal.show("Move to Trash?",
                           "Are you sure you want to move all selected files/folders to the trash?",
                           "trash",
                           [view_top.currentIndex])

        }
        return

    }

    function handleKeyEvent(key : int, modifiers : int) {

        if(PQCConstants.whichContextMenusOpen.length > 0)
            return

        ignoreMouseEvents = true

        if(key === Qt.Key_Up) {

            if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier) {
                if(!PQCFileFolderModel.loadVirtualFolderFileDialog)
                    filedialog_top.loadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog))
            } else
                getCurrentViewId().goUpARow()

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Down) {

            getCurrentViewId().goDownARow()
            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Right) {

            if(modifiers & Qt.ControlModifier && modifiers & Qt.ShiftModifier) {

                if(!PQCFileFolderModel.loadVirtualFolderFileDialog) {
                    var nextpath = PQCScriptsFileDialog.getSiblingFolder(PQCFileFolderModel.folderFileDialog, 1)
                    if(nextpath !== "")
                        filedialog_top.loadNewPath(nextpath)
                }

            } else if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier) {

                filedialog_top.goForwardsInHistory()

            } else {

                if(view_top.currentIndex === -1)
                    view_top.currentIndex = 0
                else
                    view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex+1)

            }

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Left) {

            if(modifiers & Qt.ControlModifier && modifiers & Qt.ShiftModifier) {

                if(!PQCFileFolderModel.loadVirtualFolderFileDialog) {
                    var prevpath = PQCScriptsFileDialog.getSiblingFolder(PQCFileFolderModel.folderFileDialog, -1)
                    if(prevpath !== "")
                        filedialog_top.loadNewPath(prevpath)
                }

            } else if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier) {

                PQCNotify.filedialogGoBackInHistory()

            } else {

                if(view_top.currentIndex === -1)
                    view_top.currentIndex = PQCFileFolderModel.countAllFileDialog-1
                else
                    view_top.currentIndex = Math.max(0, view_top.currentIndex-1)

            }

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_PageDown) {

            getCurrentViewId().goDownSomeRows()
            navigateToFileStartingWith = []

        } else if(key === Qt.Key_PageUp) {

            getCurrentViewId().goUpSomeRows()
            navigateToFileStartingWith = []

        } else if(key === Qt.Key_End) {

            view_top.currentIndex = PQCFileFolderModel.countAllFileDialog-1

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Home) {

            if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier)
                filedialog_top.loadNewPath(PQCScriptsFilesPaths.getHomeDir())
             else
                view_top.currentIndex = 0

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Enter || key === Qt.Key_Return) {

            // nothing selected yet
            if(view_top.currentIndex == -1) return

            if(view_top.currentIndex < PQCFileFolderModel.countFoldersFileDialog)
                filedialog_top.loadNewPath(PQCFileFolderModel.entriesFileDialog[view_top.currentIndex])
            else {
                loadOnClick(view_top.currentIndex)
            }

            navigateToFileStartingWith = []

        } else if((key === Qt.Key_Plus || key === Qt.Key_Equal) && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogZoom = Math.min(100, PQCSettings.filedialogZoom+1)

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Minus && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogZoom = Math.max(0, PQCSettings.filedialogZoom-1)

            navigateToFileStartingWith = []

        } else if((key === Qt.Key_H && modifiers & Qt.ControlModifier) || (key === Qt.Key_Period && modifiers & Qt.AltModifier)) {

            PQCSettings.filedialogShowHiddenFilesFolders = !PQCSettings.filedialogShowHiddenFilesFolders

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_C && modifiers & Qt.ControlModifier) {

            copyFiles(true)

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_X && modifiers & Qt.ControlModifier) {

            cutFiles(true)

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_V && modifiers & Qt.ControlModifier) {

            pasteFiles()

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_A && modifiers & Qt.ControlModifier) {

            selectAll(true)

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Delete) {

            deleteFiles()

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Backspace) {

            PQCNotify.filedialogGoBackInHistory()

        } else if(key === Qt.Key_Space && view_top.navigateToFileStartingWith.length === 0) {

            if(currentFileSelected)
                PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==view_top.currentIndex)
            else {
                PQCConstants.filedialogCurrentSelection.push(view_top.currentIndex)
                PQCConstants.filedialogCurrentSelectionChanged()
            }

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_1 && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogLayout = "grid"

        } else if(key === Qt.Key_2 && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogLayout = "list"

        } else if(key === Qt.Key_3 && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogLayout = "masonry"

        } else if(key === Qt.Key_Q && modifiers & Qt.ControlModifier) {

            PQCNotify.photoQtQuit()

        } else {

            // ignore modifier modified combos (except for capitalization)
            if(modifiers === Qt.ShiftModifier)
                modifiers = Qt.NoModifier
            else if(modifiers !== Qt.NoModifier)
                return

            var keystr = PQCScriptsShortcuts.analyzeKeyPress(key).toLowerCase()
            if(keystr === "space")
                keystr = " "

            if(keystr.length > 1)
                return

            // add new key to list
            navigateToFileStartingWith.push(keystr)
            navigateToFileStartingWithChanged()

            // find starting index
            var tmp = (view_top.currentIndex===-1 ? 0 : view_top.currentIndex+1)

            // loop over all indices
            for(var i = tmp; i < tmp+PQCFileFolderModel.countAllFileDialog; ++i) {

                // we loop around to the beginning
                var use = i%PQCFileFolderModel.countAllFileDialog

                // filename
                var fname = PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.entriesFileDialog[use])

                // check start of filename
                var thisIsIt = true
                for(var j = 0; j < navigateToFileStartingWith.length; ++j) {

                    if(j >= fname.length) {
                        thisIsIt = false
                        break
                    }

                    // found mismatch
                    if(fname[j].toLowerCase() !== navigateToFileStartingWith[j]) {
                        thisIsIt = false
                        break
                    }

                }

                // done
                if(thisIsIt) {
                    view_top.currentIndex = use
                    break
                }

            }

            // restart resetting variable
            resetNavigateToFileStartingWith.restart()

        }

    }

}
