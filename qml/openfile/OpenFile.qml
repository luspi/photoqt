import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    id: openfile_top

    x: mainwindow.x
    y: mainwindow.y
    width: mainwindow.width
    height: mainwindow.height

    color: "#88000000"

    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: 200 } }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        hoverEnabled: true
    }

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

    SplitView {

        id: splitview

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: tweaks.top
        anchors.top: breadcrumbs.bottom

        orientation: Qt.Horizontal

        property int hoveringOver: -1
        property var dragSource: undefined

        UserPlaces { id: userplaces }

        Folders { id: folders }

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

    Tweaks { id: tweaks }

    Connections {
        target: call
        onOpenfileShow:
            show()
        onShortcut: {
            if(!openfile_top.visible) return
            if(sh == "Escape")
                hide()
            else if(sh == "Alt+Left") {
                if(openvariables.currentFocusOn == "userplaces")
                    openvariables.currentFocusOn = "filesview"
                else if(openvariables.currentFocusOn == "folders")
                    openvariables.currentFocusOn = "userplaces"
                else
                    openvariables.currentFocusOn = "folders"
            } else if(sh == "Alt+Right") {
                if(openvariables.currentFocusOn == "userplaces")
                    openvariables.currentFocusOn = "folders"
                else if(openvariables.currentFocusOn == "folders")
                    openvariables.currentFocusOn = "filesview"
                else
                    openvariables.currentFocusOn = "userplaces"
            } else if(sh == "Up") {
                if(filesview.filesView.currentIndex > 0)
                    filesview.filesView.currentIndex -= 1
            } else if(sh == "Down") {
                if(filesview.filesView.currentIndex < filesview.filesViewModel.count-1)
                    filesview.filesView.currentIndex += 1
            } else if(sh == "Page Up") {
                if(filesview.filesView.currentIndex > 4)
                    filesview.filesView.currentIndex -= 5
                else
                    filesview.filesView.currentIndex = 0
            } else if(sh == "Page Down") {
                if(filesview.filesView.currentIndex < filesview.filesViewModel.count-5)
                    filesview.filesView.currentIndex += 5
                else
                    filesview.filesView.currentIndex = filesview.filesViewModel.count-1
            } else if(sh == "Ctrl+Up")
                filesview.filesView.currentIndex = 0
            else if(sh == "Ctrl+Down")
                filesview.filesView.currentIndex = filesview.filesViewModel.count-1
            else if(sh == "Alt+Up")
                openvariables.currentDirectory += "/.."
            else if(sh == "Ctrl+B")
                Handle.goBackInHistory()
            else if(sh == "Ctrl+F")
                Handle.goForwardsInHistory()
            else if(sh == "Ctrl++")
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

    ShortcutNotifier {

        id: openshortcuts
        area: "openfile"

    }

    Connections {
        target: watcher
        onFolderUpdated:
            Handle.loadDirectoryFolders()
        onUserPlacesUpdated:
            Handle.loadUserPlaces()
        onStorageInfoUpdated:
            Handle.loadStorageInfo()
    }

    Connections {
        target: settings
        onOpenShowHiddenFilesFoldersChanged: {
            Handle.loadDirectory()
        }
    }

    Component.onCompleted: {

        // We needto do that here, as it seems to be not possible to compose a string in the dict definition
        // (i.e., when defining the property, inside the {})
        //: Refers to the three areas in the element for opening files
        openshortcuts.shortcuts[strings.get("alt") + " + " + strings.get("left") + "/" + strings.get("right")] = qsTr("Move focus between Places/Folders/Fileview")
        //: Entry refers to the list of files and folders loaded in the element for opening files
        openshortcuts.shortcuts[strings.get("up") + "/" + strings.get("down")] = qsTr("Go up/down an entry")
        //: Entry refers to the list of files and folders loaded in the element for opening files
        openshortcuts.shortcuts[strings.get("page up") + "/" +strings.get("page down")] = qsTr("Move 5 entries up/down")
        //: Entry refers to the list of files and folders loaded in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + " + strings.get("up") + "/" + strings.get("down")] = qsTr("Move to the first/last entry")
        //: This refers to loading the parent folder of the currently loaded folder in the element for opening files
        openshortcuts.shortcuts[strings.get("alt") + " + " + strings.get("up")] = qsTr("Go one folder level up")
        //: The history is the list of visited folders in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + B/F"] = qsTr("Go backwards/forwards in history");
        //: Item refers to the image highlighted in the element for opening files
        openshortcuts.shortcuts[strings.get("enter") + "/" + strings.get("return")] = qsTr("Load the currently highlighted item")
        //: The files is the list of files in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + +/-"] = qsTr("Zoom files in/out")
        //: The files/folders is the list of files/folders in the element for opening files
        openshortcuts.shortcuts[strings.get("ctrl") + " + H " + qsTr("or") + " " + strings.get("alt") + " + ."] = qsTr("Show/Hide hidden files/folders")
        openshortcuts.shortcuts[strings.get("escape")] = qsTr("Cancel")

        openshortcuts.display()

    }

    function show() {
        opacity = 1
        openvariables.history = []
        openvariables.historypos = -1
        variables.guiBlocked = true
        Handle.addToHistory()
        filesview.filesEditRect.selectAll()
    }
    function hide() {
        opacity = 0
        variables.guiBlocked = false
    }

}
