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
import PhotoQt.Shared

/* :-)) <3 */

Rectangle {

    id: filedialog_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: PQCConstants.windowWidth
    property int parentHeight: PQCConstants.windowHeight

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    property string thisis: "filedialog"
    property alias placesWidth: fd_places.width
    property alias fileviewWidth: fd_fileview.width
    property alias splitview: fd_splitview

    property bool dontAnimateFirstStart: PQCConstants.startupFilePath===""

    // the first entry of the history list is set in Component.onCompleted
    // we do not want a property binding here!
    property list<string> history: []
    property int historyIndex: 0

    property bool splitDividerHovered: false

    property bool isPopout: PQCSettings.interfacePopoutFileDialog

    SystemPalette { id: pqtPalette }

    color: pqtPalette.base

    state: isPopout ?
               "popout" :
               ""

    states: [
        State {
            name: "popout"
            PropertyChanges {
                filedialog_top.width: filedialog_top.parentWidth
                filedialog_top.height: filedialog_top.parentHeight
                filedialog_top.opacity: 0
            }
        }
    ]

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: dontAnimateFirstStart ? 0 : 200 } }

    onOpacityChanged: {
        if(opacity > 0.99999)
            dontAnimateFirstStart = false

        if(opacity > 0 && !isPopout)
            PQCNotify.windowTitleOverride(qsTranslate("actions", "File Dialog"))
        else if(opacity === 0)
            PQCNotify.windowTitleOverride("")

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    PQBreadCrumbs {
        id: fd_breadcrumbs
    }

    SplitView {

        id: fd_splitview

        y: fd_breadcrumbs.height
        width: parent.width
        height: parent.height-fd_breadcrumbs.height-fd_tweaks.height
        anchors.topMargin: fd_breadcrumbs.height
        anchors.bottomMargin: fd_tweaks.height

        // Show larger handle with triple dash
        handle: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            color: SplitHandle.hovered ? pqtPalette.alternateBase : PQCLook.baseBorder
            Behavior on color { ColorAnimation { duration: 200 } }
            onColorChanged:
                filedialog_top.splitDividerHovered = SplitHandle.hovered

            Image {
                y: (fd_splitview.height-height)/2
                width: fd_splitview.implicitWidth
                height: fd_splitview.implicitHeight
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/handle.svg"
            }

        }

        PQPlaces {
            id: fd_places
            SplitView.minimumWidth: (PQCSettings.filedialogPlaces || PQCSettings.filedialogDevices) ? 100 : 5
            SplitView.preferredWidth: PQCSettings.filedialogPlacesWidth
            onWidthChanged: {
                PQCSettings.filedialogPlacesWidth = Math.round(width)
            }

        }

        PQFileView {
            id: fd_fileview

            SplitView.minimumWidth: 200
            SplitView.fillWidth: true
        }

    }

    PQTweaks {
        id: fd_tweaks
        y: parent.height-height
    }

    PQPasteExistingConfirm {
        id: pasteExisting
        anchors.fill: parent
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === filedialog_top.thisis)
                    filedialog_top.showFileDialog()

            } else if(filedialog_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(filedialog_top.popoutWindowUsed && PQCSettings.interfacePopoutFileDialogNonModal)
                        return

                    // close something
                    if(param[0] === Qt.Key_Escape) {

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
                        else
                            filedialog_top.hideFileDialog()

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
            filedialog_top.hideFileDialog()
        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: !PQCWindowGeometry.filedialogForcePopout
        enabled: visible
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQCSettings.interfacePopoutFileDialog ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                filedialog_top.hideFileDialog()
                if(PQCSettings.interfacePopoutFileDialog)
                    filedialog_window.close()
                PQCSettings.interfacePopoutFileDialog = !PQCSettings.interfacePopoutFileDialog
                filedialog_top.opacityChanged()
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
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

        if(PQCSettings.filedialogKeepLastLocation)
            PQCFileFolderModel.folderFileDialog = PQCScriptsFileDialog.getLastLocation()
        else
            PQCFileFolderModel.folderFileDialog = PQCScriptsFilesPaths.getHomeDir()

        // this needs to come here as we do not want a property binding
        // otherwise the history feature wont work
        PQCConstants.filedialogHistory.push(PQCFileFolderModel.folderFileDialog)

        if(dontAnimateFirstStart)
            showFileDialog()

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

    function showFileDialog() {

        PQCConstants.idOfVisibleItem = "filedialog"
        fd_fileview.ignoreMouseEvents = true

        isPopout = PQCSettings.interfacePopoutFileDialog || PQCWindowGeometry.filedialogForcePopout

        // check that the correct folder is loaded
        if(PQCFileFolderModel.currentIndex !== -1 && PQCFileFolderModel.currentFile !== "") {
            var mv_folder = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
            if(PQCFileFolderModel.folderFileDialog !== mv_folder)
                loadNewPath(mv_folder)
        }

        if(PQCFileFolderModel.currentFile !== "")
            fd_fileview.setCurrentIndexToCurrentFile()

        opacity = 1
        if(popoutWindowUsed)
            filedialog_window.visible = true

    }

    function hideFileDialog() {

        if(pasteExisting.visible) {
            pasteExisting.hide()
            return
        }
        if(modal.visible) {
            modal.hide()
            return
        }

        // it is possible that some element (slider/...) had key focus -> reset that
        filedialog_top.forceActiveFocus()

        PQCNotify.filedialogShowAddressEdit(false)
        opacity = 0
        if(popoutWindowUsed)
            filedialog_window.visible = false

        isPopout = Qt.binding(function() { return PQCSettings.interfacePopoutFileDialog })

        // for the file dialog, setting the window.visible property to false is not sufficient, we still need to call this
        PQCNotify.loaderRegisterClose(thisis)
        PQCConstants.idOfVisibleItem = ""

    }

}
