/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    id: openfile_top

    // size is tied to mainwindow
    // anchoring to parent doesn't work here, as element is wrapped inside Loader
    x: mainwindow.x
    y: mainwindow.y
    width: mainwindow.width
    height: mainwindow.height

    // background color is a semi-transparent black
    color: "#88000000"

    // opacity is animated
    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    // mouse area preventing HandleMouseMovements from catching mouse events
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        hoverEnabled: true
    }

    // Some variables used by the various subelements
    OpenVariables { id: openvariables }

    // Bread crumb navigation
    BreadCrumbs { id: breadcrumbs }

    // Seperating Line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: breadcrumbs.bottom
        height: 1
        color: "white"
    }

    // The three panes holding userplaces, folders, files
    SplitView {

        id: splitview

        // anchors to surrounding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: tweaks.top
        anchors.top: breadcrumbs.bottom

        // panes are laid out horizontally
        orientation: Qt.Horizontal

        // the dragsource, used to distinguish between dragging new folder and reordering userplaces
        property var dragSource: undefined

        // left pane holding some places
        UserPlaces { id: userplaces }

        // middle pane showing the found subfolders
        Folders { id: folders }

        // right pane showing the image files found
        FilesView { id: filesview }

    }

    // Seperating Line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: splitview.bottom
        height: 1
        color: "white"
    }

    // the bottom part contains some tweaks and settings that directly affect the open file element
    Tweaks { id: tweaks }

    // some signals used to pass on shortcuts
    signal highlightEntry(var distance)
    signal highlightFirst()
    signal highlightLast()
    signal loadEntry()

    Connections {
        target: call
        onOpenfileShow:
            show()
        onOpenfileNavigateToCurrentDir:
            openvariables.currentDirectory = dir
        onShortcut: {
            if(!openfile_top.visible) return
            if(sh == "Escape")
                hide()
            else if(sh == "Alt+Left") {
                if(openvariables.currentFocusOn == "userplaces")
                    openvariables.currentFocusOn = "filesview"
                else if(openvariables.currentFocusOn == "folders")
                    openvariables.currentFocusOn = settings.openHideUserPlaces ? "filesview" : "userplaces"
                else
                    openvariables.currentFocusOn = "folders"
            } else if(sh == "Alt+Right") {
                if(openvariables.currentFocusOn == "userplaces")
                    openvariables.currentFocusOn = "folders"
                else if(openvariables.currentFocusOn == "folders")
                    openvariables.currentFocusOn = "filesview"
                else
                    openvariables.currentFocusOn = settings.openHideUserPlaces ? "folders" : "userplaces"
            } else if(sh == "Enter" || sh == "Return")
                loadEntry()
            else if(sh == "Up")
                highlightEntry(-1)
            else if(sh == "Down")
                highlightEntry(1)
            else if(sh == "Page Up") {
                highlightEntry(-5)
            } else if(sh == "Page Down") {
                highlightEntry(5)
            } else if(sh == "Ctrl+Up")
                highlightFirst()
            else if(sh == "Ctrl+Down")
                highlightLast()
            else if(sh == "Alt+Up")
                openvariables.currentDirectory += "/.."
            else if(sh == "Ctrl+B")
                Handle.goBackInHistory()
            else if(sh == "Ctrl+F")
                Handle.goForwardsInHistory()
            else if(sh == "Ctrl++" || sh == "Ctrl+=")
                tweaks.tweaksZoom.tweaksZoomSlider.value += Math.min(3, tweaks.tweaksZoom.tweaksZoomSlider.maximumValue-tweaks.tweaksZoom.tweaksZoomSlider.value)
            else if(sh == "Ctrl+-")
                tweaks.tweaksZoom.tweaksZoomSlider.value -= Math.min(3, tweaks.tweaksZoom.tweaksZoomSlider.value-tweaks.tweaksZoom.tweaksZoomSlider.minimumValue)
            else if(sh == "Ctrl+H" || sh == "Alt+.")
                settings.openShowHiddenFilesFolders = !settings.openShowHiddenFilesFolders
        }
        onCloseAnyElement:
            if(openfile_top.visible)
                hide()

    }

    // a notifier informing the user about the possible shortcuts. Only shown at first open until user clicks it away ('do not show again' checkbox checked by default)
    ShortcutNotifier {

        id: openshortcuts
        area: "openfile"

    }

    // react to changes in folder, userplaces, and storage devices
    Connections {
        target: watcher
        onFolderUpdated: {
            Handle.loadDirectoryFolders()
            Handle.loadDirectoryFiles()
        }
        onUserPlacesUpdated:
            Handle.loadUserPlaces()
        onStorageInfoUpdated:
            Handle.loadStorageInfo()
    }

    // react to changes in settings
    Connections {
        target: settings
        onOpenShowHiddenFilesFoldersChanged:
            Handle.loadDirectory()
    }

    Connections {
        target: imageformats
        onEnabledFileformatsChanged: imageformatsChangedSoReload.restart()
    }
    Timer {
        id: imageformatsChangedSoReload
        interval: 250
        repeat: false
        onTriggered: {
            Handle.loadDirectoryFolders()
            Handle.loadDirectoryFiles()
        }
    }

    Component.onCompleted: {

        // We needto do that here, as it seems to be not possible to compose a string in the dict definition
        // (i.e., when defining the property, inside the {})
        //: Refers to the three areas in the element for opening files
        openshortcuts.shortcuts[strings.get("alt") + " + " + strings.get("left") + "/" + strings.get("right")] = em.pty+qsTr("Move focus between Places/Folders/Fileview")
        //: Entry refers to the list of files and folders loaded in the element for opening files
        openshortcuts.shortcuts[strings.get("up") + "/" + strings.get("down")] = em.pty+qsTr("Go up/down an entry")
        //: Entry refers to the list of files and folders loaded in the element for opening files
        openshortcuts.shortcuts[strings.get("page up") + "/" +strings.get("page down")] = em.pty+qsTr("Move 5 entries up/down")
        //: Entry refers to the list of files and folders loaded in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + " + strings.get("up") + "/" + strings.get("down")] = em.pty+qsTr("Move to the first/last entry")
        //: This refers to loading the parent folder of the currently loaded folder in the element for opening files
        openshortcuts.shortcuts[strings.get("alt") + " + " + strings.get("up")] = em.pty+qsTr("Go one folder level up")
        //: The history is the list of visited folders in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + B/F"] = em.pty+qsTr("Go backwards/forwards in history");
        //: Item refers to the image highlighted in the element for opening files
        openshortcuts.shortcuts[strings.get("enter") + "/" + strings.get("return")] = em.pty+qsTr("Load the currently highlighted item")
        //: The files is the list of files in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + +/-"] = em.pty+qsTr("Zoom files in/out")
        //: The files/folders is the list of files/folders in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + H " + em.pty+qsTr("or") + " " + strings.get("alt") + " + ."] = em.pty+qsTr("Show/Hide hidden files/folders")
        openshortcuts.shortcuts[strings.get("escape")] = em.pty+qsTr("Cancel")

        openshortcuts.display()

    }

    // show the element
    function show() {

        verboseMessage("OpenFile/OpenFile", "show()")

        // First load, restore last folder of previous session
        if(settings.openKeepLastLocation && variables.currentDir === "")
            openvariables.currentDirectory = getanddostuff.getOpenFileLastLocation()
        // First load, set element to current working directory
        else if(!settings.openKeepLastLocation && variables.currentDir === "")
            openvariables.currentDirectory = getanddostuff.getCurrentWorkingDirectory()
        // Second+ load, load same folder as current main image
        else if(variables.currentDir !== "")
            openvariables.currentDirectory = variables.currentDir

        opacity = 1

        // reset history
        openvariables.history = []
        openvariables.historypos = -1

        // block interface
        variables.guiBlocked = true

        // focus on edit rect (and select all)
        filesview.filesEditRect.selectAll()
        // Make sure the current directory is set for checking
        // necessary as when element is closed the watcher is paused until this moment
        watcher.startWatchingForOpenFileElement(openvariables.currentDirectory)

        // Make sure the userplaces are up to date
        Handle.loadUserPlaces()
        // Make sure the latest changes to the folder are loaded
        Handle.loadDirectory()
        // add current folder to history (first entry)
        Handle.addToHistory()

    }
    // hide element
    function hide() {
        verboseMessage("OpenFile/OpenFile", "hide()")
        opacity = 0
        variables.guiBlocked = false
        // stop watching for changes
        watcher.stopWatchingForOpenFileElement()
    }

}
