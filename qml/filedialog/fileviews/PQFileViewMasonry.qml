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
import QtQuick.Layouts

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsOther
import PQCScriptsFileDialog

import "../../elements"
import "./parts"

Flickable {

    id: masonryview

    width: parent.width
    height: parent.height
    contentWidth: parent.width
    contentHeight: theflow.height

    property alias model: rptr.model

    property bool isCurrentView: false

    property int currentIndex: -1
    onCurrentIndexChanged: {
        if(!isCurrentView) return
        view_top.currentIndex = currentIndex
    }

    property list<int> possibleWidthStepSize: [1, 50, 100, 150]
    property int widthStepSize: possibleWidthStepSize[PQCSettings.filedialogMasonryUniformAggressiveness]
    property real unitWidth: theflow.width/Math.max(1, Math.floor(theflow.width/masonryview.widthStepSize)) - 2*PQCSettings.filedialogElementPadding

    ScrollBar.vertical: PQVerticalScrollBar { id: view_scroll }

    Flow {

        id: theflow

        width: parent.width-(view_scroll.visible ? view_scroll.width : 0)
        height: childrenRect.height

        Repeater {

            id: rptr

            model: 0

            property int finishedSetup: 0
            onModelChanged: {
                finishedSetup = 0
                fd_breadcrumbs.setBusyLoadingFolder(true)
            }
            onFinishedSetupChanged: {
                if(finishedSetup > model-5) {
                    fd_breadcrumbs.setBusyLoadingFolder(false)
                }
            }

            Loader {

                id: ldr

                required property int index

                asynchronous: true
                active: rptr.finishedSetup+2>=index

                sourceComponent:
                Rectangle {

                    id: deleg

                    property int index: ldr.index
                    property int modelData: ldr.index // some of the parts expect the index to be stored as modelData

                    property string currentPath: PQCFileFolderModel.entriesFileDialog[index] // qmllint disable unqualified
                    property string currentFile: decodeURIComponent(PQCScriptsFilesPaths.getFilename(currentPath)) // qmllint disable unqualified
                    property int numberFilesInsideFolder: 0
                    property int padding: PQCSettings.filedialogElementPadding // qmllint disable unqualified
                    property bool isFolder: index < PQCFileFolderModel.countFoldersFileDialog
                    property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(currentPath) : view_top.currentFolderOnNetwork

                    property bool isHovered: masonryview.currentIndex===deleg.index
                    property bool isSelected: view_top.currentSelection.indexOf(deleg.index)>-1

                    property real fullThumbWidth: filethumb.visible ? (filethumb.sourceSize.width * (height/filethumb.sourceSize.height)) : height

                    width: (masonryview.widthStepSize==1||!filethumb.visible) ?
                               fullThumbWidth :
                               Math.min(theflow.width, Math.max(masonryview.unitWidth, (masonryview.unitWidth+padding) * Math.floor(fullThumbWidth/masonryview.unitWidth)-padding))
                    height: 50 + PQCSettings.filedialogZoom*3

                    clip: true
                    color: "transparent"
                    border.width: PQCSettings.filedialogElementPadding
                    border.color: PQCLook.baseColorAccent // qmllint disable unqualified

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
                        width: deleg.height - 2*PQCSettings.filedialogElementPadding
                        height: deleg.height - 2*PQCSettings.filedialogElementPadding

                    }

                    // the file thumbnail
                    PQFileThumb {

                        id: filethumb

                        x: PQCSettings.filedialogElementPadding
                        y: PQCSettings.filedialogElementPadding
                        width: deleg.width - 2*PQCSettings.filedialogElementPadding
                        height: deleg.height - 2*PQCSettings.filedialogElementPadding

                        clip: true

                        sourceSize: undefined

                        onStatusChanged: {
                            if(status == Image.Ready || status == Image.Error)
                                rptr.finishedSetup += 1
                        }

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
                        anchors.bottomMargin: filename_label.height
                        color: PQCLook.inverseColor
                        opacity: deleg.isHovered ? 0.3 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        visible: opacity>0

                    }

                    // selecting an item
                    Rectangle {

                        id: rect_selecting

                        anchors.fill: parent
                        anchors.bottomMargin: filename_label.height
                        color: PQCLook.inverseColor
                        opacity: deleg.isSelected ? 0.6 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        visible: opacity>0

                    }

                    /************************************************************/
                    // FILE NAME AND SIZE

                    // the filename - icon view
                    Rectangle {
                        id: filename_label
                        width: parent.width
                        height: parent.height/4 + (deleg.isSelected||deleg.isHovered ? 10 : 0)
                        Behavior on height { NumberAnimation { duration: 200 } }
                        y: parent.height-height
                        color: deleg.isSelected ? PQCLook.baseColorHighlight : (deleg.isHovered ? PQCLook.baseColorAccent : PQCLook.transColor ) // qmllint disable unqualified
                        Behavior on color { ColorAnimation { duration: 200 } }

                        PQText {
                            id: filename
                            anchors.fill: parent
                            anchors.margins: 5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            maximumLineCount: 2
                            elide: Text.ElideMiddle
                            text: deleg.currentFile
                        }

                        Image {
                            x: (parent.width-width-5)
                            y: (parent.height-height-5)
                            source: "image://svg/:/light/folder.svg" // qmllint disable unqualified
                            height: 16
                            mipmap: true
                            width: height
                            opacity: 0.3
                            visible: deleg.isFolder && folderthumb.curnum>0 // qmllint disable unqualified
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

                        PQText {
                            id: numberOfFilesInsideFolder
                            x: 10
                            y: (parent.height-height)/2-2
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
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

                        PQTextS {
                            id: numberThumbInsideFolder
                            x: 5
                            y: (parent.height-height)/2-2
                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            elide: Text.ElideMiddle
                            text: "#"+folderthumb.curnum
                        }
                    }

                    // load async for files
                    Timer {
                        running: !deleg.isFolder // qmllint disable unqualified
                        interval: 1
                        onTriggered: {
                            fileinfo.text = PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.currentPath) // qmllint disable unqualified
                        }
                    }

                    // load async for folders
                    Timer {
                        running: deleg.isFolder // qmllint disable unqualified
                        interval: 1
                        onTriggered: {
                            PQCScriptsFileDialog.getNumberOfFilesInFolder(deleg.currentPath, function(count) { // qmllint disable unqualified
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

                        id: masonrymousearea

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        tooltipReference: fd_splitview // qmllint disable unqualified

                        Connections {
                            target: contextmenu
                            function onVisibleChanged() {
                                if(contextmenu.visible)
                                    masonrymousearea.closeTooltip()
                            }
                        }

                        acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.BackButton|Qt.ForwardButton

    // TODO
                        drag.target: PQCSettings.filedialogDragDropFileviewMasonry ? dragHandler : undefined // qmllint disable unqualified

                        drag.onActiveChanged: {
                            if(drag.active) {
                                // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                                fd_places.dragItemIndex = deleg.modelData // qmllint disable unqualified
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

                            if(!contextmenu.visible)
                                view_top.currentIndex = deleg.modelData
                            else
                                contextmenu.setCurrentIndexToThisAfterClose = deleg.modelData

                            // we only need this when a potential drag might occur
                            // otherwise no need to load this drag thumbnail
                            deleg.dragImageSource = "image://dragthumb/" + deleg.currentPath + ":://::" + (view_top.currentFileSelected ? view_top.currentSelection.length : 1)

                        }

                        onEntered: {

                            text = handleEntriesMouseEnter(deleg.modelData, deleg.currentPath, filethumb.status, fileinfo.text,
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
                        opacity: (selectmouse.containsMouse||view_top.currentSelection.indexOf(deleg.modelData)!==-1)
                                        ? 0.8
                                        : (view_top.currentIndex===deleg.modelData
                                                ? 0.8 : 0)
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        Image {
                            anchors.fill: parent
                            source: (view_top.currentSelection.indexOf(deleg.modelData)!==-1 ? ("image://svg/:/" + PQCLook.iconShade + "/deselectfile.svg") : ("image://svg/:/" + PQCLook.iconShade + "/selectfile.svg")) // qmllint disable unqualified
                            mipmap: true
                            opacity: selectmouse.containsMouse ? 0.8 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            PQMouseArea {
                                id: selectmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if(!view_top.currentFileSelected) {
                                        view_top.shiftClickIndexStart = deleg.modelData
                                        view_top.currentSelection.push(deleg.modelData)
                                        view_top.currentSelectionChanged()
                                    } else {
                                        view_top.shiftClickIndexStart = -1
                                        view_top.currentSelection = view_top.currentSelection.filter(item => item!==deleg.modelData)
                                    }
                                }
                                onEntered: {
                                    view_top.currentIndex = deleg.modelData
                                }
                            }
                        }

                    }

                    Drag.active: masonrymousearea.drag.active
                    Drag.mimeData: {
                        if(!view_top.currentFileSelected) {
                            return ({"text/uri-list": encodeURI("file:"+deleg.currentPath)})
                        } else {
                            var uris = []
                            for(var i in view_top.currentSelection)
                                uris.push(encodeURI("file:" + PQCFileFolderModel.entriesFileDialog[view_top.currentSelection[i]])) // qmllint disable unqualified
                            return ({"text/uri-list": uris})
                        }
                    }
                    Drag.dragType: Drag.Automatic

                    // this is set in the mousearea's onPressed signal
                    // this avoid loading all drag thumbnails at the start
                    property string dragImageSource: ""
                    Drag.imageSource: dragImageSource

                }

            }

        }

    }

    function goDownARow() {

        // if(view_top.currentIndex === -1)
        //     view_top.currentIndex = 0
        // else
        //     view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex + Math.floor(gridview.width/gridview.cellWidth))

    }

    function goDownSomeRows() {

        // if(view_top.currentIndex === -1)
        //     view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, 4*Math.floor(gridview.width/gridview.cellWidth))
        // else
        //     view_top.currentIndex = Math.min(PQCFileFolderModel.countAllFileDialog-1, view_top.currentIndex + 5*Math.floor(gridview.width/gridview.cellWidth))

    }

    function goUpARow() {

        // if(view_top.currentIndex === -1)
        //     view_top.currentIndex = PQCFileFolderModel.countAllFileDialog-1
        // else
        //     view_top.currentIndex = Math.max(0, view_top.currentIndex - Math.floor(gridview.width/gridview.cellWidth))

    }

    function goUpSomeRows() {

        // if(view_top.currentIndex === -1)
        //     view_top.currentIndex = Math.max(0, PQCFileFolderModel.countAllFileDialog-1 - 4*Math.floor(gridview.width/gridview.cellWidth))
        // else
        //     view_top.currentIndex = Math.max(0, view_top.currentIndex - 5*Math.floor(gridview.width/gridview.cellWidth))

    }

}
