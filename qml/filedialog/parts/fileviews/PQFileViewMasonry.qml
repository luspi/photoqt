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

Flickable {

    id: masonryview

    width: parent.width
    height: parent.height

    contentHeight: mainrow.height

    signal handleEntriesMouseEnter(var index, var currentPath, var fileThumbStatus, var fileInfo, var isFolder,
                                   var numberFilesInsideFolder, var currentFolderThumbNum)
    signal handleEntriesMouseExit(var index)
    signal handleEntriesMouseClick(var index, var currentPath, var isFolder, var mouseModifiers, var mouseButton)

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

    property int currentIndex: -1
    onCurrentIndexChanged: {
        if(PQGlobalItems.filedialogFileview.currentIndex !== currentIndex)
            PQGlobalItems.filedialogFileview.currentIndex = currentIndex
        if(!masonryview.flicking)
            ensureCurrentItemIsVisible()
    }

    ScrollBar.vertical: PQVerticalScrollBar { id: view_scroll }

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

    property int _startWidth: 50 + (PQCSettings.filedialogThumbnailSizeFollowsGlobalThumbnails ? PQCSettings.thumbnailsSize : PQCSettings.filedialogZoom)*5
    property int numColumns: Math.floor(width/_startWidth)
    onNumColumnsChanged: {
        if(firstStart && listviews.count < numColumns) {
            firstStart = false
            return
        }
        callSetup.restart()
    }


    Timer {
        id: callSetup
        interval: 50
        onTriggered: {
            if(PQCConstants.filedialogSplitviewResizing) {
                callSetup.restart()
                return
            }
            masonryview.setupData()
        }
    }

    property real columnWidth: width/numColumns

    property var listviews: ({})
    property bool listviewsReady: false

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

                    width: masonryview.columnWidth
                    height: childrenRect.height
                    interactive: false

                    model: ListModel { id: mdl }

                    Component.onCompleted: {
                        masonryview.listviews[columndeleg.index] = mdl
                        masonryview.listviewsReady = true
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
            property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(currentPath) : PQGlobalItems.filedialogFileview.currentFolderOnNetwork

            property bool isHovered: masonryview.currentIndex===deleg.modelData
            property bool isSelected: PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)>-1

            property bool isFileCut: PQGlobalItems.filedialogFileview.currentCuts.indexOf(deleg.modelData) > -1

            width: masonryview.columnWidth
            height: filethumbVisible&&filethumbStatus==Image.Ready ? Math.max(30, (filethumbSourceSize.height * (width/filethumbSourceSize.width))) : masonryview.columnWidth

            property bool filethumbVisible: false
            property int filethumbStatus: Image.Null
            property size filethumbSourceSize: Qt.size(0,0)

            property int folderthumbCurNum: 0

            clip: true
            color: palette.base
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

                isFileCut: deleg.isFileCut
                onNetwork: deleg.onNetwork
                isFolder: deleg.isFolder
                currentPath: deleg.currentPath

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

                    isFileCut: deleg.isFileCut
                    isFolder: deleg.isFolder
                    onNetwork: deleg.onNetwork
                    currentPath: deleg.currentPath
                    myIndex: deleg.modelData

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

                    function onHideFileIcon() {
                        fileicon.source = ""
                    }

                    function onShowFileIcon() {
                        fileicon.source = fileicon.sourceString
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

                        isFileCut: deleg.isFileCut
                        myIndex: deleg.modelData

                        anchors.fill: parent

                        onCurnumChanged:
                            deleg.folderthumbCurNum = curnum

                        function onHideFileIcon() {
                            fileicon.source = ""
                        }

                    }

                    // how many files inside folder
                    Rectangle {
                        id: numberOfFilesInsideFolder_cont
                        x: (deleg.width-width)-5
                        y: 5
                        width: numberOfFilesInsideFolder.width + 20
                        height: 30
                        radius: 5
                        color: palette.text
                        opacity: 0.8
                        visible: numberOfFilesInsideFolder.text !== "" && numberOfFilesInsideFolder.text !== "0"

                        PQText {
                            id: numberOfFilesInsideFolder
                            x: 10
                            y: (parent.height-height)/2-2
                            font.weight: PQCLook.fontWeightBold
                            color: palette.base
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
                        color: palette.text
                        opacity: 0.6
                        visible: folderthumb.curnum>0 && folderthumb.visible

                        PQTextS {
                            id: numberThumbInsideFolder
                            x: 5
                            y: (parent.height-height)/2-2
                            font.weight: PQCLook.fontWeightBold
                            color: palette.base
                            elide: Text.ElideMiddle
                            text: "#"+folderthumb.curnum
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
                    Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    y: deleg.height-height
                    color: deleg.isSelected ? palette.text : (deleg.isHovered ? palette.alternateBase : palette.base )
                    Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                    opacity: 0.8
                    clip: true

                    PQText {
                        id: filename
                        anchors.fill: parent
                        anchors.margins: 5
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        maximumLineCount: 2
                        elide: Text.ElideMiddle
                        text: deleg.currentFile
                        color: palette.text
                        Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                    }

                    Image {
                        x: (parent.width-width-5)
                        y: (parent.height-height-5)
                        source: "image://svg/:/light/folder.svg"
                        height: 16
                        mipmap: true
                        width: height
                        opacity: 0.3
                        visible: deleg.isFolder && deleg.folderthumbCurNum!==0
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

                    tooltip = ""
                    tooltip = PQGlobalItems.filedialogFileview.handleEntriesMouseEnter(deleg.modelData, deleg.currentPath, deleg.filethumbStatus, deleg.fileinfoString,
                                            deleg.isFolder, deleg.numberFilesInsideFolder, deleg.folderthumbCurNum)

                }

                onExited: {
                    if(!selectmouse.containsMouse)
                        PQGlobalItems.filedialogFileview.handleEntriesMouseExit(deleg.modelData)
                }

                onClicked: (mouse) => {

                    PQGlobalItems.filedialogFileview.handleEntriesMouseClick(deleg.modelData, deleg.currentPath, deleg.isFolder,
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
                                : (PQGlobalItems.filedialogFileview.currentIndex===deleg.modelData
                                        ? 0.8 : 0)
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    source: (PQCConstants.filedialogCurrentSelection.indexOf(deleg.modelData)!==-1 ? ("image://svg/:/" + PQCLook.iconShade + "/deselectfile.svg") : ("image://svg/:/" + PQCLook.iconShade + "/selectfile.svg"))
                    mipmap: true
                    opacity: selectmouse.containsMouse ? 0.8 : 0.4
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    PQMouseArea {
                        id: selectmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(!PQGlobalItems.filedialogFileview.currentFileSelected) {
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

            Drag.active: masonrymousearea.drag.active
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
                        deleg.fileinfoString = (num===1 ? qsTranslate("filedialog", "%1 image").arg(num) : qsTranslate("filedialog", "%1 images").arg(num))
                    }
                }
            }

        }
    }

    PropertyAnimation {
        id: contentYAni
        duration: 100
        target: masonryview
        easing.type: Easing.InOutQuad
        property: "contentY"
    }

    property list<real> columnHeights: []
    property var columnIndices: ({})

    Timer {
        id: waitForListviewsReady
        interval: 50
        onTriggered: {
            masonryview.setupData()
        }
    }

    function setupData() {

        if(!listviewsReady) {
            waitForListviewsReady.restart()
        }

        for(var i = 0; i < masonryview.numColumns; ++i) {
            if(listviews[i] === undefined) continue;
            listviews[i].clear()
            columnHeights[i] = 0
            columnIndices[i] = []
        }

        // first do all folders
        for(let j = 0; j < PQCFileFolderModel.countFoldersFileDialog; ++j) {

            const pth = PQCFileFolderModel.entriesFileDialog[j]

            // find shortest column
            const minCol = columnHeights.reduce((minIdx, value, idx, arr) => value < arr[minIdx] ? idx : minIdx, 0)
            columnIndices[minCol].push(j)

            listviews[minCol].append({"currentPath" : pth, "modelData" : j, "offsetY" : columnHeights[minCol], "itemHeight" : columnWidth})

            columnHeights[minCol] += columnWidth

        }

        // then do all the files
        for(let k = PQCFileFolderModel.countFoldersFileDialog; k < PQCFileFolderModel.countAllFileDialog; ++k) {

            const pth = PQCFileFolderModel.entriesFileDialog[k]

            // find shortest column
            const minCol = columnHeights.reduce((minIdx, value, idx, arr) => value < arr[minIdx] ? idx : minIdx, 0)
            columnIndices[minCol].push(k)

            var sze = PQCImageHandler.getSize(pth)
            var h = (sze.height * (columnWidth/sze.width))
            listviews[minCol].append({"currentPath" : pth, "modelData" : k, "offsetY" : columnHeights[minCol], "itemHeight" : h})

            columnHeights[minCol] += h

        }

    }

    function findCurrentRowColumn() {
        var curCol = -1
        var curRow = -1
        for(var i = 0; i < masonryview.numColumns; ++i) {
            curRow = columnIndices[i].indexOf(PQGlobalItems.filedialogFileview.currentIndex)
            if(curRow > -1) {
                curCol = i
                break
            }
        }
        return [curCol, curRow]
    }

    function goDownARow() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = 0
        else {
            var curColRow = findCurrentRowColumn()
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[curColRow[0]][Math.min(columnIndices[curColRow[0]].length-1, curColRow[1]+1)]
        }

    }

    function goDownSomeRows() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[0][Math.min(4, columnIndices[0].length)]
        else {
            var curColRow = findCurrentRowColumn()
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[curColRow[0]][Math.min(curColRow[1]+5, columnIndices[curColRow[0]].length)]
        }

    }

    function goUpARow() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[0][columnIndices[0].length-1]
        else {
            var curColRow = findCurrentRowColumn()
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[curColRow[0]][Math.max(0, curColRow[1]-1)]
        }

    }

    function goUpSomeRows() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[0][Math.max(0, columnIndices[0].length-5)]
        else {
            var curColRow = findCurrentRowColumn()
            PQGlobalItems.filedialogFileview.currentIndex = columnIndices[curColRow[0]][Math.max(0, curColRow[1]-5)]
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
