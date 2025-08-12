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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

GridView {

    id: gridview

    anchors.fill: parent

    model: 0

    property int baseSize: 50 + PQCSettings.filedialogZoom*3

    property bool ignoreMouseEvents: false
    interactive: !ignoreMouseEvents

    cellWidth: width / Math.floor(width / baseSize)
    cellHeight: baseSize

    ScrollBar.vertical: PQFileDialogScrollBar { id: view_scroll }

    SystemPalette { id: pqtPalette }

    onContentYChanged: {
        // this check makes sure that value is not reset when a directory is reloaded due to a change
        if(contentY > 0)
            cacheContentY = contentY
    }

    PQScrollManager {
        flickable: gridview
        cursorShape: Qt.PointingHandCursor
    }

    visible: isCurrentView
    property bool isCurrentView: PQCSettings.filedialogLayout==="grid"

    // this pair stores the current scroll position
    // this way we can preserve that position when the content of the current directory changes
    property string cachePath: ""
    property real cacheContentY: 0.

    onCurrentIndexChanged: {
        if(!isCurrentView) return
        if(view_top.currentIndex !== currentIndex)
            view_top.currentIndex = currentIndex
        if(!gridview.flicking)
            gridview.positionViewAtIndex(currentIndex, GridView.Contain)
    }

    onModelChanged: {
        // same folder reloaded
        if(PQCFileFolderModel.folderFileDialog === cachePath) {

            // restore position
            gridview.contentY = cacheContentY

        // new folder loaded
        } else {

            // reset position
            gridview.contentY = 0
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

        property bool isHovered: gridview.currentIndex===deleg.modelData
        property bool isSelected: PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)>-1

        visible: currentPath!=""

        width: gridview.cellWidth
        height: gridview.cellHeight

        color: pqtPalette.base
        border.width: 1
        border.color: PQCLook.baseBorder

        Item {
            id: dragHandler

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.width - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file type icon
        PQFileIcon {

            id: fileicon

            gridlike: true

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.width - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file thumbnail
        PQFileThumb {

            id: filethumb

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.width - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the folder thumbnails
        PQFolderThumb {

            id: folderthumb

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: deleg.width - 2*PQCSettings.filedialogElementPadding
            height: deleg.height - 2*PQCSettings.filedialogElementPadding

        }

        /************************************************************/
        // HIGHLIGHT/SELECT

        // hovering an item
        Rectangle {

            id: rect_hovering

            anchors.fill: parent
            color: pqtPalette.text
            opacity: deleg.isHovered ? 0.3 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

        }

        // selecting an item
        Rectangle {

            id: rect_selecting

            anchors.fill: parent
            color: pqtPalette.text
            opacity: deleg.isSelected ? 0.6 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

        }

        /************************************************************/
        // FILE NAME AND SIZE

        // the filename - icon view
        Loader {

            active: PQCSettings.filedialogLabelsShowGrid||deleg.isFolder

            sourceComponent:
            Item {
                id: filename_label
                width: deleg.width
                height: deleg.height/4 + (deleg.isSelected||deleg.isHovered ? 10 : 0)
                Behavior on height { NumberAnimation { duration: 200 } }
                y: deleg.height-height
                Rectangle {
                    anchors.fill: parent
                    color: deleg.isSelected ? pqtPalette.text : (deleg.isHovered ? pqtPalette.alternateBase : pqtPalette.base)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    border.width: 1
                    border.color: pqtPalette.button
                }

                Label {
                    id: filename
                    anchors.fill: parent
                    anchors.margins: 5
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    elide: Text.ElideMiddle
                    text: deleg.currentFile
                    font.pointSize: PQCLook.fontSize
                    color: deleg.isSelected ? pqtPalette.base : pqtPalette.text
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Image {
                    x: (parent.width-width-5)
                    y: (parent.height-height-5)
                    source: "image://svg/:/light/folder.svg"
                    height: 16
                    mipmap: true
                    width: height
                    opacity: 0.3
                    visible: deleg.isFolder && folderthumb.curnum>0
                }
            }

        }

        // this is a dummy item to be able to reuse some logic from other views
        Item {
            id: fileinfo
            property string text: ""
        }

        /************************************************************/
        // meta information

        // how many files inside folder
        Rectangle {
            id: numberOfFilesInsideFolder_cont
            x: (deleg.width-width)-5
            y: 5
            width: numberOfFilesInsideFolder.width + 20
            height: 30
            radius: 5
            color: "#000000"
            opacity: 0.8
            visible: numberOfFilesInsideFolder.text !== "" && numberOfFilesInsideFolder.text !== "0"

            Label {
                id: numberOfFilesInsideFolder
                x: 10
                y: (parent.height-height)/2-2
                font.weight: PQCLook.fontWeightBold
                font.pointSize: PQCLook.fontSize
                elide: Text.ElideMiddle
                text: deleg.numberFilesInsideFolder
            }
        }

        // which # thumbnail inside folder
        Rectangle {
            id: numberThumbInsideFolderCont
            x: (deleg.width-width)/2
            y: 10
            width: numberThumbInsideFolder.width + 10
            height: 20
            radius: 3
            color: "#000000"
            opacity: 0.6
            visible: folderthumb.curnum>0 && folderthumb.visible

            Label {
                id: numberThumbInsideFolder
                x: 5
                y: (parent.height-height)/2-2
                font.weight: PQCLook.fontWeightBold
                font.pointSize: PQCLook.fontSizeS
                elide: Text.ElideMiddle
                text: "#"+folderthumb.curnum
            }
        }

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

        // mouse area handling general mouse events
        PQMouseArea {

            id: gridmousearea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Connections {
                target: PQCConstants
                function onWhichContextMenusOpenChanged() {
                    if(PQCConstants.isContextmenuOpen("fileviewentry"))
                        gridmousearea.closeTooltip()
                }
            }

            acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.BackButton|Qt.ForwardButton

            drag.target: PQCSettings.filedialogDragDropFileviewGrid ? dragHandler : undefined

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

                tooltip = handleEntriesMouseEnter(deleg.modelData, deleg.currentPath, filethumb.status, fileinfo.text,
                                        deleg.isFolder, deleg.numberFilesInsideFolder, folderthumb.curnum)

            }

            onExited: {
                if(!selectmouse.containsMouse)
                    view_top.handleEntriesMouseExit(deleg.modelData)
            }

            onClicked: (mouse) => {

                view_top.handleEntriesMouseClick(deleg.modelData, deleg.currentPath, deleg.isFolder,
                                                 mouse.modifiers, mouse.button)

            }

            // detect Ctrl+scroll for zooming
            onWheel: (wheel) => {
                if(wheel.modifiers === Qt.ControlModifier) {
                    PQCSettings.filedialogZoom += (wheel.angleDelta.y < 0 ? -2 : 2)
                    wheel.accepted = true
                    return
                }
                wheel.accepted = false
            }

        }

        /************************************************************/
        // + ICON TO SELECT/ - ICON TO DESELECT
        // has to be on top of main mouse area

        Rectangle {
            id: selectedornot
            x: 5
            y: 5
            width: 30
            height: 30
            radius: 5

            color: "#bbbbbb"
            opacity: (selectmouse.containsMouse||PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)!==-1)
                            ? 0.8
                            : (view_top.currentIndex===deleg.modelData
                                    ? 0.8 : 0)
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
                        if(!view_top.currentFileSelected) {
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

        Drag.active: gridmousearea.drag.active
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
            view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex + Math.floor(gridview.width/gridview.cellWidth))

    }

    function goDownSomeRows() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, 4*Math.floor(gridview.width/gridview.cellWidth))
        else
            view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex + 5*Math.floor(gridview.width/gridview.cellWidth))

    }

    function goUpARow() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = PQCFileFolderModel.countAllFileDialog-1
        else
            view_top.currentIndex = Math.max(0, view_top.currentIndex - Math.floor(gridview.width/gridview.cellWidth))

    }

    function goUpSomeRows() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = Math.max(0, PQCFileFolderModel.countAllFileDialog-1 - 4*Math.floor(gridview.width/gridview.cellWidth))
        else
            view_top.currentIndex = Math.max(0, view_top.currentIndex - 5*Math.floor(gridview.width/gridview.cellWidth))

    }

}
