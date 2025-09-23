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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Flickable {

    id: masonryview

    width: parent.width
    height: parent.height

    contentHeight: mainrow.height

    SystemPalette { id: pqtPalette }

    property int model: 0
    onModelChanged: {
        if(model == 0) {
            for(var i = 0; i < masonryview.numColumns; ++i) {
                listviews[i].clear()
            }
            return
        }
        masonryview.setupData()
        // same folder reloaded
        if(PQCFileFolderModel.folderFileDialog === cachePath) {

            // restore position
            masonryview.contentY = cacheContentY

        // new folder loaded
        } else {

            // reset position
            masonryview.contentY = 0
            cachePath = PQCFileFolderModel.folderFileDialog
            cacheContentY = 0

        }
    }

    visible: isCurrentView
    property bool isCurrentView: PQCSettings.filedialogLayout==="masonry"

    property int currentIndex: -1
    onCurrentIndexChanged: {
        if(!isCurrentView)
            return
        if(view_top.currentIndex !== currentIndex)
            view_top.currentIndex = currentIndex
        if(!masonryview.flicking)
            ensureCurrentItemIsVisible()
    }

    ScrollBar.vertical: PQFileDialogScrollBar { id: view_scroll }

    onContentYChanged: {
        // this check makes sure that value is not reset when a directory is reloaded due to a change
        if(contentY > 0)
            cacheContentY = contentY
    }

    PQScrollManager {
        flickable: masonryview
        cursorShape: Qt.PointingHandCursor
    }

    // this pair stores the current scroll position
    // this way we can preserve that position when the content of the current directory changes
    property string cachePath: ""
    property real cacheContentY: 0.

    property bool firstStart: true

    property int _startWidth: 50 + PQCSettings.filedialogZoom*3
    property int numColumns: Math.floor(width/_startWidth)
    onNumColumnsChanged: {
        if(firstStart) {
            firstStart = false
            return
        }
        callSetup.restart()
    }


    Timer {
        id: callSetup
        interval: 50
        onTriggered: {
            if(fd_splitview.resizing) {
                callSetup.restart()
                return
            }
            masonryview.setupData()
        }
    }

    property real columnWidth: width/numColumns

    property var listviews: ({})

    Row {

        id: mainrow

        Repeater {

            id: columnRepeater

            model: masonryview.numColumns

            Column {

                id: columndeleg
                required property int index

                width: lv.width

                ListView {

                    id: lv

                    width: columnWidth
                    height: childrenRect.height
                    interactive: false

                    model: ListModel { id: mdl }

                    Component.onCompleted: {
                        masonryview.listviews[columndeleg.index] = mdl
                    }

                    delegate: viewentry

                }


            }

        }

    }

    Component {
        id: viewentry

        Rectangle {

            id: deleg

            required property string currentPath
            required property int modelData
            required property int offsetY
            required property real itemHeight

            property string currentFile: decodeURIComponent(PQCScriptsFilesPaths.getFilename(currentPath))
            property int numberFilesInsideFolder: 0
            property string fileinfoString: ""
            property int padding: PQCSettings.filedialogElementPadding
            property bool isFolder: modelData < PQCFileFolderModel.countFoldersFileDialog
            property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(currentPath) : view_top.currentFolderOnNetwork

            property bool isHovered: masonryview.currentIndex===deleg.modelData
            property bool isSelected: PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)>-1

            width: masonryview.columnWidth
            height: filethumbVisible&&filethumbStatus==Image.Ready ? Math.max(30, (filethumbSourceSize.height * (width/filethumbSourceSize.width))) : masonryview.columnWidth

            property bool filethumbVisible: false
            property int filethumbStatus: Image.Null
            property size filethumbSourceSize: Qt.size(0,0)

            property int folderthumbCurNum: 0

            clip: true
            color: pqtPalette.base
            border.width: PQCSettings.filedialogElementPadding
            border.color: PQCLook.baseBorder

            Item {
                id: dragHandler

                x: PQCSettings.filedialogElementPadding
                y: PQCSettings.filedialogElementPadding
                width: deleg.width - 2*PQCSettings.filedialogElementPadding
                height: deleg.width - 2*PQCSettings.filedialogElementPadding

            }

            // the file type icon
            PQFileIcon {

                id: fileicon

                gridlike: true

                x: PQCSettings.filedialogElementPadding
                y: PQCSettings.filedialogElementPadding
                width: deleg.width - 2*PQCSettings.filedialogElementPadding
                height: deleg.width - 2*PQCSettings.filedialogElementPadding

            }

            // the file thumbnail
            Loader {
                id: filethumbldr
                asynchronous: true

                // load from the top until just beyond what's currently visible
                // anything below that doesn't need to be loaded until necessary
                active: masonryview.contentY+deleg.height > deleg.offsetY-masonryview.height || deleg.filethumbStatus===Image.Ready
                sourceComponent:
                PQFileThumb {

                    id: filethumb

                    x: PQCSettings.filedialogElementPadding
                    y: PQCSettings.filedialogElementPadding
                    width: deleg.width - 2*PQCSettings.filedialogElementPadding
                    height: deleg.height - 2*PQCSettings.filedialogElementPadding

                    clip: true

                    dontSetSourceSize: true

                    onVisibleChanged:
                        deleg.filethumbVisible = visible
                    onStatusChanged:
                        deleg.filethumbStatus = status
                    onSourceSizeChanged:
                        deleg.filethumbSourceSize = sourceSize

                    Component.onCompleted: {
                        deleg.filethumbVisible = visible
                        deleg.filethumbStatus = status
                        deleg.filethumbSourceSize = sourceSize
                    }

                }
            }

            Loader {

                id: folderloader

                active: deleg.isFolder

                sourceComponent:
                Item {

                    x: PQCSettings.filedialogElementPadding
                    y: PQCSettings.filedialogElementPadding
                    width: deleg.width - 2*PQCSettings.filedialogElementPadding
                    height: deleg.width - 2*PQCSettings.filedialogElementPadding

                    // the folder thumbnails
                    PQFolderThumb {

                        id: folderthumb

                        anchors.fill: parent

                        onCurnumChanged:
                            deleg.folderthumbCurNum = curnum

                    }

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
                            color: pqtPalette.text
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
                            color: pqtPalette.text
                            elide: Text.ElideMiddle
                            text: "#"+folderthumb.curnum
                        }
                    }

                    // load async for folders
                    Timer {
                        running: true
                        interval: 1
                        onTriggered: {
                            PQCScriptsFileDialog.getNumberOfFilesInFolder(deleg.currentPath, function(count) {
                                if(count > 0) {
                                    deleg.numberFilesInsideFolder = count
                                    deleg.fileinfoString = (count===1 ? qsTranslate("filedialog", "%1 image").arg(count) : qsTranslate("filedialog", "%1 images").arg(count))
                                    if(count === 1)
                                        deleg.fileinfoString = qsTranslate("filedialog", "%1 image").arg(count)
                                    else
                                        deleg.fileinfoString = qsTranslate("filedialog", "%1 images").arg(count)
                                }
                            })
                        }
                    }
                }

            }

            // load async for files
            Timer {
                running: !deleg.isFolder
                interval: 1
                onTriggered: {
                    deleg.fileinfoString = PQCScriptsFilesPaths.getFileSizeHumanReadable(deleg.currentPath)
                }
            }

            /************************************************************/
            // FILE NAME

            // the filename
            Loader {

                active: PQCSettings.filedialogLabelsShowMasonry||deleg.isFolder

                sourceComponent:
                Rectangle {
                    id: filename_label
                    width: deleg.width
                    height: deleg.height>100 ?
                                (Math.min(50, deleg.height/4) + (deleg.isSelected||deleg.isHovered ? 10 : 0)) :
                                (deleg.isSelected||deleg.isHovered ? Math.min(50, deleg.height) : 0)
                    Behavior on height { NumberAnimation { duration: 200 } }
                    y: deleg.height-height
                    color: deleg.isSelected ? pqtPalette.text : (deleg.isHovered ? pqtPalette.alternateBase : pqtPalette.base )
                    Behavior on color { ColorAnimation { duration: 200 } }
                    opacity: 0.8
                    clip: true

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
                        color: pqtPalette.text
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
                        visible: deleg.isFolder && deleg.folderthumbCurNum>0
                    }

                }

            }

            /************************************************************/
            // HIGHLIGHT/SELECT

            PQHighlightMarker {
                anchors.margins: 0
                opacity: !deleg.isSelected ? 0.5 : 1
                visible: deleg.isHovered || deleg.isSelected
            }

            /************************************************************/

            // mouse area handling general mouse events
            PQMouseArea {

                id: masonrymousearea

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Connections {
                    target: PQCConstants
                    function onWhichContextMenusOpenChanged() {
                        if(PQCConstants.isContextmenuOpen("fileviewentry"))
                            masonrymousearea.closeTooltip()
                    }
                }

                acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.BackButton|Qt.ForwardButton

                drag.target: PQCSettings.filedialogDragDropFileviewMasonry ? dragHandler : undefined

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

                    tooltip = ""
                    tooltip = handleEntriesMouseEnter(deleg.modelData, deleg.currentPath, deleg.filethumbStatus, deleg.fileinfoString,
                                            deleg.isFolder, deleg.numberFilesInsideFolder, deleg.folderthumbCurNum)

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
                y: deleg.height>40 ? 5 : 0
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
                    PQMouseArea {
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

            Drag.active: masonrymousearea.drag.active
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
    }

    PropertyAnimation {
        id: contentYAni
        duration: 100
        target: masonryview
        easing.type: Easing.InOutQuad
        property: "contentY"
    }

    property list<real> columnHeights: ({})
    property var columnIndices: ({})

    function setupData() {

        for(var i = 0; i < masonryview.numColumns; ++i) {
            listviews[i].clear()
            columnHeights[i] = 0
            columnIndices[i] = []
        }

        for(var j = 0; j < PQCFileFolderModel.countAllFileDialog; ++j) {

            var pth = PQCFileFolderModel.entriesFileDialog[j]

            var minCol = 0
            for(var k = 1; k < masonryview.numColumns; ++k)
                if(columnHeights[k] < columnHeights[minCol])
                    minCol = k

            columnIndices[minCol].push(j)

            if(j < PQCFileFolderModel.countFoldersFileDialog) {
                listviews[minCol].append({"currentPath" : pth, "modelData" : j, "offsetY" : columnHeights[minCol], "itemHeight" : columnWidth})
                columnHeights[minCol] += columnWidth
            } else {
                var sze = PQCScriptsImages.getCurrentImageResolution(pth)
                var h = (sze.height * (columnWidth/sze.width))
                listviews[minCol].append({"currentPath" : pth, "modelData" : j, "offsetY" : columnHeights[minCol], "itemHeight" : h})
                columnHeights[minCol] += h
            }

        }

    }

    function findCurrentRowColumn() {
        var curCol = -1
        var curRow = -1
        for(var i = 0; i < masonryview.numColumns; ++i) {
            curRow = columnIndices[i].indexOf(view_top.currentIndex)
            if(curRow > -1) {
                curCol = i
                break
            }
        }
        return [curCol, curRow]
    }

    function goDownARow() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = 0
        else {
            var curColRow = findCurrentRowColumn()
            view_top.currentIndex = columnIndices[curColRow[0]][Math.min(columnIndices[curColRow[0]].length-1, curColRow[1]+1)]
        }

    }

    function goDownSomeRows() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = columnIndices[0][Math.min(4, columnIndices[0].length)]
        else {
            var curColRow = findCurrentRowColumn()
            view_top.currentIndex = columnIndices[curColRow[0]][Math.min(curColRow[1]+5, columnIndices[curColRow[0]].length)]
        }

    }

    function goUpARow() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = columnIndices[0][columnIndices[0].length-1]
        else {
            var curColRow = findCurrentRowColumn()
            view_top.currentIndex = columnIndices[curColRow[0]][Math.max(0, curColRow[1]-1)]
        }

    }

    function goUpSomeRows() {

        if(view_top.currentIndex === -1)
            view_top.currentIndex = columnIndices[0][Math.max(0, columnIndices[0].length-5)]
        else {
            var curColRow = findCurrentRowColumn()
            view_top.currentIndex = columnIndices[curColRow[0]][Math.max(0, curColRow[1]-5)]
        }

    }

    function ensureCurrentItemIsVisible() {

        var curColRow = findCurrentRowColumn()
        if(curColRow[0] === -1)
            return

        var itm = listviews[curColRow[0]].get(curColRow[1])
        if(itm.offsetY < masonryview.contentY) {
            contentYAni.stop()
            contentYAni.from = masonryview.contentY
            contentYAni.to = itm.offsetY
            contentYAni.start()
        } else if(itm.offsetY+itm.itemHeight > masonryview.contentY+masonryview.height) {
            contentYAni.stop()
            contentYAni.from = masonryview.contentY
            contentYAni.to = itm.offsetY-masonryview.height+itm.itemHeight
            contentYAni.start()
        }

    }

}
