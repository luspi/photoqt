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
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCImageFormats
import PQCScriptsImages
import PhotoQt

Item {

    id: view_top

    y: 1
    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height-2 // qmllint disable unqualified

    // alias
    property alias fileviewContextMenu: contextmenu

    // select/cut
    property int shiftClickIndexStart: -1
    property list<int> currentSelection: []
    property list<string> currentCuts: []
    property bool currentFileSelected: (currentSelection.indexOf(currentIndex)!==-1)
    property bool currentFileCut: (currentCuts.indexOf(currentIndex)!==-1)
    property bool ignoreMouseEvents: false
    property list<string> navigateToFileStartingWith: []

    property int currentIndex: -1
    onCurrentIndexChanged: {
        if(currentIndex !== getCurrentViewId().currentIndex)
            getCurrentViewId().currentIndex = currentIndex
    }

    // properties
    property bool currentFolderExcluded: false
    property bool currentFolderOnNetwork: false
    property int currentFolderThumbnailIndex: -1
    property string storeCurrentFolderName: ""
    property var cacheSelection: ({})

    signal refreshThumbnails()
    signal refreshCurrentThumbnail()

    property var storeMouseClicks: ({})

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

    function getCurrentViewId() {
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

    /*********************************************************************/
    // mouse events from different views

    function handleEntriesMouseEnter(index : int, currentPath : string, fileThumbStatus : int, fileInfo : string,
                                     isFolder : bool, numberFilesInsideFolder : int, currentFolderThumbNum : int) : string {


        if(view_top.ignoreMouseEvents || fd_breadcrumbs.topSettingsMenu.visible) // qmllint disable unqualified
            return ""

        var ret = ""

        if(!contextmenu.visible) {
            view_top.currentIndex = index
            resetCurrentIndex.stop()
        } else
            contextmenu.setCurrentIndexToThisAfterClose = index

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

        if(!view_top.ignoreMouseEvents) {
            resetCurrentIndex.oldIndex = index
            resetCurrentIndex.restart()
        }

    }

    function handleEntriesMouseClick(index : int, currentPath : string, isFolder : bool,
                                     mouseModifiers : int, mouseButton : int) {

        fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified

        if(!contextmenu.visible)
            view_top.currentIndex = index
        else
            contextmenu.setCurrentIndexToThisAfterClose = index

        if(mouseButton === Qt.BackButton) {
            goBackInHistory()
            return
        } else if(mouseButton === Qt.ForwardButton) {
            goForwardsInHistory()
            return
        }

        if(mouseButton === Qt.RightButton) {
            contextmenu.path = currentPath;
            contextmenu.setCurrentIndexToThisAfterClose = index;
            contextmenu.popup();
            return;
        }

        if(mouseModifiers & Qt.ShiftModifier) {

            if(view_top.shiftClickIndexStart === index) {
                if(!view_top.currentFileSelected) {
                    view_top.currentSelection.push(index)
                    view_top.currentSelectionChanged()
                    view_top.shiftClickIndexStart = index
                } else {
                    view_top.currentSelection = view_top.currentSelection.filter(item => item!==index)
                    view_top.shiftClickIndexStart = -1
                }
            } else if(view_top.shiftClickIndexStart !== -1) {

                if(view_top.shiftClickIndexStart < index) {
                    for(var i = view_top.shiftClickIndexStart; i < index+1; ++i)
                        view_top.currentSelection.push(i)
                } else {
                    for(var l = index; l < view_top.shiftClickIndexStart+1; ++l)
                        view_top.currentSelection.push(l)
                }

                view_top.currentSelectionChanged()

            } else {

                if(!view_top.currentFileSelected) {
                    view_top.shiftClickIndexStart = index
                    view_top.currentSelection.push(index)
                    view_top.currentSelectionChanged()
                } else {
                    view_top.currentSelection = view_top.currentSelection.filter(item => item!==index)
                    view_top.shiftClickIndexStart = -1

                }
            }

        } else if(mouseModifiers & Qt.ControlModifier) {

            view_top.shiftClickIndexStart = index

            if(view_top.currentFileSelected) {
                view_top.currentSelection = view_top.currentSelection.filter(item => item!==index)
            } else {
                view_top.currentSelection.push(index)
                view_top.currentSelectionChanged()
            }

        } else {

            view_top.shiftClickIndexStart = -1

            if(PQCSettings.filedialogSingleClickSelect) {

                if(!view_top.currentFileSelected) {

                    view_top.currentSelection = [index]
                    view_top.storeMouseClicks[currentPath] = PQCScriptsOther.getTimestamp()

                } else {

                    var t = PQCScriptsOther.getTimestamp()
                    var o = view_top.storeMouseClicks[currentPath]

                    if(t-o < 300) {
                        if(isFolder)
                            filedialog_top.loadNewPath(currentPath)
                        else {
                            PQCFileFolderModel.extraFoldersToLoad = []
                            PQCFileFolderModel.fileInFolderMainView = currentPath
                            filedialog_top.hideFileDialog()
                        }

                        view_top.currentSelection = []
                    } else {
                        view_top.currentSelection = view_top.currentSelection.filter(item => item!==index)
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

        target: PQCFileFolderModel // qmllint disable unqualified

        function onNewDataLoadedFileDialog() {

            view_top.setupNewData()

        }
    }

    function setupNewData() {

        if(PQCSettings.filedialogRememberSelection) {

            // If this is not the first folder
            if(view_top.storeCurrentFolderName != "") {
                // this is needed to perform a deepcopy
                // otherwise a reference is stored that is changed subsequently
                var l = []
                for (var i in view_top.currentSelection)
                    l.push(view_top.currentSelection[i])
                view_top.cacheSelection[view_top.storeCurrentFolderName] = l
            }

            // load selection
            if(view_top.cacheSelection.hasOwnProperty(PQCFileFolderModel.folderFileDialog))
                view_top.currentSelection = view_top.cacheSelection[PQCFileFolderModel.folderFileDialog]
            else
                view_top.currentSelection = []

        } else

            view_top.currentSelection = []

        // store new folder name
        view_top.storeCurrentFolderName = PQCFileFolderModel.folderFileDialog

        getCurrentViewId().model = 0

        view_top.currentFolderExcluded = PQCScriptsFilesPaths.isExcludeDirFromCaching(PQCFileFolderModel.folderFileDialog) // qmllint disable unqualified
        view_top.currentFolderOnNetwork = PQCScriptsFilesPaths.isOnNetwork(PQCFileFolderModel.folderFileDialog)

        getCurrentViewId().model = PQCFileFolderModel.countAllFileDialog

        // to have no item pre-selected when a new folder is loaded we need to set the currentIndex to -1 AFTER the model is set
        // (re-)setting the model will always reset the currentIndex to 0
        view_top.currentIndex = -1

    }

    Component.onCompleted: {
        getCurrentViewId().model = PQCFileFolderModel.countAllFileDialog // qmllint disable unqualified
    }

    Connections {
        target: PQCImageFormats // qmllint disable unqualified
        function onFormatsUpdated() {
            getCurrentViewId().model = 0
            PQCFileFolderModel.forceReloadFileDialog() // qmllint disable unqualified
            getCurrentViewId().model = PQCFileFolderModel.countAllFileDialog
        }
    }

    clip: true

    // reset index to -1 if no other item has been hovered in the meantime
    Timer {
        id: resetCurrentIndex
        property int oldIndex
        interval: 100
        onTriggered: {
            if(!contextmenu.visible) {
                if(oldIndex === view_top.currentIndex)
                    view_top.currentIndex = -1
            } else {
                if(oldIndex === contextmenu.setCurrentIndexToThisAfterClose)
                    contextmenu.setCurrentIndexToThisAfterClose = -1
            }
        }
    }

    Timer {
        id: resetIgnoreMouseEvents
        interval: 200
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
        visible: PQCFileFolderModel.countAllFileDialog===0 // qmllint disable unqualified
        text: qsTranslate("filedialog", "no supported files/folders found")
    }

    PQMouseArea {

        id: bgMousearea

        property bool enableAnyways: false

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton|Qt.LeftButton|Qt.BackButton|Qt.ForwardButton

        // this allows us to catch any right click no matter where it happens
        // AND still react to onEntered/Exited events for each individual delegate
        // note: the indexAt() method is not (yet) implemented for masonry view
        enabled: (view_top.currentIndex===-1 || enableAnyways) && PQCSettings.filedialogLayout!=="masonry"
        visible: (view_top.currentIndex===-1 || enableAnyways) && PQCSettings.filedialogLayout!=="masonry"

        onClicked: (mouse) => {

            if(mouse.button === Qt.BackButton) {
                filedialog_top.goBackInHistory() // qmllint disable unqualified
                return
            } else if(mouse.button === Qt.ForwardButton) {
                filedialog_top.goForwardsInHistory() // qmllint disable unqualified
                return
            }

            // this does some basic click checking when a click occured *before* the cursor has been moved
            var ind = getCurrentViewId().indexAt(mouseX, getCurrentViewId().contentY+mouseY)
            if(ind !== -1) {
                view_top.currentIndex = ind
                enableAnyways = false
                if(!PQCSettings.filedialogSingleClickSelect && mouse.button === Qt.LeftButton)
                    view_top.loadOnClick(ind)
                return
            }

            if(mouse.button === Qt.RightButton) {
                contextmenu.path = ""
                contextmenu.popup()
            } else
                view_top.currentSelection = []
            enableAnyways = false
        }
        onPositionChanged: {
            if(fd_breadcrumbs.topSettingsMenu.visible) // qmllint disable unqualified
                return

            var ind = getCurrentViewId().indexAt(mouseX, getCurrentViewId().contentY+mouseY)
            if(contextmenu.visible)
                contextmenu.setCurrentIndexToThisAfterClose = ind
            else
                view_top.currentIndex = ind
            enableAnyways = false
        }
    }

    Rectangle {

        id: floatingString

        x: parent.width-width-10
        y: parent.height-height-10
        width: floatingStringLabel.width+20
        height: floatingStringLabel.height+10

        color: PQCLook.baseColor // qmllint disable unqualified
        radius: 5

        opacity: 0
        visible: opacity>0
        Behavior on opacity { NumberAnimation { duration: 200 } }

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
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified

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

    PQMenu {

        id: contextmenu

        property bool isFolder: false
        property bool isFile: false
        property string path: ""

        property bool shiftPressed: false

        onPathChanged: {
            if(path == "") {
                isFolder = false
                isFile = false
            } else {
                isFolder = PQCScriptsFilesPaths.isFolder(path) // qmllint disable unqualified
                isFile = !isFolder
            }
        }

        property int setCurrentIndexToThisAfterClose: -1
        onVisibleChanged: {
            if(!visible && setCurrentIndexToThisAfterClose != -2) {
                view_top.currentIndex = setCurrentIndexToThisAfterClose
                setCurrentIndexToThisAfterClose = -2
            }
        }

        Connections {
            target: filedialog_top // qmllint disable unqualified
            function onOpacityChanged() {
                if(filedialog_top.opacity<1) // qmllint disable unqualified
                    contextmenu.close()
            }
        }

        PQMenuItem {
            implicitHeight: visible ? 40 : 0
            visible: contextmenu.isFile
            text: qsTranslate("thumbnails","Reload thumbnail")
            onTriggered: {
                PQCScriptsImages.removeThumbnailFor(contextmenu.path) // qmllint disable unqualified
                view_top.refreshCurrentThumbnail()
            }
        }

        PQMenuItem {
            implicitHeight: visible ? 40 : 0
            visible: contextmenu.isFolder
            text: qsTranslate("filedialog", "Open this folder")
            onTriggered: {
                filedialog_top.loadNewPath(contextmenu.path) // qmllint disable unqualified
            }
        }
        PQMenuItem {
            implicitHeight: visible ? 40 : 0
            visible: (view_top.currentSelection.length===1 && view_top.currentFileSelected) || !view_top.currentFileSelected
            enabled: contextmenu.isFolder && PQCScriptsConfig.isPugixmlSupportEnabled() // qmllint disable unqualified
            text: qsTranslate("filedialog", "Add to Favorites")
            onTriggered: {
                PQCScriptsFileDialog.addPlacesEntry(contextmenu.path, fd_places.entries_favorites.length) // qmllint disable unqualified
                fd_places.loadPlaces()
            }
        }

        PQMenuItem {
            implicitHeight: visible ? 40 : 0
            visible: view_top.currentSelection.length < 2 || !view_top.currentFileSelected || !menuitemLoadSelection.atLeastOneFolderSelected
            enabled: contextmenu.isFile || contextmenu.isFolder
            text: (contextmenu.isFolder ? qsTranslate("filedialog", "Load content of folder") : qsTranslate("filedialog", "Load this file"))
            onTriggered: {
                PQCFileFolderModel.extraFoldersToLoad = [] // qmllint disable unqualified
                PQCFileFolderModel.fileInFolderMainView = contextmenu.path
                filedialog_top.hideFileDialog()
            }
        }

        PQMenuItem {
            id: menuitemLoadSelection
            implicitHeight: visible ? 40 : 0
            visible: (view_top.currentSelection.length>1 && (view_top.currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder))) && atLeastOneFolderSelected
            text: (atLeastOneFolderSelected&&atLeastOneFileSelected) ? qsTranslate("filedialog", "Load all selected files/folders") : qsTranslate("filedialog", "Load all selected folders")
            // THis menu item is only visible if at least one folder is visible
            // If only files are selected we will load the current folder anyways
            property bool atLeastOneFolderSelected: false
            property bool atLeastOneFileSelected: false
            Connections {
                target: view_top
                function onCurrentSelectionChanged() {
                    var havefolder = false
                    var havefile = false
                    for(var i in view_top.currentSelection) {
                        var cur = PQCFileFolderModel.entriesFileDialog[view_top.currentSelection[i]] // qmllint disable unqualified
                        if(PQCScriptsFilesPaths.isFolder(cur)) {
                            havefolder = true
                        } else {
                            havefile = true
                        }
                        // we found as much as we can find -> can stop now
                        if(havefile && havefolder)
                            break
                    }
                    menuitemLoadSelection.atLeastOneFolderSelected = havefolder
                    menuitemLoadSelection.atLeastOneFileSelected = havefile
                }
            }

            onTriggered: {
                var allfiles = []
                var allfolders = []
                for(var i in view_top.currentSelection) {
                    var cur = PQCFileFolderModel.entriesFileDialog[view_top.currentSelection[i]] // qmllint disable unqualified
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
                    filedialog_top.hideFileDialog()

                }
            }
        }

        PQMenuSeparator { }

        PQMenuItem {
            enabled: contextmenu.isFile || contextmenu.isFolder
            text: view_top.currentFileSelected ? qsTranslate("filedialog", "Remove file selection") : qsTranslate("filedialog", "Select file")
            onTriggered: {
                if(view_top.currentFileSelected) {
                    view_top.currentSelection = view_top.currentSelection.filter(item => item!==view_top.currentIndex)
                } else {
                    view_top.currentSelection.push(view_top.currentIndex)
                    view_top.currentSelectionChanged()
                }
            }
        }
        PQMenuItem {
            text: view_top.currentFileSelected ? qsTranslate("filedialog", "Remove all file selection") : qsTranslate("filedialog", "Select all files")
            onTriggered: {
                view_top.selectAll(!view_top.currentFileSelected)
            }
        }
        PQMenuSeparator { }
        PQMenuItem {
            implicitHeight: visible ? 40 : 0
            visible: !PQCScriptsConfig.amIOnWindows() // qmllint disable unqualified
            enabled: visible && (contextmenu.isFile || contextmenu.isFolder || view_top.currentSelection.length)
            font.weight: contextmenu.shiftPressed ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal // qmllint disable unqualified
            text: (view_top.currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder && view_top.currentSelection.length))
                        ? (contextmenu.shiftPressed ? qsTranslate("filedialog", "Delete selection permanently") : qsTranslate("filedialog", "Delete selection"))
                        : (contextmenu.isFile ? (contextmenu.shiftPressed ? qsTranslate("filedialog", "Delete file permanently") : qsTranslate("filedialog", "Delete file"))
                                              : (contextmenu.isFolder ? (contextmenu.shiftPressed ? qsTranslate("filedialog", "Delete folder permanently") : qsTranslate("filedialog", "Delete folder"))
                                                                      : (contextmenu.shiftPressed ? qsTranslate("filedialog", "Delete file/folder permanently") : qsTranslate("filedialog", "Delete file/folder"))))
            onTriggered:
                view_top.deleteFiles()
        }
        PQMenuItem {
            enabled: (contextmenu.isFile || contextmenu.isFolder || view_top.currentSelection.length)
            text: (view_top.currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder && view_top.currentSelection.length))
                        ? qsTranslate("filedialog", "Cut selection")
                        : (contextmenu.isFile ? qsTranslate("filedialog", "Cut file")
                                              : (contextmenu.isFolder ? qsTranslate("filedialog", "Cut folder")
                                                                      : qsTranslate("filedialog", "Cut file/folder")))
            onTriggered:
                view_top.cutFiles()
        }
        PQMenuItem {
            enabled: (contextmenu.isFile || contextmenu.isFolder || view_top.currentSelection.length)
            text: (view_top.currentFileSelected || (!contextmenu.isFile && !contextmenu.isFolder && view_top.currentSelection.length))
                        ? qsTranslate("filedialog", "Copy selection")
                        : (contextmenu.isFile ? qsTranslate("filedialog", "Copy file")
                                              : (contextmenu.isFolder ? qsTranslate("filedialog", "Copy folder")
                                                                      : qsTranslate("filedialog", "Copy file/folder")))
            onTriggered:
                view_top.copyFiles()
        }
        PQMenuItem {
            id: menuitem_paste
            text: qsTranslate("filedialog", "Paste files from clipboard")
            onTriggered:
                view_top.pasteFiles()

            Component.onCompleted: {
                enabled = PQCScriptsClipboard.areFilesInClipboard() // qmllint disable unqualified
            }
            Connections {
                target: PQCScriptsClipboard // qmllint disable unqualified
                function onClipboardUpdated() {
                    menuitem_paste.enabled = PQCScriptsClipboard.areFilesInClipboard() // qmllint disable unqualified
                }
            }
        }

        PQMenuSeparator { }

        PQMenuItem {
            checkable: true
            checked: PQCSettings.filedialogShowHiddenFilesFolders // qmllint disable unqualified
            text: qsTranslate("filedialog", "Show hidden files")
            keepOpenWhenCheckedChanges: false
            onTriggered:
                PQCSettings.filedialogShowHiddenFilesFolders = checked // qmllint disable unqualified
        }
        PQMenuItem {
            checkable: true
            checked: PQCSettings.filedialogDetailsTooltip // qmllint disable unqualified
            text: qsTranslate("filedialog", "Show tooltip with image details")
            keepOpenWhenCheckedChanges: false
            onTriggered:
                PQCSettings.filedialogDetailsTooltip = checked // qmllint disable unqualified
        }


    }

    Connections {

        target: PQCNotify // qmllint disable unqualified

        enabled: (filedialog_top.opacity > 0) // qmllint disable unqualified

        function onKeyRelease(key: int, modifiers: int) {
            if(key < 16770000 || modifiers !== Qt.ShiftModifier)
                contextmenu.shiftPressed = false
        }

    }

    // this has been pulled out of the delegate to allow clicks at startup without moving the mouse to be handled
    function loadOnClick(index : int) {

        if(index < PQCFileFolderModel.countFoldersFileDialog) // qmllint disable unqualified
            filedialog_top.loadNewPath(PQCFileFolderModel.entriesFileDialog[index])
        else {
            PQCFileFolderModel.extraFoldersToLoad = []
            PQCFileFolderModel.fileInFolderMainView = PQCFileFolderModel.entriesFileDialog[index]
            if(!PQCSettings.interfacePopoutFileDialog || !PQCSettings.interfacePopoutFileDialogNonModal)
                filedialog_top.hideFileDialog()

            if(!PQCSettings.filedialogRememberSelection)
                view_top.currentSelection = []
        }

    }

    function selectAll(select : bool) {
        if(!select) {
            currentSelection = []
            return
        }
        currentSelection = [...Array(model).keys()]
    }

    function copyFiles(forceSelection = false) {
        currentCuts = []
        if(currentFileSelected || (view_top.currentIndex===-1 && currentSelection.length) || (forceSelection && currentSelection.length>0)) {
            var urls = []
            for(var key in currentSelection)
                urls.push(PQCFileFolderModel.entriesFileDialog[currentSelection[key]])
            PQCScriptsClipboard.copyFilesToClipboard(urls)
        } else if(view_top.currentIndex > -1) {
            PQCScriptsClipboard.copyFilesToClipboard([PQCFileFolderModel.entriesFileDialog[view_top.currentIndex]])
        }
        currentSelection = []
    }

    function cutFiles(forceSelection = false) {

        var urls = []

        if(currentFileSelected || (view_top.currentIndex===-1 && currentSelection.length) || (forceSelection && currentSelection.length>0)) {
            for(var key in currentSelection)
                urls.push(PQCFileFolderModel.entriesFileDialog[currentSelection[key]])
        } else if(view_top.currentIndex > -1)
            urls = [PQCFileFolderModel.entriesFileDialog[view_top.currentIndex]]

        if(urls.length > 0) {
            PQCScriptsClipboard.copyFilesToClipboard(urls)
            currentCuts = urls
        }

        currentSelection = []

    }

    function pasteFiles() {

        currentSelection = []

        var lst = PQCScriptsClipboard.getListOfFilesInClipboard() // qmllint disable unqualified

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

        if(existing.length == 0 && nonexisting.length == 0) {
            modal.button2.visible = false
            modal.show("Nothing found", "There are no files/folders in the clipboard.", "", [])
        }

    }

    function deleteFiles() {

        modal.button2.visible = true // qmllint disable unqualified

        if(contextmenu.shiftPressed) {

            if(currentFileSelected || (view_top.currentIndex===-1 && currentSelection.length))
                modal.show("Delete permanently?",
                           "Are you sure you want to delete all selected files/folders PERMANENTLY?",
                           "permanent",
                           currentSelection)
            else
                modal.show("Delete permanently?",
                           "Are you sure you want to delete all selected files/folders PERMANENTLY?",
                           "permanent",
                           [view_top.currentIndex])

        } else {

            if(currentFileSelected || (view_top.currentIndex===-1 && currentSelection.length))
                modal.show("Move to Trash?",
                           "Are you sure you want to move all selected files/folders to the trash?",
                           "trash",
                           currentSelection)
            else
                modal.show("Move to Trash?",
                           "Are you sure you want to move all selected files/folders to the trash?",
                           "trash",
                           [view_top.currentIndex])

        }
        return

    }

    function handleKeyEvent(key : int, modifiers : int) {

        ignoreMouseEvents = true
        bgMousearea.enableAnyways = true

        resetIgnoreMouseEvents.restart()

        if(modifiers !== Qt.ShiftModifier || key < 16770000)
            contextmenu.shiftPressed = false

        if(key === Qt.Key_Up) {

            if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier)
                filedialog_top.loadNewPath(PQCScriptsFilesPaths.goUpOneLevel(PQCFileFolderModel.folderFileDialog)) // qmllint disable unqualified
            else
                getCurrentViewId().goUpARow()

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Down) {

            getCurrentViewId().goDownARow()
            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Right) {

            if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier) {

                filedialog_top.goForwardsInHistory()

            } else {

                if(view_top.currentIndex === -1)
                    view_top.currentIndex = 0
                else
                    view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex+1)

            }

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_Left) {

            if(modifiers & Qt.AltModifier || modifiers & Qt.ControlModifier) {

                filedialog_top.goBackInHistory()

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

            filedialog_top.goBackInHistory()

        } else if(key === Qt.Key_Space && view_top.navigateToFileStartingWith.length === 0) {

            if(currentFileSelected)
                view_top.currentSelection = view_top.currentSelection.filter(item => item!==view_top.currentIndex)
            else {
                view_top.currentSelection.push(view_top.currentIndex)
                view_top.currentSelectionChanged()
            }

            navigateToFileStartingWith = []

        } else if(key === Qt.Key_1 && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogLayout = "grid"

        } else if(key === Qt.Key_2 && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogLayout = "list"

        } else if(key === Qt.Key_3 && modifiers & Qt.ControlModifier) {

            PQCSettings.filedialogLayout = "masonry"

        } else if(key > 16770000 && modifiers === Qt.ShiftModifier) {

            contextmenu.shiftPressed = true

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
