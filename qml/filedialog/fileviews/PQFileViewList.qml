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

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsOther
import PQCScriptsFileDialog

import "../../elements"
import "./parts"

ListView {

    id: listview

    orientation: Qt.Vertical

    anchors.fill: parent

    model: 0

    ScrollBar.vertical: PQVerticalScrollBar { id: view_scroll }

    onCurrentIndexChanged: {
        view_top.currentIndex = currentIndex
    }

    delegate:
    Rectangle {

        id: listdeleg

        required property int modelData

        property string currentPath: PQCFileFolderModel.entriesFileDialog[modelData] // qmllint disable unqualified
        property string currentFile: decodeURIComponent(PQCScriptsFilesPaths.getFilename(currentPath)) // qmllint disable unqualified
        property int numberFilesInsideFolder: 0
        property int padding: PQCSettings.filedialogElementPadding // qmllint disable unqualified
        property bool isFolder: modelData < PQCFileFolderModel.countFoldersFileDialog
        property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(currentPath) : view_top.currentFolderOnNetwork

        width: listview.width
        height: 15 + PQCSettings.filedialogZoom

        color: "transparent"
        border.width: 1
        border.color: PQCLook.baseColorAccent // qmllint disable unqualified

        Rectangle {
            anchors.fill: parent
            color: PQCLook.transColor // qmllint disable unqualified
            opacity: listdeleg.isFolder ? 0.6 : (modelData%2 ? 0.55 : 0.5)
        }

        Item {
            id: dragHandler

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: listdeleg.height - 2*PQCSettings.filedialogElementPadding
            height: listdeleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file type icon
        PQFileIcon {

            id: fileicon

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: listdeleg.height - 2*PQCSettings.filedialogElementPadding
            height: listdeleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the file thumbnail
        PQFileThumb {

            id: filethumb

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: listdeleg.height - 2*PQCSettings.filedialogElementPadding
            height: listdeleg.height - 2*PQCSettings.filedialogElementPadding

        }

        // the folder thumbnails
        PQFolderThumb {

            id: folderthumb

            x: PQCSettings.filedialogElementPadding
            y: PQCSettings.filedialogElementPadding
            width: listdeleg.height - 2*PQCSettings.filedialogElementPadding
            height: listdeleg.height - 2*PQCSettings.filedialogElementPadding

        }

        /************************************************************/
        // HIGHLIGHT/SELECT

        // hovering an item
        Rectangle {

            id: rect_hovering

            anchors.fill: parent
            anchors.leftMargin: fileicon.width+2
            color: PQCLook.inverseColor
            property bool toShow: listview.currentIndex===listdeleg.modelData
            opacity: toShow ? 0.6 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

        }

        // selecting an item
        Rectangle {

            id: rect_selecting

            anchors.fill: parent
            // anchors.leftMargin: fileicon.width+2
            color: PQCLook.inverseColor
            property bool toShow: !(view_top.currentSelection.indexOf(listdeleg.modelData)===-1)
            opacity: toShow ? 0.8 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0

        }

        /************************************************************/
        // FILE NAME AND SIZE

        // the filename
        PQText {
            opacity: view_top.currentFileCut ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            x: fileicon.width+10
            width: listdeleg.width-fileicon.width-fileinfo.width-10
            height: listdeleg.height
            font.weight: rect_hovering.toShow || rect_selecting.toShow ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            text: listdeleg.currentFile
            animateColorChanged: false
            color: (!rect_hovering.toShow&&!rect_selecting.toShow) ? PQCLook.textColor : PQCLook.textInverseColor
        }

        // the file size/number of images
        PQText {
            id: fileinfo
            opacity: view_top.currentFileCut ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            x: listdeleg.width-width-10
            height: listdeleg.height
            font.weight: rect_hovering.toShow || rect_selecting.toShow ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
            verticalAlignment: Text.AlignVCenter
            text: ""
            animateColorChanged: false
            color: (!rect_hovering.toShow&&!rect_selecting.toShow) ? PQCLook.textColor : PQCLook.textInverseColor
        }

        /************************************************************/
        // meta information

        // load async for files
        Timer {
            running: !listdeleg.isFolder // qmllint disable unqualified
            interval: 1
            onTriggered: {
                fileinfo.text = PQCScriptsFilesPaths.getFileSizeHumanReadable(listdeleg.currentPath) // qmllint disable unqualified
            }
        }

        // load async for folders
        Timer {
            running: listdeleg.isFolder // qmllint disable unqualified
            interval: 1
            onTriggered: {
                PQCScriptsFileDialog.getNumberOfFilesInFolder(listdeleg.currentPath, function(count) { // qmllint disable unqualified
                    if(count > 0) {
                        listdeleg.numberFilesInsideFolder = count
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
        PQMouseArea {

            id: listthumbmousearea

            anchors.fill: filethumb

            hoverEnabled: true
            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor

            drag.target: PQCSettings.filedialogDragDropFileviewList? dragHandler : undefined // qmllint disable unqualified

            drag.onActiveChanged: {
                if(drag.active) {
                    // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                    fd_places.dragItemIndex = listdeleg.modelData // qmllint disable unqualified
                    fd_places.dragReordering = false
                    fd_places.dragItemId = listdeleg.currentPath
                }
                listdeleg.Drag.drop();
                if(!drag.active) {
                    // reset variables used for drag/drop
                    fd_places.dragItemIndex = -1
                    fd_places.dragItemId = ""
                }
            }

            onPressed: {

                if(!contextmenu.visible)
                    view_top.currentIndex = listdeleg.modelData
                else
                    contextmenu.setCurrentIndexToThisAfterClose = listdeleg.modelData

                // we only need this when a potential drag might occur
                // otherwise no need to load this drag thumbnail
                listdeleg.dragImageSource = "image://dragthumb/" + listdeleg.currentPath + ":://::" + (view_top.currentFileSelected ? view_top.currentSelection.length : 1)

            }

            onEntered: {
                if(view_top.ignoreMouseEvents || fd_breadcrumbs.topSettingsMenu.visible) // qmllint disable unqualified
                    return

                if(!contextmenu.visible) {
                    view_top.currentIndex = listdeleg.modelData
                    resetCurrentIndex.stop()
                } else
                    contextmenu.setCurrentIndexToThisAfterClose = listdeleg.modelData

            }

            onExited: {
                view_top.handleEntriesMouseExit(listdeleg.modelData)
            }

            property var storeClicks: ({})

            onClicked: (mouse) => {

                view_top.handleEntriesMouseClick(listdeleg.modelData, listdeleg.currentPath, listdeleg.isFolder,
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

            tooltipReference: fd_splitview // qmllint disable unqualified

            Connections {
                target: contextmenu
                function onVisibleChanged() {
                    if(contextmenu.visible)
                        listmousearea.closeTooltip()
                }
            }

            acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.BackButton|Qt.ForwardButton

            onPressed: {

                if(!contextmenu.visible)
                    view_top.currentIndex = listdeleg.modelData
                else
                    contextmenu.setCurrentIndexToThisAfterClose = listdeleg.modelData

                // we only need this when a potential drag might occur
                // otherwise no need to load this drag thumbnail
                listdeleg.dragImageSource = "image://dragthumb/" + listdeleg.currentPath + ":://::" + (view_top.currentFileSelected ? view_top.currentSelection.length : 1)

            }

            onEntered: {

                text = handleEntriesMouseEnter(listdeleg.modelData, listdeleg.currentPath, filethumb.status, fileinfo.text,
                                        listdeleg.isFolder, listdeleg.numberFilesInsideFolder, folderthumb.curnum)

            }

            onExited: {
                view_top.handleEntriesMouseExit(listdeleg.modelData)
            }

            onClicked: (mouse) => {

                view_top.handleEntriesMouseClick(listdeleg.modelData, listdeleg.currentPath, listdeleg.isFolder,
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
            opacity: (selectmouse.containsMouse||view_top.currentSelection.indexOf(listdeleg.modelData)!==-1)
                            ? 0.8
                            : (view_top.currentIndex===listdeleg.modelData
                                    ? 0.4 : 0)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Image {
                anchors.fill: parent
                source: (view_top.currentSelection.indexOf(listdeleg.modelData)!==-1 ? ("image://svg/:/" + PQCLook.iconShade + "/deselectfile.svg") : ("image://svg/:/" + PQCLook.iconShade + "/selectfile.svg")) // qmllint disable unqualified
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
                            view_top.shiftClickIndexStart = listdeleg.modelData
                            view_top.currentSelection.push(listdeleg.modelData)
                            view_top.currentSelectionChanged()
                        } else {
                            view_top.shiftClickIndexStart = -1
                            view_top.currentSelection = view_top.currentSelection.filter(item => item!==listdeleg.modelData)
                        }
                    }
                    onEntered: {
                        view_top.currentIndex = listdeleg.modelData
                    }
                }
            }

        }

        Drag.active: listmousearea.drag.active || listthumbmousearea.drag.active
        Drag.mimeData: {
            if(!view_top.currentFileSelected) {
                return ({"text/uri-list": encodeURI("file:"+listdeleg.currentPath)})
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
