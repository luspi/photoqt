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
import QtQuick.Controls
import PhotoQt.Shared

/* :-)) <3 */

ListView {

    id: listview

    orientation: Qt.Vertical

    anchors.fill: parent

    model: 0

    ScrollBar.vertical: PQFileDialogScrollBar { id: view_scroll }

    SystemPalette { id: pqtPalette }

    onContentYChanged: {
        // this check makes sure that value is not reset when a directory is reloaded due to a change
        if(contentY > 0)
            cacheContentY = contentY
    }

    PQScrollManager {
        flickable: listview
        cursorShape: Qt.PointingHandCursor
    }

    visible: isCurrentView
    property bool isCurrentView: PQCSettings.filedialogLayout==="list"

    // this pair stores the current scroll position
    // this way we can preserve that position when the content of the current directory changes
    property string cachePath: ""
    property real cacheContentY: 0.

    onCurrentIndexChanged: {
        if(!isCurrentView) return
        if(view_top.currentIndex !== currentIndex)
            view_top.currentIndex = currentIndex
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
        property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(currentPath) : view_top.currentFolderOnNetwork

        width: listview.width

        // without the parseInt() the value is taken for some reason as string resulting in a height of "15" + "xx" = "15xx"
        height: 15 + parseInt(PQCSettings.filedialogZoom)

        color: pqtPalette.base
        border.width: 1
        border.color: pqtPalette.alternateBase

        Rectangle {
            anchors.fill: parent
            color: modelData%2 ? pqtPalette.base : pqtPalette.alternateBase
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

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file thumbnail
        PQFileThumb {

            id: filethumb

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the folder thumbnails
        PQFolderThumb {

            id: folderthumb

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.height - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        /************************************************************/
        // HIGHLIGHT/SELECT

        // hovering an item
        Rectangle {

            id: rect_hovering

            anchors.fill: parent
            anchors.leftMargin: fileicon.width+2
            color: pqtPalette.text
            property bool toShow: listview.currentIndex===deleg.modelData
            opacity: toShow ? 0.6 : 0
            // Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

        }

        // selecting an item
        Rectangle {

            id: rect_selecting

            anchors.fill: parent
            color: pqtPalette.text
            property bool toShow: !(PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)===-1)
            opacity: toShow ? 0.8 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

        }

        /************************************************************/
        // FILE NAME AND SIZE

        // the filename
        Label {
            id: filename_label
            opacity: view_top.currentFileCut ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            x: fileicon.width+10
            width: deleg.width-fileicon.width-fileinfo.width-10
            height: deleg.height
            font.pointSize: PQCLook.fontSize
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            text: deleg.currentFile
            color: (!rect_hovering.toShow&&!rect_selecting.toShow) ? pqtPalette.text : pqtPalette.base
        }

        // the file size/number of images
        Label {
            id: fileinfo
            opacity: view_top.currentFileCut ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            x: deleg.width-width-10
            height: deleg.height
            font.pointSize: PQCLook.fontSize
            verticalAlignment: Text.AlignVCenter
            text: ""
            color: (!rect_hovering.toShow&&!rect_selecting.toShow) ? pqtPalette.text : pqtPalette.base
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

        // load async for folders
        Timer {
            running: deleg.isFolder
            interval: 1
            onTriggered: {
                PQCScriptsFileDialog.getNumberOfFilesInFolder(deleg.currentPath, function(count) {
                    if(count > 0) {
                        deleg.numberFilesInsideFolder = count
                        fileinfo.text = (count===1 ? qsTranslate("filedialog", "%1 image").arg(count) : qsTranslate("filedialog", "%1 images").arg(count))
                        if(count === 1)
                            fileinfo.text = qsTranslate("filedialog", "%1 image").arg(count)
                        else
                            fileinfo.text = qsTranslate("filedialog", "%1 images").arg(count)
                    }
                })
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
                    fd_places.dragItemIndex = deleg.modelData
                    fd_places.dragReordering = false
                    fd_places.dragItemId = deleg.currentPath
                }
                deleg.Drag.drop();
                if(!drag.active) {
                    // reset variables used for drag/drop
                    fd_places.dragItemIndex = -1
                    fd_places.dragItemId = ""
                }
            }

            onPressed: {

                if(!PQCConstants.isContextmenuOpen("fileviewentry"))
                    view_top.currentIndex = deleg.modelData
                // else
                    // contextmenu.setCurrentIndexToThisAfterClose = deleg.modelData

                // we only need this when a potential drag might occur
                // otherwise no need to load this drag thumbnail
                deleg.dragImageSource = "image://dragthumb/" + deleg.currentPath + ":://::" + (view_top.currentFileSelected ? PQCConstants.filedialogCurrentSelection.length : 1)

            }

            onEntered: {
                if(view_top.ignoreMouseEvents || PQCConstants.isContextmenuOpen("filedialogsettingsmenu"))
                    return

                if(!PQCConstants.isContextmenuOpen("fileviewentry")) {
                    view_top.currentIndex = deleg.modelData
                    resetCurrentIndex.stop()
                } /*else
                    contextmenu.setCurrentIndexToThisAfterClose = deleg.modelData*/

            }

            onExited: {
                view_top.handleEntriesMouseExit(deleg.modelData)
            }

            property var storeClicks: ({})

            onClicked: (mouse) => {

                view_top.handleEntriesMouseClick(deleg.modelData, deleg.currentPath, deleg.isFolder,
                                                 mouse.modifiers, mouse.button)

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
                    view_top.currentIndex = deleg.modelData
                // else
                    // contextmenu.setCurrentIndexToThisAfterClose = deleg.modelData

            }

            onEntered: {

                tooltip = handleEntriesMouseEnter(deleg.modelData, deleg.currentPath, filethumb.status, fileinfo.text,
                                                  deleg.isFolder, deleg.numberFilesInsideFolder, folderthumb.curnum)

            }

            onExited: {
                view_top.handleEntriesMouseExit(deleg.modelData)
            }

            onClicked: (mouse) => {

                view_top.handleEntriesMouseClick(deleg.modelData, deleg.currentPath, deleg.isFolder,
                                                 mouse.modifiers, mouse.button)

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
                            : (view_top.currentIndex===deleg.modelData
                                    ? 0.4 : 0)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Image {
                anchors.fill: parent
                source: (PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)!==-1 ? ("image://svg/:/" + PQCLook.iconShade + "/deselectfile.svg") : ("image://svg/:/" + PQCLook.iconShade + "/selectfile.svg"))
                mipmap: true
                opacity: selectmouse.containsMouse ? 0.8 : 0.4
                Behavior on opacity { NumberAnimation { duration: 200 } }
                MouseArea {
                    id: selectmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData) === -1) {
                            view_top.shiftClickIndexStart = deleg.modelData
                            PQCConstants.filedialogCurrentSelection.push(deleg.modelData)
                            PQCConstants.filedialogCurrentSelectionChanged()
                        } else {
                            view_top.shiftClickIndexStart = -1
                            PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==deleg.modelData)
                        }
                    }
                    onEntered: {
                        view_top.currentIndex = deleg.modelData
                    }
                }
            }

        }

        Drag.active: listmousearea.drag.active || listthumbmousearea.drag.active
        Drag.mimeData: {
            if(!view_top.currentFileSelected) {
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

    }

    function goDownARow() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = 0
        else
            view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex+1)

    }

    function goDownSomeRows() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, 4)
        else
            view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex + 5)

    }

    function goUpARow() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = PQCFileFolderModel.countAllFileDialog-1
        else
            view_top.currentIndex = Math.max(0, view_top.currentIndex-1)

    }

    function goUpSomeRows() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = Math.max(0, PQCFileFolderModel.countAllFileDialog-1 - 4)
        else
            view_top.currentIndex = Math.max(0, view_top.currentIndex - 5)

    }

}
