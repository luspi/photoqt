import QtQuick
import QtQuick.Controls

import PQCScriptsFileManagement
import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsFileDialog
import PQCNotify
import PQCWindowGeometry

import "../elements"

Rectangle {

    id: filedialog_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    property string thisis: "filedialog"
    property alias placesWidth: fd_places.width
    property alias fileviewWidth: fd_fileview.width
    property alias splitview: fd_splitview

    // the first entry of the history list is set in Component.onCompleted
    // we do not want a property binding here!
    property var history: []
    property int historyIndex: 0

    property bool splitDividerHovered: false

    property bool isPopout: PQCSettings.interfacePopoutFileDialog||PQCWindowGeometry.filedialogForcePopout

    color: PQCLook.baseColor

    state: isPopout ?
               "popout" :
               ""

    states: [
        State {
            name: "popout"
            PropertyChanges {
                target: filedialog_top
                width: parentWidth
                height: parentHeight
                opacity: 1
            }
        }
    ]

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

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
            color: SplitHandle.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
            Behavior on color { ColorAnimation { duration: 200 } }
            onColorChanged:
                splitDividerHovered = SplitHandle.hovered

            Image {
                y: (parent.height-height)/2
                width: parent.implicitWidth
                height: parent.implicitHeight
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/white/handle.svg"
            }

        }

        PQPlaces {
            id: fd_places
            SplitView.minimumWidth: (PQCSettings.filedialogPlaces || PQCSettings.filedialogDevices) ? 100 : 5
            SplitView.preferredWidth: PQCSettings.filedialogPlacesWidth
            onWidthChanged: {
                PQCSettings.filedialogPlacesWidth = width
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
        target: loader
        function onPassOn(what, param) {
            if(what === "show") {

                if(param === thisis)
                    showFileDialog()

            } else if(filedialog_top.opacity > 0) {

                if(what === "keyEvent") {

                    // close something
                    if(param[0] === Qt.Key_Escape) {

                        // pasting existing files
                        if(pasteExisting.visible)
                            pasteExisting.hide()

                        // modal confirmation popup
                        else if(modal.visible)
                            modal.hide()

                        // context menu
                        else if(fd_fileview.fileviewContextMenu.visible)
                            fd_fileview.fileviewContextMenu.close()

                        // settings menu
                        else if(fd_breadcrumbs.topSettingsMenu.visible)
                            fd_breadcrumbs.topSettingsMenu.close()

                        // folder list menu
                        else if(fd_breadcrumbs.folderListMenuOpen)
                            fd_breadcrumbs.closeFolderListMenu()

                        else if(fd_breadcrumbs.isEditVisible())
                            fd_breadcrumbs.disableAddressEdit()

                        // current selection
                        else if(fd_fileview.currentSelection.length)
                            fd_fileview.currentSelection = []

                        // current cut
                        else if(fd_fileview.currentCuts.length)
                            fd_fileview.currentCuts = []

                        // file dialog
                        else
                            hideFileDialog()

                    } else {

                        if(fd_breadcrumbs.isEditVisible()) {
                            fd_breadcrumbs.handleKeyEvent(param[0], param[1])
                            return
                        }

                        if((param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) && (pasteExisting.visible || modal.visible)) {
                            if(modal.visible)
                                modal.button1.clicked()
                            else
                                pasteExisting.hide()
                        } else if(param[0] === Qt.Key_L && param[1] === Qt.ControlModifier) {
                            fd_breadcrumbs.enableAddressEdit()
                        } else
                            fd_fileview.handleKeyEvent(param[0], param[1])
                    }
                } else if(what === "forceClose") {
                    pasteExisting.hide()
                    modal.hide()
                    hideFileDialog()
                }

            }
        }
    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: !PQCWindowGeometry.filedialogForcePopout
        enabled: visible
        source: "image://svg/:/white/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfacePopoutFileDialog ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                filedialog_top.hideFileDialog()
                if(PQCSettings.interfacePopoutFileDialog)
                    close()
                PQCSettings.interfacePopoutFileDialog = !PQCSettings.interfacePopoutFileDialog
                PQCNotify.executeInternalCommand("__open")
            }
        }
    }

    PQModal {

        id: modal

        button1.text: button1.genericStringOk
        button2.text: button1.genericStringCancel

        onAccepted: {
            if(action == "trash") {
                for(var key in payload)
                    PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.entriesFileDialog[payload[key]])
                fd_fileview.currentSelection = []
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
        history.push(PQCFileFolderModel.folderFileDialog)
    }

    function loadNewPath(path) {
        fd_breadcrumbs.disableAddressEdit()
        PQCFileFolderModel.folderFileDialog = path
        if(historyIndex < history.length-1)
            history.splice(historyIndex+1)
        if(history[history.length-1] !== path)
            history.push(path)
        historyIndex = history.length-1
    }

    function goBackInHistory() {
        fd_breadcrumbs.disableAddressEdit()
        historyIndex = Math.max(0, historyIndex-1)
        PQCFileFolderModel.folderFileDialog = history[historyIndex]
    }

    function goForwardsInHistory() {
        fd_breadcrumbs.disableAddressEdit()
        historyIndex = Math.min(history.length-1, historyIndex+1)
        PQCFileFolderModel.folderFileDialog = history[historyIndex]
    }

    function showFileDialog() {
        opacity = 1
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

        fd_breadcrumbs.disableAddressEdit()
        opacity = 0
        loader.elementClosed(thisis)
    }

}
