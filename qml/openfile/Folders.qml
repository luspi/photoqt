import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1

import "../elements"

Rectangle {

    id: folderlist

    Layout.minimumWidth: 200
    width: settings.openFoldersWidth
    onWidthChanged:
        saveFolderWidth.start()

    color: activeFocus ? "#44000055" : "#44000000"
    clip: true

    Timer {
        id: saveFolderWidth
        interval: 250
        repeat: false
        running: false
        onTriggered:
            settings.openFoldersWidth = width
    }

    property string dir_path: getanddostuff.getHomeDir()
    property var folders: []

    signal focusOnFilesView()
    signal focusOnUserPlaces()

    ListView {

        id: folderlistview
        anchors.fill: parent

        highlight: Rectangle { color: "#DD5d5d5d"; radius: 5 }
        highlightMoveDuration: 50

        property string highlightedFolder: ""

        model: ListModel { id: folderlistmodel; }

        onCurrentIndexChanged:{
            if(!activeFocus)
                folderlist.forceActiveFocus()
        }

        delegate: Rectangle {
            width: folderlist.width
            height: folder_txt.height+10
            color: index%2==0 ? "#88000000" : "#44000000"

            Image {
                id: folder_img
                source: "image://icon/folder"
                width: folder_txt.height-4
                y: 7
                x: 7
                height: width
            }

            Text {
                y: 5
                x: 5 + folder_img.width+5
                id: folder_txt
                width: folderlist.width-(x+5)
                text: "<b>" + folder + "</b>" + ((counter==0||folder=="..") ? "" : " <i>(" + counter + ")</i>")
                color: "white"
                font.pointSize: 11
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onEntered:
                    folderlistview.currentIndex = index
                onClicked: {
                    // Context Menu, except on top entry ('go up a level' item)
                    if (mouse.button == Qt.RightButton && folder != "..")
                        contextmenu.popup()
                    else if(mouse.button == Qt.LeftButton)
                        loadCurrentDirectory(dir_path + "/" + folder)
                }
            }

            ContextMenu {

                id: contextmenu

                MenuItem {
                    text: qsTr("Add to Favourites")
                    onTriggered: getanddostuff.addToUserPlaces(dir_path + "/" + folder)
                }

                MenuItem {
                    text: qsTr("Load directory")
                    onTriggered: loadCurrentDirectory(dir_path + "/" + folder)
                }
            }
        }

    }

    Keys.onPressed: {

        verboseMessage("Folders.Keys::onPressed", event.modifiers + " - " + event.key)

        if(event.key === Qt.Key_Left) {

            if(event.modifiers & Qt.AltModifier)
                focusOnUserPlaces()

        } else if(event.key === Qt.Key_Right) {

            if(event.modifiers & Qt.AltModifier)
                focusOnFilesView()

        } else if(event.key === Qt.Key_Up) {
            if(event.modifiers & Qt.ControlModifier)
                focusOnFirstItem()
            else if(event.modifiers & Qt.AltModifier)
                moveOneLevelUp()
            else
                focusOnPrevItem()
        } else if(event.key === Qt.Key_Down) {
            if(event.modifiers & Qt.ControlModifier)
                focusOnLastItem()
            else
                focusOnNextItem()
        } else if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
            loadCurrentlyHighlightedFolder()
        else if(event.key === Qt.Key_PageDown)
            moveFocusFiveDown()
        else if(event.key === Qt.Key_PageUp)
            moveFocusFiveUp()
        else if(event.key === Qt.Key_F) {
            if(event.modifiers & Qt.ControlModifier)
                breadcrumbs.goForwardsInHistory()
        } else if(event.key === Qt.Key_B) {
            if(event.modifiers & Qt.ControlModifier)
                breadcrumbs.goBackInHistory()
        } else if(event.key === Qt.Key_Plus || event.key === Qt.Key_Equal) {
            if(event.modifiers & Qt.ControlModifier)
                tweaks.zoomLarger()
        } else if(event.key === Qt.Key_Minus) {
            if(event.modifiers & Qt.ControlModifier)
                tweaks.zoomSmaller()
        } else if(event.key === Qt.Key_Period) {
            if(event.modifiers & Qt.AltModifier)
                tweaks.toggleHiddenFolders()
        } else if(event.key === Qt.Key_H) {
            if(event.modifiers & Qt.ControlModifier)
                tweaks.toggleHiddenFolders()
        } else {
            var key = getanddostuff.convertQKeyToQString(event.key)
            for(var i = 0; i < folderlistmodel.count; ++i) {
                if(folderlistmodel.get(i).folder[0].toLowerCase() == key.toLowerCase()) {
                    folderlistview.currentIndex = i
                    break;
                }
            }
        }

    }

    function loadDirectory(path) {

        if(path == "") return

        verboseMessage("Folders::loadDirectory()", path)

        folderlistmodel.clear()
        folders = getanddostuff.getFoldersIn(path, true, tweaks.getHiddenFolders())
        dir_path = getanddostuff.removePrefixFromDirectoryOrFile(path)

        for(var j = 0; j < folders.length; ++j)
            folderlistmodel.append({"folder" : folders[j], "counter" : getanddostuff.getNumberFilesInFolder(dir_path + "/" + folders[j], tweaks.getFileTypeSelection())})

    }

    function loadCurrentlyHighlightedFolder() {
        verboseMessage("Folders::loadCurrentlyHighlightedFolder()", dir_path + "/" + folders[folderlistview.currentIndex])
        loadCurrentDirectory(dir_path + "/" + folders[folderlistview.currentIndex])
    }

    function focusOnNextItem() {
        verboseMessage("Folders::focusOnNextItem()", folderlistview.currentIndex + " - " + folderlistview.count)
        if(folderlistview.currentIndex+1 < folderlistview.count)
            folderlistview.currentIndex += 1
    }

    function focusOnPrevItem() {
        verboseMessage("Folders::focusOnPrevItem()", folderlistview.currentIndex)
        if(folderlistview.currentIndex > 0)
            folderlistview.currentIndex -= 1
    }

    function moveFocusFiveDown() {
        verboseMessage("Folders::moveFocusFiveDown()", folderlistview.currentIndex + " - " + folderlistview.count)
        if(folderlistview.currentIndex+5 < folderlistview.count)
            folderlistview.currentIndex += 5
        else
            folderlistview.currentIndex = folderlistview.count-1
    }

    function moveFocusFiveUp() {
        verboseMessage("Folders::moveFocusFiveUp()", folderlistview.currentIndex)
        if(folderlistview.currentIndex > 4)
            folderlistview.currentIndex -= 5
        else
            folderlistview.currentIndex  = 0
    }

    function focusOnLastItem() {
        verboseMessage("Folders::focusOnLastItem()", folderlistview.currentIndex + " - " + folderlistview.count)
        if(folderlistview.count > 0)
            folderlistview.currentIndex = folderlistview.count-1
    }

    function focusOnFirstItem() {
        verboseMessage("Folders::focusOnFirstItem()", folderlistview.currentIndex + " - " + folderlistview.count)
        if(folderlistview.count > 0)
            folderlistview.currentIndex = 0
    }

    function moveOneLevelUp() {

        verboseMessage("Folders::moveOneLevelUp()", "")

        var parts = dir_path.split("/")

        var moveup = 0
        for(var i = 0; i < parts.length; ++i) {
            if(parts[i] === "..")
                --moveup
            else
                ++moveup
        }

        if(moveup > 1)
            loadCurrentDirectory(dir_path + "/..")
    }

}
