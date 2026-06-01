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

ListView {

    id: listview

    orientation: Qt.Vertical

    anchors.fill: parent

    model: 0

    ScrollBar.vertical: PQVerticalScrollBar { id: view_scroll }

    onContentYChanged: {
        // this check makes sure that value is not reset when a directory is reloaded due to a change
        if(contentY > 0)
            cacheContentY = contentY
    }

    PQScrollManager {
        flickable: listview
        cursorShape: Qt.PointingHandCursor
    }

    // this pair stores the current scroll position
    // this way we can preserve that position when the content of the current directory changes
    property string cachePath: ""
    property real cacheContentY: 0.

    onCurrentIndexChanged: {
        if(PQGlobalItems.filedialogFileview === undefined) return
        if(PQGlobalItems.filedialogFileview.currentIndex !== currentIndex)
            PQGlobalItems.filedialogFileview.currentIndex = currentIndex
        if(!listview.flicking)
            listview.positionViewAtIndex(currentIndex, ListView.Contain)
    }

    onModelChanged: {
        // same folder reloaded
        if(PQCFileFolderModel.folderFileDialog === cachePath) {

            // restore position
            listview.contentY = cacheContentY

        // new folder loaded
        } else {

            // reset position
            listview.contentY = 0
            cachePath = PQCFileFolderModel.folderFileDialog
            cacheContentY = 0

        }

    }

    delegate:
    Rectangle {

        id: deleg

        required property int modelData

        // this check is necessary as some data might be available quicker than other. This avoid errant warnings.
        property string currentPath: modelData < PQCFileFolderModel.entriesFileDialog.length ? PQCFileFolderModel.entriesFileDialog[modelData] : ""
        property string currentFile: decodeURIComponent(PQCScriptsFilesPaths.getFilename(currentPath))
        property int numberFilesInsideFolder: 0
        property int padding: PQCSettings.filedialogElementPadding
        property bool isFolder: modelData < PQCFileFolderModel.countFoldersFileDialog
        property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(currentPath) : PQGlobalItems.filedialogFileview.currentFolderOnNetwork

        property bool isFileCut: PQGlobalItems.filedialogFileview.currentCuts.indexOf(deleg.modelData) > -1

        width: listview.width

        // without the parseInt() the value is taken for some reason as string resulting in a height of "15" + "xx" = "15xx"
        height: (PQCSettings.filedialogThumbnailSizeFollowsGlobalThumbnails ? PQCSettings.thumbnailsSize/2: parseInt(PQCSettings.filedialogZoom/2))

        color: palette.base
        border.width: 1
        border.color: palette.alternateBase

        Rectangle {
            anchors.fill: parent
            color: deleg.modelData%2 ? palette.base : palette.alternateBase
            opacity: 0.5
        }

        Item {
            id: dragHandler

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file type icon
        PQFileIcon {

            id: fileicon

            isFileCut: deleg.isFileCut
            onNetwork: deleg.onNetwork
            isFolder: deleg.isFolder
            currentPath: deleg.currentPath

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file thumbnail
        PQFileThumb {

            id: filethumb

            isFileCut: deleg.isFileCut
            isFolder: deleg.isFolder
            onNetwork: deleg.onNetwork
            currentPath: deleg.currentPath
            myIndex: deleg.modelData

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

            function onHideFileIcon() {
                fileicon.source = ""
            }

            function onShowFileIcon() {
                fileicon.source = fileicon.sourceString
            }

        }

        // the folder thumbnails
        PQFolderThumb {

            id: folderthumb

            isFileCut: deleg.isFileCut
            myIndex: deleg.modelData

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

            function onHideFileIcon() {
                fileicon.source = ""
            }

        }

        /************************************************************/
        // HIGHLIGHT/SELECT

        PQHighlightMarker {
            id: higlighselectmarker
            anchors.leftMargin: fileicon.width+2
            visible: listview.currentIndex===deleg.modelData || !(PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)===-1)
        }

        /************************************************************/
        // FILE NAME AND SIZE

        // the filename
        PQText {
            id: filename_label
            opacity: deleg.isFileCut ? 0.3 : 1
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            x: fileicon.width+10
            width: deleg.width-fileicon.width-fileinfo.width-10
            height: deleg.height
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            text: deleg.currentFile
            color: palette.text
        }

        // the file size/number of images
        PQText {
            id: fileinfo
            opacity: deleg.isFileCut ? 0.3 : 1
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            x: deleg.width-width-10
            height: deleg.height
            verticalAlignment: Text.AlignVCenter
            text: ""
            color: palette.text
        }

        /************************************************************/
        // meta information

        // load async for files
        Timer {
            running: !deleg.isFolder
            interval: 1
            onTriggered: {
                fileinfo.text = PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.currentPath)
            }
        }

        /************************************************************/

        // mouse area handling file icon events
        MouseArea {

            id: listthumbmousearea

            anchors.fill: filethumb

            hoverEnabled: true
            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor

            drag.target: PQCSettings.filedialogDragDropFileviewList ? dragHandler : undefined

            drag.onActiveChanged: {
                if(drag.active) {
                    // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                    PQGlobalItems.filedialogPlaces.dragItemIndex = deleg.modelData
                    PQGlobalItems.filedialogPlaces.dragReordering = false
                    PQGlobalItems.filedialogPlaces.dragItemId = deleg.currentPath
                }
                deleg.Drag.drop();
                if(!drag.active) {
                    // reset variables used for drag/drop
                    PQGlobalItems.filedialogPlaces.dragItemIndex = -1
                    PQGlobalItems.filedialogPlaces.dragItemId = ""
                }
            }

            onPressed: {

                if(!PQCConstants.isContextmenuOpen("fileviewentry"))
                    PQGlobalItems.filedialogFileview.currentIndex = deleg.modelData

                // we only need this when a potential drag might occur
                // otherwise no need to load this drag thumbnail
                deleg.dragImageSource = "image://dragthumb/" + deleg.currentPath + ":://::" + (PQGlobalItems.filedialogFileview.currentFileSelected ? PQCConstants.filedialogCurrentSelection.length : 1)

            }

            onEntered: {
                if(PQGlobalItems.filedialogFileview.ignoreMouseEvents || PQCConstants.isContextmenuOpen("filedialogsettingsmenu"))
                    return

                if(!PQCConstants.isContextmenuOpen("fileviewentry")) {
                    PQGlobalItems.filedialogFileview.currentIndex = deleg.modelData
                }
            }

            onExited: {
                PQGlobalItems.filedialogFileview.handleEntriesMouseExit(deleg.modelData)
            }

            property var storeClicks: ({})

            onClicked: (mouse) => {

                PQGlobalItems.filedialogFileview.handleEntriesMouseClick(deleg.modelData, deleg.currentPath, deleg.isFolder, mouse.modifiers, mouse.button)

            }

        }

        // mouse area handling general mouse events
        PQMouseArea {

            id: listmousearea

            anchors.fill: parent
            anchors.leftMargin: fileicon.width

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Connections {
                target: PQCConstants
                function onWhichContextMenusOpenChanged() {
                    if(PQCConstants.isContextmenuOpen("fileviewentry"))
                        listmousearea.closeTooltip()
                }
            }

            acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.BackButton|Qt.ForwardButton

            onPressed: {

                if(!PQCConstants.isContextmenuOpen("fileviewentry"))
                    PQGlobalItems.filedialogFileview.currentIndex = deleg.modelData

            }

            onEntered: {

                tooltip = ""
                tooltip = PQGlobalItems.filedialogFileview.handleEntriesMouseEnter(deleg.modelData, deleg.currentPath, filethumb.status, fileinfo.text,
                                        deleg.isFolder, deleg.numberFilesInsideFolder, folderthumb.curnum)

            }

            onExited: {
                PQGlobalItems.filedialogFileview.handleEntriesMouseExit(deleg.modelData)
            }

            onClicked: (mouse) => {

                PQGlobalItems.filedialogFileview.handleEntriesMouseClick(deleg.modelData, deleg.currentPath, deleg.isFolder, mouse.modifiers, mouse.button)

            }

        }

        /************************************************************/
        // + ICON TO SELECT/ - ICON TO DESELECT
        // has to be on top of main mouse area

        Rectangle {
            id: selectedornot
            x: fileicon.x + (fileicon.width-width)/2
            y: fileicon.y + (fileicon.height-height)/2
            width: 30
            height: 30
            radius: 5

            color: "#bbbbbb"
            opacity: (selectmouse.containsMouse||PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)!==-1)
                            ? 0.8
                            : (PQGlobalItems.filedialogFileview.currentIndex===deleg.modelData
                                    ? 0.4 : 0)
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

            Image {
                anchors.fill: parent
                source: (PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)!==-1 ? ("image://svg/:/" + PQCLook.iconShade + "/deselectfile.svg") : ("image://svg/:/" + PQCLook.iconShade + "/selectfile.svg"))
                mipmap: true
                opacity: selectmouse.containsMouse ? 0.8 : 0.4
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                MouseArea {
                    id: selectmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData) === -1) {
                            PQGlobalItems.filedialogFileview.shiftClickIndexStart = deleg.modelData
                            PQCConstants.filedialogCurrentSelection.push(deleg.modelData)
                            PQCConstants.filedialogCurrentSelectionChanged()
                        } else {
                            PQGlobalItems.filedialogFileview.shiftClickIndexStart = -1
                            PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==deleg.modelData)
                        }
                    }
                    onEntered: {
                        PQGlobalItems.filedialogFileview.currentIndex = deleg.modelData
                    }
                }
            }

        }

        Drag.active: listmousearea.drag.active || listthumbmousearea.drag.active
        Drag.mimeData: {
            if(!PQGlobalItems.filedialogFileview.currentFileSelected) {
                return ({"text/uri-list": encodeURI("file:"+deleg.currentPath)})
            } else {
                var uris = []
                for(var i in PQCConstants.filedialogCurrentSelection)
                    uris.push(encodeURI("file:" + PQCFileFolderModel.entriesFileDialog[PQCConstants.filedialogCurrentSelection[i]]))
                return ({"text/uri-list": uris})
            }
        }
        Drag.dragType: Drag.Automatic

        // this is set in the mousearea's onPressed signal
        // this avoid loading all drag thumbnails at the start
        property string dragImageSource: ""
        Drag.imageSource: dragImageSource

        Component.onCompleted: {
            PQCScriptsFileDialog.getNumberOfFilesInFolder(deleg.currentPath)
        }

        Connections {
            target: PQCScriptsFileDialog
            function onFiguredOutNumberOfFilesInFolder(path : string, num : int) {
                if(deleg.currentPath !== path) return
                if(num > 0) {
                    deleg.numberFilesInsideFolder = num
                    fileinfo.text = (num===1 ? qsTranslate("filedialog", "%1 image").arg(num) : qsTranslate("filedialog", "%1 images").arg(num))
                }
            }
        }

    }

    function goDownARow() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = 0
        else
            PQGlobalItems.filedialogFileview.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, PQGlobalItems.filedialogFileview.currentIndex+1)

    }

    function goDownSomeRows() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, 4)
        else
            PQGlobalItems.filedialogFileview.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, PQGlobalItems.filedialogFileview.currentIndex + 5)

    }

    function goUpARow() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = PQCFileFolderModel.countAllFileDialog-1
        else
            PQGlobalItems.filedialogFileview.currentIndex = Math.max(0, PQGlobalItems.filedialogFileview.currentIndex-1)

    }

    function goUpSomeRows() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = Math.max(0, PQCFileFolderModel.countAllFileDialog-1 - 4)
        else
            PQGlobalItems.filedialogFileview.currentIndex = Math.max(0, PQGlobalItems.filedialogFileview.currentIndex - 5)

    }

}
