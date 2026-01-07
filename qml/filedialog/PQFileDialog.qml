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

PQTemplate {

    id: filedialog_top

    elementId: "FileDialog"
    letMeHandleClosing: true

    property alias placesWidth: fd_places.width
    property alias fileviewWidth: fd_fileview.width
    property alias splitview: fd_splitview

    property bool dontAnimateFirstStart: PQCConstants.startupFilePath===""

    // the first entry of the history list is set in Component.onCompleted
    // we do not want a property binding here!
    property list<string> history: []
    property int historyIndex: 0

    property bool splitDividerHovered: false

    color: palette.base

    PQBreadCrumbs {
        id: fd_breadcrumbs
    }

    property bool finishedSetup: false
    Timer {
        interval: 500
        running: true
        onTriggered:
            filedialog_top.finishedSetup = true
    }

/*1off_Qt64
    Item {
2off_Qt64*/
/*1on_Qt65+*/
    SplitView {
/*2on_Qt65+*/

        id: fd_splitview

        y: fd_breadcrumbs.height
        width: parent.width
        height: parent.height-fd_breadcrumbs.height-fd_tweaks.height
        anchors.topMargin: fd_breadcrumbs.height
        anchors.bottomMargin: fd_tweaks.height

/*1on_Qt65+*/
        // Show larger handle with triple dash
        handle: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            color: palette.text
            opacity: SplitHandle.hovered ? 0.5 : 0.2
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            onOpacityChanged:
                filedialog_top.splitDividerHovered = SplitHandle.hovered

            Image {
                y: (fd_splitview.height-height)/2
                width: fd_splitview.implicitWidth
                height: fd_splitview.implicitHeight
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/handle.svg"
            }

        }
/*2on_Qt65+*/

        PQPlaces {
            id: fd_places
/*1off_Qt64
            width: 200
2off_Qt64*/
/*1on_Qt65+*/
            SplitView.minimumWidth: (PQCSettings.filedialogPlaces || PQCSettings.filedialogDevices) ? 100 : 5
            SplitView.preferredWidth: PQCSettings.filedialogPlacesWidth
            onWidthChanged: {
                if(filedialog_top.finishedSetup)
                    PQCSettings.filedialogPlacesWidth = Math.round(width)
            }
/*2on_Qt65+*/
        }

/*1off_Qt64
        Rectangle {
            color: palette.text
            opacity: 0.2
            width: 5
            height: parent.height
            x: 200
        }
2off_Qt64*/

        PQFileView {
            id: fd_fileview
/*1off_Qt64
            x: 205
            width: parent.width-205
2off_Qt64*/
/*1on_Qt65+*/
            SplitView.minimumWidth: 200
            SplitView.fillWidth: true
/*2on_Qt65+*/

        }

    }

    PQTweaks {
        id: fd_tweaks
        y: parent.height-height
    }

    // this accepts files dragged into the window
    DropArea {

        anchors.fill: parent
        enabled: !modal.visible && !pasteExisting.visible

        onDropped: (event) => {

            var found = false;

            if(event.hasUrls) {

                for(var i in event.urls) {

                    var suffix1 = PQCScriptsFilesPaths.getSuffixLowerCase(event.urls[i])
                    var suffix2 = PQCScriptsFilesPaths.getCompleteSuffixLowerCase(event.urls[i])
                    var mimetype = PQCScriptsImages.getMimetypeForFile(event.urls[i])
                    if(PQCImageFormats.getEnabledFormats().indexOf(suffix1) > -1 ||
                       PQCImageFormats.getEnabledFormats().indexOf(suffix2) > -1 ||
                       PQCImageFormats.getEnabledMimeTypes().indexOf(mimetype) > -1) {
                        loadNewPath(PQCScriptsFilesPaths.getDir(PQCScriptsFilesPaths.cleanPath(PQCScriptsFilesPaths.fromPercentEncoding(event.urls[i]))))
                        found = true
                        break;
                    }

                }

            }

            event.accepted = found

        }

        onEntered: (event) => {

            // do we accept the event?
            var found = false;

            // if there are urls:
            if(event.hasUrls) {

                // we look for the first url that is supported and load that one
                for(var i in event.urls) {

                    // suffix and mimetype
                    var suffix1 = PQCScriptsFilesPaths.getSuffixLowerCase(event.urls[i])
                    var suffix2 = PQCScriptsFilesPaths.getCompleteSuffixLowerCase(event.urls[i])
                    var mimetype = PQCScriptsImages.getMimetypeForFile(event.urls[i])
                    if(PQCImageFormats.getEnabledFormats().indexOf(suffix1) > -1 ||
                       PQCImageFormats.getEnabledFormats().indexOf(suffix2) > -1 ||
                       PQCImageFormats.getEnabledMimeTypes().indexOf(mimetype) > -1) {
                        found = true
                    }

                }

            }

            event.accepted = found

        }
    }

    PQPasteExistingConfirm {
        id: pasteExisting
        anchors.fill: parent
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(filedialog_top.opacity > 0) {

                if(what === "forceCloseEverything") {

                    filedialog_top.handleHiding(true)

                } else if(what === "keyEvent") {

                    if(PQCSettings.interfacePopoutFileDialogNonModal)
                        return

                    // close something
                    if(param[0] === Qt.Key_Escape) {

                        filedialog_top.handleHiding(false)

                    } else {

                        if((param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) && (pasteExisting.visible || modal.visible)) {
                            if(modal.visible)
                                modal.button1.clicked()
                            else
                                pasteExisting.hide()
                        } else if(param[0] === Qt.Key_L && param[1] === Qt.ControlModifier) {
                            PQCNotify.filedialogShowAddressEdit(true)
                        } else
                            fd_fileview.handleKeyEvent(param[0], param[1])
                    }
                } else if(what === "forceClose") {
                    pasteExisting.hide()
                    modal.hide()
                }

            }
        }

        function onFiledialogGoBackInHistory() {
            filedialog_top.goBackInHistory()
        }

        function onFiledialogGoForwardsInHistory() {
            filedialog_top.goForwardsInHistory()
        }

        function onFiledialogLoadNewPath(path : string) {
            filedialog_top.loadNewPath(path)
        }

        function onFiledialogClose() {
            filedialog_top.handleHiding(true)
        }

    }

    PQFileDeleteConfirm {

        id: modal

        onAccepted: {
            if(action == "trash") {
                for(var key1 in payload)
                    PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.entriesFileDialog[payload[key1]])
                PQCConstants.filedialogCurrentSelection = []
                fd_fileview.currentCuts = []
            } else if(action == "permanent") {
                for(var key2 in payload)
                    PQCScriptsFileManagement.deletePermanent(PQCFileFolderModel.entriesFileDialog[payload[key2]])
                PQCConstants.filedialogCurrentSelection = []
                fd_fileview.currentCuts = []
            }
        }

    }

    Component.onCompleted: {

        const nothingHere = (PQCFileFolderModel.firstFolderMainViewLoaded && PQCFileFolderModel.countMainView === 0)

        if(!nothingHere) {

            // we default to showing the home folder
            var folder = PQCScriptsFilesPaths.getHomeDir()

            // if we remember the last location, load it
            if(PQCSettings.filedialogStartupRestorePrevious) {

                var tmp = PQCScriptsFileDialog.getLastLocation()
                if(tmp !== "") folder = tmp

            } else if(PQCSettings.filedialogStartupRestoreCustom &&
                    PQCSettings.filedialogStartupRestoreCustomFolder !== "" &&
                    PQCScriptsFilesPaths.doesItExist(PQCSettings.filedialogStartupRestoreCustomFolder))
                folder = PQCSettings.filedialogStartupRestoreCustomFolder


            // if an image was loaded with PhotoQt, we make sure the file dialog opens at the right location
            if(PQCFileFolderModel.currentFile !== "" && !PQCScriptsFilesPaths.areDirsTheSame(folder, PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)))
                folder = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)

            // load folder
            PQCFileFolderModel.folderFileDialog = folder

            // this needs to come here as we do not want a property binding
            // otherwise the history feature wont work
            PQCConstants.filedialogHistory.push(folder)

        }

        // PQCConstants.idOfVisibleItem might contain the settingsmanager id
        // this happens when the type of file dialog for the integrated ui is changed there
        // in that case we don't want to show the filedialog onCompleted()
        if((dontAnimateFirstStart || nothingHere) && PQCConstants.idOfVisibleItem === "") {

            if(nothingHere) {

                PQCFileFolderModel.folderFileDialog = PQCFileFolderModel.fileInFolderMainView

                // this needs to come here as we do not want a property binding
                // otherwise the history feature wont work
                PQCConstants.filedialogHistory.push(PQCFileFolderModel.folderFileDialog)

            }

            filedialog_top.handleShowing()

        }

    }

    Connections {

        target: PQCFileFolderModel

        function onFirstFolderMainViewLoadedChanged() {
            if(PQCFileFolderModel.firstFolderMainViewLoaded && PQCFileFolderModel.countMainView === 0)
                filedialog_top.handleShowing()
        }

    }

    Connections {

        target: PQCScriptsShortcuts

        function onSendShortcutShowFile(path : string) {
            PQCFileFolderModel.folderFileDialog = PQCScriptsFilesPaths.getDir(path)
        }

    }

    function loadNewPath(path : string) {
        PQCNotify.filedialogShowAddressEdit(false)
        PQCFileFolderModel.folderFileDialog = PQCScriptsFilesPaths.cleanPath(path)
        if(PQCConstants.filedialogHistoryIndex < PQCConstants.filedialogHistory.length-1)
            PQCConstants.filedialogHistory.splice(PQCConstants.filedialogHistoryIndex+1)
        if(PQCConstants.filedialogHistory[PQCConstants.filedialogHistory.length-1] !== path)
            PQCConstants.filedialogHistory.push(path)
        PQCConstants.filedialogHistoryIndex = PQCConstants.filedialogHistory.length-1
    }

    function goBackInHistory() {
        PQCNotify.filedialogShowAddressEdit(false)
        PQCConstants.filedialogHistoryIndex = Math.max(0, PQCConstants.filedialogHistoryIndex-1)
        PQCFileFolderModel.folderFileDialog = PQCConstants.filedialogHistory[PQCConstants.filedialogHistoryIndex]
    }

    function goForwardsInHistory() {
        PQCNotify.filedialogShowAddressEdit(false)
        PQCConstants.filedialogHistoryIndex = Math.min(PQCConstants.filedialogHistory.length-1, PQCConstants.filedialogHistoryIndex+1)
        PQCFileFolderModel.folderFileDialog = PQCConstants.filedialogHistory[PQCConstants.filedialogHistoryIndex]
    }

    function handleShowing() {

        fd_fileview.ignoreMouseEvents = true

        // check that the correct folder is loaded
        if(PQCFileFolderModel.currentIndex !== -1 && PQCFileFolderModel.currentFile !== "") {
            var mv_folder = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
            if(PQCFileFolderModel.folderFileDialog !== mv_folder)
                loadNewPath(mv_folder)
        }

        if(PQCFileFolderModel.currentFile !== "")
            fd_fileview.setCurrentIndexToCurrentFile()

    }

    function handleHiding(forceHide : bool) {

        if(forceHide) {

            // it is possible that some element (slider/...) had key focus -> reset that
            filedialog_top.forceActiveFocus()
            PQCNotify.filedialogShowAddressEdit(false)
            filedialog_top.hide()
            PQCConstants.idOfVisibleItem = ""

            return

        }

        // pasting existing files
        if(pasteExisting.visible)
            pasteExisting.hide()

        // modal confirmation popup
        else if(modal.visible)
            modal.hide()

        else if(PQCConstants.filedialogAddressEditVisible)
            PQCNotify.filedialogShowAddressEdit(false)

        // current selection
        else if(PQCConstants.filedialogCurrentSelection.length)
            PQCConstants.filedialogCurrentSelection = []

        // current cut
        else if(fd_fileview.currentCuts.length)
            fd_fileview.currentCuts = []

        // file dialog
        else {

            // it is possible that some element (slider/...) had key focus -> reset that
            filedialog_top.forceActiveFocus()
            PQCNotify.filedialogShowAddressEdit(false)
            filedialog_top.hide()
            PQCConstants.idOfVisibleItem = ""

        }

    }

}
