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

    property string cachePath: ""

    property int model: 0
    onModelChanged: {

        if(model == 0) {
            for(var i = 0; i < masonryview.numColumns; ++i) {
                listviews[i].clear()
            }
            return
        }

        masonryview.setupData()

        // reset position
        masonryview.contentY = 0
        cachePath = cacheKey
        cacheContentY = 0

    }

    property int currentIndex: -1
    onCurrentIndexChanged: {
        // TODO
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

    property int numColumns: 0
    property int columnWidth: 0
    property var listviews: ({})

    property int listviewMaxHeight: 0

    Row {

        id: mainrow

        Repeater {

            id: columnRepeater

            model: masonryview.numColumns

            ListView {

                id: lv

                required property int modelData

                width: masonryview.columnWidth
                height: masonryview.height
                interactive: false

                model: ListModel { id: mdl }

                Component.onCompleted: {
                    masonryview.listviews[modelData] = mdl
                }

                delegate: viewentry

            }

        }

    }

    Component {
        id: viewentry

        Rectangle {

            id: deleg

            required property int modelData
            required property string path
            required property bool isFolder
            required property int itemHeight
            required property string fileSize
            required property int numberFilesInsideFolder

            property bool isFileCut: PQGlobalItems.filedialogFileview.currentCuts.indexOf(modelData) > -1
            property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(path) : PQGlobalItems.filedialogFileview.currentFolderOnNetwork

            width: masonryview.columnWidth
            height: itemHeight
            color: palette.base

            border.width: PQCSettings.filedialogElementPadding
            border.color: PQCLook.baseBorder

            // the file type icon
            PQFileIcon {

                id: fileicon

                gridlike: true

                isFileCut: deleg.isFileCut
                onNetwork: deleg.onNetwork
                isFolder: deleg.isFolder
                currentPath: deleg.path

                x: PQCSettings.filedialogElementPadding
                y: PQCSettings.filedialogElementPadding
                width: deleg.width - 2*PQCSettings.filedialogElementPadding
                height: deleg.height - 2*PQCSettings.filedialogElementPadding

            }

            PQFileThumb {

                id: filethumb

                x: PQCSettings.filedialogElementPadding
                y: PQCSettings.filedialogElementPadding
                width: deleg.width - 2*PQCSettings.filedialogElementPadding
                height: deleg.height - 2*PQCSettings.filedialogElementPadding

                isFileCut: deleg.isFileCut
                isFolder: deleg.isFolder
                onNetwork: deleg.onNetwork
                currentPath: deleg.path
                myIndex: deleg.modelData

                clip: true

                onHideFileIcon: {
                    fileicon.source = ""
                }

                onShowFileIcon: {
                    fileicon.source = fileicon.sourceString
                }

            }

        }
    }

    Connections {

        target: PQCFileFolderModel

        function onNewMasonryData(col : int, dat : var) {
            console.warn(">>>>>", col, dat["path"])
            masonryview.listviews[col].append(dat)
        }

        function onMasonryDataReady(dat : var) {

            PQCNotify.filedialogBusyLoading(false)

            // for(let i = 0; i < masonryview.numColumns; ++i) {
            //     for(let j in dat[i])
            //         masonryview.listviews[i].append(dat[i][j])
            // }

        }

    }

    Timer {
        id: callSetup
        interval: 50
        onTriggered:
            setupData()
    }

    function setupData() {

        if(width < 5) {
            callSetup.restart()
            return
        }

        console.warn("***************** setup()")

        for(let i = 0; i < masonryview.numColumns; ++i)
            masonryview.listviews[i].clear()

        var _w = (PQCSettings.filedialogThumbnailSizeFollowsGlobalThumbnails ? 10+PQCSettings.thumbnailsSize : 10+PQCSettings.filedialogZoom*10)
        var nc = Math.floor(width/_w)
        var cw = width/nc

        numColumns = nc
        columnWidth = cw

        PQCNotify.filedialogBusyLoading(true)

        PQCFileFolderModel.generateDataForMasonryView(PQCFileFolderModel.folderFileDialog, nc, cw)

    }

    function goDownARow() {

        // TODO

    }

    function goDownSomeRows() {

        // TODO

    }

    function goUpARow() {

        // TODO

    }

    function goUpSomeRows() {

        // TODO

    }

    function ensureCurrentItemIsVisible() {

        // TODO

    }

}
